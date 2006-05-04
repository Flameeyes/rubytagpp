# kate: encoding UTF-8; remove-trailing-space on; replace-trailing-space-save on; space-indent on; indent-width 3;

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

   def function_free
      @parent ? "#{@parent.gsub("::", "__")}_free" : "#{varname}_free"
   end

   def parentvar
      @parent ? "c#{@parent.sub("::", "__")}" : "rb_cObject"
   end

   def unit
      ret = "VALUE c#{varname};\n"

      unless @parent
         ret << %@
T#{ptrmap} #{ptrmap};

static void #{varname}_free(void *p) {
  T#{ptrmap}::iterator it, eend = #{ptrmap}.end();
  for(it = #{ptrmap}.begin(); it != eend; it++)
     if ( (*it).second == (#{@ns.name}::#{@name}*)p ) {
        #{ptrmap}.erase(it); break;
     }
  delete (#{@ns.name}::#{@name}*)p;
}

@
      end

      ret << %@

#{@ns.name}::#{@name}* ruby2#{varname}(VALUE rval) {
   Check_Type(rval, T_OBJECT);
   T#{ptrmap}::iterator it = #{ptrmap}.find(rval);

   if ( it == #{ptrmap}.end() ) {
      rb_raise(rb_eRuntimeError, "Unable to find #{@ns.name}::#{name} instance for value %x (type %d)\\n", rval, TYPE(rval));
      return NULL;
   }

   return dynamic_cast<#{@ns.name}::#{@name}*>((*it).second);
}

VALUE cxx2ruby(#{@ns.name}::#{@name}* instance) {
  T#{ptrmap}::iterator it, eend = #{ptrmap}.end();

  for(it = #{ptrmap}.begin(); it != eend; it++)
     if ( (*it).second == (#{@ns.name}::#{@name}*)instance ) break;

  if ( it != #{ptrmap}.end() )
     return (*it).first;
  else {
     VALUE rval = Data_Wrap_Struct(c#{varname}, 0, #{function_free}, (void*)instance);
     #{ptrmap}[rval+5*sizeof(void*)] = instance;
     fprintf(stderr, "Wrapping instance %p in value %x (type %d)\\n", instance, rval+5*sizeof(void*), TYPE(rval+5*sizeof(void*)));
     return rval;
  }
}
@

      @methods.each { |method| ret << method.binding_stub }
      ret << "\n"
   end

   def methods_init
      res = ""
      @methods.each do |method| res << method.init; end
      res
   end

   def init
      %@
c#{varname} = rb_define_class_under(#{@ns.varname}, \"#{@name.split("::").last}\", #{parentvar});
#{methods_init}
      @
   end
end
