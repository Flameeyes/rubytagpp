# Simple test of getting data out of an MPC file

require "rubytagpp"
require "custom-tmpfile"

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

# Convert the compressed wave in mpc and set test tags
@tmp = CustomTempfile.new("rubytag-test-mpcbasic", "mpc")
tmpwav = CustomTempfile.new("rubytag-test-mpcbasic", "wav")
@tmp.close
tmpwav.close
doexit(-21) unless system("bzcat #{ARGV[0]} > #{tmpwav.path} && mppenc --overwrite --thumb #{tmpwav.path}")
tmpwav.unlink

file = TagLib::MPC::File.new(@tmp.path)
doexit(-3) unless file.open?
doexit(-4) unless \
	file.tag.title == TEST_TITLE and \
	file.tag.album == TEST_ALBUM and \
	file.tag.artist == TEST_ARTIST

doexit
