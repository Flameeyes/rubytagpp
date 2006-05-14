# Test of FileRef working. This will simply create a series of temporary files
# and then check with FileRef.new if they get the right type assigned.

require "rubytagpp"
require "converters"

fref = TagLib::FileRef.new(MPCConverter.new.path)
exit -22 unless fref.file.open?
puts "	Musepack file is #{fref.file.class} (should be TagLib::MPC::File)"
exit -23 unless fref.file.is_a?(TagLib::MPC::File)

exit 0
