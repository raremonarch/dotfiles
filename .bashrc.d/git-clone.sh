#!/bin/bash
# Module: git-clone
# Version: 0.1.0
# Description: Git repository cloning shortcuts for multiple remotes
# BashMod Dependencies: git-ssh@0.1.0

DEVELOPMENT_DIR="$HOME/code"

function clone-repo () {
    if [ -z "$1" ] || [ -z "$2" ]; then
        echo "Usage: clone-repo <owner> <repo-name>"
        echo "Examples:"
        echo "  clone-repo EBSCOIS platform.shared.bookjacket-image-resolver"
        echo "    -> git@ebscois:EBSCOIS/platform.shared.bookjacket-image-resolver.git"
        echo "    -> $DEVELOPMENT_DIR/platform.shared.bookjacket-image-resolver"
        echo ""
        echo "  clone-repo daevski my-personal-project"
        echo "    -> git@daevski:daevski/my-personal-project.git"
        echo "    -> $DEVELOPMENT_DIR/my-personal-project"
        return 1
    fi

    local owner="$1"
    local repo_name="$2"
    local ssh_host=$(echo "$owner" | tr '[:upper:]' '[:lower:]')

    local git_url="git@${ssh_host}:${owner}/${repo_name}.git"
    local clone_path="$DEVELOPMENT_DIR/${repo_name}"

    ssh_load_key_for_url "$git_url" && git clone "$git_url" "$clone_path"
}

function git-del-branch() {
    branch="$1"
    git checkout main
    git branch -D "$branch" && git push origin --delete "$branch" && git fetch --prune
}
