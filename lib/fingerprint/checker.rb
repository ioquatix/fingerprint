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
