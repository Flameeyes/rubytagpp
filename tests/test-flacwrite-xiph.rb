# Test n. 7, simple test of getting data out of a flac file

require "rubytagpp"
require "converters"

cvt = FlacConverter.new

savefile = TagLib::FLAC::File.new(cvt.path)
exit -2 unless savefile.open?

exit -3 unless savefile.xiph_comment(true)

savefile.xiph_comment.title = Converter::TEST_TITLE
savefile.xiph_comment.album = Converter::TEST_ALBUM
savefile.xiph_comment.artist = Converter::TEST_ARTIST
savefile.xiph_comment.comment = Converter::TEST_COMMENT

savefile.save

readfile = TagLib::FLAC::File.new(cvt.path)
exit -4 unless readfile.open?

puts %@
	Title: "#{readfile.xiph_comment.title}" (should be "#{Converter::TEST_TITLE}")
	Album: "#{readfile.xiph_comment.album}" (should be "#{Converter::TEST_ALBUM}")
	Artist: "#{readfile.xiph_comment.artist}" (should be "#{Converter::TEST_ARTIST}")
	Comment: "#{readfile.xiph_comment.comment}" (should be "#{Converter::TEST_COMMENT}")
@

exit -5 unless \
	readfile.xiph_comment.title == Converter::TEST_TITLE and \
	readfile.xiph_comment.album == Converter::TEST_ALBUM and \
	readfile.xiph_comment.artist == Converter::TEST_ARTIST and \
	readfile.xiph_comment.comment == Converter::TEST_COMMENT

exit 0
