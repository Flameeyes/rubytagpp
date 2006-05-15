# Simple test to make sure that the render funciton of ID3v1 tags is reporting
# correctly a string as type

require "rubytagpp"
require "converters"

cvt = MP3Converter.new

file = TagLib::MPEG::File.new(cvt.path)
exit -3 unless file.open?

unless file.ID3v1Tag
   puts "	Unable to find ID3v1 tag needed."
   exit -4
end

puts "	Rendered tag is #{file.ID3v1Tag.render.class} (should be String)"

exit -5 if not file.ID3v1Tag.render.is_a?(String)

exit 0

# kate: encoding UTF-8; remove-trailing-space on; replace-trailing-space-save on; space-indent on; indent-width 3;