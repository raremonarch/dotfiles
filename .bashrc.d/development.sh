#!/bin/bash
# ~/.bashrc.d/development.sh

# --------------------
#         Git
# --------------------
alias gitaddcommit='git add -A . && git commit -m '

function clone-eis () {
    if [ -z ${1} ]; then
        echo "Usage: clone-eis git@github.com:EBSCOIS/devex-gha-workflows.git"
    else
        git clone "${1//github.com/gh-eis}"
    fi
}
function clone-daev () {
    if [ -z ${1} ]; then
        echo "Usage: clone-daev git@github.com:EBSCOIS/devex-gha-workflows.git"
    else
        git clone "${1//github.com/gh-daev}"
    fi
}
function git-del-branch() {
  branch="$1"
  git checkout main
  git branch -D "$branch" && git push origin --delete "$branch" && git fetch --prune
}
# -----------------------
#         Docker         
# -----------------------
function docker-nukec {
    all_ids=`docker ps -aq`
    docker stop $all_ids; docker rm $all_ids
}

function docker-purge-all {
    docker system prune -a --volumes
}

# -----------------------
#         Python         
# -----------------------
function cdpydev () {
    cd /f/Development/Personal/Private/Python
}

function poetryreq () {
    cmd='poetry export -f requirements.txt --without-hashes'
    if [ -z ${1} ]; then
        cmd+=' -o requirements.txt'
        echo "$cmd"
        ${cmd}
    elif [ ${1} == "--dev" ]; then
        cmd1="${cmd} -o requirements.txt"
        cmd2="${cmd} -o requirements_dev.txt --with dev"
        echo "$cmd1"
        ${cmd1}
        echo "$cmd2"
        ${cmd2}
    fi
}

function pycov () {
    pytest --cov-report term-missing:skip-covered --cov=.
}

function pycov-all () {
    pytest --cov-report term-missing --cov=.
}

function coverage-check () {
    coverage report --fail-under=80 --show-missing
}
