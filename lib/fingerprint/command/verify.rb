# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2016-2025, by Samuel Williams.

require "samovar"

require_relative "../checker"
require_relative "../record"

module Fingerprint
	module Command
		class Verify < Samovar::Command
			self.description = "Check an existing fingerprint against the filesystem."
			
			options do
				option "-n/--name <name>", "The fingerprint file name.", default: INDEX_FINGERPRINT
				
				option "-f/--force", "Force all operations to complete despite warnings."
				option "-x/--extended", "Include extended information about files and directories."
				
				option "-s/--checksums <SHA2.256>", "Specify what checksum algorithms to use (#{Fingerprint::CHECKSUMS.keys.join(', ')}).", default: Fingerprint::DEFAULT_CHECKSUMS
				
				option "--progress", "Print structured progress to standard error."
				option "--verbose", "Verbose fingerprint output, e.g. excluded paths."
				
				option "--fail-on-errors", "Exit with non-zero status if errors are encountered."
			end
			
			many :paths, "Paths relative to the root to use for verification, or ./ if not specified.", default: ["./"]
			
			attr :error_count
			
			def call
				input_file = @options[:name]

				unless File.exist? input_file
					abort "Can't find index #{input_file}. Aborting."
				end

				options = @options.dup
				options[:output] = @parent.output

				master = RecordSet.load_file(input_file)

				if master.configuration
					options.merge!(master.configuration.options)
				end

				scanner = Scanner.new(@paths, **options)
				
				# We use a sparse record set here, so we can't check for additions.
				copy = SparseRecordSet.new(scanner)

				@error_count = Checker.verify(master, copy, **options)
				
				if @options[:fail_on_errors]
					abort "Data inconsistent, #{error_count} error(s) found!" if error_count != 0
				end
			end
		end
	end
end
