# Simple test n. 1: try to decompress the wave, if it's not present or it's
# broken, this will fail and allow to understand why the following tests will
# fail, too

exit system("bzcat #{ARGV[0]} > /dev/null")
