# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2016-2025, by Samuel Williams.

require "samovar"

require_relative "../checksums"
require_relative "../scanner"
require_relative "../record"

module Fingerprint
	module Command
		class Scan < Samovar::Command
			self.description = "Generate a fingerprint from the given paths."
			
			options do
				option "-p/--path <path>", "Analyze the given path relative to root.", default: "./"
				
				option "-x/--extended", "Include extended information about files and directories."
				option "-s/--checksums <SHA2.256>", "Specify what checksum algorithms to use: #{CHECKSUMS.keys.join(', ')}.", default: DEFAULT_CHECKSUMS, type: Checksums
				
				option "--progress", "Print structured progress to standard error."
				option "--verbose", "Verbose fingerprint output, e.g. excluded paths."
			end
			
			many :paths, "Paths to scan."
			
			def call
				@paths = [Dir.pwd] unless @paths
				
				options = @options.dup
				
				# This configuration ensures that the output is printed to $stdout.
				options[:output] = @parent.output
				options[:recordset] = nil
				
				Scanner.scan_paths(@paths, **options)
			end
		end
	end
end
