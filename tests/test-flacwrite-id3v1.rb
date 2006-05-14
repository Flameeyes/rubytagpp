# Test n. 7, simple test of getting data out of a flac file

require "rubytagpp"
require "converters"

cvt = FlacConverter.new

savefile = TagLib::FLAC::File.new(cvt.path)
exit -2 unless savefile.open?

exit -3 unless savefile.ID3v1Tag(true)

savefile.ID3v1Tag.title = Converter::TEST_TITLE
savefile.ID3v1Tag.album = Converter::TEST_ALBUM
savefile.ID3v1Tag.artist = Converter::TEST_ARTIST
savefile.ID3v1Tag.comment = Converter::TEST_COMMENT

if not savefile.save
   puts "Error while saving the file."
   exit -2
end

readfile = TagLib::FLAC::File.new(cvt.path)
exit -4 unless readfile.open?

puts %@
	Title: "#{readfile.ID3v1Tag.title}" (should be "#{Converter::TEST_TITLE}")
	Album: "#{readfile.ID3v1Tag.album}" (should be "#{Converter::TEST_ALBUM}")
	Artist: "#{readfile.ID3v1Tag.artist}" (should be "#{Converter::TEST_ARTIST}")
	Comment: "#{readfile.ID3v1Tag.comment}" (should be "#{Converter::TEST_COMMENT}")
@

exit -5 unless \
	readfile.ID3v1Tag.title == Converter::TEST_TITLE and \
	readfile.ID3v1Tag.album == Converter::TEST_ALBUM and \
	readfile.ID3v1Tag.artist == Converter::TEST_ARTIST and \
	readfile.ID3v1Tag.comment == Converter::TEST_COMMENT

exit 0
