# Validation checklist for the public reconstruction

The original archive project completed successfully, but the exact original `.ps1` files were not retained. The scripts in this repository are later reconstructions and should be validated on disposable synthetic data before anyone uses them on personal files.

## Recommended test sequence

1. Create three temporary source folders representing OneDrive, PC and SD-card inputs.
2. Add only synthetic/disposable files.
3. Include:
   - one exact duplicate with the same filename and size;
   - one same-name collision containing different data;
   - one filename containing a `YYYYMMDD` date;
   - one file with no usable filename date;
   - one manual date override.
4. Run `01-inventory.ps1` against each source.
5. Review the inventory CSVs before proceeding.
6. Run `02-build-copy-plan.ps1` and inspect every `Action`, `DateBasis`, destination and note.
7. Confirm exact duplicates are skipped only after SHA-256 comparison.
8. Confirm same-name but different files are retained with unique destination names.
9. Run `03-copy-archive.ps1` first with `-WhatIf`.
10. Review the proposed actions, then run the real copy against the disposable archive root.
11. Run `04-verify-archive.ps1`.
12. Confirm all copied source/destination hashes match.
13. Deliberately alter one destination file and re-run verification; the script should report a problem and return a non-zero exit status.
14. Deliberately remove one source/destination file and confirm the error is recorded.

## Important

These reconstructed scripts are portfolio/reference code, not a claim that the exact public version has been run against the original private archive.

The original project result remains separately evidenced by preserved outputs: 3,288 files checked, 3,288 exact SHA-256 matches, and zero verification problems.
