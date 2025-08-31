# dotfiles

This repository contains configuration files and scripts for your system setup.

## How to update the repository

To copy new files/directories from your system into this repository, run:

```bash
./SYNC.sh
```

- Any files or directories that do not already exist in the repository will be copied automatically.
- If a file or directory already exists in the repository, it will NOT be overwritten. Instead, you will see a summary at the end of the script listing all such items.
- You should manually compare and merge any files or directories listed in the summary to ensure your repository stays up to date with your system changes.

## Note

Backup files (with a `.bak.YYYYMMDDHHMMSS` timestamp) are ignored and not copied into the repository.
