#!/usr/bin/env ruby
# kate: encoding UTF-8; remove-trailing-space on; replace-trailing-space-save on; space-indent on; indent-width 3;

require "yaml"

require "namespace.rb"
require "class.rb"
require "method.rb"

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
