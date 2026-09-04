# PowerShell Photo Archive Automation

[![PowerShell smoke test](https://github.com/jdohertydev/powershell-photo-archive-automation/actions/workflows/powershell-smoke-test.yml/badge.svg)](https://github.com/jdohertydev/powershell-photo-archive-automation/actions/workflows/powershell-smoke-test.yml)

AI-assisted PowerShell workflow for consolidating, organising and verifying a real multi-source household archive.

## The problem

The project began because a household OneDrive account was close to its cloud-storage limit, mainly because phone photos and videos had accumulated there. OneDrive was **not installed or synchronised on the Windows PC**, so the cloud files were not available locally as a normal OneDrive folder.

The first step was therefore manual: the entire OneDrive contents were downloaded through the browser as **one large ZIP file** and extracted locally.

That was only part of the problem. An SD card already contained years of photos and videos in old device/backup folders with little useful organisation, and a small number of useful files also existed on the Windows PC. The goal became to consolidate those sources into one understandable chronological archive, avoid unnecessary duplicate copies, verify the result before cleanup, and free the OneDrive storage before an additional storage subscription began charging.

## Outcome

The completed project finished with:

- **3,288 files copied into the final archive**
- **3,288 exact SHA-256 source/destination matches**
- **0 verification problems**
- **52 exact duplicates identified and not copied twice**
- the permanent organised archive stored on the SD card
- the old OneDrive cloud contents removed after verification, freeing the cloud storage
- the additional OneDrive storage subscription cancelled through Google Play before the paid period began

The SD card now contains the organised archive rather than the old device/backup-folder structure.

## Completed project flow

```text
OneDrive cloud
     |
     | manual browser download as one large ZIP
     v
Extracted local OneDrive copy ----\
Windows PC useful files ------------> Inventory -> Analyse -> Dry run -> Copy -> SHA-256 verify
Legacy SD-card folders ------------/                                |
                                                                    v
                                                     Organised archive on SD card
                                                                    |
                                                                    v
                                                  Verified before source cleanup
                                                                    |
                                                                    v
                                        OneDrive cloud cleared + subscription cancelled
```

The PowerShell work began **after** the OneDrive ZIP had been downloaded and extracted. This project did not use the OneDrive desktop sync client or a OneDrive API to obtain the original cloud archive.

## What I built

The original technical work was deliberately stage-based rather than one monolithic application. PowerShell was used to:

1. inventory the extracted OneDrive download, the Windows PC and the existing SD-card contents;
2. analyse file types, sizes and source locations;
3. build a dry-run archive plan before copying anything;
4. determine usable dates from metadata, filenames and documented exceptions;
5. organise media into a clearer chronological structure;
6. narrow potential duplicates using filename and size;
7. confirm exact duplicates using SHA-256;
8. preserve filename collisions when the underlying files were different;
9. copy files into a new archive structure rather than destructively moving them;
10. run a full SHA-256 source/destination verification pass;
11. document the archive rules and final result.

After verification passed, the cloud copies could be removed safely and the additional storage subscription was cancelled. The cloud cleanup and subscription cancellation were operational follow-up steps, not PowerShell automation.

## Final archive organisation

The completed archive replaced device-oriented folders with a structure based mainly on capture date. Contemporaneous project notes show representative paths following this pattern:

```text
Photos/
  YYYY/

Videos/
  YYYY/
    YYYY-MM/
```

Meaningful event collections were preserved when reliable individual dates were unavailable, rather than inventing dates. Useful documents were also retained where appropriate.

The public reconstructed scripts use a privacy-safe illustrative destination layout and should not be treated as a byte-for-byte reproduction of every private folder rule used in the original archive.

## Why the workflow was cautious

This was personal data, so the project favoured recoverability over speed.

Safeguards included:

- dry-run planning before the real copy;
- copy rather than move;
- creation of the new archive while legacy SD-card source folders were still available;
- no blind overwriting of filename collisions;
- SHA-256 confirmation before treating files as exact duplicates;
- retention of apparently similar files when hashes differed;
- full source-versus-destination verification after copying;
- manual handling of ambiguous dates and special collections;
- cleanup only after verification;
- documentation of important archive decisions.

The full hash verification across thousands of files took a long time, but that was accepted because confidence in the archive mattered more than runtime.

## AI-assisted development

This was an AI-assisted development project.

I identified the storage, cost and organisation problem and decided that a chronological archive would be more usable. I then worked iteratively with ChatGPT to design the stages, rules and safeguards.

ChatGPT helped generate stage-specific PowerShell scripts and commands. I personally ran them on the Windows machine, inspected the outputs, copied results back into the conversation, and then decided or followed the next step. The process repeated until the archive and verification were complete.

The project is therefore described as **collaborative AI-assisted development**, not as code written entirely unaided.

## Public portfolio reconstruction

The exact original `.ps1` files were deleted after the real archive project was completed.

The scripts in this repository are therefore **later reconstructions**, based on:

- preserved project CSV outputs;
- the surviving final-verification PowerShell fragment;
- contemporaneous project notes;
- the recorded ChatGPT development conversation;
- the actual stage order and rules used during the project.

They are not presented as byte-for-byte copies of the original scripts.

The original private CSVs are also not published because they contain personal filenames and filesystem paths. Synthetic equivalents are provided instead.

See [`docs/provenance.md`](docs/provenance.md) for the evidence/reconstruction boundary.

## Repository structure

```text
scripts/
  01-inventory.ps1
  02-build-copy-plan.ps1
  03-copy-archive.ps1
  04-verify-archive.ps1

docs/
  workflow.md
  provenance.md
  privacy.md
  validation-checklist.md

examples/
  README.md
  run-synthetic-demo.ps1
  synthetic-inventory.csv
  synthetic-plan.csv
  synthetic-verification.csv
  synthetic-overrides.csv
```

### Reconstructed scripts

- **`01-inventory.ps1`** — scans a local source and exports a structured file inventory.
- **`02-build-copy-plan.ps1`** — creates the dry-run plan, classifies files, infers dates, checks duplicate candidates with SHA-256 and preserves destination collisions.
- **`03-copy-archive.ps1`** — copies planned files without overwriting and records a transaction log. Supports `-WhatIf`.
- **`04-verify-archive.ps1`** — recalculates SHA-256 hashes for each planned source/destination pair and reports any mismatch or missing file.

In the public demo, the source group called `OneDrive` represents an **already downloaded and extracted local copy**. The reconstructed scripts do not connect to OneDrive cloud.

## Synthetic demo and CI

No real household data is required to inspect the workflow.

`examples/run-synthetic-demo.ps1` creates disposable synthetic files and runs the reconstructed inventory, planning, copy and verification stages end to end.

```powershell
powershell -ExecutionPolicy Bypass -File .\examples\run-synthetic-demo.ps1
```

The same synthetic end-to-end flow runs automatically on a Windows GitHub Actions runner after each push or pull request. The workflow checks that verification output is created and that every synthetic copied file passes SHA-256 comparison.

The generated workspace is ignored by Git. The example media files contain synthetic text data; they exist only to exercise the file-processing logic.

Because the public scripts are later reconstructions rather than the original working files, they should still be validated on disposable data before use with anything important. A test sequence is provided in [`docs/validation-checklist.md`](docs/validation-checklist.md).

## Privacy

This repository is completely sanitised for public use.

It contains no:

- family names;
- personal Microsoft account details;
- original Windows usernames;
- real personal filenames;
- personal photos, videos or documents;
- original private filesystem paths;
- raw private inventories or logs.

All paths, filenames and data in `examples/` are synthetic. See [`docs/privacy.md`](docs/privacy.md).

## What was not implemented

After the completed one-off archive project, a possible future design was discussed in which new phone media uploaded to OneDrive Camera Backup would feed a continuous PowerShell/Windows Task Scheduler ingestion process with automatic verification and cloud cleanup.

That continuous pipeline was **an idea only. It was not implemented.** There is no automatic OneDrive-to-archive service running as part of this project. New phone media therefore continues to accumulate in OneDrive through normal use.

## Skills demonstrated

- PowerShell scripting
- staged workflow automation
- Microsoft OneDrive / Windows problem solving
- translating a cloud-storage problem into a controlled local workflow
- file and data inventory design
- duplicate detection
- SHA-256 integrity verification
- dry-run and non-destructive workflow design
- exception handling and human review
- documentation and handover thinking
- AI-assisted iterative development
- translating a real user problem into a technical process
