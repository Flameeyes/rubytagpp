# Test of FileRef working. This will simply create a series of temporary files
# and then check with FileRef.new if they get the right type assigned.

require "rubytagpp"
require "converters"

fref = TagLib::FileRef.new(OggFlacConverter.new(false).path)
exit -32 unless fref.file.open?
puts "	Ogg Flac file is #{fref.file.class} (should be TagLib::Ogg::FLAC::File)"
exit -33 unless fref.file.is_a?(TagLib::Ogg::FLAC::File)

# NOTE: Ogg Flac detection is imperfect, as .ogg file can be either Vorbis or
# FLAC streams. TagLib for simplicity defaults to always consider .ogg files as
# Ogg Vorbis files, thus this fifth pass isn't realiable

exit 0
