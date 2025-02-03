# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2016-2025, by Samuel Williams.

require "samovar"

require_relative "scanner"

require_relative "command/scan"
require_relative "command/analyze"
require_relative "command/verify"
require_relative "command/compare"
require_relative "command/duplicates"

module Fingerprint
	module Command
		def self.call(*args)
			Top.call(*args)
		end
		
		class Top < Samovar::Command
			self.description = "A file checksum analysis and verification tool."
			
			options do
				option "--root <path>", "Work in the given root directory."
				
				option "-o/--output <path>", "Output the transcript to a specific file rather than stdout."
				
				option "-h/--help", "Print out help information."
				option "-v/--version", "Print out the application version."
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
			
			nested :command, {
				"scan" => Scan,
				"analyze" => Analyze,
				"verify" => Verify,
				"compare" => Compare,
				"duplicates" => Duplicates
			}, default: "analyze"
			
			def call
				if @options[:version]
					puts "fingerprint v#{VERSION}"
				elsif @options[:help]
					self.print_usage
				else
					chdir do
						@command.call
					end
				end
			end
		end
	end
end
