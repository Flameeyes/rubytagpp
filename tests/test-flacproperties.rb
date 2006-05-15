# This test will check that the Ogg Vorbis properties read from the file 
# correspond to the ones asked to oggenc.

require "rubytagpp"
require "converters"

cvt = FlacConverter.new(false)

file = TagLib::FLAC::File.new(cvt.path)
exit -3 unless file.open?

puts "File audio properties are #{file.audio_properties.class} (should be TagLib::FLAC::Properties)"
exit -4 if file.audio_properties and not file.audio_properties.is_a?(TagLib::FLAC::Properties)

puts %@
	Sample Rate: #{file.audio_properties.sample_rate} (should be #{Converter::SAMPLE_RATE})
	Channels: #{file.audio_properties.channels} (should be #{Converter::CHANNELS})
	Length: #{file.audio_properties.length} (should be #{Converter::LENGTH})
	Sample Width: #{file.audio_properties.sample_width} (just information)
@

# oggenc takes bitrates in kbps, while taglib returns them in bps, take this into account!
exit -5 if file.audio_properties.sample_rate != Converter::SAMPLE_RATE or \
	file.audio_properties.channels != Converter::CHANNELS or \
	file.audio_properties.length != Converter::LENGTH

exit 0
