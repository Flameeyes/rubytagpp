# Simple test of saving data from and reading it to an Ogg Flac
# (via fields)

require "rubytagpp"
require "converters"

cvt = VorbisConverter.new(false)

savefile = TagLib::Ogg::FLAC::File.new(cvt.path)
exit -3 unless savefile.open? or savefile.read_only?

savefile.tag.addField("TITLE", Converter::TEST_TITLE)
savefile.tag.addField("ALBUM", Converter::TEST_ALBUM)
savefile.tag.addField("ARTIST", Converter::TEST_ARTIST)
savefile.tag.addField("COMMENT", Converter::TEST_COMMENT)
savefile.tag.addField("TESTFIELD", Converter::TEST_TESTFIELD)

if not savefile.save
   puts "Error while saving the file."
   exit -2
end

readfile = TagLib::Ogg::FLAC::File.new(cvt.path)
exit -4 unless readfile.open?

puts %@
	Title: "#{readfile.tag.fieldListMap["TITLE"][0]}" (should be "#{Converter::TEST_TITLE}")
	Album: "#{readfile.tag.fieldListMap["ALBUM"][0]}" (should be "#{Converter::TEST_ALBUM}")
	Artist: "#{readfile.tag.fieldListMap["ARTIST"][0]}" (should be "#{Converter::TEST_ARTIST}")
	Comment: "#{readfile.tag.fieldListMap["COMMENT"][0]}" (should be "#{Converter::TEST_COMMENT}")
	Test Field: "#{readfile.tag.fieldListMap["TESTFIELD"][0]}" (should be "#{Converter::TEST_TESTFIELD}")
@

exit -4 unless \
   readfile.tag.fieldListMap["TITLE"][0] == Converter::TEST_TITLE and \
   readfile.tag.fieldListMap["ALBUM"][0] == Converter::TEST_ALBUM and \
   readfile.tag.fieldListMap["ARTIST"][0] == Converter::TEST_ARTIST and \
   readfile.tag.fieldListMap["COMMENT"][0] == Converter::TEST_COMMENT and \
   readfile.tag.fieldListMap["TESTFIELD"][0] == Converter::TEST_TESTFIELD

exit 0
