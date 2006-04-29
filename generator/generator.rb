#!/usr/bin/env ruby
# kate: encoding UTF-8; remove-trailing-space on; replace-trailing-space-save on; space-indent on; indent-width 3;

require "yaml"

class Namespace
   attr_reader :name

   def initialize(name, content)
      @name = name
      @classes = Array.new

      content["classes"].each_pair { |clsname, clscont|
         @classes << Class.new(self, clsname, clscont)
      }
   end

   def varname
      "m#{@name.sub("::", "_")}"
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

      ret << "\n"
   end
end

class Class
   attr_reader :ns, :name

   def initialize(ns, name, content)
      @ns = ns
      @name = name
      @methods = Array.new
      @parent = content["parent"]

      if content["methods"]
         content["methods"].each_pair { |mtname, mtcont|
            @methods << ClassMethod.new(self, mtname, mtcont)
         }
      end

      if content["attributes"]
         content["attributes"].each_pair { |atname, atcont|
            setmethod = ClassMethod.new(self, atcont["funcset"], nil, "#{atname}=")
            getmethod = ClassMethod.new(self, atcont["funcget"], nil, atname)

            getmethod.return = atcont["type"]
            setmethod.params << Parameter.new(atcont["type"], "value")

            @methods << setmethod
            @methods << getmethod
         }
      end
   end

   def varname
      "#{@ns.name.sub("::", "_")}__#{@name}"
   end

   def ptrmap
      unless @parent
         "#{@ns.name.sub("::", "_")}__#{@name}_ptrMap"
      else
         tokens = @parent.split("::")
         classname = tokens.pop

         "#{tokens.join("_")}__#{classname}_ptrMap"
      end
   end

   def header
      ret = "extern VALUE c#{varname};\n"

      unless @parent
         ret << \
            "typedef std::map<VALUE, #{@ns.name}::#{@name}*> T#{ptrmap};\n" \
            "extern T#{ptrmap} #{ptrmap};\n" \
            "static void #{varname}_free(void *p);\n"
      end

      @methods.each { |method|
         ret << "#{method.binding_prototype};\n"
      }

      ret << "\n"
   end

   def unit
      ret = "VALUE c#{varname};\n"

      unless @parent
         ret << \
            "T#{ptrmap} #{ptrmap};\n\n" \
            "static void #{varname}_free(void *p) {\n" \
            "  T#{ptrmap}::iterator it, eend = #{ptrmap}.end();\n" \
            "  for(it = #{ptrmap}.begin(); it != eend; it++)\n" \
            "     if ( (*it).second == (#{@ns.name}::#{@name}*)p ) {\n" \
            "        #{ptrmap}.erase(it); break;\n" \
            "     }\n" \
            "  delete (#{@ns.name}::#{@name}*)p;\n" \
            "}\n\n"
         freer_function="#{varname}_free"
      else
         freer_function="#{@parent.gsub("::", "__")}_free"
      end

      ret << \
         "#{@ns.name}::#{@name}* ruby2#{varname}(VALUE rval) {\n" \
         "  T#{ptrmap}::iterator it = #{ptrmap}.find(rval);\n" \
         "  if ( it == #{ptrmap}.end() ) {\n" \
         "     rb_raise(rb_eException, \"#{@ns.name}::#{@name} instance not found in ptrMap\");\n" \
         "     return NULL;\n" \
         "  }\n" \
         "  return dynamic_cast<#{@ns.name}::#{@name}*>((*it).second);\n" \
         "}\n\n"

      ret << \
         "VALUE #{varname}2ruby(#{@ns.name}::#{@name}* instance) {\n" \
         "  T#{ptrmap}::iterator it, eend = #{ptrmap}.end();\n" \
         "  for(it = #{ptrmap}.begin(); it != eend; it++)\n" \
         "     if ( (*it).second == (#{@ns.name}::#{@name}*)instance ) break;\n" \
         "  if ( it != #{ptrmap}.end() )\n" \
         "     return (*it).first;\n" \
         "  else {\n" \
         "     VALUE rval = Data_Wrap_Struct(c#{varname}, 0, #{freer_function}, instance);\n" \
         "     #{ptrmap}[rval] = instance;\n" \
         "     return rval;\n" \
         "  }\n" \
         "}\n\n"

      @methods.each { |method|
         ret << method.binding_stub
      }

      ret << "\n"
   end

   def init
      unless @parent
         parentvar = "rb_cObject"
      else
         parentvar = "c#{@parent.sub("::", "__")}"
      end
      ret = "c#{varname} = rb_define_class_under(#{@ns.varname}, \"#{@name.split("::").last}\", #{parentvar});\n"

      @methods.each { |method|
         ret << method.init
      }

      ret << "\n"
   end
end

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

      if content
         @return = content["return"]
      else
         @return = "void"
      end

      if content and content["params"]
         content["params"].each_pair { |pmname, pmtype|
            @params << Parameter.new(pmtype, pmname)
         }
      end
   end

   def varname
      "f#{@cls.ns.name.sub("::", "_")}__#{@cls.name}__#{@name}"
   end

   def binding_prototype
      prototype = "VALUE #{varname} ( VALUE self"

      @params.each { |p|
         prototype << ", VALUE #{p.name}"
      }

      prototype << " )"
   end

   def binding_stub
      ret = \
         "#{binding_prototype} {\n" \
         "  #{@cls.ns.name}::#{@cls.name}* tmp = ruby2#{@cls.varname}(self);\n" \
         "  if ( ! tmp ) return Qnil;\n" \
         "  \n"
      if @params.empty?
         if @return != "void"
            ret << "  return cxx2ruby ( tmp->#{@name}() );\n"
         else
            ret << \
               "  tmp->#{@name}();\n" \
               "  return Qnil;"
         end
      else
         ret << "  "
         if @return != "void"
            ret << "#{@return} res = "
         end

         ret << "tmp->#{@name}("

         @params.each { |p|
            ret << " ruby2#{p.type}(#{p.name}),"
         }

         ret.chomp!(",")
         ret << " );\n" <<

         if @return == "void"
            "  return Qnil;\n"
         else
            "  return res;"
         end
      end
      ret << "}\n\n"
   end

   def init
      ret = "rb_define_method(c#{@cls.varname}, \"#{@bindname}\", RUBY_METHOD_FUNC(#{varname}), #{@params.length});\n"
   end
end

class Parameter
   attr_reader :type, :name

   def initialize(type, name)
      @type = type
      @name = name
   end
end

description = YAML::load(File.new(ARGV[0]).read)

namespaces = Array.new
bindings = description["bindings"]

description["namespaces"].each_pair do |nsname, nscont|
   namespaces << Namespace.new(nsname, nscont)
end

header = File.new("#{bindings}.h", "w")
unit = File.new("#{bindings}.cpp", "w")

header.puts "#include <ruby.h>\n"

description["includes"].each do |libincl|
   header.puts "#include #{libincl}"
end

unit.puts "#include \"#{bindings}.h\"\n\n"

header.puts

namespaces.each { |ns|
   header.puts(ns.header)
   unit.puts(ns.unit)
}

unit.puts

unit.puts "void binds_initialise() {\n"

namespaces.each { |ns|
   unit.puts "#{ns.init}"
}

unit.puts "}\n"
