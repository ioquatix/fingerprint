# RSpec Integration

This guide explains how `fingerprint` can be used with RSpec to compare files.

## File Comparison

The simplest usage of fingerprint is checking if two directories are equivalent:

``` ruby
Fingerprint.identical?(source_path, destination_path) do |record|
	puts "#{record.path} is different"
end
```

This would catch additions, removals, and changes. You can use this in RSpec:

``` ruby
expect(Fingerprint).to be_identical(source_path, destination_path)
```
