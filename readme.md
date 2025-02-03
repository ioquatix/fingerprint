# Fingerprint

> Matter and energy degrade to more probable, less informative states. The larger the amounts of information processed or diffused, the more likely it is that information will degrade toward meaningless variety, like noise or information overload, or sterile uniformity — Orrin Klapp

Fingerprint is a general purpose data integrity tool that uses cryptographic hashes to detect changes in files and directory trees. The fingerprint command scans a directory tree and generates a fingerprint file containing the names and cryptographic hashes of the files in the tree. This snapshot can be later used to generate a list of files that have been created, deleted or modified. If so much as a single bit in the file data has changed, Fingerprint will detect it.

Traditionally, the only way to preserve data was to take regular backups and hope that any unwanted changes that occurred would be major, obvious ones (such as loss of the disk). This approach means trusting all the software to which the data is exposed: operating systems, backup software, communications software, compression software, encryption software, and archiving software. Unfortunately, each of these systems is highly complex and can inflict all kinds of damage on data, much of the damage undetectable to humans. Fingerprint allows data to be monitored, detecting even the change of a single bit.

[![Development Status](https://github.com/ioquatix/fingerprint/workflows/Test/badge.svg)](https://github.com/ioquatix/fingerprint/actions?workflow=Test)

## Features

Fingerprint can be used for:

  - Preservation: Detect corruption of important data, e.g. web server integrity, write-once storage verification.
  - Security: Detect changes made by intruders, e.g. firewall integrity, network configuration, software auditing.
  - Transfers:  Verify file copies and transfers between different systems, e.g. file transfer integrity.
  - Sealing: Cryptographically seal critical files, e.g. document verification.
  - Notarizing: Prove that documents existed at a particular time.
  - Backups: Verify restored backups to ensure that backups are sound, e.g. backup verification and integrity.

A companion app is available in the [Mac App Store](https://itunes.apple.com/nz/app/fingerprint/id470866821). Purchasing this app helps fund the open source software development.

## Motivation

As the world becomes further entrenched in digital data and storage, the accuracy and correctness of said data is going to become a bigger problem. As humans create information, we are ultimately decreasing the amount of entropy in the universe. By the second law of thermodynamics, when a closed system moves from "the least to the most probable, from differentiation to sameness, from ordered individuality to a kind of chaos," (Thomas Pynchon) the only logical conclusion is that what we consider to be important data is destined to become meaningless noise in the sands of time.

When I first suffered data-loss, it wasn't catastrophic - it was the slow deterioration of a drive which silently corrupted many files. After this event, I wanted a tool which would allow me to minimize the chance of this happening in the future. When I take a backup now, I also make a fingerprint. If I ever need to restore from backup, I can be confident the data is as it was when it was backed up.

As fingerprint provides a fast way to compare the files, I've also extended it to find duplicates within one or more fingerprints. This is useful for de-duplicating your home directory and I've also used it when marking assignments to find blatant copying.

In cases where I've been concerned about the migration of data (e.g. copying my entire home directory from one system to another), I've used fingerprint to generate a transcript on the source machine, and then run it on the destination machine, to reassure me that the data was copied correctly and completely.

## Usage

Please see the [project documentation](https://ioquatix.github.io/fingerprint).

## Todo

  - Command line option to show files that have changed but have the same modified time (hardware corruption).
  - Supporting tools for signing fingerprints easily.
  - Because fingerprint is currently IO bound in terms of performance, single-threaded checksumming is fine, but for SSD and other fast storage, it might be possible to improve speed somewhat by using a map-reduce style approach.

## Contributing

We welcome contributions to this project.

1.  Fork it.
2.  Create your feature branch (`git checkout -b my-new-feature`).
3.  Commit your changes (`git commit -am 'Add some feature'`).
4.  Push to the branch (`git push origin my-new-feature`).
5.  Create new Pull Request.

### Developer Certificate of Origin

In order to protect users of this project, we require all contributors to comply with the [Developer Certificate of Origin](https://developercertificate.org/). This ensures that all contributions are properly licensed and attributed.

### Community Guidelines

This project is best served by a collaborative and respectful environment. Treat each other professionally, respect differing viewpoints, and engage constructively. Harassment, discrimination, or harmful behavior is not tolerated. Communicate clearly, listen actively, and support one another. If any issues arise, please inform the project maintainers.
