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

	MODES = {
		:configuration => 'C',
		:file => 'F',
		:link => 'L',
		:directory => 'D',
		:summary => 'S',
		:warning => 'W',
		:excluded => '#',
	}

	class Record
		def initialize(mode, path, metadata = {})
			@mode = mode
			@path = path

			@metadata = metadata
			@keys = metadata.keys.grep(/^key\./)
		end

		attr :mode
		attr :path
		attr :metadata
		attr :keys

		def [](key)
			@metadata[key]
		end

		def diff(other)
			changes = []

			all_keys = Set.new
			all_keys += @metadata.keys + other.metadata.keys
			# all_keys -= @keys + other.keys

			all_keys.each do |key|
				changes << key if @metadata[key].to_s != other.metadata[key].to_s
			end

			return changes
		end
		
		def options
			options = {}
			
			options[:extended] = true if @metadata['options.extended'] == 'true'
			options[:checksums] = @metadata['options.checksums'].split(/[\s,]+/) if @metadata['options.checksums']
			
			return options
		end
		
		def write(output)
			output.puts "#{MODES[@mode]} #{@path}"
			
			return if @mode == :excluded
			
			@metadata.keys.sort.each do |key|
				output.puts "\t#{key} #{@metadata[key]}"
			end
		end
	end
	
	class RecordSet
		def initialize
			@records = []
			@paths = {}
			@keys = {}
			
			@configuration = nil

			@callback = nil
		end

		attr :records
		attr :paths
		attr :keys

		attr :configuration

		def <<(record)
			@records << record
			if record.mode == :configuration
				# What should we do if we get multiple configurations?
				@configuration = record
			else
				@paths[record.path] = record
				record.keys.each do |key|
					@keys[key] ||= {}
					
					@keys[key][record[key]] = record
				end
			end
		end

		def lookup(path)
			return @paths[path]
		end

		def find_by_key(record)
			record.keys.each do |key|
				value = record[key]
				
				result = @keys[key][value]

				return result if result
			end

			return nil
		end

		def find(record)
			result = lookup(record.path)

			return result if result

			return find_by_key(record)
		end

		def compare(other)
			main = lookup(other.path)

			# Did we find a corresponding other at the same path?
			if main
				# Keep track of how many keys were checked..
				checked = 0

				# Are all the keys of the other record equivalent to the main record?
				other.keys.each do |key|
					if main[key]
						checked += 1

						# Is the key the same?
						if main[key] != other[key]
							return :keys_different, "Key #{key.gsub(/^key\./, '')} does not match"
						end
					end
				end

				# Are the records the same size? We put this check second because we do this as a last resort to
				# ensure that the file hasn't been deliberately tampered with.
				if main.metadata['size'] and other.metadata['size'] and main.metadata['size'] != other.metadata['size']
					return :size_different, "File size differs"
				end

				if checked == 0
					return :no_keys, "No valid keys to check"
				else
					# At least one key could be validated.
					return :valid, "Valid"
				end
			else
				return :not_found, "File not found"
			end
		end

		def self.parse(input)
			mode = nil
			path = nil
			metadata = nil

			markers = {}
			MODES.each do |key, value|
				markers[value] = key
			end

			# Parse original fingerprint
			input.each_line do |line|
				# Skip comments and blank lines
				next if line.match(/^\s*#/) || line.match(/^\s*$/)

				if line.match(/^([A-Z])\s+(.*)$/)
					if path
						yield mode, path, metadata
					end

					mode = markers[$1] || :unknown

					path = $2
					metadata = {}
				elsif line.match(/^\s+([a-zA-Z\.0-9]+)\s+(.*)$/)
					metadata[$1] = $2
				else
					$stderr.puts "Unhandled line: #{line}"
				end
			end

			if path
				yield mode, path, metadata
			end
		end

		def parse(input)
			self.class.parse(input) do |mode, path, metadata|
				self << Record.new(mode, path, metadata)
			end
		end
		
		def write(output)
			@records.each do |record|
				record.write(output)
			end
		end
	end
	
	# This record set dynamically computes data from the disk as required.
	class SparseRecordSet < RecordSet
		def initialize(scanner)
			super()
			
			@scanner = scanner
		end
		
		def lookup(path)
			if @paths.key?(path)
				return @paths[path]
			else
				@paths[path] = @scanner.scan_path(path)
			end
		end
	end
	
	class RecordSetWrapper
		def initialize(recordset)
			@recordset = recordset
		end

		def method_missing(name, *args, &block)
			@recordset.send(name, *args, &block)
		end

		def respond_to?(name)
			@recordset.respond_to?(name)
		end
	end
	
	class RecordSetPrinter < RecordSetWrapper
		def initialize(recordset, output)
			super(recordset)
			@output = output
		end

		def <<(record)
			record.write(@output)
			@recordset << record if @recordset
		end
	end
end
