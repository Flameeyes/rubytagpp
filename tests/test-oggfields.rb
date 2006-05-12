# Test n. 6, simple test of getting data out of an ogg file with the raw fields
# list

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

# Convert the compressed wave in ogg/vorbis and set test tags
doexit(-1) unless system("bzcat #{ARGV[0]} | oggenc -q -1 - -o #{@tmp.path} -c 'COMMENT=#{TEST_COMMENT}' -t '#{TEST_TITLE}' -l '#{TEST_ALBUM}' -a '#{TEST_ARTIST}' -c 'TESTFIELD=#{TEST_TESTFIELD}'")

file = TagLib::Ogg::Vorbis::File.new(@tmp.path)
doexit(-3) unless file.open?
doexit(-4) unless \
	file.tag.fieldListMap["TITLE"][0] == TEST_TITLE and \
	file.tag.fieldListMap["ALBUM"][0] == TEST_ALBUM and \
	file.tag.fieldListMap["ARTIST"][0] == TEST_ARTIST and \
	file.tag.fieldListMap["COMMENT"][0] == TEST_COMMENT and \
	file.tag.fieldListMap["TESTFIELD"][0] == TEST_TESTFIELD

doexit
