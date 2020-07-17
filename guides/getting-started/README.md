# Getting Started

This guide explains how to use `fingerprint` gem.

## Installation

Add the gem to your project:

~~~ bash
$ bundle add fingerprint
~~~

Install it globally:

~~~ bash
$ gem install fingerprint
~~~

## Core Concepts

`fingerprint` has two main high level commands:

- A `fingerprint analyze` command which generates an index of files (typically in the current working directory) and their associated metadata, including one or more checksums.
- A `fingerprint verify` command which checks a previously generated index against the file system and reports any changes.

These commands are designed to provide the most straight forward interface. However, there are several lower level commands:

- A `fingerprint scan` command which generates an index of one or more paths and outputs the index to `stdout`.
- A `fingerprint compare` command which compares two indexes and reports any differences.
- A `fingerprint duplicates` command which detects duplicates across one or more indexes.

### Analyze and Verify

This usage is centered around analysing a given directory using `fingerprint analyze` and then, at a later date, checking that the directory is not missing any files and that all files are the same as they were originally, using `fingerprint verify`.

~~~ bash
$ fingerprint analyze
$ fingerprint verify
S 0 error(s) detected.
	error.count 0
~~~

If we modify a file (`file-1.txt` in this example), it will be reported:

~~~ bash
$ fingerprint verify
W file-1.txt
	changes.file.size.new 8
	changes.file.size.old 4
	changes.key.SHA2.256.new 1f2ec52b774368781bed1d1fb140a92e0eb6348090619c9291f9a5a3c8e8d151
	changes.key.SHA2.256.old b5bb9d8014a0f9b1d61e21e796d78dccdf1352f23cd32812f4850b878ae4944c
	error.code keys_different
	error.message Key SHA2.256 does not match
S 1 error(s) detected.
	error.count 1
~~~

This command does not report files which have been added.

### Scan

It is possible to generate a fingerprint using the scan command, which takes a list of paths and writes out the transcript.

~~~ bash
$ fingerprint scan spec 
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
~~~

### Duplicates

Fingerprint can efficiently find duplicates in one or more fingerprints.

~~~ bash
$ fingerprint duplicates index.fingerprint
F .git/refs/heads/master
	file.size 41
	fingerprint index.fingerprint
	key.MD5 aaadaeee72126dedcd4044d687a74068
	key.SHA2.256 6750f057b38c2ea93e3725545333b8167301b6d8daa0626b0a2a613a6a4f4f04
	original.fingerprint index.fingerprint
	original.path .git/refs/remotes/origin/master
~~~

### Supported Digests

Fingerprint can use one or more digest algorithms:

* `MD5`
* `SHA1`
* `SHA2.256` (default)
* `SHA2.384`
* `SHA2.512`

You specify these on the command line, e.g. `fingerprint scan -s MD5,SHA2.256 ...`.

The use of `MD5` and `SHA1` are no longer recommended due to the risk of hash collisions.
