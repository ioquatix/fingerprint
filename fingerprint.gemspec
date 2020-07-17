
require_relative "lib/fingerprint/version"

Gem::Specification.new do |spec|
	spec.name = "fingerprint"
	spec.version = Fingerprint::VERSION
	
	spec.summary = "Fingerprint is a tool for creating checksums of entire directory structures, and comparing them for inconsistencies."
	spec.authors = ["Samuel Williams"]
	spec.license = "MIT"
	
	spec.homepage = "https://github.com/ioquatix/fingerprint"
	
	spec.metadata = {
		"funding_uri" => "https://github.com/sponsors/ioquatix/",
	}
	
	spec.files = Dir.glob('{bin,lib}/**/*', File::FNM_DOTMATCH, base: __dir__)
	
	spec.executables = ["fingerprint"]
	
	spec.required_ruby_version = ">= 2.5"
	
	spec.add_dependency "build-files", "~> 1.2"
	spec.add_dependency "samovar", "~> 2.0"
	
	spec.add_development_dependency "bundler"
	spec.add_development_dependency "covered"
	spec.add_development_dependency "rake"
	spec.add_development_dependency "rspec", "~> 3.4"
end
