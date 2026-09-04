# Synthetic examples

Everything in this folder is invented demonstration data.

It is designed to show the shape of the reconstructed workflow without publishing any original household filenames, paths, documents, photos or account information.

## What the synthetic `OneDrive` source means

In the original project, OneDrive was not installed/synchronised on the Windows PC. The cloud archive was first downloaded manually through the browser as one large ZIP file and extracted locally.

The synthetic source group called `OneDrive` in this folder therefore represents an **already downloaded and extracted local copy**. The demo does not connect to OneDrive cloud and does not reproduce the browser download or ZIP extraction step.

## What the examples illustrate

- inventory rows from three local source groups;
- date inference and planning;
- an exact duplicate excluded after SHA-256 confirmation;
- a filename collision retained with a unique destination name;
- final source/destination verification.

The synthetic workflow also does not delete cloud files or cancel subscriptions. Those were later operational cleanup steps in the real project after the archive had been fully verified.

The example counts do **not** represent the original project. The real completed project result is documented separately in the main README.
