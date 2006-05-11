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
# along with this program; if not, write to the Free Software
# Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
#
# kate: encoding UTF-8; remove-trailing-space on; replace-trailing-space-save on; space-indent on; indent-width 3;

class ClassMethod
   attr_reader :return, :params
   attr_writer :return, :params

   def initialize(cls, name, content, bindname = nil)
      @params = Array.new

      @cls = cls
      @name = name

      if bindname
         @bindname = bindname
      else
         @bindname = name
      end

      if @name == @cls.name
         @bindname = "initialize"
      end

      if content
         @return = content["return"]
      else
         @return = "void"
      end

      @vararg = false

      @aliases = content["aliases"] if content

      if content and content["params"]
         content["params"].each { |p|
            @params << Parameter.new(p["type"], p["name"], p["optional"] == "yes")
            @vararg ||= p["optional"] == "yes"
         }
      end
   end

   def varname
      "f#{@cls.ns.name.gsub("::", "_")}_#{@cls.name}_#{@name}"
   end

   def binding_prototype
      unless @vararg
         prototype = "VALUE #{varname} ( VALUE self"

         @params.each { |p|
            prototype << ", VALUE #{p.name}"
         }

         prototype << " )"
      else
         prototype = "VALUE #{varname} ( int argc, VALUE *argv, VALUE self )"
      end
   end

   def params_conversion(nparms = nil)
      ret = ""
      unless nparms
         @params.each { |p|
            ret << " ruby2#{p.type.sub("*", "Ptr").gsub("::", "_")}(#{p.name}),"
         } if @params
      else
         @params.slice(0, nparms).each_index { |p|
            ret << " ruby2#{@params[p].type.sub("*", "Ptr").gsub("::", "_")}(argv[#{p}]),"
         } if @params
      end

      ret.chomp!(",")
   end

   def binding_stub
      if @bindname == "initialize"
         return constructor_stub
      end

      ret = %@
#{binding_prototype} {
   #{@cls.ns.name}::#{@cls.name}* tmp = ruby2#{@cls.varname}(self);
   // fprintf(stderr, "Called #{@cls.ns.name}::#{@cls.name}::#{@name} for value %x (%p).\\n", self, tmp);
   if ( ! tmp ) return Qnil; // The exception is thrown by ruby2*

  @

      unless @vararg
         if @return and @return != "void"
            ret << "return cxx2ruby(tmp->#{@name}(#{params_conversion}));\n"
         else
            ret << "tmp->#{@name}(#{params_conversion}); return Qnil;\n"
         end
      else
         ret << %@
            switch(argc)
            {
            @

         @params.each_index { |n|
            if @params[n].optional
               if @return and @return != "void"
                  ret << "case #{n}: return cxx2ruby(tmp->#{@name}(#{params_conversion(n)}));\n"
               else
                  ret << "case #{n}: tmp->#{@name}(#{params_conversion(n)}); return Qnil;\n"
               end
            end
         }

         ret << %@
               default: rb_raise(rb_eArgError, "Mantatory parameters missing"); return Qnil;
            } // switch
            @
      end

      ret << "}\n"
   end

   def constructor_stub
      ret = %@
#{binding_prototype} {
   #{@cls.ns.name}::#{@cls.name}* tmp;
   Data_Get_Struct(self, #{@cls.ns.name}::#{@cls.name}, tmp);
@
      unless @vararg
         ret << "tmp = new #{@cls.ns.name}::#{@cls.name}(#{params_conversion});"
      else
         ret << %@
            switch(argc)
            {
@

         @params.each_index { |n|
            if @params[n].optional
               ret << "case #{n}: tmp = new #{@cls.ns.name}::#{@cls.name}(#{params_conversion(n)}); break;\n"
            end
         }

         ret << %@
               case #{@params.size}: tmp = new #{@cls.ns.name}::#{@cls.name}(#{params_conversion(@params.size)}); break;
               default: rb_raise(rb_eArgError, "Mandatory parameters missing (passed %d)\\n", argc); return Qnil;
            } // switch
            @
      end

      ret << %@

   DATA_PTR(self) = tmp;
   #{@cls.ptrmap}[self] = tmp;
   return self;
}
@
   end

   def init
      res = "rb_define_method(c#{@cls.varname}, \"#{@bindname}\", RUBY_METHOD_FUNC(#{varname}), #{@vararg ? "-1" : @params.length});\n"
      if @aliases
         @aliases.each { |meth_alias|
            res << "rb_define_method(c#{@cls.varname}, \"#{meth_alias}\", RUBY_METHOD_FUNC(#{varname}), #{@vararg ? "-1" : @params.length});\n"
         }
      end

      res
   end
end

class Parameter
   attr_reader :type, :name, :optional

   def initialize(type, name, optional)
      @type = type
      @name = name
      @optional = optional
   end
end
