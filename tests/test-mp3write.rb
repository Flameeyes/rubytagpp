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

if not savefile.save
   puts "Error while saving the file."
   exit -2
end

readfile = TagLib::MPEG::File.new(cvt.path)
exit -4 unless readfile.open?

puts %@
	Title: "#{readfile.tag.title}" (should be "#{Converter::TEST_TITLE}")
	Album: "#{readfile.tag.album}" (should be "#{Converter::TEST_ALBUM}")
	Artist: "#{readfile.tag.artist}" (should be "#{Converter::TEST_ARTIST}")
	Track: "#{readfile.tag.track}" (should be "#{Converter::TEST_TRACK}")
@

exit -5 unless \
	readfile.tag.title == Converter::TEST_TITLE and \
	readfile.tag.album == Converter::TEST_ALBUM and \
	readfile.tag.artist == Converter::TEST_ARTIST and \
	readfile.tag.track == Converter::TEST_TRACK

exit 0
