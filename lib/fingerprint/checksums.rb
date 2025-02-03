# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2016-2025, by Samuel Williams.

require "samovar"

module Fingerprint
	module Checksums
		def self.call(result)
			result.split(/\s*,\s*/)
		end
	end
end
