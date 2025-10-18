#!/bin/bash
# Dotfiles Module - Initialize $HOME as git repo and pull dotfiles

DOTFILES_REPO="${1:-https://github.com/daevski/dotfiles.git}"
DOTFILES_BRANCH="${2:-main}"

echo "  dotfiles module starting ..."

# Change to home directory
cd "$HOME"

# Check if already initialized as a git repo
if [ -d "$HOME/.git" ]; then
    echo "    git repository already exists in \$HOME"
    echo "    fetching latest changes ..."
    git fetch origin
    echo "    resetting to origin/$DOTFILES_BRANCH ..."
    git reset --hard "origin/$DOTFILES_BRANCH"
    echo "    repository updated"
else
    echo "    initializing \$HOME as git repository ..."
    git init

    echo "    setting default branch to $DOTFILES_BRANCH ..."
    git branch -m "$DOTFILES_BRANCH"

    echo "    adding remote origin ..."
    git remote add origin "$DOTFILES_REPO"

    echo "    setting upstream branch ..."
    git branch --set-upstream-to=origin/$DOTFILES_BRANCH "$DOTFILES_BRANCH"

    echo "    fetching from origin ..."
    git fetch origin

    echo "    pulling dotfiles ..."
    if git reset --hard "origin/$DOTFILES_BRANCH"; then
        echo "    dotfiles deployed successfully"
    else
        echo "    ERROR: failed to pull dotfiles"
        return 1
    fi
fi

echo "  dotfiles module complete"
