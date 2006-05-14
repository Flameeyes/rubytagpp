# Test of FileRef working. This will simply create a series of temporary files
# and then check with FileRef.new if they get the right type assigned.

require "rubytagpp"
require "converters"

fref = TagLib::FileRef.new(VorbisConverter.new(false).path)
exit -12 unless fref.file.open?
puts "	Ogg Vorbis file is #{fref.file.class} (should be TagLib::Ogg::Vorbis::File)"
exit -13 unless fref.file.is_a?(TagLib::Ogg::Vorbis::File)

exit 0
