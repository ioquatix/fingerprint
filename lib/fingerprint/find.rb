# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2016-2025, by Samuel Williams.

require "find"
require "build/files/path"
require "build/files/system"

module Fingerprint
	module Find
		def self.find(root)
			# Ensure root is a directory:
			root += File::SEPARATOR unless root.end_with?(File::SEPARATOR)
			
			::Find.find(root) do |path|
				yield Build::Files::Path.new(path, root)
			end
		end
		
		def self.prune
			::Find.prune
		end
	end
end
