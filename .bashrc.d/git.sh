#!/bin/bash
# ~/.bashrc.d/git.sh

alias gitaddcommit='git add -A . && git commit -m '

function clone-eis () {
    if [ -z ${1} ]; then
        echo "Usage: clone-eis <repo-name>"
        echo "Example: clone-eis platform.shared.bookjacket-image-resolver"
        echo "         -> git@gh-eis:EBSCOIS/platform.shared.bookjacket-image-resolver.git"
    else
        git clone "git@gh-eis:EBSCOIS/${1}.git"
    fi
}

function clone-daev () {
    if [ -z ${1} ]; then
        echo "Usage: clone-daev <repo-name>"
        echo "Example: clone-daev my-personal-project"
        echo "         -> git@gh-daev:daevski/my-personal-project.git"
    else
        git clone "git@gh-daev:daevski/${1}.git"
    fi
}

function git-del-branch() {
    branch="$1"
    git checkout main
    git branch -D "$branch" && git push origin --delete "$branch" && git fetch --prune
}