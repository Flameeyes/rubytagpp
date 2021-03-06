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

class Class
   attr_reader :ns, :name, :children
   @@classes = Hash.new

   def Class.new_virtual_variable(cls, setter, getter, variable, type)
      res = Array.new
      res << ClassMethod.new(cls, setter, { "name" => setter, "bindname" => variable+"=", "params" => [ "name" => "value", "type" => type ] })
      res << ClassMethod.new(cls, getter, { "name" => getter, "bindname" => variable, "return" => type })
   end

   def initialize(ns, name, content)
      @ns = ns
      @name = name
      @@classes["#{@ns.name}::#{@name}"] = self
      @methods = Array.new
      @constants = Array.new
      @parent = content["parent"] ? @@classes[content["parent"]] : nil
      @parent.children << self if @parent

      @children = Array.new

      if content["standalone"]
         @standalone = (content["standalone"] == "yes")
      else
         @standalone = false
      end

      if content["methods"]
         content["methods"].each { |method|
            @methods << ClassMethod.new(self, method["name"], method)
         }
      end

      if content["constants"]
         content["constants"].each { |constant|
            constant["value"] = "#{@ns.cxxname}::#{@name}::#{constant["name"]}"
            @constants << constant
         }
      end

      @enums = content["enums"]

      if content["attributes"]
         content["attributes"].each_pair { |atname, atcont|
            @methods.concat(Class.new_virtual_variable(self, atcont["funcset"], atcont["funcget"], atname, atcont["type"]))
         }
      end
   end

   def varname
      "#{@ns.name.gsub("::", "_")}_#{@name}"
   end

   def ptrmap
      unless @parent
         "#{@ns.name.gsub("::", "_")}_#{@name}_ptrMap"
      else
         @parent.ptrmap
      end
   end

   def header
      ret = %@
         extern VALUE c#{varname};
         VALUE cxx2ruby(#{@ns.cxxname}::#{@name}* instance);
         #{@ns.cxxname}::#{@name}* ruby2#{varname}Ptr(VALUE rval);
      @

      unless @parent
         ret << %@
            typedef std::map<VALUE, #{@ns.cxxname}::#{@name}*> T#{ptrmap};
            extern T#{ptrmap} #{ptrmap};
            static void #{varname}_free(void *p);
         @
      end

      if @standalone
         ret << %@
            VALUE cxx2ruby(const #{@ns.cxxname}::#{@name}& object);
         @
      end

      @methods.each { |method|
         ret << "#{method.binding_prototype};\n"
      }

      if @enums
         @enums.each { |enum|
            ret << %@
               static inline #{@ns.cxxname}::#{@name}::#{enum} ruby2#{varname}_#{enum}(VALUE rval);
            @
         }
      end

      ret << "\n"
   end

   def function_free
      @parent ? @parent.function_free : "#{varname}_free"
   end

   def parentvar
      @parent ? "c#{@parent.varname}" : "rb_cObject"
   end

   def test_children
      return unless @children

      ret = ""

      @children.each { |klass|
         ret << %@
if ( dynamic_cast< #{klass.ns.cxxname}::#{klass.name}* >(instance) != NULL )
{
   klass = c#{klass.varname};
   #{klass.test_children}
}
@
      }

      ret
   end

   def unit
      ret = "VALUE c#{varname};\n"

      unless @parent
         ret << %@
T#{ptrmap} #{ptrmap};

static void #{varname}_free(void *p) {
  T#{ptrmap}::iterator it, eend = #{ptrmap}.end();
  for(it = #{ptrmap}.begin(); it != eend; it++)
     if ( (*it).second == (#{@ns.cxxname}::#{@name}*)p ) {
        #{ptrmap}.erase(it); break;
     }
  delete (#{@ns.cxxname}::#{@name}*)p;
}

@
      end

      ret << %@

#{@ns.cxxname}::#{@name}* ruby2#{varname}Ptr(VALUE rval) {
   #{@ns.cxxname}::#{@name}* ptr;
   Data_Get_Struct(rval, #{@ns.cxxname}::#{@name}, ptr);

   if ( ptr ) return dynamic_cast< #{@ns.cxxname}::#{@name}* >(ptr);

   T#{ptrmap}::iterator it = #{ptrmap}.find(rval);

   if ( it == #{ptrmap}.end() ) {
      rb_raise(rb_eRuntimeError, "Unable to find #{@ns.cxxname}::#{name} instance for value %x (type %d)\\n", rval, TYPE(rval));
      return NULL;
   }

   return dynamic_cast< #{@ns.cxxname}::#{@name}* >((*it).second);
}

VALUE cxx2ruby(#{@ns.cxxname}::#{@name}* instance) {
  if ( instance == NULL ) return Qnil;

  T#{ptrmap}::iterator it, eend = #{ptrmap}.end();

  for(it = #{ptrmap}.begin(); it != eend; it++)
     if ( (*it).second == (#{@ns.cxxname}::#{@name}*)instance ) break;

   if ( it != #{ptrmap}.end() )
      return (*it).first;
   else {
      VALUE klass = c#{varname};

#{test_children}

      VALUE rval = Data_Wrap_Struct(klass, 0, 0, (void*)instance);
      #{ptrmap}[rval] = instance;
      // fprintf(stderr, "Wrapping instance %p in value %x (type %d)\\n", instance, rval, TYPE(rval));
      return rval;
   }
}

static VALUE #{varname}_alloc(VALUE self) {
   return Data_Wrap_Struct(self, 0, #{function_free}, 0);
}
@

      if @standalone
         ret << %@
            #{@ns.cxxname}::#{@name} ruby2#{varname}(VALUE rval) {
               #{@ns.cxxname}::#{@name}* ptr;
               Data_Get_Struct(rval, #{@ns.cxxname}::#{@name}, ptr);

               if ( ptr ) return *(dynamic_cast< #{@ns.cxxname}::#{@name}* >(ptr));

               return #{@ns.cxxname}::#{@name}();
            }

            VALUE cxx2ruby(const #{@ns.cxxname}::#{@name} &object) {
               #{@ns.cxxname}::#{@name}* instance = new #{@ns.cxxname}::#{@name}(object);
               VALUE klass = c#{varname};

            #{test_children}

               VALUE rval = Data_Wrap_Struct(klass, 0, #{function_free}, (void*)instance);
               #{ptrmap}[rval] = instance;
               // fprintf(stderr, "Wrapping instance %p in value %x (type %d)\\n", instance, rval, TYPE(rval));
               return rval;
            }
         @
      end

      @methods.each { |method| ret << method.binding_stub }

      if @enums
         @enums.each { |enum|
            ret << %@
               static inline #{@ns.cxxname}::#{@name}::#{enum} ruby2#{varname}_#{enum}(VALUE rval) {
                  return static_cast<#{@ns.cxxname}::#{@name}::#{enum}>(ruby2int(rval));
               }
            @
         }
      end
      ret << "\n"
   end

   def methods_init
      res = ""
      res
   end

   def init
      res = %@
c#{varname} = rb_define_class_under(#{@ns.varname}, \"#{@name.split("::").last}\", #{parentvar});
rb_define_alloc_func(c#{varname}, #{varname}_alloc);
      @

      @methods.each do |method| res << method.init; end

      @constants.each { |constant|
         res << "rb_define_const(c#{varname}, \"#{constant["name"]}\", cxx2ruby(#{constant["value"]}));\n"
      }

      res
   end
end

end

# kate: encoding UTF-8; remove-trailing-space on; replace-trailing-space-save on; space-indent on; indent-width 3;
