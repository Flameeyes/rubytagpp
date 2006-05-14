# Simple test of saving data from and reading it to an mp3 file

require "rubytagpp"
require "converters"

cvt = MPCConverter.new

savefile = TagLib::MPC::File.new(cvt.path)
exit -3 unless savefile.open? or savefile.read_only?

savefile.APETag.title = Converter::TEST_TITLE
savefile.APETag.album = Converter::TEST_ALBUM
savefile.APETag.artist = Converter::TEST_ARTIST
savefile.APETag.track = Converter::TEST_TRACK

if not savefile.save
   puts "Error while saving the file."
   exit -2
end

readfile = TagLib::MPEG::File.new(cvt.path)
exit -4 unless readfile.open?

puts %@
	Title: "#{readfile.APETag.title}" (should be "#{Converter::TEST_TITLE}")
	Album: "#{readfile.APETag.album}" (should be "#{Converter::TEST_ALBUM}")
	Artist: "#{readfile.APETag.artist}" (should be "#{Converter::TEST_ARTIST}")
	Track: "#{readfile.APETag.track}" (should be "#{Converter::TEST_TRACK}")
@

exit -5 unless \
	readfile.APETag.title == Converter::TEST_TITLE and \
	readfile.APETag.album == Converter::TEST_ALBUM and \
	readfile.APETag.artist == Converter::TEST_ARTIST and \
	readfile.APETag.track == Converter::TEST_TRACK

exit 0
