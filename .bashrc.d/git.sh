#!/bin/bash
# ~/.bashrc.d/git.sh

alias gitaddcommit='git add -A . && git commit -m '

function clone-eis () {
    if [ -z ${1} ]; then
        echo "Usage: clone-eis <repo-name>"
    echo "Example: clone-eis platform.shared.bookjacket-image-resolver"
    echo "         -> git@eis:EBSCOIS/platform.shared.bookjacket-image-resolver.git"
    else
    git clone "git@eis:EBSCOIS/${1}.git" ~/development/eis/${1}
    fi
}

function clone-daevski () {
    if [ -z ${1} ]; then
        echo "Usage: clone-daevski <repo-name>"
    echo "Example: clone-daevski my-personal-project"
    echo "         -> git@daevski:daevski/my-personal-project.git"
    else
    git clone "git@daevski:daevski/${1}.git" ~/development/daevski/${1}
    fi
}

function git-del-branch() {
    branch="$1"
    git checkout main
    git branch -D "$branch" && git push origin --delete "$branch" && git fetch --prune
}