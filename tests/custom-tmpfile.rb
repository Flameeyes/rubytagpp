# kate: encoding UTF-8; remove-trailing-space on; replace-trailing-space-save on; space-indent on; indent-width 3;
#
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
# along with this program; if not, write to the Free Software
# Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
#
# Simple custom tempfile class that respect the given extension for the file.
# needed for a few things in the test suite.
require "tempfile"

class CustomTempfile < Tempfile
   def initialize(basename, extension, tmpdir=Dir::tmpdir)
      @extension = extension
      super(basename, tmpdir)
   end

   def make_tmpname(basename, n)
      sprintf('%s%d.%d.%s', basename, $$, n, @extension)
   end
end
