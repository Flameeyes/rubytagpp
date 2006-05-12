# Test of FileRef working. This will simply create a series of temporary files
# and then check with FileRef.new if they get the right type assigned.

require "rubytagpp"
require "custom-tmpfile"

def doexit(ret = 0)
    @tmp.unlink
    exit ret
end

# First pass: mp3 file
@tmp = CustomTempfile.new("rubytag-test-fileref", "mp3")
@tmp.close
doexit(-1) unless system("bzcat #{ARGV[0]} | lame -f - #{@tmp.path}")

fref = TagLib::FileRef.new(@tmp.path)
doexit(-2) unless fref.file.open?
doexit(-3) unless fref.file.is_a?(TagLib::MPEG::File)

@tmp.unlink

# Second pass: Ogg Vorbis file
@tmp = CustomTempfile.new("rubytag-test-fileref", "ogg")
@tmp.close
doexit(-11) unless system("bzcat #{ARGV[0]} | oggenc -q -1 - -o #{@tmp.path}")

fref = TagLib::FileRef.new(@tmp.path)
doexit(-12) unless fref.file.open?
doexit(-13) unless fref.file.is_a?(TagLib::Ogg::Vorbis::File)

@tmp.unlink

# Third pass: Musepack file
@tmp = CustomTempfile.new("rubytag-test-fileref", "mpc")
tmpwav = CustomTempfile.new("rubytag-test-fileref", "wav")
@tmp.close
tmpwav.close
doexit(-21) unless system("bzcat #{ARGV[0]} > #{tmpwav.path} && mppenc --overwrite --thumb #{tmpwav.path}")
tmpwav.unlink

fref = TagLib::FileRef.new("#{@tmp.path}")
doexit(-22) unless fref.file.open?
doexit(-23) unless fref.file.is_a?(TagLib::MPC::File)

doexit
