# Flameeyes's RubyTag++ Test suite
# Copyright (C) 2006, Diego "Flameeyes" Pettenò
#
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 2 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program; if not, write to the Free Software
# Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA

require "tempfile"

# Simple custom tempfile class that respect the given extension for the file.
# needed for a few things in the test suite.
class CustomTempfile < Tempfile
   def initialize(basename, extension, tmpdir=Dir::tmpdir)
      @extension = extension
      super(basename, tmpdir)
   end

   def make_tmpname(basename, n)
      sprintf('%s%d.%d.%s', basename, $$, n, @extension)
   end
end

class Converter
   TEST_TITLE = "This is a test"
   TEST_ALBUM = "Run your little test"
   TEST_ARTIST = "The Testers"
   TEST_COMMENT = "If you had not forseen this, this is a test file."
   TEST_TESTFIELD = "Noone knows about this"
   TEST_TRACK = 12

   # Specific of the emptywave.wav test file: 44.1KHz Stereo, 5 seconds length
   SAMPLE_RATE = 44100
   CHANNELS = 2
   LENGTH = 5

   def initialize(extension)
      @tmp = CustomTempfile.new("converter", extension)
      @tmp.close
   end

   def path
      @tmp.path
   end
end

class MP3Converter < Converter
   BITRATE = 128
   LAYER = 3
   PROTECTION = false
   COPYRIGHTED = false
   ORIGINAL = false
   CHANNEL_MODE = TagLib::MPEG::Header::Stereo

   def initialize(tag = true, bitrates = false)
      super("mp3")

      extraopts = ""

      extraopts = "#{extraopts} --tt '#{TEST_TITLE}' --ta '#{TEST_ARTIST}' --tl '#{TEST_ALBUM}' --tn '#{TEST_TRACK}'" \
         if tag

      extraopts = "#{extraopts} -b #{BITRATE}" \
         if bitrates

      exit -1 if not system("bzcat #{ARGV[0]} | lame #{extraopts} -f - #{@tmp.path}")
   end
end

class MPCConverter < Converter
   def initialize
      super("mpc")
      tmpwav = CustomTempfile.new("converter", "wav")
      tmpwav.close
      exit -1 unless system("bzcat #{ARGV[0]} > #{tmpwav.path} && mppenc --overwrite --thumb #{tmpwav.path} #{@tmp.path}")
      tmpwav.unlink
   end
end

class VorbisConverter < Converter
   MINIMUM_BITRATE = 234
   MAXIMUM_BITRATE = 16

   def initialize(tag = true, bitrates = false)
      super("ogg")

      extraopts = ""

      extraopts = "#{extraopts} -c 'COMMENT=#{TEST_COMMENT}' -t '#{TEST_TITLE}' -l '#{TEST_ALBUM}' -a '#{TEST_ARTIST}' -c 'TESTFIELD=#{TEST_TESTFIELD}'" \
         if tag

      extraopts = "#{extraopts} -m #{MINIMUM_BITRATE} -M #{MAXIMUM_BITRATE}" \
         if bitrates

      exit -1 if not system("bzcat #{ARGV[0]} | oggenc - -o #{@tmp.path} #{extraopts}")
   end
end

class FlacConverter < Converter
   def initialize(tag = true)
      super( @ogg ? "ogg" : "flac" )

      extraopts = ""

      extraopts = "#{extraopts} --ogg" if @ogg

      extraopts = "#{extraopts} --tag=Comment=\"#{TEST_COMMENT}\" --tag=Title=\"#{TEST_TITLE}\" --tag=Album=\"#{TEST_ALBUM}\" --tag=Artist=\"#{TEST_ARTIST}\" --tag=Testfield=\"#{TEST_TESTFIELD}\"" \
         if tag

      exit -1 unless system("bzcat #{ARGV[0]} | flac -f -s #{extraopts} -o #{@tmp.path} - 2>/dev/null")
   end
end

class OggFlacConverter < FlacConverter
   def initialize(tag = true)
      @ogg = true
      super(tag)
   end
end

# kate: encoding UTF-8; remove-trailing-space on; replace-trailing-space-save on; space-indent on; indent-width 3;
