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
	# Given two fingerprints (master and copy) ensures that the copy has at least everything contained
	# in master: For every file in the master, a corresponding file must exist in the copy. This means that
	# there may be extraneous files in the copy, but ensures that every file in the master has been replicated
	# accurately.
	#
	# At this time, this implementation may require a large amount of memory, proportional to the number of
	# files being checked.
	#
	# Master and copy are +IO+ objects corresponding to the output produced by +Fingerprint::Scanner+.
	class Checker
		def initialize(master, copy, options = {})
			@master = master
			@copy = copy
			
			@mismatches = []
			
			@options = options
			
			@failures = []
		end

		# Run the checking process.
		def check (options = {}, &block)
			@files = Set.new
			@file_paths = {}
			@file_hashes = {}

			# Parse original fingerprint
			@copy.each_line do |line|
				# Skip comments
				next if line.match(/^\s+#/)
				
				if line.chomp.match(/^([a-fA-F0-9]{32}): (.*)$/)
					@files.add([$1, $2])

					@file_paths[$2] = $1
					@file_hashes[$1] ||= Set.new
					@file_hashes[$1].add($2)
				end
			end

			# For every file in the src, we check that it exists
			# in the destination:
			@master.each_line do |line|
				# Skip comments
				next if line.match(/^\s+#/)
				
				if line.chomp.match(/^([a-fA-F0-9]{32}): (.*)$/)
					unless @files.include?([$1, $2])
						yield($1, $2) if block_given?
						@failures << [$1, $2]
					end
				end
			end
		end
		
		# A list of files which either did not exist in the copy, or had the wrong checksum.
		attr :failures
		
		# An array of all files in the copy
		attr :files
		
		# A hash of all files in copy +path => file hash+
		attr :file_paths
		
		# A hash of all files in copy +file hash => [file1, file2, ...]+
		attr :file_hashes

		# Helper function to check two fingerprint files.
		def self.check_files(master, copy, &block)
			error_count = 0 
			
			master = File.open(master) unless master.respond_to? :read
			copy = File.open(copy) unless copy.respond_to? :read
			
			checker = Checker.new(master, copy)

			checker.check do |hash, path|
				error_count += 1

				if !checker.file_paths[path]
					$stderr.puts "File #{path.dump} is missing!"
				elsif checker.file_paths[path] != hash
					$stderr.puts "File #{path.dump} is different!"
				else
					$stderr.puts "Unknown error for path #{path.dump}"
				end
			end

			return error_count
		end

	end
end
