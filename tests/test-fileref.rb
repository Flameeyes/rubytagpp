# Test of FileRef working. This will simply create a series of temporary files
# and then check with FileRef.new if they get the right type assigned.

require "rubytagpp"
require "converters"

# First pass: mp3 file
fref = TagLib::FileRef.new(MP3Converter.new(false).path)
exit -2 unless fref.file.open?
puts "	mp3 file is #{fref.file.class} (should be TagLib::MPEG::File)"
exit -3 unless fref.file.is_a?(TagLib::MPEG::File)

# Second pass: Ogg Vorbis file
fref = TagLib::FileRef.new(VorbisConverter.new(false).path)
exit -12 unless fref.file.open?
puts "	Ogg Vorbis file is #{fref.file.class} (should be TagLib::Ogg::Vorbis::File)"
exit -13 unless fref.file.is_a?(TagLib::Ogg::Vorbis::File)

# Third pass: Musepack file
fref = TagLib::FileRef.new(MPCConverter.new.path)
exit -22 unless fref.file.open?
puts "	Musepack file is #{fref.file.class} (should be TagLib::MPC::File)"
exit -23 unless fref.file.is_a?(TagLib::MPC::File)

# Fourth pass: FLAC file
fref = TagLib::FileRef.new(FlacConverter.new(false).path)
exit -32 unless fref.file.open?
puts "	FLAC file is #{fref.file.class} (should be TagLib::FLAC::File)"
exit -33 unless fref.file.is_a?(TagLib::FLAC::File)

# Fifth pass: Ogg Flac file
# fref = TagLib::FileRef.new(OggFlacConverter.new(false).path)
# exit -32 unless fref.file.open?
# puts "	Ogg Flac file is #{fref.file.class} (should be TagLib::Ogg::FLAC::File)"
# exit -33 unless fref.file.is_a?(TagLib::Ogg::FLAC::File)
#
# NOTE: Ogg Flac detection is imperfect, as .ogg file can be either Vorbis or
# FLAC streams. TagLib for simplicity defaults to always consider .ogg files as
# Ogg Vorbis files, thus this fifth pass isn't realiable

exit 0
