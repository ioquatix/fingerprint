# Copyright (c) 2011 Samuel G. D. Williams. <http://www.oriontransfer.co.nz>
# 
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
# 
# The above copyright notice and this permission notice shall be included in
# all copies or substantial portions of the Software.
# 
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
# THE SOFTWARE.

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