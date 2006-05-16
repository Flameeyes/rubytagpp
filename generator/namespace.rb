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

module CxxBindingsGenerator

class Namespace
   attr_reader :name

   def initialize(name, content)
      @name = name
      @classes = Array.new

      content["classes"].each { |klass|
         @classes << Class.new(self, klass["name"], klass)
      }
   end

   def varname
      "m#{@name.gsub("::", "_")}"
   end

   def header
      ret = "extern VALUE #{varname};\n"

      @classes.each { |cls|
         ret << cls.header
      }

      ret << "\n"
   end

   def unit
      ret = "VALUE #{varname};\n"

      @classes.each { |cls|
         ret << cls.unit
      }

      ret << "\n"
   end

   def init
      unless @name.include?("::")
         ret = "#{varname} = rb_define_module(\"#{@name}\");\n"
      else
         ret = "#{varname} = rb_define_module_under(m#{@name.split("::").slice(0..-2).join("_")}, \"#{@name.split("::").last}\");\n"
      end

      @classes.each { |cls|
         ret << cls.init
      }

      ret
   end
end

end

# kate: encoding UTF-8; remove-trailing-space on; replace-trailing-space-save on; space-indent on; indent-width 3;
