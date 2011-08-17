#!/usr/bin/env ruby

# Copyright (c) 2007, 2011 Samuel G. D. Williams. <http://www.oriontransfer.co.nz>
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

require 'rubygems'

require 'test/unit'
require 'fileutils'
require 'pathname'
require 'fingerprint'

require 'timeout'

class CommandTest < Test::Unit::TestCase

	def test_analyze_verify
		result = system("fingerprint --analyze ./ -f")
		
		File.open("junk.txt", "w") { |fp| fp.write("foobar") }
		
		result = system("fingerprint --verify ./")
		
		assert_equal result, true
		
		File.open("junk.txt", "w") { |fp| fp.write("foobaz") }
		
		result = system("fingerprint --verify ./")
		
		assert_equal result, false
	end

	def test_check_paths
		errors = 0
		test_path = File.dirname(__FILE__) + '/test'
		
		Fingerprint::check_paths(test_path, test_path) do |record, result, message|
			errors += 1
		end
		
		assert_equal errors, 0
	end

end
