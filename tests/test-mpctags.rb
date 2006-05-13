# Test correctness of tagging in mpc files.
# As mpc files can have more than one tag and more than one tag format, this
# test will check for them to be returned of the right type

require "rubytagpp"
require "custom-tmpfile"

def doexit(ret = 0)
    @tmp.unlink
    exit ret
end

# Convert the compressed wave in mpc
@tmp = CustomTempfile.new("rubytag-test-mpcbasic", "mpc")
tmpwav = CustomTempfile.new("rubytag-test-mpcbasic", "wav")
@tmp.close
tmpwav.close
doexit(-21) unless system("bzcat #{ARGV[0]} > #{tmpwav.path} && mppenc --overwrite --thumb #{tmpwav.path}")
tmpwav.unlink

file = TagLib::MPC::File.new(@tmp.path)
doexit(-3) unless file.open?

if file.tag
   puts "File base tag is #{file.tag.class} (should be one of TagLib::APE::Tag, TagLib::ID3v1::Tag or TagLib::Tag)"

   doexit(-5) if not ( file.tag.is_a?(TagLib::APE::Tag) or \
      file.tag.is_a?(TagLib::ID3v1::Tag) or \
      file.tag.is_a?(TagLib::Tag))
end

if file.APETag
   puts "File APE tag is #{file.APETag.class} (should be TagLib::APE::Tag)"
   doexit(-6) if not file.APETag.is_a?(TagLib::APE::Tag)
end

if file.ID3v1Tag
   puts "File ID3v1 tag is #{file.ID3v1Tag.class} (should be TagLib::ID3v1::Tag)"
   doexit(-7) if not file.ID3v1Tag.is_a?(TagLib::ID3v1::Tag)
end


doexit
