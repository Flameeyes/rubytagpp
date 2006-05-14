# Test n. 7, simple test of getting data out of a flac file

require "rubytagpp"
require "converters"

cvt = FlacConverter.new

file = TagLib::FLAC::File.new(cvt.path)
exit -3 unless file.open?

if file.tag
   puts "File base tag is #{file.tag.class} (should be one of TagLib::Ogg::XiphComment::Tag, TagLib::ID3v1::Tag, TagLib::ID3v2::Tag or TagLib::Tag)"

   exit -5 if not ( file.tag.is_a?(TagLib::Ogg::XiphComment::Tag) or \
      file.tag.is_a?(TagLib::ID3v1::Tag) or \
      file.tag.is_a?(TagLib::ID3v2::Tag) or \
      file.tag.is_a?(TagLib::Tag))
else
   puts "No base tag"
end

if file.xiph_comment
   puts "File Xiph Comment tag is #{file.xiph_comment.class} (should be TagLib::Ogg::XiphComment::Tag)"
   exit -6 if not file.xiph_comment.is_a?(TagLib::Ogg::XiphComment::Tag)
else
   puts "No Xiph Comment"
end

if file.ID3v1Tag
   puts "File ID3v1 tag is #{file.ID3v1Tag.class} (should be TagLib::ID3v1::Tag)"
   exit -7 if not file.ID3v1Tag.is_a?(TagLib::ID3v1::Tag)
else
   puts "No ID3v1 Tag"
end

if file.ID3v2Tag
   puts "File ID3v2 tag is #{file.ID3v2Tag.class} (should be TagLib::ID3v2::Tag)"
   exit -8 if not file.ID3v2Tag.is_a?(TagLib::ID3v2::Tag)
else
   puts "No ID3v2 Tag"
end

exit 0

# kate: encoding UTF-8; remove-trailing-space on; replace-trailing-space-save on; space-indent on; indent-width 3;
