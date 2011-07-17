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

require 'set'

module Fingerprint
  # Check that every file specified in fp2 exists in fp1 correctly,
  # i.e. ensure that the fingerprint fp2 accurately is a superset of
  # fp1
  class Checker
    def initialize(fp1, fp2)
      @fp1 = fp1
      @fp2 = fp2
      @mismatches = []
    end
    
    def check (&block)
      @fp1.seek(0)
      @fp2.seek(0)
      
      @dst = Set.new
      @dst_paths = {}
      @dst_hashes = {}
      
      # Parse original fingerprint
      @fp2.each_line do |line|
        if line.chomp.match(/^([a-fA-F0-9]{32}): (.*)$/)
          @dst.add([$1, $2])

          @dst_paths[$2] = $1
          @dst_hashes[$1] ||= Set.new
          @dst_hashes[$1].add($2)
        end
      end
      
      # For every file in the src, we check that it exists
      # in the destination:
      @fp1.each_line do |line|
        if line.chomp.match(/^([a-fA-F0-9]{32}): (.*)$/)
          yield($1, $2, self) unless dst.include?([$1, $2])
        end
      end
    end
    
    attr :dst
    attr :dst_paths
    attr :dst_hashes
    
    def self.check_files(p1, p2)
      puts "Comparing src: #{p1.dump} with dst: #{p2.dump}..."
      error_count = 0 
      checker = Checker.new(File.open(p1), File.open(p2))
      
      checker.check do |hash, path|
        error_count += 1
        
        if !checker.dst_paths[path]
          puts "Source file: #{path.dump} does not exist in destination!"
        elsif checker.dst_paths[path] != hash
          puts "Destination file: #{path.dump} is different!"
        else
          puts "Unknown error for path: #{path.dump}"
        end
      end
      
      return error_count
    end
    
  end
end
