# This test will check that the musepack properties read from the file 
# correspond to the ones asked to lame

require "rubytagpp"
require "converters"

cvt = MPCConverter.new

file = TagLib::MPC::File.new(cvt.path)
exit -3 unless file.open?

puts "File audio properties are #{file.audio_properties.class} (should be TagLib::MPC::Properties)"
exit -4 if file.audio_properties and not file.audio_properties.is_a?(TagLib::MPC::Properties)

puts %@
	Sample Rate: #{file.audio_properties.sample_rate} (should be #{Converter::SAMPLE_RATE})
	Channels: #{file.audio_properties.channels} (should be #{Converter::CHANNELS})
	Length: #{file.audio_properties.length} (should be #{Converter::LENGTH})
	MPC version: #{file.audio_properties.mpc_version} (just informational)
@

exit -5 if file.audio_properties.sample_rate != Converter::SAMPLE_RATE or \
	file.audio_properties.channels != Converter::CHANNELS or \
	file.audio_properties.length != Converter::LENGTH

exit 0
