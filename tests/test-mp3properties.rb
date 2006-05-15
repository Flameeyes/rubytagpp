# This test will check that the mp3 properties read from the file 
# correspond to the ones asked to lame

require "rubytagpp"
require "converters"

cvt = MP3Converter.new(false, true)

file = TagLib::MPEG::File.new(cvt.path)
exit -3 unless file.open?

puts "File audio properties are #{file.audio_properties.class} (should be TagLib::MPEG::Properties)"
exit -4 if file.audio_properties and not file.audio_properties.is_a?(TagLib::MPEG::Properties)

puts %@
	Sample Rate: #{file.audio_properties.sample_rate} (should be #{Converter::SAMPLE_RATE})
	Channels: #{file.audio_properties.channels} (should be #{Converter::CHANNELS})
	Length: #{file.audio_properties.length} (should be #{Converter::LENGTH})
	Bitrate: #{file.audio_properties.bitrate} (should be #{MP3Converter::BITRATE})
	Version: #{file.audio_properties.version} (just informational)
	Layer: #{file.audio_properties.layer} (should be #{MP3Converter::LAYER})
	Protection: #{file.audio_properties.protection_enabled} (should be #{MP3Converter::PROTECTION})
	Copyrighted: #{file.audio_properties.copyrighted?} (should be #{MP3Converter::COPYRIGHTED})
	Original: #{file.audio_properties.original?} (should be #{MP3Converter::ORIGINAL})
@

exit -5 if file.audio_properties.sample_rate != Converter::SAMPLE_RATE or \
	file.audio_properties.channels != Converter::CHANNELS or \
	file.audio_properties.length != Converter::LENGTH or \
	file.audio_properties.bitrate != MP3Converter::BITRATE or \
	file.audio_properties.layer != MP3Converter::LAYER or \
	file.audio_properties.protection_enabled != MP3Converter::PROTECTION or \
	file.audio_properties.copyrighted? != MP3Converter::COPYRIGHTED or \
	file.audio_properties.original? != MP3Converter::ORIGINAL

exit 0
