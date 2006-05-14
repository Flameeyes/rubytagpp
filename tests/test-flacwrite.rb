# Test n. 7, simple test of getting data out of a flac file

require "rubytagpp"
require "converters"

cvt = FlacConverter.new

savefile = TagLib::FLAC::File.new(cvt.path)
exit -2 unless savefile.open?

exit -3 unless savefile.ID3v2Tag(true)

savefile.tag.title = Converter::TEST_TITLE
savefile.tag.album = Converter::TEST_ALBUM
savefile.tag.artist = Converter::TEST_ARTIST
savefile.tag.track = Converter::TEST_TRACK

savefile.save

readfile = TagLib::FLAC::File.new(cvt.path)
exit -4 unless readfile.open?
exit -5 unless \
	readfile.tag.title == Converter::TEST_TITLE and \
	readfile.tag.album == Converter::TEST_ALBUM and \
	readfile.tag.artist == Converter::TEST_ARTIST

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
