# Test n. 3, simple test of getting data out of an mp3 file

require "rubytagpp"
require "tempfile"

TEST_TITLE = "This is a test"
TEST_ALBUM = "Run your little test"
TEST_ARTIST = "The Testers"
TEST_TRACK = 1

# First of all, create a temporary file
@tmp = Tempfile.new("rubytag-test-mp3basic.mp3")
@tmp.close

def doexit(ret = 0)
    @tmp.unlink
    exit ret
end

# Convert the compressed wave in mp3 and set test tags
doexit(-1) unless system("bzcat #{ARGV[0]} | lame -f - #{@tmp.path}")
doexit(-2) unless system("id3tool -t '#{TEST_TITLE}' -a '#{TEST_ALBUM}' -r '#{TEST_ARTIST}' #{@tmp.path}")

file = TagLib::MPEG::File.new(@tmp.path)
doexit(-3) unless file.open?
doexit(-4) unless \
	file.tag.title == TEST_TITLE and \
	file.tag.album == TEST_ALBUM and \
	file.tag.artist == TEST_ARTIST

doexit
