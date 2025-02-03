# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2016-2025, by Samuel Williams.

require "samovar"

module Fingerprint
	module Command
		class Compare < Samovar::Command
			self.description = "Compare two fingerprints and report additions, removals and changes."
			
			options do
				option "-x/--extended", "Include extended information about files and directories."
				option "-a/--additions", "Report files that have been added to the copy."
				option "--fail-on-errors", "Exit with non-zero status if errors are encountered."
				
				option "--progress", "Print structured progress to standard error."
			end
			
			one :master, "The fingerprint which represents the original data."
			one :copy,  "The fingerprint which represents a copy of the data."
			
			def call
				options = @options.dup
				options[:output] = @parent.output
				
				error_count = Checker.check_files(@master, @copy, **options)

				if @options[:fail_on_errors]
					abort "Data inconsistent, #{error_count} error(s) found!" if error_count != 0
				end
			end
		end
	end
end
