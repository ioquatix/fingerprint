# Copyright (c) 2010 Samuel Williams. Released under the GNU GPLv3.
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
# 
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
# 
# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.

require 'stringio'
require 'find'
require 'digest'

module Fingerprint
  
  class Scanner
    def initialize(dirs)
      @dirs = dirs
      @dirs << Dir.pwd if dirs.size == 0
      
      @excludes = [/^\._/]
      
      @output = StringIO.new
    end

    def output_dir(path)
      @output.puts ""
      @output.puts((" " * 32) + "  #{path}")
    end

    def output_file(path)
      d = Digest::MD5.new

      File.open(path) do |f|
        while buf = f.read(1024*1024*10)
          d << buf
        end
      end

      @output.puts "#{d.hexdigest}: #{path}"
    end
    
    def excluded?(path)
      @excludes.each do |exclusion|
        if exclusion.match(path)
          return true
        end
      end
      
      return false
    end

    def process
      for dir in @dirs
        Dir.chdir(dir) do
          Find.find("./") do |path|
            if FileTest.directory?(path)
              if excluded?(path)
                Find.prune # Ignore this directory
              else
                output_dir(path)
              end
            else
              output_file(path) unless excluded?(path)
            end
          end
        end # Dir.chdir
      end
    end
    
    attr :output, true
    
    def self.scan_dirs(dirs, output = $stdout)
      scanner = Scanner.new(dirs)
      scanner.output = output
      
      scanner.process
    end
  end
end