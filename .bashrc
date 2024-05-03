set bell-style none

# Note: you can list all functions and aliases in this file
alias custom-functions="grep -hiroP 'function \K[\w-]+|alias \K[\w-]+' .bashrc"

# ----------------------------
#     Exec On Bashrc Load     
# ----------------------------
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion


# -----------------------
#         System         
# -----------------------
alias pwdsize='du -sh .'
alias tstamp='~/Scripts/timestamp-to-clipboard.sh'

function timeit {
    echo "Starting function timer ..."; START_TIME=$(date +%s); $1; END_TIME=$(date +%s); echo "That took ... $(($END_TIME - $START_TIME)) seconds."
}

# -----------------------
#         OpenStack      
# -----------------------
alias oa='source ~/.openstack/activate-openstack.sh'
alias o-sl='openstack server list'
alias o-ss='openstack server show'
alias o-il='openstack image list'
alias o-fl='openstack flavor list'
alias o-nl='openstack network list'
alias o-srw16='openstack server rebuild --image be0a195a-0c04-403a-8351-a8182c26e905'

# -----------------------
#         Docker         
# -----------------------
#DOCKER_REGISTRY_URL='pdc-v-nvdocker1.epnet.com:5000'

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
