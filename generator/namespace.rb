
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
