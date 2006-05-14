# Test of FileRef working. This will simply create a series of temporary files
# and then check with FileRef.new if they get the right type assigned.

require "rubytagpp"
require "converters"

fref = TagLib::FileRef.new(MP3Converter.new(false).path)
exit -2 unless fref.file.open?
puts "	mp3 file is #{fref.file.class} (should be TagLib::MPEG::File)"
exit -3 unless fref.file.is_a?(TagLib::MPEG::File)

exit 0
