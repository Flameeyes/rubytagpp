# Simple test of getting data out of an MPC file

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
doexit(-5) if file.tag and not ( file.tag.is_a?(TagLib::APE::Tag) or file.tag.is_a?(TagLib::ID3v1::Tag) )
doexit(-6) if file.APETag and not file.APETag.is_a?(TagLib::APE::Tag)
doexit(-7) if file.ID3v1Tag and not file.ID3v1Tag.is_a?(TagLib::ID3v1::Tag)

doexit
