# kate: encoding UTF-8; remove-trailing-space on; replace-trailing-space-save on; space-indent on; indent-width 3;

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
