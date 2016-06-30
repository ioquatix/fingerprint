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

describe Fingerprint do
	after(:each) do
		FileUtils.rm_rf(Fingerprint::INDEX_FINGERPRINT)
	end
	
	it "should analyze and verify files" do
		Fingerprint::Command::Top.new(["analyze", "-f"]).invoke
		
		expect(File).to be_exist(Fingerprint::INDEX_FINGERPRINT)
		
		top = Fingerprint::Command::Top.new(["verify"]).tap(&:invoke)
		
		expect(top.command.error_count).to be == 0
	end
	
	let(:source_directory) {File.expand_path("../../lib", __dir__)}
	let(:fingerprint_name) {File.join(__dir__, "test.fingerprint")}
	
	it "should analyze a different path" do
		Fingerprint::Command::Top.new(["analyze", "-n", fingerprint_name, "-f", source_directory]).invoke
		
		expect(File).to be_exist(fingerprint_name)
		
		top = Fingerprint::Command::Top.new(["verify", "-n", fingerprint_name, "-f", source_directory]).tap(&:invoke)
		
		expect(top.command.error_count).to be == 0
	end
end
