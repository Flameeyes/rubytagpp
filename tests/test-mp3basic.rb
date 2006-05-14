# Simple test of getting data out of an mp3 file

require "rubytagpp"
require "converters"

cvt = MP3Converter.new

file = TagLib::MPEG::File.new(cvt.path)
exit -3 unless file.open?
exit -4 unless \
   file.tag.title == Converter::TEST_TITLE and \
   file.tag.album == Converter::TEST_ALBUM and \
   file.tag.artist == Converter::TEST_ARTIST

exit -9 if file.audioProperties and not file.audioProperties.is_a?(TagLib::MPEG::Properties)

exit 0

# kate: encoding UTF-8; remove-trailing-space on; replace-trailing-space-save on; space-indent on; indent-width 3;