# kate: encoding UTF-8; remove-trailing-space on; replace-trailing-space-save on; space-indent on; indent-width 3;

class Class
   attr_reader :ns, :name
   @@classes = Hash.new

   def initialize(ns, name, content)
      @ns = ns
      @name = name
      @@classes["#{@ns.name}::#{@name}"] = self
      @methods = Array.new
      @parent = content["parent"] ? @@classes[content["parent"]] : nil

      if content["methods"]
         content["methods"].each { |method|
            @methods << ClassMethod.new(self, method["name"], method)
         }
      end

      if content["attributes"]
         content["attributes"].each_pair { |atname, atcont|
            setmethod = ClassMethod.new(self, atcont["funcset"], nil, "#{atname}=")
            getmethod = ClassMethod.new(self, atcont["funcget"], nil, atname)

            getmethod.return = atcont["type"]
            setmethod.params << Parameter.new(atcont["type"], "value", false)

            @methods << setmethod
            @methods << getmethod
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
      ret = "extern VALUE c#{varname};\n" \
         "VALUE cxx2ruby(#{@ns.name}::#{@name}* instance, VALUE self = Qnil);\n"

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
      @parent ? @parent.function_free : "#{varname}_free"
   end

   def parentvar
      @parent ? "c#{@parent.varname}" : "rb_cObject"
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
   T#{ptrmap}::iterator it = #{ptrmap}.find(rval);

   if ( it == #{ptrmap}.end() ) {
      rb_raise(rb_eRuntimeError, "Unable to find #{@ns.name}::#{name} instance for value %x (type %d)\\n", rval, TYPE(rval));
      return NULL;
   }

   return dynamic_cast<#{@ns.name}::#{@name}*>((*it).second);
}

VALUE cxx2ruby(#{@ns.name}::#{@name}* instance, VALUE self) {
  T#{ptrmap}::iterator it, eend = #{ptrmap}.end();

  for(it = #{ptrmap}.begin(); it != eend; it++)
     if ( (*it).second == (#{@ns.name}::#{@name}*)instance ) break;

   if ( it != #{ptrmap}.end() )
      return (*it).first;
   else {
      VALUE rval = Data_Wrap_Struct(c#{varname}, 0, (self != Qnil) ? #{function_free} : 0, (void*)instance);
      #{ptrmap}[rval] = instance;
      if ( self != Qnil ) #{ptrmap}[self] = instance;
      // fprintf(stderr, "Wrapping instance %p in value %x (type %d)\\n", instance, rval, TYPE(rval));
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
