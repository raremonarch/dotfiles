# dotfiles Integration Guide

This repository is designed to help you manage and track configuration files (dotfiles) in your home directory. To integrate this repository with your system, follow these steps:

## 1. Clone to a Temporary Directory

Clone the repository to a temporary location (not directly to your home folder):

```bash
git clone https://github.com/daevski/dotfiles.git /tmp/dotfiles
```

## 2. Copy Git Metadata to Your Home Folder

Copy the `.git/` directory and `.gitignore` file from the cloned repo to your home directory:

```bash
cp -r /tmp/dotfiles/.git ~/
cp /tmp/dotfiles/.gitignore ~/
```

This will allow you to track differences between the repository and your actual home directory files.

## 3. Review and Merge Files

Manually review and merge any files from the repository that you wish to include in your home directory. Do **not** overwrite your files blindly—carefully compare and merge changes as needed.

## 4. Track New Files and Folders

To track new files or folders in your home directory, add them to your `.gitignore` file. Be selective to avoid overburdening the repository. Only add files and folders that are important to track.

**Note:**

- To properly track a folder and all its contents, you need to list the folder twice in `.gitignore`: once as the folder name, and a second time with a trailing `/**` to include all files and subfolders. For example:

  ```plaintext
  myfolder
  myfolder/**
  ```

- However, it is generally better to target specific files rather than entire folders, to keep the repository manageable.

## 5. Commit and Push Changes

After making changes and updating `.gitignore`, you can commit and push your changes as usual:

```bash
git add .
git commit -m "Update tracked dotfiles"
git push
```

---

**Always review changes before committing to avoid accidentally tracking sensitive or unnecessary files.**
