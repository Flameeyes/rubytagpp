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

$templates = Hash.new
if description.has_key?("templates")
  description["templates"].each do |tmpl|
    $templates[tmpl["name"]] = {
      :name => tmpl["name"],
      :prototype => tmpl["prototype"],
      :function => tmpl["function"],
      :paramcount => tmpl["paramcount"]
    }
  end
end

description["namespaces"].each do |ns|
   puts "Error in parsing description file, unnamed namespace." unless ns["name"]
   namespaces << CxxBindingsGenerator::Namespace.new(ns["name"], ns)
end

header = File.new("#{bindings}.hh", "w")
unit = File.new("#{bindings}.cc", "w")

header.puts %@
#include <ruby.h>
#include <map> /* This is for the ptrMap */

@

description["includes"].each do |libincl|
   header.puts "#include #{libincl}"
end

unit.puts %@
#include "#{bindings}.hh"
#include "conversions.hh"
@

namespaces.each { |ns|
   header.puts(ns.header)
   unit.puts(ns.unit)
}

unit.puts %@
extern "C" {

#ifdef HAVE_VISIBILITY
void Init_#{bindings}() __attribute__((visibility("default")));
#endif

void Init_#{bindings}() {
@

namespaces.each { |ns|
   unit.puts "#{ns.init}"
}

unit.puts %@
} /* Init_#{bindings} */

} /* extern C */
@

# kate: encoding UTF-8; remove-trailing-space on; replace-trailing-space-save on; space-indent on; indent-width 3;
