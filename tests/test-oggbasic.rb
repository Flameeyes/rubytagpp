# Simple test of getting data out of an Ogg Vorbis file

require "rubytagpp"
require "converters"

cvt = VorbisConverter.new()

file = TagLib::Ogg::Vorbis::File.new(cvt.path)
exit -3 unless file.open? and file.tag

puts %@
	Title: "#{file.tag.title}" (should be "#{Converter::TEST_TITLE}")
	Album: "#{file.tag.album}" (should be "#{Converter::TEST_ALBUM}")
	Artist: "#{file.tag.artist}" (should be "#{Converter::TEST_ARTIST}")
	Comment: "#{file.tag.comment}" (should be "#{Converter::TEST_COMMENT}")
@

exit -4 unless \
	file.tag.title == Converter::TEST_TITLE and \
	file.tag.album == Converter::TEST_ALBUM and \
	file.tag.artist == Converter::TEST_ARTIST and \
	file.tag.comment == Converter::TEST_COMMENT

exit -5 if file.tag and not file.tag.is_a?(TagLib::Ogg::XiphComment)

exit 0
