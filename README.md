# Fingerprint

> Matter and energy degrade to more probable, less informative states. The larger the amounts of information processed or diffused, the more likely it is that information will degrade toward meaningless variety, like noise or information overload, or sterile uniformity — Orrin Klapp

Fingerprint is a general purpose data integrity tool that uses cryptographic hashes to detect changes in files. Fingerprint scans a directory tree and generates a small transcript file containing the names and hashes of the files. This snapshot file can then be used to generate a list of files that have been created, deleted, or modified. If so much as a single bit in a single file in the directory tree has changed, fingerprint will detect it.

Traditionally, the only way to preserve data was to take regular backups and hope that any unwanted changes that occurred would be major, obvious ones (such as loss of the disk). This approach means trusting all the software to which the data is exposed: operating systems, backup software, communications software, compression software, encryption software, and archiving software. Unfortunately, each of these systems is highly complex and can inflict all kinds of damage on data, much of the damage undetectable to humans. Fingerprint allows data to be monitored, detecting even the change of a single bit.

Fingerprint can be used for:

- Preservation: Detect corruption of important data, e.g. web server integrity, write-once storage verification.
- Security: Detect changes made by intruders, e.g. firewall integrity, network configuration, software auditing.
- Transfers:  Verify file copies and transfers between different systems, e.g. file transfer integrity.
- Sealing: Cryptographically seal critical files, e.g. document verification.
- Notarizing: Prove that documents existed at a particular time.
- Backups: Verify restored backups to ensure that backups are sound, e.g. backup verification and integrity.

A companion app is available in the [Mac App Store](https://itunes.apple.com/nz/app/fingerprint/id470866821). Purchasing this app helps fund the open source software development.

[![Build Status](https://secure.travis-ci.org/ioquatix/fingerprint.svg)](http://travis-ci.org/ioquatix/fingerprint)
[![Code Climate](https://codeclimate.com/github/ioquatix/fingerprint.svg)](https://codeclimate.com/github/ioquatix/fingerprint)
[![Coverage Status](https://coveralls.io/repos/ioquatix/fingerprint/badge.svg)](https://coveralls.io/r/ioquatix/fingerprint)

## Motivation

As the world becomes further entrenched in digital data and storage, the accuracy and correctness of said data is going to become a bigger problem. As humans create information, we are ultimately decreasing the amount of disorder/entropy in the universe. By the second law of thermodynamics, when a closed system moves from "the least to the most probable, from differentiation to sameness, from ordered individuality to a kind of chaos," (Thomas Pynchon) the only logical conclusion is that what we consider to be important data is destined to become meaningless noise in the sands of time.

When I first suffered data-loss, it wasn't catastrophic - it was the slow deterioration of a drive which silently corrupted many files. After this event, I wanted a tool which would allow me to minimize the chance of this happening in the future. When I take a backup now, I also make a fingerprint. If I ever need to restore from backup, I can be confident the data is as it was when it was backed up.

As fingerprint provides a fast way to compare the files, I've also extended it to find duplicates within one or more fingerprints. This is useful for de-duplicating your home directory and I've also used it when marking assignments to find blatant copying.

In cases where I've been concerned about the migration of data (e.g. copying my entire home directory from one system to another), I've used fingerprint to generate a transcript on the source machine, and then run it on the destination machine, to reassure me that the data was copied correctly and completely.

## Installation

Add this line to your application's Gemfile:

	gem 'fingerprint'

And then execute:

	$ bundle

Or install it yourself as:

	$ gem install fingerprint

## Usage

Please consult the [GUIDE](GUIDE.md) for an overview of how fingerprint command can be used.

### RSpec

The simplest usage of fingerprint is checking if two directories are equivalent:

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
	W README.md
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
	D 
	D fingerprint
	F fingerprint/check_paths_spec.rb
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
	F .git/refs/heads/master
		file.size 41
		fingerprint index.fingerprint
		key.MD5 aaadaeee72126dedcd4044d687a74068
		key.SHA2.256 6750f057b38c2ea93e3725545333b8167301b6d8daa0626b0a2a613a6a4f4f04
		original.fingerprint index.fingerprint
		original.path .git/refs/remotes/origin/master

## Todo

* Command line option to show files that have changed but have the same modified time (hardware corruption).
* Supporting tools for signing fingerprints easily.
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
