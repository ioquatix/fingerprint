# Fingerprint

Fingerprint is primarily a command line tool to compare directory structures on disk. It also provides a programmatic interface for this procedure.

Because Fingerprint produces output to `IO` like structures, it is easy to transmit this data across a network, or store it for later use. As an example, it could be used to check the integrity of a remote backup.

For examples and documentation please see the main [project page][1].

[1]: http://www.codeotaku.com/projects/fingerprint/index

[![Build Status](https://secure.travis-ci.org/ioquatix/fingerprint.svg)](http://travis-ci.org/ioquatix/fingerprint)
[![Code Climate](https://codeclimate.com/github/ioquatix/fingerprint.svg)](https://codeclimate.com/github/ioquatix/fingerprint)
[![Coverage Status](https://coveralls.io/repos/ioquatix/fingerprint/badge.svg)](https://coveralls.io/r/ioquatix/fingerprint)

## Installation

Add this line to your application's Gemfile:

	gem 'fingerprint'

And then execute:

	$ bundle

Or install it yourself as:

	$ gem install fingerprint

## Usage

The simplest usage of Fingerprint is checking if two directories are equivalent:

	Fingerprint.identical?(source_path, destination_path) do |record|
		puts "#{record.path} is different"
	end

This would catch additions, removals, and changes. You can use this in RSpec:

	expect(Fingerprint).to be_identical(source_path, destination_path)

### Command Line

The `fingerprint` command has a high-level and low-level interface.

#### High-level Interface

This usage is centered around analysing a given directory using `fingerprint analyze` and then, at a later date, checking that the directory is not missing any files and that all files are the same as they were originally, using `fingerprint verify`.

	% fingerprint analyze
	% fingerprint verify
	S 0 error(s) detected.
		error.count 0

If we modify a file, it will be reported:

	% fingerprint verify 
	W ./README.md
		changes.file.size.new 4157
		changes.file.size.old 4048
		changes.key.MD5.new 167cceb2136426b9dabab2df0d0f855d
		changes.key.MD5.old 0445e524835596184e47d091085fa7b9
		changes.key.SHA2.256.new 7c955edef21625cc6817d0df8c549fac236b062ce7f5077743708c56394bd87a
		changes.key.SHA2.256.old 72d151c34e0565c6b645188e34608ff08b40d560e667f7a0bf9392d72586cef4
		error.code keys_different
		error.message Key MD5 does not match
	S 1 error(s) detected.
		error.count 1

This command does not report files which have been added.

#### Low-level interface

It is possible to generate a fingerprint using the scan command, which takes a list of paths and writes out the transcript.

	% fingerprint scan spec 
	C /home/samuel/Documents/Programming/ioquatix/fingerprint/spec
		fingerprint.version 2.0.0
		options.checksums MD5, SHA2.256
		options.extended false
		summary.time.start 2016-06-25 11:46:12 +1200
	D ./
	D ./fingerprint
	F ./fingerprint/check_paths_spec.rb
		file.size 1487
		key.MD5 ef77034977daa683bbaaed47c553f6f5
		key.SHA2.256 970ec4663ffc257ec1d4f49f54711c38434108d580afc0c92ea7bf864e08a1e0
	S 1 files processed.
		summary.directories 2
		summary.excluded 0
		summary.files 1
		summary.size 1487
		summary.time.end 2016-06-25 11:46:12 +1200

#### Duplicates

Fingerprint can efficiently find duplicates in one or more fingeprints.

	$ fingerprint duplicates index.fingerprint
	F ./.git/refs/heads/master
		file.size 41
		fingerprint index.fingerprint
		key.MD5 aaadaeee72126dedcd4044d687a74068
		key.SHA2.256 6750f057b38c2ea93e3725545333b8167301b6d8daa0626b0a2a613a6a4f4f04
		original.fingerprint index.fingerprint
		original.path ./.git/refs/remotes/origin/master

## Todo

* Command line option to show files that have been created (e.g. don't exist in master fingerprint).
* Command line option to show files that have changed but have the same modified time (hardware corrutpion).
* Command line option to check fingerprint files based on checksums, e.g. duplicate files, unique files, over a set of directories.
* Command line tool for extracting duplicate and unique files over a set of directories?
* Supporting tools for signing fingerprints easily.
* Support indexing specific files as well as whole directories (maybe?).
* Support general filenames for `--archive`, e.g. along with `-n`, maybe support a file called `index.fingerprint` by default: improved visibility for end user.
* Because fingerprint is currently IO bound in terms of performance, single-threaded checksumming is fine, but for SSD and other fast storage, it might be possible to improve speed somewhat by using a map-reduce style approach.

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request

## License

Released under the MIT license.

Copyright, 2016, by [Samuel G. D. Williams](http://www.codeotaku.com/samuel-williams).

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in
all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
THE SOFTWARE.
