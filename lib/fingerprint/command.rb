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

require_relative 'scanner'

require_relative 'command/scan'
require_relative 'command/analyze'
require_relative 'command/verify'
require_relative 'command/check'
require_relative 'command/duplicates'

module Fingerprint
	module Command
		class Top < Samovar::Command
			self.description = "A file checksum analysis and verification tool."
			
			options do
				option '--root <path>', "Work in the given root directory."
				
				option '-o/--output <path>', "Output the transcript to a specific file rather than stdout."
				
				option '-h/--help', "Print out help information."
				option '-v/--version', "Print out the application version."
			end
			
			def chdir(&block)
				if root = @options[:root]
					Dir.chdir(root, &block)
				else
					yield
				end
			end
			
			def output
				if path = @options[:output]
					File.open(path, "w")
				else
					$stdout
				end
			end
			
			nested '<command>',
				'scan' => Scan,
				'analyze' => Analyze,
				'verify' => Verify,
				'check' => Check,
				'duplicates' => Duplicates
			
			def invoke(program_name: File.basename($0))
				if @options[:version]
					puts "lsync v#{LSync::VERSION}"
				elsif @options[:help] or @command.nil?
					print_usage(program_name)
				else
					chdir do
						@command.invoke(self)
					end
				end
			end
		end
	end
end
