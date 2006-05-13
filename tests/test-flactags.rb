# Test n. 7, simple test of getting data out of a flac file

require "rubytagpp"
require "tempfile"

TEST_TITLE = "This is a test"
TEST_ALBUM = "Run your little test"
TEST_ARTIST = "The Testers"
TEST_COMMENT = "If you had not forseen this, this is a test file."

# First of all, create a temporary file
@tmp = Tempfile.new("rubytag-test-flacbasic.flac")
@tmp.close

def doexit(ret = 0)
    @tmp.unlink
    exit ret
end

# Convert the compressed wave in mp3 and set test tags
doexit(-1) unless system("bzcat #{ARGV[0]} | flac -f --tag=Comment=\"#{TEST_COMMENT}\" --tag=Title=\"#{TEST_TITLE}\" --tag=Album=\"#{TEST_ALBUM}\" --tag=Artist=\"#{TEST_ARTIST}\" -s -o #{@tmp.path} - 2>/dev/null")

file = TagLib::FLAC::File.new(@tmp.path)
doexit(-3) unless file.open?

if file.tag
   puts "File base tag is #{file.tag.class} (should be one of TagLib::Ogg::XiphComment::Tag, TagLib::ID3v1::Tag, TagLib::ID3v2::Tag or TagLib::Tag)"

   doexit(-5) if not ( file.tag.is_a?(TagLib::Ogg::XiphComment::Tag) or \
      file.tag.is_a?(TagLib::ID3v1::Tag) or \
      file.tag.is_a?(TagLib::ID3v2::Tag) or \
      file.tag.is_a?(TagLib::Tag))
else
   puts "No base tag"
end

if file.xiph_comment
   puts "File Xiph Comment tag is #{file.xiph_comment.class} (should be TagLib::Ogg::XiphComment::Tag)"
   doexit(-6) if not file.xiph_comment.is_a?(TagLib::Ogg::XiphComment::Tag)
else
   puts "No Xiph Comment"
end

if file.ID3v1Tag
   puts "File ID3v1 tag is #{file.ID3v1Tag.class} (should be TagLib::ID3v1::Tag)"
   doexit(-7) if not file.ID3v1Tag.is_a?(TagLib::ID3v1::Tag)
else
   puts "No ID3v1 Tag"
end

if file.ID3v2Tag
   puts "File ID3v2 tag is #{file.ID3v2Tag.class} (should be TagLib::ID3v2::Tag)"
   doexit(-8) if not file.ID3v2Tag.is_a?(TagLib::ID3v2::Tag)
else
   puts "No ID3v2 Tag"
end

doexit

# kate: encoding UTF-8; remove-trailing-space on; replace-trailing-space-save on; space-indent on; indent-width 3;
