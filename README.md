# PowerShell Photo Archive Automation

AI-assisted PowerShell workflow for consolidating, organising and verifying a real multi-source household photo archive.

The original problem was practical: cloud storage was approaching its limit, the Windows PC was also under storage pressure, and an SD card already contained years of photos and videos with very little useful organisation. Rather than pay indefinitely for additional cloud storage, the goal was to create one safe, chronological local archive that a non-technical user could browse and understand.

## What the project did

The completed project used a staged PowerShell workflow to:

- inventory files from three sources: OneDrive, a Windows PC and an SD card;
- analyse file types, folder sizes and source locations;
- build a dry-run copy plan before changing anything;
- determine usable dates from metadata, filenames and documented exceptions;
- organise media into a clearer chronological archive structure;
- identify potential duplicates;
- confirm exact duplicates with SHA-256 rather than relying only on filename or size;
- preserve files when names collided but hashes showed the contents were different;
- copy the planned archive;
- verify every copied source/destination pair byte-for-byte with SHA-256;
- document the archive rules and final outcome.

## Result

The final verification completed successfully:

- **3,288 files checked**
- **3,288 exact SHA-256 matches**
- **0 verification problems**
- **52 exact duplicates identified and excluded from duplicate copying**

The result was a consolidated archive that was easier to navigate, no longer dependent on the original folder layout, and verified before redundant source data was removed.

## Workflow

```text
OneDrive ---------\
Windows PC --------> Inventory -> Analyse -> Dry run -> Copy -> SHA-256 verify -> Final archive
SD card ----------/
```

The project was deliberately stage-based rather than a single monolithic script. Each stage produced evidence that was reviewed before proceeding to the next.

## Safety and data-integrity decisions

The main design principle was to avoid destructive changes until the archive had been proved safe.

Key safeguards included:

- dry-run planning before copying;
- no blind overwrite of filename collisions;
- SHA-256 comparison for duplicate confirmation;
- source-versus-destination SHA-256 verification after copying;
- retention of files when two apparently similar items produced different hashes;
- documented handling of uncertain dates and special collections;
- no deletion as part of the verification step.

A full SHA-256 pass across thousands of files was relatively slow, but the extra runtime was accepted because data integrity mattered more than speed for this project.

## AI-assisted development

This was an AI-assisted development project.

I identified the storage and organisation problem, decided that a chronological archive would be more usable, and worked iteratively with ChatGPT to design the workflow, rules and safeguards. ChatGPT helped generate stage-specific PowerShell scripts and commands. I ran them on the Windows machine, inspected the outputs, returned the results to the conversation, and then decided or followed the next stage.

The process was therefore collaborative rather than a claim that every line was written unaided.

## Public-repository reconstruction

The original working PowerShell files were not retained after the archive project was completed.

This public repository therefore reconstructs the workflow from preserved project outputs, surviving code fragments and contemporaneous documentation. Reconstructed code is labelled as such and is not presented as the exact original source.

All public examples are sanitised. Real names, account details, personal filenames, private documents and original filesystem paths are excluded or replaced with synthetic data.

## What was not implemented

A possible later design explored turning OneDrive into a temporary ingestion buffer using PowerShell and Windows Task Scheduler, with automatic copy, verification and source cleanup.

That continuous OneDrive ingestion pipeline was **an idea only and was not implemented** as part of the completed project.

## Why this project matters

The technical work was useful, but the project started with a real operational problem rather than with a technology choice:

- cloud storage cost was about to become an ongoing expense;
- media was spread across multiple storage locations;
- an existing SD-card archive was poorly organised;
- the archive needed to remain understandable to a non-technical user;
- data loss was unacceptable.

PowerShell, staged validation and SHA-256 verification were used because they addressed those constraints directly.

## Repository status

This repository is being rebuilt as a privacy-safe portfolio version of the completed project. The next stages are to add reconstructed PowerShell scripts, synthetic sample data and sanitised example outputs that demonstrate the workflow without exposing private information.
