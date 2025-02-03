# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2009-2025, by Samuel Williams.

require "fingerprint/record"
require "fingerprint/version"
require "fingerprint/scanner"
require "fingerprint/checker"

module Fingerprint
	# A helper function to check two paths for consistency. Provides callback from +Fingerprint::Checker+.
	def self.check_paths(master_path, copy_path, **options, &block)
		master = Scanner.new([master_path])
		copy = Scanner.new([copy_path])
		
		master_recordset = RecordSet.new
		copy_recordset = SparseRecordSet.new(copy)
		
		master.scan(master_recordset)
		
		checker = Checker.new(master_recordset, copy_recordset, **options)
		
		checker.check(&block)
		
		return checker
	end
	
	# Returns true if the given paths contain identical files. Useful for expectations, e.g. `expect(Fingerprint).to be_identical(source, destination)`
	def self.identical?(source, destination, &block)
		failures = 0
		
		check_paths(source, destination) do |record, name, message|
			failures += 1
			
			yield(record) if block_given?
		end
		
		return failures == 0
	end
end
