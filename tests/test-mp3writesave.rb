# Simple test of saving data from and reading it to an mp3 file

require "rubytagpp"
require "converters"

cvt = MP3Converter.new(false)

savefile = TagLib::MPEG::File.new(cvt.path)
exit -3 unless savefile.open? or savefile.read_only?

savefile.tag.title = Converter::TEST_TITLE
savefile.tag.album = Converter::TEST_ALBUM
savefile.tag.artist = Converter::TEST_ARTIST
savefile.tag.track = Converter::TEST_TRACK

savefile.save

readfile = TagLib::MPEG::File.new(cvt.path)
exit -4 unless readfile.open?
exit -5 unless \
	readfile.tag.title == Converter::TEST_TITLE and \
	readfile.tag.album == Converter::TEST_ALBUM and \
	readfile.tag.artist == Converter::TEST_ARTIST

exit 0
