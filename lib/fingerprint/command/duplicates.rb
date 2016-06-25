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

module Fingerprint
	module Command
		class Duplicates < Samovar::Command
			self.description = "Efficiently find duplicates in a given fingerprint."
			
			options do
				option "-i/--inverse", "Invert the output, i.e. show files which are not duplicates."
				option "-x/--extended", "Include extended information about files and directories."
				
				option "--verbose", "Verbose output, e.g. what is happening."
			end
			
			one :master, "The source fingerprint which represents the primarily file list."
			many :copies, "Zero or more fingerprints which might contain duplicates."
			
			def invoke(parent)
				@options[:output] = $stdout
				
				duplicates_recordset = RecordSet.new
				results = RecordSetPrinter.new(duplicates_recordset, @options[:output])
				
				master_file_path = @master
				File.open(master_file_path) do |master_file|
					master_recordset = RecordSet.new
					master_recordset.parse(master_file)
					
					ignore_similar = false
					
					copy_file_paths = @copies
					if copy_file_paths.size == 0
						copy_file_paths = [master_file_path]
						ignore_similar = true
					end
					
					copy_file_paths.each do |copy_file_path|
						File.open(copy_file_path) do |copy_file|
							copy_recordset = RecordSet.new
							copy_recordset.parse(copy_file)
							
							copy_recordset.records.each do |record|
								record.metadata['fingerprint'] = copy_file_path
								# We need to see if the record exists in the master
								
								if @options[:verbose]
									$stderr.puts "Checking #{record.inspect}"
								end
								
								main_record = master_recordset.find_by_key(record)
								
								# If we are scanning the same index, don't print out every file, just those that are duplicates within the single file.
								if ignore_similar && main_record && (main_record.path == record.path)
									main_record = nil
								end
								
								if main_record
									record.metadata['original.path'] = main_record.path
									record.metadata['original.fingerprint'] = master_file_path
									results << record if !@options[:inverse]
								else
									results << record if @options[:inverse]
								end
							end
						end
					end
				end
			end
		end
	end
end
