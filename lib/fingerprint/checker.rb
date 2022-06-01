# Copyright, 2011, by Samuel G. D. Williams. <http://www.codeotaku.com>
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

require_relative 'record'

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
		def initialize(master, copy, **options)
			@master = master
			@copy = copy
			
			@options = options
		end

		attr :master
		attr :copy

		# Run the checking process.
		def check(&block)
			# For every file in the src, we check that it exists
			# in the destination:
			total_count = @master.records.count
			processed_size = 0
			total_size = @master.records.inject(0) { |count, record| count + (record['file.size'] || 0).to_i }
			
			if @options[:additions]
				copy_paths = @copy.paths.dup
			else
				copy_paths = {}
			end
			
			@master.records.each_with_index do |record, processed_count|
				copy_paths.delete(record.path)

				if @options[:progress]
					$stderr.puts "# Checking: #{record.path}"
				end

				next if record.mode != :file

				result, message = @copy.compare(record)
				if result != :valid
					yield record, result, message
				elsif @options[:extended]
					# Extended check compares other attributes such as user, group, file modes.
					changes = record.diff(copy.paths[record.path])
					
					if changes.size > 0
						yield record, :attribute_changed, "Attribute(s) #{changes.join(', ')} changed"
					end
				end
				
				if @options[:progress]
					$stderr.puts "# Progress: File #{processed_count} / #{total_count}; Byte #{processed_size} / #{total_size} = #{sprintf('%0.2f%%', processed_size.to_f / total_size.to_f * 100.0)}"

					processed_size += (record['file.size'] || 0).to_i
				end
			end
			
			if @options[:additions]
				copy_paths.each do |path, record|
					next unless record.mode == :file || record.mode == :directory
					
					yield record, :addition, "File added"
				end
			end
		end
		
		# A list of files which either did not exist in the copy, or had the wrong checksum.
		attr :failures

		def self.check_files(master, copy, **options, &block)
			# New API that takes two RecordSets...
			
			File.open(master) do |master_file|
				File.open(copy) do |copy_file|
					master_recordset = RecordSet.new
					master_recordset.parse(master_file)
					
					copy_recordset = RecordSet.new
					copy_recordset.parse(copy_file)

					verify(master_recordset, copy_recordset, **options, &block)
				end
			end
		end

		# Helper function to check two fingerprint files.
		def self.verify(master, copy, **options, &block)
			error_count = 0 

			errors = options.delete(:recordset) || RecordSet.new
			if options[:output]
				errors = RecordSetPrinter.new(errors, options[:output])
			end

			checker = Checker.new(master, copy, **options)

			checker.check do |record, result, message|
				error_count += 1

				metadata = {
					'error.code' => result,
					'error.message' => message
				}

				if result == :addition
					metadata.merge!(record.metadata)
					
					errors << Record.new(:warning, record.path, metadata)
				elsif (copy = checker.copy.paths[record.path])
					changes = record.diff(copy)

					changes.each do |name|
						metadata["changes.#{name}.old"] = record[name]
						metadata["changes.#{name}.new"] = copy[name]
					end

					errors << Record.new(:warning, record.path, metadata)
				else
					errors << Record.new(:warning, record.path, metadata)
				end
			end

			if error_count
				summary_message = "#{error_count} error(s) detected."
			else
				summary_message = "No errors detected"
			end

			errors << Record.new(:summary, summary_message, {
				'error.count' => error_count
			})

			return error_count
		end

	end
end
