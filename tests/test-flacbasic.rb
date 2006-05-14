# Test n. 7, simple test of getting data out of a flac file

require "rubytagpp"
require "converters"

cvt = FlacConverter.new

file = TagLib::FLAC::File.new(cvt.path)
exit -3 unless file.open?

exit -4 unless file.tag

puts %@
	Title: "#{file.tag.title}" (should be "#{Converter::TEST_TITLE}")
	Album: "#{file.tag.album}" (should be "#{Converter::TEST_ALBUM}")
	Artist: "#{file.tag.artist}" (should be "#{Converter::TEST_ARTIST}")
	Comment: "#{file.tag.comment}" (should be "#{Converter::TEST_COMMENT}")
@

exit -5 unless \
	file.tag.title == Converter::TEST_TITLE and \
	file.tag.album == Converter::TEST_ALBUM and \
	file.tag.artist == Converter::TEST_ARTIST and \
	file.tag.comment == Converter::TEST_COMMENT

exit 0
