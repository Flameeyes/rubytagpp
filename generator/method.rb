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

      if content and content["params"]
         content["params"].each { |p|
            @params << Parameter.new(p["type"], p["name"])
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

   def params_conversion
      ret = ""
      @params.each { |p|
         ret << " ruby2#{p.type.sub("*", "Ptr")}(#{p.name}),"
      } if @params

      ret.chomp!(",")
   end

   def binding_stub
      if @bindname == "initialize"
         return constructor_stub
      end

      ret = %@
#{binding_prototype} {
   #{@cls.ns.name}::#{@cls.name}* tmp = ruby2#{@cls.varname}(self);
   fprintf(stderr, "Called #{@cls.ns.name}::#{@cls.name}::#{@name} for value %x (%p).\\n", self, tmp);
   if ( ! tmp ) return Qnil; // The exception is thrown by ruby2*

  @

      if @return and @return != "void"
         ret << "return cxx2ruby(tmp->#{@name}(#{params_conversion}));\n"
      else
         ret << "tmp->#{@name}(#{params_conversion}); return Qnil;\n"
      end

      ret << "}\n"
   end

   def constructor_stub
      %@
#{binding_prototype} {
   #{@cls.ns.name}::#{@cls.name}* tmp = new #{@cls.ns.name}::#{@cls.name}(#{params_conversion});

   return cxx2ruby(tmp, true);
}
@
   end

   def init
      "rb_define_method(c#{@cls.varname}, \"#{@bindname}\", RUBY_METHOD_FUNC(#{varname}), #{@params.length});\n"
   end
end

class Parameter
   attr_reader :type, :name

   def initialize(type, name)
      @type = type
      @name = name
   end
end
