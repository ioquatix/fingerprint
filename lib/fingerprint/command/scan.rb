# Copyright, 2016, by Samuel G. D. Williams. <http://www.codeotaku.com>
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

# This script takes a given path, and renames it with the given format. 
# It then ensures that there is a symlink called "latest" that points 
# to the renamed directory.

require 'samovar'

require_relative '../scanner'
require_relative '../record'

module Fingerprint
	module Command
		class Scan < Samovar::Command
			self.description = "Check an existing fingerprint against the filesystem."
			
			options do
				option "-p/--path <path>", "Analyze the given path relative to root.", default: "./"
				
				option "-x/--extended", "Include extended information about files and directories."
				option "-s/--checksums <MD5,SHA1>", "Specify what checksum algorithms to use (#{Fingerprint::CHECKSUMS.keys.join(', ')}).", default: Fingerprint::DEFAULT_CHECKSUMS
			end
			
			many :paths, "Paths to scan."
			
			def invoke(parent)
				@paths = [Dir.pwd] if @paths.empty?
				
				options = @options.dup
				
				# This configuration ensures that the output is printed to $stdout.
				options[:output] = $stdout
				options[:recordset] = nil
				
				Fingerprint::Scanner.scan_paths(@paths, options)
			end
		end
	end
end
