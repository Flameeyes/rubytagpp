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

require "function.rb"

module CxxBindingsGenerator

class ClassMethod < Function
   attr_reader :return, :params
   attr_writer :return, :params

   def initialize(cls, name, content)
      retval = content["return"] ? content["return"] : "void"
      bindname = content["bindname"] ? content["bindname"] : name
      bindname = "initialize" if bindname == cls.name

      @cls = cls
      super(name, content, retval, bindname)
   end

   def varname
     if @custom
       @custom_name
     else
       "f#{@cls.ns.name.gsub("::", "_")}_#{@cls.name}_#{@name}"
     end
   end

   def raw_call(param = nil)
      "tmp->#{super(param)}"
   end

   def binding_stub
      return "" if @custom
      return @template[:function].gsub('#{name}', @name).gsub('#{varname}', varname) if @template

      if @bindname == "initialize"
         return constructor_stub
      end

      ret = %@
         #{binding_prototype} {
            #{@cls.ns.cxxname}::#{@cls.name}* tmp = ruby2#{@cls.varname}Ptr(self);
            // fprintf(stderr, "Called #{@cls.ns.cxxname}::#{@cls.name}::#{@name} for value %x (%p).\\n", self, tmp);
            if ( ! tmp ) return Qnil; // The exception is thrown by ruby2*

         @

      if @vararg
         ret << %@
            switch(argc)
            {
            @

         for n in 0..(@params.size-1)
           ret << "case #{n}: #{bind_call(n)}" if @params[n].optional
           ret << "case #{n}: #{bind_call(n, [@params[n].default])}" if @params[n].default
         end

         ret << "case #{@params.size}: #{bind_call(@params.size)};"

         ret << %@
               default: rb_raise(rb_eArgError, "Mantatory parameters missing"); return Qnil;
            } // switch
            @
      else
         ret << bind_call
      end

      ret << "}\n"
   end

   def constructor_stub
      ret = %@
#{binding_prototype} {
   #{@cls.ns.cxxname}::#{@cls.name}* tmp;
   Data_Get_Struct(self, #{@cls.ns.cxxname}::#{@cls.name}, tmp);
@
      unless @vararg
         ret << "tmp = new #{@cls.ns.cxxname}::#{@cls.name}(#{params_conversion});"
      else
         ret << %@
            switch(argc)
            {
@

         for n in 0..(@params.size-1)
           ret << "case #{n}: tmp = new #{@cls.ns.cxxname}::#{@cls.name}(#{params_conversion(n)}); break;\n" if @params[n].optional
           ret << "case #{n}: tmp = new #{@cls.ns.cxxname}::#{@cls.name}(#{params_conversion(n, [@params[n].default])}); break;\n" if @params[n].default
         end

         ret << %@
               case #{@params.size}: tmp = new #{@cls.ns.cxxname}::#{@cls.name}(#{params_conversion(@params.size)}); break;
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
     if @custom
       res = "rb_define_method(c#{@cls.varname}, \"#{@bindname}\", RUBY_METHOD_FUNC(#{varname}), #{@custom_paramcount});\n"
     elsif @template
       res = "rb_define_method(c#{@cls.varname}, \"#{@bindname}\", RUBY_METHOD_FUNC(#{varname}), #{@template[:paramcount]});\n"
     else
       res = "rb_define_method(c#{@cls.varname}, \"#{@bindname}\", RUBY_METHOD_FUNC(#{varname}), #{@vararg ? "-1" : @params.length});\n"
     end
      if @aliases
         @aliases.each { |meth_alias|
            res << "rb_define_alias(c#{@cls.varname}, \"#{meth_alias}\", \"#{@bindname}\");\n"
            nocamel_alias = meth_alias.gsub(/([^A-Z])([A-Z])([^A-Z])/) { |letter| "#{$1}_#{$2.downcase}#{$3}" }
            res << "rb_define_alias(c#{@cls.varname}, \"#{nocamel_alias}\", \"#{@bindname}\");\n" \
               unless nocamel_alias == meth_alias
         }
      end

      nocamel_bindname = @bindname.gsub(/([^A-Z])([A-Z])([^A-Z])/) { |letter| "#{$1}_#{$2.downcase}#{$3}" }
      res << "rb_define_alias(c#{@cls.varname}, \"#{nocamel_bindname}\", \"#{@bindname}\");\n" \
         unless nocamel_bindname == @bindname

      res
   end
end

end

# kate: encoding UTF-8; remove-trailing-space on; replace-trailing-space-save on; space-indent on; indent-width 3;
