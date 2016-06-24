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
require 'fileutils'

require_relative '../scanner'
require_relative '../record'

module Fingerprint
	module Command
		class Analyze < Samovar::Command
			self.description = "Scan the filesystem and generate a fingerprint."
			
			POSSIBLE_CHECKSUMS = CHECKSUMS.keys.join(', ')
			
			options do
				option "-n/--name <name>", "The fingerprint file name.", default: "index.fingerprint"
				option "-p/--path <path>", "Analyze the given path relative to root.", default: "./"
				
				option "-f/--force", "Force all operations to complete despite warnings."
				option "-x/--extended", "Include extended information about files and directories."
				option "-s/--checksums <MD5,SHA1>", "Specify what checksum algorithms to use: #{POSSIBLE_CHECKSUMS}.", default: DEFAULT_CHECKSUMS
				
				option "--progress", "Print structured progress to standard error."
				option "--verbose", "Verbose fingerprint output, e.g. excluded paths."
			end
			
			def invoke(parent)
				output_file = @options[:name]

				if File.exist?(output_file) and !@options[:force]
					abort "Output file #{output_file} already exists. Aborting."
				end

				options = @options.dup
				options[:excludes] = [options[:name]]

				finished = false
				begin
					File.open(output_file, "w") do |io|
						options[:output] = io

						Scanner.scan_paths([@options[:path]], options)
					end
					finished = true
				ensure
					FileUtils.rm(output_file) unless finished
				end	
			end
		end
	end
end
