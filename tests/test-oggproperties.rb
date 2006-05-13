# This test will check that the Ogg Vorbis properties read from the file 
# correspond to the ones asked to oggenc.

require "rubytagpp"
require "tempfile"

MAXIMUM_BITRATE = 234
MINIMUM_BITRATE = 20

# First of all, create a temporary file
@tmp = Tempfile.new("rubytag-test-oggbasic.ogg")
@tmp.close

def doexit(ret = 0)
    @tmp.unlink
    exit ret
end

# Convert the compressed wave in ogg/vorbis and set test tags
doexit(-1) unless system("bzcat #{ARGV[0]} | oggenc -q -1 - -o #{@tmp.path} -m #{MINIMUM_BITRATE} -M #{MAXIMUM_BITRATE}")

file = TagLib::Ogg::Vorbis::File.new(@tmp.path)
doexit(-3) unless file.open?
doexit(-4) if file.audio_properties and not file.audio_properties.is_a?(TagLib::Vorbis::Properties)

puts %@
	Maximum bitrate: #{file.audio_properties.bitrate_maximum} (should be #{MAXIMUM_BITRATE*1000})
	Minimum bitrate: #{file.audio_properties.bitrate_minimum} (should be #{MINIMUM_BITRATE*1000})
@

# oggenc takes bitrates in kbps, while taglib returns them in bps, take this into account!
doexit(-5) if file.audio_properties.bitrate_maximum != MAXIMUM_BITRATE*1000 or \
	file.audio_properties.bitrate_minimum != MINIMUM_BITRATE*1000

doexit
