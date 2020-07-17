# Use Cases

This guide explains some typical use cases for `fingerprint` and how to implement them.

## Transmission and Archival Usage

Fingerprint provides two high-level operations `analyze` which is roughly equivalent to `scan` but outputs to the file `index.fingerprint` by default, and `verify` which reads by default from `index.fingerprint`.

Typical use cases would include analyzing a directory before copying it, and verifying it after the copy, or analyzing a backup and verifying it before restore.

~~~ bash
-- Fingerprint the local data:
$ fingerprint --root /srv/http analyze

-- Copy it to the remote system:
$ rsync -a /srv/http production:/srv/http

-- Run fingerprint on the remote system to verify the data copied correctly:
$ ssh production fingerprint --root /srv/http verify
S 0 error(s) detected.
	error.count 0
~~~

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

~~~ bash
$ mv latest.fingerprint previous.fingerprint
$ ssh data.example.com fingerprint scan /etc > latest.fingerprint
$ fingerprint compare previous.fingerprint latest.fingerprint
S 0 error(s) detected.
	error.count 0
~~~

This can be scripted and run in an hourly cron job:

~~~ ruby
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
~~~

## Backup integrity

Data backup is typically an important part of any storage system. However, without end-to-end verification of backup data, it may not be possible to ensure that a backup system is working correctly. In the event that a failure occurs, data recovery may not be possible despite the existence of a backup, if that data has not been backed up reliably or correctly.

If you are backing up online data, the backup tool you are using may backup files at non-deterministic times. This means that if software (such as a database) is writing to a file at the time the backup occurs, the data may be transferred incorrectly. Fingerprint can help to detect this, by running fingerprint before the backup on the local storage, and then verifying the backup data after it has been copied. Ideally, you'd expect to see minimal changes to critical files.

However, the real world is often not so simple. Some software doesn't provide facilities for direct synchronization; other software provides facilities for dumping data (which may not be an option of the dataset is large). In these cases, fingerprint can give you some visibility about the potential issues you may face during a restore. You may want to consider [Synco](https://github.com/ioquatix/synco) which can coordinate more complex backup tasks.

### Ensuring Data Validity

To ensure that data has been backed up correctly, use fingerprint to analyze the data before it is backed up.

~~~ bash
-- Perform the data analysis
$ sudo fingerprint analyze -f /etc

-- Backup the data to a remote system
$ sudo rsync --archive /etc backups.example.com:/mnt/backups/server.example.com/etc
~~~

After the data has been copied to the remote backup device, restore the data to a temporary location and use fingerprint to verify the data. The exact procedure will depend on your backup system, e.g. if you use a tape you may need to restore from the tape to local storage first.

~~~ bash
-- On the backup server
$ cd /mnt/backups/server.example.com/etc
$ fingerprint verify
S 0 error(s) detected.
	error.count 0
~~~

### Preserving Backups

If your primary concern is ensuring that backup data is consistent over time (e.g. files are not modified or damaged), fingerprint can be used directly on the backup data to check for corruption. After the data has been backed up successfully, simply analyze the data as above, but on the backup server. Once this is done, at any point in the future you can verify the correctness of the backup set.

## Cryptographic Sealing

Fingerprint can be used to ensure that a set of files has been delivered without manipulation, by creating a fingerprint and signing this with a private key. The fingerprint and associated files can later be verified using the public key.

### Generating Keys

To sign fingerprints, the first step is to create a private and public key pair. This is easily achieved using OpenSSL:

~~~ bash
-- Create a private key, which you must keep secure.
$ openssl genrsa -out private.pem 2048
Generating RSA private key, 2048 bit long modulus
.............+++
........+++
e is 65537 (0x10001)

-- Create a public key, which can be used to verify sealed fingerprints.
$ openssl rsa -in private.pem -pubout -out public.pem
writing RSA key
~~~

### Signing Fingerprints

After you have generated a fingerprint, you can sign it easily using the private key:

~~~ bash
-- We assume here that you are using fingerprint analyze to generate fingerprints.
$ openssl dgst -sha1 -sign private.pem -out index.signature index.fingerprint
~~~

### Verifying Fingerprint Signature

You can easily verify the security of the fingerprint data:

~~~ bash
$ openssl dgst -sha1 -verify public.pem -signature index.signature index.fingerprint
Verified OK
-- Fingerprint data has been cryptographically verified

$ fingerprint verify
S 0 error(s) detected.
	error.count 0
Data verified, 0 errors found.
-- File list has been checked and no errors.
~~~

As long as private key is kept secure, we can be sure that these files have not been tampered with.

## Notarizing

In many cases it is good to ensure that documents existed at a particular time. With modern document storage systems, it may be impossible to verify this by simply relying on databases and filesystems alone, especially because technology can be manipulated.

Fingerprint can be used to produce printed documents which can be used to verify the existence of files at a given time. With appropriate physical signatures, these could be used to verify the existence of a given set of files at a specific time and place.

Simply follow the procedure to produce a cryptographic hash of a directory, print these documents out, and get them signed.

N.B. Please consult a lawyer for the correct procedure and legal standing of such techniques. This document is not legal advice and we accept no responsibility for any use or misuse of this tool.
