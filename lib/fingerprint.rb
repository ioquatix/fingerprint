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

require 'fingerprint/record'
require 'fingerprint/version'
require 'fingerprint/scanner'
require 'fingerprint/checker'

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
