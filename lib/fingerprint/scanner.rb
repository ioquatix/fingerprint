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
require 'etc'
require 'digest/sha2'

require_relative 'find'
require_relative 'version'

module Fingerprint
	INDEX_FINGERPRINT = "index.fingerprint"
	
	CHECKSUMS = {
		'MD5' => lambda { Digest::MD5.new },
		'SHA1' => lambda { Digest::SHA1.new },
		'SHA2.256' => lambda { Digest::SHA2.new(256) },
		'SHA2.512' => lambda { Digest::SHA2.new(512) },
	}

	DEFAULT_CHECKSUMS = ['MD5', 'SHA2.256']

	# The scanner class can scan a set of directories and produce an index.
	class Scanner
		# Initialize the scanner to scan a given set of directories in order.
		# [+options[:excludes]+]  An array of regular expressions of files to avoid indexing.
		# [+options[:output]+]    An +IO+ where the results will be written.
		def initialize(roots, options = {})
			@roots = roots

			@excludes = options[:excludes] || []
			@options = options

			@digests = {}

			@progress = nil

			unless @options[:checksums] and @options[:checksums].size > 0
				@options[:checksums] = DEFAULT_CHECKSUMS
			end

			@options[:checksums].each do |name|
				@digests[name] = CHECKSUMS[name].call
			end

			@callback = nil
		end

		attr :recordset
		attr :digests

		protected

		# Adds a header for a given path which is mainly version information.
		def header_for(root)
			Record.new(:configuration, File.expand_path(root), {
				'options.extended' => @options[:extended] == true,
				'options.checksums' => @options[:checksums].join(', '),
				'summary.time.start' => Time.now,
				'fingerprint.version' => Fingerprint::VERSION
			})
		end

		# This code won't handle multiple threads..
		def digests_for(path)
			total = 0

			@digests.each do |key, digest|
				digest.reset
			end

			File.open(path, "rb") do |file|
				buf = ""
				while file.read(1024 * 1024 * 10, buf)
					total += buf.size
					
					@progress.call(total) if @progress
					
					@digests.each do |key, digest|
						digest << buf
					end
				end
			end

			metadata = {}
			
			@digests.each do |key, digest|
				metadata["key." + key] = digest.hexdigest
			end
			
			return metadata
		end

		def metadata_for(type, path)
			stat = File.stat(path)
			metadata = {}

			if type == :file
				metadata['file.size'] = stat.size
				digests = digests_for(path)
				metadata.merge!(digests)
			end

			# Extended information
			if @options[:extended]
				metadata['posix.time.modified'] = File.mtime(path)

				metadata['posix.mode'] = stat.mode.to_s(8)

				metadata['posix.permissions.user.id'] = stat.uid
				metadata['posix.permissions.user.name'] = Etc.getpwuid(stat.uid).name
				metadata['posix.permissions.group.id'] = stat.gid
				metadata['posix.permissions.group.name'] = Etc.getgrgid(stat.gid).name
			end

			return metadata
		end
		
		# Output a directory header.
		def directory_record_for(path)
			Record.new(:directory, path, metadata_for(:directory, path))
		end

		# Output a file and associated metadata.
		def file_record_for(path)
			metadata = metadata_for(:file, path)
			
			# Should this be here or in metadata_for?
			# metadata.merge!(digests_for(path))
			
			Record.new(:file, path, metadata)
		end

		# Add information about excluded paths.
		def excluded_record_for(path)
			Record.new(:excluded, path)
		end

		public
		
		# Returns true if the given path should be excluded.
		def excluded?(path)
			@excludes.each do |exclusion|
				if path.match(exclusion)
					return true
				end
			end

			return false
		end

		def valid_file?(path)
			!(excluded?(path) || File.symlink?(path) || !File.file?(path) || !File.readable?(path))
		end

		def scan_path(path)
			@roots.each do |root|
				# Dir.chdir(root) do
				if valid_file?(path)
					return file_record_for(path)
				end
			end
			
			return nil
		end



		# Run the scanning process.
		def scan(recordset)
			excluded_count = 0
			processed_count = 0
			processed_size = 0
			directory_count = 0

			total_count = 0
			total_size = 0

			# Estimate the number of files and amount of data to process..
			if @options[:progress]
				@roots.each do |root|
					Find.find(root) do |path|
						if @options[:progress]
							$stderr.puts "# Scanning: #{path}"
						end
						
						if File.directory?(path)
							if excluded?(path)
								Find.prune # Ignore this directory
							end
						else
							# Skip anything that isn't a valid file (e.g. pipes, sockets, symlinks).
							if valid_file?(path)
								total_count += 1
								total_size += File.size(path)
							end
						end
					end
				end
			end
			
			if @options[:progress]
				@progress = lambda do |read_size|
					$stderr.puts "# Progress: File #{processed_count} / #{total_count}; Byte #{processed_size + read_size} / #{total_size} = #{sprintf('%0.3f%', (processed_size + read_size).to_f / total_size.to_f * 100.0)} (#{read_size}, #{processed_size}, #{total_size})"
				end
			end
			
			@roots.each do |root|
				recordset << header_for(root)
				
				Find.find(root) do |path|
					if @options[:progress]
						$stderr.puts "# Path: #{path}"
					end
					
					if File.directory?(path)
						if excluded?(path)
							excluded_count += 1
							
							if @options[:verbose]
								recordset << excluded_record_for(path)
							end
							
							Find.prune # Ignore this directory
						else
							directory_count += 1
							
							recordset << directory_record_for(path)
						end
					else
						# Skip anything that isn't a valid file (e.g. pipes, sockets, symlinks).
						if valid_file?(path)
							recordset << file_record_for(path)

							processed_count += 1
							processed_size += File.size(path)
						else
							excluded_count += 1
							
							if @options[:verbose]
								recordset << excluded_record_for(path)
							end
						end
					end
					
					# Print out a progress summary if requested
					@progress.call(0) if @progress
				end
			end
			
			summary_message = "#{processed_count} files processed."

			# Output summary
			recordset << Record.new(:summary, summary_message, {
				'summary.directories' => directory_count,
				'summary.files' => processed_count,
				'summary.size' => processed_size,
				'summary.excluded' => excluded_count,
				'summary.time.end' => Time.now
			})
			
			return recordset
		end

		# A helper function to scan a set of directories.
		def self.scan_paths(paths, options = {})
			if options[:output]
				if options.key? :recordset
					recordset = options[:recordset]
				else
					recordset = RecordSet.new
				end
				
				options[:recordset] = RecordSetPrinter.new(recordset, options[:output])
			end

			scanner = Scanner.new(paths, options)

			scanner.scan(options[:recordset])

			return options[:recordset]
		end
	end
end
