Fingerprint
===========

* Author: Samuel G. D. Williams (<http://www.oriontransfer.co.nz>)
* Copyright (C) 2010, 2011 Samuel G. D. Williams.
* Released under the MIT license.

Fingerprint is primarily a command line tool to compare directory structures on 
disk. It also provides a programmatic interface for this procedure.

Because Fingerprint produces output to `IO` like structures, it is easy to transmit
this data across a network, or store it for later use. As an example, it could be
used to check the integrity of a remote backup.

For examples and documentation please see the main [project page][1].

[1]: http://www.oriontransfer.co.nz/gems/fingerprint

Todo
----

* Command line option to show files that have been created (e.g. don't exist in master fingerprint).
* Command line option to show files that have changed but have the same modified time (hardware corrutpion).
* Command line option to check fingerprint files based on checksums, e.g. duplicate files, unique files, over a set of directories.
* Command line tool for extracting duplicate and unique files over a set of directories?
* Supporting tools for signing fingerprints easily.
* Support indexing specific files as well as whole directories (maybe?).
* Support general filenames for `--archive`, e.g. along with `-n`, maybe support a file called `index.fingerprint` by default: improved visibility for end user.
* Because fingerprint is currently IO bound in terms of performance, single-threaded checksumming is fine, but for SSD and other fast storage, it might be possible to improve speed somewhat by using a map-reduce style approach.

License
-------

Copyright (c) 2010, 2011 Samuel G. D. Williams. <http://www.oriontransfer.co.nz>

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
