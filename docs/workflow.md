# Workflow

This repository reconstructs the staged workflow used to consolidate a real household archive in August 2026.

The original project was **not** one end-to-end application. It was an iterative sequence of manual setup steps and PowerShell stages, with outputs reviewed before moving on.

## Starting situation

The OneDrive account was close to its cloud-storage limit, mainly because phone photos and videos had accumulated there. OneDrive was not installed or synchronised on the Windows PC.

The OneDrive data therefore entered the project through a manual browser download: the account contents were downloaded as **one large ZIP file** and extracted locally before PowerShell processing began.

At the same time:

- the SD card already contained years of photos and videos in old device/backup folders with little useful organisation;
- a small number of useful files also existed on the Windows PC;
- the SD card was also intended to become the permanent organised archive location.

## Completed project flow

```text
OneDrive cloud
     |
     | manual browser download as one large ZIP
     v
Extracted local OneDrive copy ----\
Windows PC useful files ------------> 1. Inventory
Legacy SD-card folders ------------/         |
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
                              Organised archive on the SD card
                                             |
                                             v
                              Verified before redundant cleanup
                                             |
                                             v
                           OneDrive cloud cleared after verification
                           Additional storage subscription cancelled
```

The public scripts start at the **local-source stage**. They do not download the original OneDrive ZIP and do not connect to OneDrive cloud.

## 1. Inventory

The first PowerShell stage established what actually existed before any reorganisation took place.

The real project produced separate inventory/summary outputs for:

- the extracted OneDrive download;
- the existing SD-card contents;
- the Windows PC.

The reconstructed `scripts/01-inventory.ps1` records:

- source group;
- relative and full path;
- filename and extension;
- file size;
- filesystem timestamp.

In the public reconstruction, the source label `OneDrive` means an **already downloaded and extracted local copy**, not a live OneDrive sync folder.

## 2. Dry-run planning

The archive was not reorganised directly. A proposed plan was generated first and reviewed.

The real project used a combination of:

- embedded media metadata where available;
- dates encoded in filenames;
- existing meaningful collection names;
- manual judgement for documented exceptions.

The public reconstruction keeps the same principle: deterministic rules first, explicit override/review for exceptions.

The exact destination layout in the reconstructed scripts is illustrative and privacy-safe. It is not claimed to be a byte-for-byte reproduction of the original working script.

## 3. Archive structure

The completed archive replaced the old device/backup-folder layout with a structure based mainly on capture date.

Contemporaneous project notes show representative paths following this pattern:

```text
Photos/
  YYYY/

Videos/
  YYYY/
    YYYY-MM/
```

Meaningful event collections were retained where reliable individual dates were unavailable instead of inventing dates. Useful documents were also retained where appropriate.

The final SD card no longer contains the old legacy device/backup-folder system; the organised archive is the permanent structure now in use.

## 4. Duplicate handling

Potential duplicates were narrowed using filename and file size, then checked with SHA-256.

This mattered because matching filenames and sizes were not sufficient evidence. In the original project, at least one apparently matching pair produced different SHA-256 hashes and was therefore correctly retained as two separate files.

Final project notes recorded:

- 52 exact duplicates confirmed;
- duplicate copies excluded from the copy plan;
- filename collisions preserved rather than blindly overwritten.

## 5. Copy, do not move

The project prioritised recoverability.

Files were copied into a new archive structure while the original source material was still available. This was especially important because some source files and the destination archive were on the same physical SD card.

The new archive could therefore be verified before redundant old source folders were cleaned up.

The reconstructed copy script follows the same principle and refuses to overwrite an existing destination.

## 6. Full verification

The final verification stage recalculated SHA-256 hashes for each copied source/destination pair.

The original completed result was:

- 3,288 files checked;
- 3,288 exact SHA-256 matches;
- 0 mismatches, missing files or corrupt copies reported by the verification stage.

The full hash pass was relatively slow, but the project accepted the runtime cost because data integrity mattered more than speed.

## 7. Cleanup and cost outcome

Only after verification had passed were the cloud copies removed from OneDrive.

That freed the cloud storage and allowed the additional storage subscription to be cancelled through Google Play before the paid period began.

The exact mechanism used to remove legacy SD-card folders is not reconstructed here. What is known is the final state: the old device/backup-folder structure is no longer present, and the organised archive remains on the SD card.

## 8. Human review and documentation

The project included judgement that should not be hidden behind automation. Examples included ambiguous dates, unusual camera-clock metadata and meaningful event collections.

The final archive included a plain-language README documenting the important decisions so a future user could understand why the structure looked the way it did.

## Not part of the completed implementation

A later idea explored a continuous pipeline using OneDrive Camera Backup, PowerShell and Windows Task Scheduler to ingest new media automatically, verify each file and remove verified cloud copies.

That idea was **not implemented**. No automatic OneDrive-to-archive service is running as part of this project; new phone media continues to accumulate in OneDrive through normal use.
