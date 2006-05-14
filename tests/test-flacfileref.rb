# Test of FileRef working. This will simply create a series of temporary files
# and then check with FileRef.new if they get the right type assigned.

require "rubytagpp"
require "converters"

fref = TagLib::FileRef.new(FlacConverter.new(false).path)
exit -32 unless fref.file.open?
puts "	FLAC file is #{fref.file.class} (should be TagLib::FLAC::File)"
exit -33 unless fref.file.is_a?(TagLib::FLAC::File)

exit 0
