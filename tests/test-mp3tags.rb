# Test correctness of tagging in mp3 files.
# As mp3 files can have more than one tag and more than one tag format, this
# test will check for them to be returned of the right type

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

if file.tag
   puts "File base tag is #{file.tag.class} (should be one of TagLib::APE::Tag, TagLib::ID3v1::Tag, TagLib::ID3v2::Tag or TagLib::Tag)"

   doexit(-5) if not ( file.tag.is_a?(TagLib::APE::Tag) or \
      file.tag.is_a?(TagLib::ID3v1::Tag) or \
      file.tag.is_a?(TagLib::ID3v2::Tag) or \
      file.tag.is_a?(TagLib::Tag))
end

if file.APETag
   puts "File APE tag is #{file.APETag.class} (should be TagLib::APE::Tag)"
   doexit(-6) if not file.APETag.is_a?(TagLib::APE::Tag)
end

if file.APETag
   puts "File ID3v1 tag is #{file.ID3v1Tag.class} (should be TagLib::ID3v1::Tag)"
   doexit(-7) if not file.ID3v1Tag.is_a?(TagLib::ID3v1::Tag)
end

if file.APETag
   puts "File ID3v2 tag is #{file.ID3v2Tag.class} (should be TagLib::ID3v2::Tag)"
   doexit(-8) if not file.ID3v2Tag.is_a?(TagLib::ID3v2::Tag)
end

doexit(-9) if file.audioProperties and not file.audioProperties.is_a?(TagLib::MPEG::Properties)

doexit

# kate: encoding UTF-8; remove-trailing-space on; replace-trailing-space-save on; space-indent on; indent-width 3;
