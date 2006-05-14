# Simple test of getting data out of an Ogg FLAC file with the raw fields list

require "rubytagpp"
require "tempfile"

TEST_TITLE = "This is a test"
TEST_ALBUM = "Run your little test"
TEST_ARTIST = "The Testers"
TEST_COMMENT = "If you had not forseen this, this is a test file."
TEST_TESTFIELD = "Noone knows about this"

# First of all, create a temporary file
@tmp = Tempfile.new("rubytag-test-oggfields.ogg")
@tmp.close

def doexit(ret = 0)
    @tmp.unlink
    exit ret
end

# Convert the compressed wave in ogg/flac and set test tags
doexit(-1) unless system("bzcat #{ARGV[0]} | flac --ogg -f --tag=Comment=\"#{TEST_COMMENT}\" --tag=Title=\"#{TEST_TITLE}\" --tag=Album=\"#{TEST_ALBUM}\" --tag=Artist=\"#{TEST_ARTIST}\" --tag=Testfield=\"#{TEST_TESTFIELD}\" -s -o #{@tmp.path} - 2>/dev/null")

file = TagLib::Ogg::FLAC::File.new(@tmp.path)
doexit(-3) unless file.open?

puts %@
	Title: "#{file.tag.fieldListMap["TITLE"][0]}" (should be "#{TEST_TITLE}")
	Album: "#{file.tag.fieldListMap["ALBUM"][0]}" (should be "#{TEST_ALBUM}")
	Artist: "#{file.tag.fieldListMap["ARTIST"][0]}" (should be "#{TEST_ARTIST}")
	Comment: "#{file.tag.fieldListMap["COMMENT"][0]}" (should be "#{TEST_COMMENT}")
	Test Field: "#{file.tag.fieldListMap["TESTFIELD"][0]}" (should be "#{TEST_TESTFIELD}")
@

doexit(-4) unless \
   file.tag.fieldListMap["TITLE"][0] == TEST_TITLE and \
   file.tag.fieldListMap["ALBUM"][0] == TEST_ALBUM and \
   file.tag.fieldListMap["ARTIST"][0] == TEST_ARTIST and \
   file.tag.fieldListMap["COMMENT"][0] == TEST_COMMENT and \
   file.tag.fieldListMap["TESTFIELD"][0] == TEST_TESTFIELD

doexit

# kate: encoding UTF-8; remove-trailing-space on; replace-trailing-space-save on; space-indent on; indent-width 3;
