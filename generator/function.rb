# Flameeyes's C++<->Ruby bindings generator
# Copyright (C) 2006, Diego "Flameeyes" Pettenò
#
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 2 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this generator; if not, write to the Free Software
# Foundation, Inc., 51 Franklin St, Fifth Floor, Boston, MA  02110-1301  USA

module CxxBindingsGenerator

class Function

   def initialize(name, content, retval = "void", bindname = nil)
      @params = Array.new

      @name = name

      @bindname = bindname ? bindname : name

      @return = retval

      @vararg = false

      return unless content
      # From now on it's just the handling of content, that might be empty

      @aliases = content["aliases"]

      @template = content["template"] ? $templates[content["template"]] : nil

      @custom = content["custom"] == "yes"
      @custom_prototype = content["custom_prototype"]
      @custom_name = content["custom_name"]
      @custom_paramcount = content["custom_paramcount"]

      if content["params"]
         content["params"].each { |p|
            @params << Parameter.new(p["type"], p["name"], p["optional"] == "yes", p["default"])
            @vararg ||= ( (p["optional"] == "yes") or (p["default"] != nil) )
         }
      end
   end

   def varname
      "f#{@name}"
   end

   def params_conversion(nparms = nil, params = nil)
      return if @params.empty?
      vararg = nparms != nil
      nparms = @params.size unless nparms

      ret = ""
      @params.slice(0, nparms).each_index { |p|
         ret << @params[p].conversion( vararg ? p : nil )
      }
      ret << "#{params[0]}," if params

      ret.chomp!(",")
   end

   def binding_prototype
     return @template[:prototype].gsub('#{varname}', varname) if @template
     return @custom_prototype if @custom
     if @vararg
       prototype = "VALUE #{varname} ( int argc, VALUE *argv, VALUE self )"
     else
       prototype = "VALUE #{varname} ( VALUE self"
       
       @params.each { |p| prototype << ", VALUE #{p.name}" }
       
       prototype << " )"
     end
   end

   def raw_call(param = nil, params = nil)
      "#{@name}(#{params_conversion(param)})"
   end

   def bind_call(param = nil, params = nil)
      if @return == "void"
         "#{raw_call(param)}; return Qnil;\n"
      else
        "return cxx2ruby((#{@return})#{raw_call(param)});\n"
      end
   end

end

class Parameter
   attr_reader :type, :name, :optional, :default

   def initialize(type, name, optional, default)
      @type = type
      @name = name
      @optional = optional
      @default = default
   end

   def conversion(index = nil)
      "ruby2#{@type.sub("*", "Ptr").gsub("::", "_")}(#{index ? "argv[#{index}]" : @name}),"
   end
end

end

# kate: encoding UTF-8; remove-trailing-space on; replace-trailing-space-save on; space-indent on; indent-width 3;
