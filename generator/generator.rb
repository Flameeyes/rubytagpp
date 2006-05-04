#!/usr/bin/env ruby
# kate: encoding UTF-8; remove-trailing-space on; replace-trailing-space-save on; space-indent on; indent-width 3;

require "yaml"

require "namespace.rb"
require "class.rb"
require "method.rb"

description = YAML::load(File.new(ARGV[0]).read)

namespaces = Array.new
bindings = description["bindings"]

description["namespaces"].each do |ns|
   puts "Error in parsing description file, unnamed namespace." unless ns["name"]
   namespaces << Namespace.new(ns["name"], ns)
end

header = File.new("#{bindings}.h", "w")
unit = File.new("#{bindings}.cpp", "w")

header.puts "#include <ruby.h>\n"

description["includes"].each do |libincl|
   header.puts "#include #{libincl}"
end

unit.puts %@#include "#{bindings}.h"
@

header.puts %@
extern "C" {

@

namespaces.each { |ns|
   header.puts(ns.header)
   unit.puts(ns.unit)
}

unit.puts

unit.puts %@
extern "C" {

void Init_#{bindings}() {
@

namespaces.each { |ns|
   unit.puts "#{ns.init}"
}

unit.puts %@
} /* Init_#{bindings} */

} /* extern C */
@

header.puts %@
} /* extern C */
@
