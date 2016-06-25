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

require_relative '../checker'
require_relative '../record'

module Fingerprint
	module Command
		class Verify < Samovar::Command
			self.description = "Check an existing fingerprint against the filesystem."
			
			options do
				option "-n/--name <name>", "The fingerprint file name.", default: INDEX_FINGERPRINT
				
				option "-f/--force", "Force all operations to complete despite warnings."
				option "-x/--extended", "Include extended information about files and directories."
				
				option "-s/--checksums <MD5,SHA1>", "Specify what checksum algorithms to use (#{Fingerprint::CHECKSUMS.keys.join(', ')}).", default: Fingerprint::DEFAULT_CHECKSUMS
				
				option "--progress", "Print structured progress to standard error."
				option "--verbose", "Verbose fingerprint output, e.g. excluded paths."
				
				option "--fail-on-errors", "Exit with non-zero status if errors are encountered."
			end
			
			many :paths, "Paths relative to the root to use for verification, or ./ if not specified."
			
			def invoke(parent)
				@paths = ["./"] if @paths.empty?

				input_file = @options[:name]

				unless File.exist? input_file
					abort "Can't find index #{input_file}. Aborting."
				end

				options = @options.dup
				options[:output] = $stdout

				master = RecordSet.new

				File.open(input_file, "r") do |io|
					master.parse(io)
				end

				if master.configuration
					options.merge!(master.configuration.options)
				end

				scanner = Scanner.new(@paths, options)
				
				# We use a sparse record set here, so we can't check for additions.
				copy = SparseRecordSet.new(scanner)

				error_count = Checker.verify(master, copy, options)
				
				if @options[:fail_on_errors]
					abort "Data inconsistent, #{error_count} error(s) found!" if error_count != 0
				end
			end
		end
	end
end
