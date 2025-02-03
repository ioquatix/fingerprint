# frozen_string_literal: true

require_relative "lib/fingerprint/version"

Gem::Specification.new do |spec|
	spec.name = "fingerprint"
	spec.version = Fingerprint::VERSION
	
	spec.summary = "Fingerprint is a tool for creating checksums of entire directory structures, and comparing them for inconsistencies."
	spec.authors = ["Samuel Williams", "Glenn Rempe"]
	spec.license = "MIT"
	
	spec.cert_chain  = ["release.cert"]
	spec.signing_key = File.expand_path("~/.gem/release.pem")
	
	spec.homepage = "https://github.com/ioquatix/fingerprint"
	
	spec.metadata = {
		"documentation_uri" => "https://ioquatix.github.io/fingerprint/",
		"funding_uri" => "https://github.com/sponsors/ioquatix/",
		"source_code_uri" => "https://github.com/ioquatix/fingerprint.git",
	}
	
	spec.files = Dir.glob(["{bin,lib}/**/*", "*.md"], File::FNM_DOTMATCH, base: __dir__)
	
	spec.executables = ["fingerprint"]
	
	spec.required_ruby_version = ">= 3.1"
	
	spec.add_dependency "build-files", "~> 1.2"
	spec.add_dependency "samovar", "~> 2.0"
end
