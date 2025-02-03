# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2016-2025, by Samuel Williams.

require "samovar"
require "fileutils"

require_relative "../checksums"
require_relative "../scanner"
require_relative "../record"

module Fingerprint
	module Command
		class Analyze < Samovar::Command
			self.description = "Generates a fingerprint for the specified paths and saves it."
			
			options do
				option "-n/--name <name>", "The fingerprint file name.", default: INDEX_FINGERPRINT
				
				option "-f/--force", "Force all operations to complete despite warnings."
				option "-x/--extended", "Include extended information about files and directories."
				option "-s/--checksums <SHA2.256>", "Specify what checksum algorithms to use: #{CHECKSUMS.keys.join(', ')}.", default: DEFAULT_CHECKSUMS, type: Checksums
				
				option "--progress", "Print structured progress to standard error."
				option "--verbose", "Verbose fingerprint output, e.g. excluded paths."
			end
			
			many :paths, "Paths relative to the root to use for verification, or pwd if not specified.", default: ["./"]
			
			def call
				output_file = @options[:name]
				
				if File.exist?(output_file) and !@options[:force]
					abort "Output file #{output_file} already exists. Aborting."
				end
				
				options = @options.dup
				options[:excludes] = [File.expand_path(options[:name], Dir.pwd)]
				
				finished = false
				begin
					File.open(output_file, "w") do |io|
						options[:output] = io
						
						Scanner.scan_paths(@paths, **options)
					end
					finished = true
				ensure
					FileUtils.rm(output_file) unless finished
				end
			end
		end
	end
end
