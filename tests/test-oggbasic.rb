# Simple test of getting data out of an ogg file

require "rubytagpp"
require "tempfile"

TEST_TITLE = "This is a test"
TEST_ALBUM = "Run your little test"
TEST_ARTIST = "The Testers"
TEST_COMMENT = "If you had not forseen this, this is a test file."

# First of all, create a temporary file
@tmp = Tempfile.new("rubytag-test-oggbasic.ogg")
@tmp.close

def doexit(ret = 0)
    @tmp.unlink
    exit ret
end

# Convert the compressed wave in ogg/vorbis and set test tags
doexit(-1) unless system("bzcat #{ARGV[0]} | oggenc -q -1 - -o #{@tmp.path} -c 'COMMENT=#{TEST_COMMENT}' -t '#{TEST_TITLE}' -l '#{TEST_ALBUM}' -a '#{TEST_ARTIST}'")

file = TagLib::Ogg::Vorbis::File.new(@tmp.path)
doexit(-3) unless file.open?
doexit(-4) unless \
	file.tag.title == TEST_TITLE and \
	file.tag.album == TEST_ALBUM and \
	file.tag.artist == TEST_ARTIST and \
	file.tag.comment == TEST_COMMENT

doexit
