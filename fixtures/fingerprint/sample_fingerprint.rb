#!/usr/bin/env rspec
# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2016-2025, by Samuel Williams.

require "fileutils"
require "tmpdir"

module Fingerprint
	SampleFingerprint = Sus::Shared("sample fingerprint") do
		let(:source_directory) {File.expand_path("../..", __dir__)}
		let(:fingerprint_path) {File.join(@root, "test.fingerprint")}
		
		around do |&block|
			Dir.mktmpdir do |temporary_directory|
				@root = temporary_directory
				super(&block)
			ensure
				@root = nil
			end
		end
	end
end
