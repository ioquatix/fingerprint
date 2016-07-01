#!/usr/bin/env rspec

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

require 'fingerprint/command'
require 'fileutils'

require_relative 'source_fingerprint'

describe Fingerprint do
	include_context "source fingerprint"
	
	it "should have no duplicates" do
		Fingerprint::Command::Top.new(["analyze", "-n", fingerprint_name, "-f", source_directory]).invoke
		
		expect(File).to be_exist(fingerprint_name)
		
		record_set = Fingerprint::RecordSet.load_file(fingerprint_name)
		
		top = Fingerprint::Command::Top.new(["duplicates", fingerprint_name]).tap(&:invoke)
		
		expect(top.command.duplicates_recordset).to be_empty
	end
	
	it "should have duplicates" do
		Fingerprint::Command::Top.new(["analyze", "-n", fingerprint_name, "-f", source_directory]).invoke
		
		expect(File).to be_exist(fingerprint_name)
		
		record_set = Fingerprint::RecordSet.load_file(fingerprint_name)
		
		top = Fingerprint::Command::Top.new(["duplicates", fingerprint_name, fingerprint_name]).tap(&:invoke)
		
		expect(top.command.duplicates_recordset).to_not be_empty
	end
end
