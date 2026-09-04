# Workflow

This repository reconstructs the staged workflow used to consolidate a real household archive from three sources: a downloaded OneDrive copy, a Windows PC and an SD card containing an older, poorly organised media collection.

The original project was not one end-to-end application. It was an iterative sequence of PowerShell stages. Results from each stage were reviewed before moving on.

## Completed project flow

```text
OneDrive download ----\
Windows PC ------------> 1. Inventory
SD card --------------/         |
                                v
                         2. Analyse + plan
                                |
                                v
                       Duplicate candidates
                      filename + size first
                                |
                                v
                         SHA-256 confirmation
                                |
                                v
                           Dry-run review
                                |
                                v
                              Copy
                                |
                                v
                    SHA-256 source/destination
                           verification
                                |
                                v
                       Documented final archive
```

## 1. Inventory

The first stage establishes what actually exists before any reorganisation takes place.

The reconstructed `scripts/01-inventory.ps1` records:

- source group;
- relative and full path;
- filename and extension;
- file size;
- filesystem timestamp.

The real project produced separate PC, SD-card and OneDrive inventory/summary outputs.

## 2. Dry-run planning

The archive was not reorganised directly. A proposed plan was generated first and reviewed.

The real project used a combination of:

- embedded media metadata where available;
- dates encoded in filenames;
- existing meaningful collection names;
- manual judgement for documented exceptions.

The public reconstruction keeps the same principle: deterministic rules first, explicit override/review for exceptions.

The exact destination layout in the reconstructed scripts is illustrative and privacy-safe. It is not claimed to be a byte-for-byte reproduction of the original working script.

## 3. Duplicate handling

Potential duplicates were narrowed using filename and file size, then checked with SHA-256.

This mattered because matching filenames and sizes were not sufficient evidence. In the original project, at least one apparently matching pair produced different SHA-256 hashes and was therefore correctly retained as two separate files.

Final project notes recorded:

- 52 exact duplicates confirmed;
- duplicate copies excluded from the copy plan;
- filename collisions preserved rather than blindly overwritten.

## 4. Copy, do not move

The project prioritised recoverability.

The archive was copied into a new structure while source material remained in place. That allowed the destination to be verified before redundant source copies were considered for cleanup.

The reconstructed copy script follows the same principle and refuses to overwrite an existing destination.

## 5. Full verification

The final verification stage recalculated SHA-256 hashes for each copied source/destination pair.

The original completed result was:

- 3,288 files checked;
- 3,288 exact SHA-256 matches;
- 0 mismatches, missing files or corrupt copies reported by the verification stage.

The full hash pass was relatively slow, but the project accepted the runtime cost because data integrity mattered more than speed.

## 6. Human review and documentation

The project included judgement that should not be hidden behind automation. Examples included ambiguous dates, unusual camera-clock metadata and meaningful event collections.

The final archive included a plain-language README documenting the important decisions so a future user could understand why the structure looked the way it did.

## Not part of the completed implementation

A later idea explored a continuous pipeline using OneDrive Camera Backup, PowerShell and Windows Task Scheduler to ingest new media automatically and remove verified cloud copies.

That idea was **not implemented** and is intentionally excluded from the reconstructed scripts in this repository.
