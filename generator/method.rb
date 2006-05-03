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
