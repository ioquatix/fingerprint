# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'fingerprint/version'

Gem::Specification.new do |spec|
	spec.name          = "fingerprint"
	spec.version       = Fingerprint::VERSION
	spec.authors       = ["Samuel Williams"]
	spec.email         = ["samuel.williams@oriontransfer.co.nz"]
	spec.description   = <<-EOF
		Fingerprint is a general purpose data integrity tool that uses cryptographic hashes to detect changes in files and directory trees. The fingerprint command scans a directory tree and generates a fingerprint file containing the names and cryptographic hashes of the files in the tree. This snapshot can be later used to generate a list of files that have been created, deleted or modified. If so much as a single bit in the file data has changed, Fingerprint will detect it.
	EOF
	spec.summary       = "Fingerprint is a tool for creating checksums of entire directory structures, and comparing them for inconsistencies."
	spec.homepage      = "http://www.codeotaku.com/projects/fingerprint"
	spec.license       = "MIT"

	spec.files         = `git ls-files`.split($/)
	spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
	spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
	spec.require_paths = ["lib"]

	spec.add_dependency("samovar", ">= 1.1.1")
	spec.add_dependency("build-files", "~> 1.1")
	
	spec.add_development_dependency "bundler", "~> 1.11"
	spec.add_development_dependency "rspec", "~> 3.4"
	spec.add_development_dependency "rake"
end
