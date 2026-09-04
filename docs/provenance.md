# Provenance and reconstruction status

This repository is a public portfolio reconstruction of a real project completed on a Windows PC in August 2026.

## What is original project evidence

The following artefacts survived after the original scripts were deleted:

- PC inventory output;
- PC file-type and folder-total summaries;
- SD-card file-type and folder-total summaries;
- OneDrive file-type and folder-total summaries;
- duplicate-verification output;
- final archive dry-run output;
- final archive notes/README;
- the recorded final SHA-256 verification result;
- a surviving PowerShell fragment for the full source/destination verification stage;
- contemporaneous ChatGPT conversation records describing the staged process.

Those artefacts establish the project flow and final outcome without requiring the original private data to be published.

## What is reconstructed

The PowerShell scripts in `scripts/` were created later for this public repository.

They are reconstructed from:

1. preserved project outputs;
2. the surviving verification-code fragment;
3. the documented rules and decisions from the original work;
4. the stage order used during the project.

They are **not** presented as the exact original `.ps1` files.

The reconstructed scripts intentionally favour readability, explicit safety checks and synthetic demonstration data over reproducing private filesystem details.

## AI-assisted development

The original project was developed collaboratively with ChatGPT.

The human role included:

- identifying the storage, cost and organisation problem;
- deciding that a chronological archive was required;
- running the PowerShell scripts/commands on the Windows machine;
- inspecting outputs;
- feeding results back into the conversation;
- approving or deciding next steps;
- completing the real copy and verification process.

ChatGPT helped:

- break the project into stages;
- propose rules and safeguards;
- generate stage-specific PowerShell code;
- interpret outputs;
- suggest the next technical step.

This repository describes that process as collaborative rather than claiming the code was written unaided.

## What is deliberately excluded

The public repository does not contain:

- original family names;
- Microsoft account information;
- original Windows usernames;
- original filesystem paths;
- personal photographs or videos;
- personal document names or contents;
- raw original inventories or logs;
- the original archive itself.

## Unimplemented idea

A later continuous OneDrive-to-local ingestion design was discussed, including Windows Task Scheduler and automatic cleanup after verification.

It was **not implemented**. It is mentioned only to distinguish the idea from the completed staged archive project.
