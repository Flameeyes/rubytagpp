
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
