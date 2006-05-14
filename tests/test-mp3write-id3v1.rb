# Simple test of saving data from and reading it to an mp3 file

require "rubytagpp"
require "converters"

cvt = MP3Converter.new(false)

savefile = TagLib::MPEG::File.new(cvt.path)
exit -3 unless savefile.open? or savefile.read_only?

exit -5 unless savefile.ID3v1Tag(true)

savefile.ID3v1Tag.title = Converter::TEST_TITLE
savefile.ID3v1Tag.album = Converter::TEST_ALBUM
savefile.ID3v1Tag.artist = Converter::TEST_ARTIST
savefile.ID3v1Tag.track = Converter::TEST_TRACK

if not savefile.save
   puts "Error while saving the file."
   exit -2
end

readfile = TagLib::MPEG::File.new(cvt.path)
exit -4 unless readfile.open?

puts %@
	Title: "#{readfile.ID3v1Tag.title}" (should be "#{Converter::TEST_TITLE}")
	Album: "#{readfile.ID3v1Tag.album}" (should be "#{Converter::TEST_ALBUM}")
	Artist: "#{readfile.ID3v1Tag.artist}" (should be "#{Converter::TEST_ARTIST}")
	Track: "#{readfile.ID3v1Tag.track}" (should be "#{Converter::TEST_TRACK}")
@

exit -5 unless \
	readfile.ID3v1Tag.title == Converter::TEST_TITLE and \
	readfile.ID3v1Tag.album == Converter::TEST_ALBUM and \
	readfile.ID3v1Tag.artist == Converter::TEST_ARTIST and \
	readfile.ID3v1Tag.track == Converter::TEST_TRACK

exit 0

# kate: encoding UTF-8; remove-trailing-space on; replace-trailing-space-save on; space-indent on; indent-width 3;
