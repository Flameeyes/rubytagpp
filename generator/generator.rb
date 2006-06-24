#!/usr/bin/env ruby
# Flameeyes's C++<->Ruby bindings generator
# Copyright (C) 2006, Diego "Flameeyes" Pettenò
#
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 2 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this generator; if not, write to the Free Software
# Foundation, Inc., 51 Franklin St, Fifth Floor, Boston, MA  02110-1301  USA

require "yaml"

require "namespace.rb"
require "class.rb"
require "method.rb"

description = YAML::load(File.new(ARGV[0]).read)

namespaces = Array.new
bindings = description["bindings"]

description["namespaces"].each do |ns|
   puts "Error in parsing description file, unnamed namespace." unless ns["name"]
   namespaces << CxxBindingsGenerator::Namespace.new(ns["name"], ns)
end

header = File.new("#{bindings}.h", "w")
unit = File.new("#{bindings}.cpp", "w")

header.puts %@
#ifdef __GNUC__
# pragma GCC visibility push(default)
#endif

#include <ruby.h>

@

description["includes"].each do |libincl|
   header.puts "#include #{libincl}"
end

header.puts %@
#ifdef __GNUC__
# pragma GCC visibility pop
#endif

#ifdef __GNUC__
# pragma GCC visibility push(hidden)
#endif
@

unit.puts %@
#include "#{bindings}.h"
#include "conversions.h"

#ifdef __GNUC__
# pragma GCC visibility push(hidden)
#endif
@

namespaces.each { |ns|
   header.puts(ns.header)
   unit.puts(ns.unit)
}

header.puts %@
#ifdef __GNUC__
# pragma GCC visibility pop
#endif

@

unit.puts %@
#ifdef __GNUC__
# pragma GCC visibility pop
#endif

extern "C" {

#ifdef __GNUC__
# pragma GCC visibility push(default)
#endif

void Init_#{bindings}() {
@

namespaces.each { |ns|
   unit.puts "#{ns.init}"
}

unit.puts %@
} /* Init_#{bindings} */

#ifdef __GNUC__
# pragma GCC visibility pop
#endif

} /* extern C */
@

# kate: encoding UTF-8; remove-trailing-space on; replace-trailing-space-save on; space-indent on; indent-width 3;
