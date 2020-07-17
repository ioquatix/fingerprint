source 'https://rubygems.org'

# Specify your gem's dependencies in fingerprint.gemspec
gemspec

group :maintenance, optional: true do
	gem "bake-bundler"
	gem "bake-modernize"
	
	gem "utopia-project"
end
