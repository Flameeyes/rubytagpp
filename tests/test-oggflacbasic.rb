# Simple test of getting data out of an Ogg FLAC file

require "rubytagpp"
require "tempfile"

TEST_TITLE = "This is a test"
TEST_ALBUM = "Run your little test"
TEST_ARTIST = "The Testers"
TEST_COMMENT = "If you had not forseen this, this is a test file."

# First of all, create a temporary file
@tmp = Tempfile.new("rubytag-test-oggflacbasic.ogg")
@tmp.close

def doexit(ret = 0)
    @tmp.unlink
    exit ret
end

# Convert the compressed wave in mp3 and set test tags
doexit(-1) unless system("bzcat #{ARGV[0]} | flac --ogg -f --tag=Comment=\"#{TEST_COMMENT}\" --tag=Title=\"#{TEST_TITLE}\" --tag=Album=\"#{TEST_ALBUM}\" --tag=Artist=\"#{TEST_ARTIST}\" -s -o #{@tmp.path} - 2>/dev/null")

file = TagLib::Ogg::FLAC::File.new(@tmp.path)
doexit(-3) unless file.open?

doexit(-4) unless file.tag

puts %@
	Title: "#{file.tag.title}" (should be "#{TEST_TITLE}")
	Album: "#{file.tag.album}" (should be "#{TEST_ALBUM}")
	Artist: "#{file.tag.artist}" (should be "#{TEST_ARTIST}")
	Comment: "#{file.tag.comment}" (should be "#{TEST_COMMENT}")
@

doexit(-5) unless \
	file.tag.title == TEST_TITLE and \
	file.tag.album == TEST_ALBUM and \
	file.tag.artist == TEST_ARTIST and \
	file.tag.comment == TEST_COMMENT

doexit
