# Test correctness of tagging in mp3 files.
# As mp3 files can have more than one tag and more than one tag format, this
# test will check for them to be returned of the right type

require "rubytagpp"
require "converters"

cvt = MP3Converter.new

file = TagLib::MPEG::File.new(cvt.path)
exit -3 unless file.open?

if file.tag
   puts "File base tag is #{file.tag.class} (should be one of TagLib::APE::Tag, TagLib::ID3v1::Tag, TagLib::ID3v2::Tag or TagLib::Tag)"

   exit -5 if not ( file.tag.is_a?(TagLib::APE::Tag) or \
      file.tag.is_a?(TagLib::ID3v1::Tag) or \
      file.tag.is_a?(TagLib::ID3v2::Tag) or \
      file.tag.is_a?(TagLib::Tag))
end

if file.APETag
   puts "File APE tag is #{file.APETag.class} (should be TagLib::APE::Tag)"
   exit -6 if not file.APETag.is_a?(TagLib::APE::Tag)
end

if file.ID3v1Tag
   puts "File ID3v1 tag is #{file.ID3v1Tag.class} (should be TagLib::ID3v1::Tag)"
   exit -7 if not file.ID3v1Tag.is_a?(TagLib::ID3v1::Tag)
end

if file.ID3v2Tag
   puts "File ID3v2 tag is #{file.ID3v2Tag.class} (should be TagLib::ID3v2::Tag)"
   exit -8 if not file.ID3v2Tag.is_a?(TagLib::ID3v2::Tag)
end

exit 0

# kate: encoding UTF-8; remove-trailing-space on; replace-trailing-space-save on; space-indent on; indent-width 3;
