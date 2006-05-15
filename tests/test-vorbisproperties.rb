# This test will check that the Ogg Vorbis properties read from the file 
# correspond to the ones asked to oggenc.

require "rubytagpp"
require "converters"

cvt = VorbisConverter.new(false, true)

file = TagLib::Ogg::Vorbis::File.new(cvt.path)
exit -3 unless file.open?

puts "File audio properties are #{file.audio_properties.class} (should be TagLib::Vorbis::Properties)"
exit -4 if file.audio_properties and not file.audio_properties.is_a?(TagLib::Vorbis::Properties)

puts %@
	Sample Rate: #{file.audio_properties.sample_rate} (should be #{Converter::SAMPLE_RATE})
	Channels: #{file.audio_properties.channels} (should be #{Converter::CHANNELS})
	Length: #{file.audio_properties.length} (should be #{Converter::LENGTH})
	Maximum bitrate: #{file.audio_properties.bitrate_maximum} (should be #{VorbisConverter::MAXIMUM_BITRATE*1000})
	Minimum bitrate: #{file.audio_properties.bitrate_minimum} (should be #{VorbisConverter::MINIMUM_BITRATE*1000})
@

# oggenc takes bitrates in kbps, while taglib returns them in bps, take this into account!
exit -5 if file.audio_properties.sample_rate != Converter::SAMPLE_RATE or \
	file.audio_properties.channels != Converter::CHANNELS or \
	file.audio_properties.length != Converter::LENGTH or \
	file.audio_properties.bitrate_maximum != VorbisConverter::MAXIMUM_BITRATE*1000 or \
	file.audio_properties.bitrate_minimum != VorbisConverter::MINIMUM_BITRATE*1000

exit 0
