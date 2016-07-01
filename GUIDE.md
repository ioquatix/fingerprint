# Fingerprint Guide

This guide gives an overview of the various ways in which fingerprint can be used.

## Generating fingerprints

Fingerprint is designed to index directories. The basic verb `scan` will index all paths specified in order (or the current path if none is given).

	$ fingerprint scan /bin
	fingerprint scan /bin | head -n 100
	C /bin
		fingerprint.version 2.1.3
		options.checksums MD5, SHA2.256
		options.extended false
		summary.time.start 2016-07-01 15:16:51 +1200
	D 
	F [
		file.size 22464
		key.MD5 576c4bb1e8cd269d3bdaf2b6dcd62cda
		key.SHA2.256 8cd75d8ddbeee27938c5fb9dee380bbc40159be687ba18d99d5b10ef3b16a7cb
	F bash
		file.size 628496
		key.MD5 5d7583d80e5314ac844eedc6d68c6cd7
		key.SHA2.256 fe162e301556121782e1e5334a023e94f742a3a66434812620ae41a5da5f3360
	F cat
		file.size 23520
		key.MD5 3fb0e3ca64776d182c422400a09673c3
		key.SHA2.256 2b4e43b4fe74e662a8063b61ab85c65d3a5d6f431166c38abb1f9c2df06ac69c
	F chmod
		file.size 33904
		key.MD5 ecb64579c6dd0ebee31bf8e4d4cdcc6e
		key.SHA2.256 139432e4cfdd8761ab8ddd36f0121f8d34ef4b05e61d63d45e8703ef53a2b447
	F cp
		file.size 28832
		key.MD5 a8ebcee2d17317beee2136ec59bfba4d
		key.SHA2.256 c126b5445251cb5be295d6a9e238bb71df9e8450dee1e84c1ee46760052985ba
	F csh
		file.size 378624
		key.MD5 0d3ea03a76f98011f35812a912068515
		key.SHA2.256 c20dac3882d08111cafcc42b4e689b8d963650244f8b8e9e13ade7cd9300d538
	F date
		file.size 28368
		key.MD5 52c4e2ef8d1e621901abaa75d875d743
		key.SHA2.256 6a6cade84d420801e974aa493b127a1af1bb9482e9e9fc8a563fb626c1f5d3c7
	F dd
		file.size 31856
		key.MD5 88cb8607654c414248b629441f74e865
		key.SHA2.256 dc53fcea0dda988dc63225b06c7c5b3690aa3926947b8d3ee15362c008c9f5c4
	F df
		file.size 27440
		key.MD5 f0857735cd9e35b183204528f2be2114
		key.SHA2.256 f71696bc4933373a1b64f5510a98909752256f1c57122999cf5784c30f2f8216
	-- snip --
	F zsh
		file.size 573600
		key.MD5 52d52aa8579eaef58addc0757f9c97d9
		key.SHA2.256 72508fe3cef985ca91b766727c4d9a6374f216a8b69a13ce41677f2e0400eacd
	S 37 files processed.
		summary.directories 1
		summary.excluded 0
		summary.files 37
		summary.size 4983584
		summary.time.end 2016-07-01 15:17:26 +1200

## Verifing Fingerprints

Files can be checked against a given fingerprint. In the case of `verify`, only changes and deletions will be reported. Additions are not reported.

To generate a fingerprint for a given path:

	fingerprint scan /bin > bin.fingerprint

This fingerprint can then be used to verify that no files have changed:

	$ fingerprint verify -n bin.fingerprint /bin
	S 0 error(s) detected.
		error.count 0

## Comparing Fingerprints

The `verify` operation checks a given fingerprint against a current filesystem, and can work efficiently according to the files in the source fingerprint. In the case that you want to compare two fingerprints, you can find all differences, including additions. This can be useful when comparing two backups to see what files changed (e.g. a tripwire).

	$ fingerprint scan /bin > bin1.fingerprint
	$ pacman -Syu
	-- snip --
	$ fingerprint scan /bin > bin2.fingerprint
	$ fingerprint compare -a bin1.fingerprint bin2.fingerprint
	W blkdeactivate
		changes.file.size.new 12503
		changes.file.size.old 12515
		changes.key.MD5.new 64f768d7d19fdc4e5197b1b43443f9f5
		changes.key.MD5.old 360e5623e86148c7168ef7dd4146d833
		changes.key.SHA2.256.new 8f7a4de6f1dea81b1c924603ff36b1d70b1f44580072d911f9c86cc8ccacd732
		changes.key.SHA2.256.old 26b1e560e5f3a2c47860cffe2189228b7825260957af0424e5e20317fcf0d570
		error.code keys_different
		error.message Key MD5 does not match
	-- snip --
	W bsdcat
		error.code addition
		error.message File added
		file.size 155256
		key.MD5 062e16f4cd910f28f2879c41a16296f4
		key.SHA2.256 53c74350abaae592571c8bb0e340a8754c22681292bab5d635e150d401d48ace
	S 41 error(s) detected.
		error.count 41

Here we can see files which have been changed and added to `/bin` after a system upgrade.

## Transmission and Archival Usage

Fingerprint provides two high-level operations `analyze` which is roughly equivalent to `scan` but outputs to the file `index.fingerprint` by default, and `verify` which reads by default from `index.fingerprint`.

Typical use cases would include analyzing a directory before copying it, and verifying it after the copy, or analyzing a backup and verifying it before restore.

	-- Fingerprint the local data:
	$ fingerprint --root /srv/http analyze
	
	-- Copy it to the remote system:
	$ rsync -a /srv/http production:/srv/http
	
	-- Run fingerprint on the remote system to verify the data copied correctly:
	$ ssh production fingerprint --root /srv/http verify
	S 0 error(s) detected.
		error.count 0

This is equally useful for traditional backup mediums, e.g. write-only storage, offline backups, etc.

## Data Preservation

Data preservation means that data is available in a useful form for as long as it is required (which could be indefinitely). Faulty hardware, software, user error or malicious attack are the primary concerns affecting data preservation. Fingerprint can provide insight into data integrity problems, which can then be resolved appropriately.

In almost all cases of data corruption, the sooner the corruption is detected, the less damage that occurs overall. It is in this sense that regular fingerprinting of critical files should be considered an important step in comprehensive data preservation policy.

Data preservation almost always involves data replication and verification. If data becomes corrupt, it it essential that backups are available to recover the original data. However, it is also important that backup data can be verified otherwise there is no guarantee that the recovered data is correct.

End to end testing on a regular basis is the only sane policy if your data is important.

### Non-malicious Bit-rot

Using standard analyze/verify procedure, fingerprint can detect file corruption. Make sure you record extended information using `-x`. The primary indication of file corruption is a change in checksum data but not in modified time. Standard operating system functions update the modified time when the file is changed. But, if the file changes without this, it may indicate hardware or software fault, and should be investigated further.

Once data has been analyzed, you can store it on archival media (e.g. optical or tape storage). At a later date, you can verify this to ensure the data has not become damaged over time.

### Malicious Changes

Malicious modification of files can be detected using fingerprint. This setup is typically referred to as a tripwire, because when an attacker modifies some critical system files, the system administrator will be notified. To maintain the security of such a setup, the fingerprint should be stored on a separate server:

	$ mv latest.fingerprint previous.fingerprint
	$ ssh data.example.com fingerprint scan /etc > latest.fingerprint
	$ fingerprint compare previous.fingerprint latest.fingerprint
	S 0 error(s) detected.
		error.count 0

This can be scripted and run in an hourly cron job:

	#!/usr/bin/env ruby

	require 'fileutils'

	REMOTE = "server.example.com"
	DIRECTORY = "/etc"
	PREVIOUS = "previous.fingerprint"
	LATEST = "latest.fingerprint"

	if File.exist? LATEST
		FileUtils.mv LATEST, PREVIOUS
	end

	$stderr.puts "Generating fingerprint of #{REMOTE}:#{DIRECTORY}..."
	system("ssh #{REMOTE} fingerprint #{DIRECTORY} > #{LATEST}")

	if File.exist? PREVIOUS
		$stderr.puts "Comparing fingerprints..."
		system('fingerprint', 'compare', '-a', PREVIOUS, LATEST)
	end

## Backup integrity

Data backup is typically an important part of any storage system. However, without end-to-end verification of backup data, it may not be possible to ensure that a backup system is working correctly. In the event that a failure occurs, data recovery may not be possible despite the existence of a backup, if that data has not been backed up reliably or correctly.

If you are backing up online data, the backup tool you are using may backup files at non-deterministic times. This means that if software (such as a database) is writing to a file at the time the backup occurs, the data may be transferred incorrectly. Fingerprint can help to detect this, by running fingerprint before the backup on the local storage, and then verifying the backup data after it has been copied. Ideally, you'd expect to see minimal changes to critical files.

However, the real world is often not so simple. Some software doesn't provide facilities for direct synchronization; other software provides facilities for dumping data (which may not be an option of the dataset is large). In these cases, fingerprint can give you some visibility about the potential issues you may face during a restore. You may want to consider [Synco](https://github.com/ioquatix/synco) which can coordinate more complex backup tasks.

### Ensuring Data Validity

To ensure that data has been backed up correctly, use fingerprint to analyze the data before it is backed up.

	-- Perform the data analysis
	$ sudo fingerprint analyze -f /etc

	-- Backup the data to a remote system
	$ sudo rsync --archive /etc backups.example.com:/mnt/backups/server.example.com/etc

After the data has been copied to the remote backup device, restore the data to a temporary location and use fingerprint to verify the data. The exact procedure will depend on your backup system, e.g. if you use a tape you may need to restore from the tape to local storage first.

	-- On the backup server
	$ cd /mnt/backups/server.example.com/etc
	$ fingerprint verify
	S 0 error(s) detected.
		error.count 0

### Preserving Backups

If your primary concern is ensuring that backup data is consistent over time (e.g. files are not modified or damaged), fingerprint can be used directly on the backup data to check for corruption. After the data has been backed up successfully, simply analyze the data as above, but on the backup server. Once this is done, at any point in the future you can verify the correctness of the backup set.

## Cryptographic Sealing

Fingerprint can be used to ensure that a set of files has been delivered without manipulation, by creating a fingerprint and signing this with a private key. The fingerprint and associated files can later be verified using the public key.

### Generating Keys

To sign fingerprints, the first step is to create a private and public key pair. This is easily achieved using OpenSSL:

	-- Create a private key, which you must keep secure.
	$ openssl genrsa -out private.pem 2048
	Generating RSA private key, 2048 bit long modulus
	.............+++
	........+++
	e is 65537 (0x10001)

	-- Create a public key, which can be used to verify sealed fingerprints.
	$ openssl rsa -in private.pem -pubout -out public.pem
	writing RSA key

### Signing Fingerprints

After you have generated a fingerprint, you can sign it easily using the private key:

	-- We assume here that you are using fingerprint analyze to generate fingerprints.
	$ openssl dgst -sha1 -sign private.pem -out index.signature index.fingerprint

### Verifying Fingerprint Signature

You can easily verify the security of the fingerprint data:

	$ openssl dgst -sha1 -verify public.pem -signature index.signature index.fingerprint
	Verified OK
	-- Fingerprint data has been cryptographically verified

	$ fingerprint verify
	S 0 error(s) detected.
		error.count 0
	Data verified, 0 errors found.
	-- File list has been checked and no errors.

As long as private key is kept secure, we can be sure that these files have not been tampered with.

### Notarizing

In many cases it is good to ensure that documents existed at a particular time. With modern document storage systems, it may be impossible to verify this by simply relying on databases and filesystems alone, especially because technology can be manipulated.

Fingerprint can be used to produce printed documents which can be used to verify the existence of files at a given time. With appropriate physical signatures, these could be used to verify the existence of a given set of files at a specific time and place.

Simply follow the procedure to produce a cryptographic hash of a directory, print these documents out, and get them signed.

N.B. Please consult a lawyer for the correct procedure and legal standing of such techniques. This document is not legal advise and we accepts no responsibility for any use or misuse of this tool.
