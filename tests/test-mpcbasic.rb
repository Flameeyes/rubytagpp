# Simple test of getting data out of an MPC file

require "rubytagpp"
require "converters"

cvt = MPCConverter.new

file = TagLib::MPC::File.new(cvt.path)
exit -3 unless file.open?

exit -9 if file.audioProperties and not file.audioProperties.is_a?(TagLib::MPC::Properties)

exit 0
