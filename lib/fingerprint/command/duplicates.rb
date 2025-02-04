# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2016-2025, by Samuel Williams.

require "samovar"

module Fingerprint
	module Command
		class Duplicates < Samovar::Command
			self.description = "Efficiently find duplicates in a given fingerprint."
			
			options do
				option "-i/--inverse", "Invert the output, i.e. show files which are not duplicates."
				option "-x/--extended", "Include extended information about files and directories."
				
				option "--delete", "Delete duplicates."
				
				option "--verbose", "Verbose output, e.g. what is happening."
			end
			
			one :master, "The source fingerprint which represents the primarily file list."
			many :copies, "Zero or more fingerprints which might contain duplicates.", default: []
			
			attr :duplicates_recordset
			
			def delete(path)
				FileUtils.rm_f(path)
			end
			
			def call
				@duplicates_recordset = RecordSet.new
				results = RecordSetPrinter.new(@duplicates_recordset, @parent.output)
				
				master_file_path = @master
				master_recordset = RecordSet.load_file(master_file_path)
					
				ignore_similar = false
				
				copy_file_paths = @copies
				
				if copy_file_paths.size == 0
					copy_file_paths = [master_file_path]
					ignore_similar = true
				end
				
				copy_file_paths.each do |copy_file_path|
					copy_recordset = RecordSet.load_file(copy_file_path)
					
					copy_recordset.records.each do |record|
						next unless record.file?
						
						record.metadata["fingerprint"] = copy_file_path
						
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
							record.metadata["original.path"] = main_record.path
							record.metadata["original.fingerprint"] = master_file_path
							results << record if !@options[:inverse]
							
							if @options[:delete]
								delete(copy_recordset.full_path(record.path))
							end
						else
							results << record if @options[:inverse]
						end
					end
				end
			end
		end
	end
end
