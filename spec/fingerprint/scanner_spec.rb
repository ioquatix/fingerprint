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

require 'fingerprint/scanner'

RSpec.shared_examples "scanner checksum" do |digests|
	let(:scanner) {Fingerprint::Scanner.new([__dir__], checksums: subject)}
	
	it "computes checksums correctly" do
		digests.each do |path, required_metadata|
			record = scanner.scan_path(path)
			
			expect(record.metadata).to include(required_metadata)
		end
	end
end

RSpec.describe ['MD5'] do
	it_behaves_like "scanner checksum",
		"corpus/README.md" => {
			"file.size" => 52,
			"key.MD5" => "2d7157522d94e7d1621daefd5b92817f",
		}
end

RSpec.describe ['SHA2.256', 'SHA2.384', 'SHA2.512'] do
	it_behaves_like "scanner checksum",
		"corpus/README.md" => {
			"file.size" => 52,
			"key.SHA2.256" => "0d991d01d74c50cd5dcce8140e61e4da5a06e468d9df704195e84863269ce20f",
			"key.SHA2.384" => "8d9b81d6aa761b9611dbcb76471e667854ece77a134aa53953651938e233791fe6a4b6aa2db3eb7b9531bdb49ce5a31f",
			"key.SHA2.512" => "73c9d10f92ca7a0d53641efe59860a7bd358185cfe5ba51fe7b19a6894344f3109de8840d3ae73742c5a059daffcbdda865111f1925604e3f6c59d33443bde2c",
		}
end
