# Simple test of getting data out of an ogg file with the raw fields list

require "rubytagpp"
require "converters"

cvt = VorbisConverter.new()

file = TagLib::Ogg::Vorbis::File.new(cvt.path)
exit -3 unless file.open?

puts %@
	Title: "#{file.tag.fieldListMap["TITLE"][0]}" (should be "#{Converter::TEST_TITLE}")
	Album: "#{file.tag.fieldListMap["ALBUM"][0]}" (should be "#{Converter::TEST_ALBUM}")
	Artist: "#{file.tag.fieldListMap["ARTIST"][0]}" (should be "#{Converter::TEST_ARTIST}")
	Comment: "#{file.tag.fieldListMap["COMMENT"][0]}" (should be "#{Converter::TEST_COMMENT}")
	Test Field: "#{file.tag.fieldListMap["TESTFIELD"][0]}" (should be "#{Converter::TEST_TESTFIELD}")
@

exit -4 unless \
   file.tag.fieldListMap["TITLE"][0] == Converter::TEST_TITLE and \
   file.tag.fieldListMap["ALBUM"][0] == Converter::TEST_ALBUM and \
   file.tag.fieldListMap["ARTIST"][0] == Converter::TEST_ARTIST and \
   file.tag.fieldListMap["COMMENT"][0] == Converter::TEST_COMMENT and \
   file.tag.fieldListMap["TESTFIELD"][0] == Converter::TEST_TESTFIELD

exit 0

# kate: encoding UTF-8; remove-trailing-space on; replace-trailing-space-save on; space-indent on; indent-width 3;
