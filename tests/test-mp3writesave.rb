# Test n. 5, simple test of saving data from and reading it to an mp3 file

require "rubytagpp"
require "tempfile"

TEST_TITLE = "This is a test"
TEST_ALBUM = "Run your little test"
TEST_ARTIST = "The Testers"
TEST_TRACK = 1

# First of all, create a temporary file
@tmp = Tempfile.new("rubytag-test-mp3writesave.mp3")
@tmp.close

def doexit(ret = 0)
    @tmp.unlink
    exit ret
end

# Convert the compressed wave in mp3
doexit(-1) unless system("bzcat #{ARGV[0]} | lame -f - #{@tmp.path}")

savefile = TagLib::MPEG::File.new(@tmp.path)
doexit(-2) unless savefile.open?
doexit(-3) if savefile.read_only?

savefile.tag.title = TEST_TITLE
savefile.tag.album = TEST_ALBUM
savefile.tag.artist = TEST_ARTIST
savefile.tag.track = TEST_TRACK

savefile.save

readfile = TagLib::MPEG::File.new(@tmp.path)
doexit(-4) unless readfile.open?
doexit(-5) unless \
	readfile.tag.title == TEST_TITLE and \
	readfile.tag.album == TEST_ALBUM and \
	readfile.tag.artist == TEST_ARTIST

doexit
