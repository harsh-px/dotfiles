# .bashrc

# User specific aliases and functions

source ~/env
[ -f ~/.kubectl_aliases ] && source ~/.kubectl_aliases


alias rm='rm -i'
alias cp='cp -i'
alias mv='mv -i'
alias vi='vim'
alias gitd='git ls-tree --no-commit-id --name-only -r"'

# Source global definitions
if [ -f /etc/bashrc ]; then
	. /etc/bashrc
fi

export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:/usr/lib64
export EDITOR=vi
export EC2_HOME=/usr/local/ec2/ec2-api-tools-1.7.1.0
export PATH=$PATH:/usr/local/bin/:$EC2_HOME/bin:/usr/local/go/bin:/opt/gccgo/bin:$HOME/git/go/bin/:$HOME/google-cloud-sdk/bin:$GOPATH/bin
export SHELL=bash

function auth() {
	eval "$(ssh-agent -s)"
	ssh-add ~/.ssh/github_rsa
}
function setup_branch () {
# note WA is used in .vimrc to set tags.
    [ -z "${GOPATH}" ] && echo "Warning GOPATH not defined.  Resetting to ${HOME}/git/go." && export GOPATH=${HOME}/git/go
    export WA="${GOPATH}/src/github.com/$1"
    export CSCOPE_DB=${WA}/.cscope/cscope.out
	export GDFS=${WA}/src/gdfs
	export P=${WA}/storage
	export B=${P}/disk/block
	export O=$WA/daemon/graphdriver/overlay
	export PATH=$PATH:$GOPATH/bin
	export PATH=$PATH:$WA/bin
	export PATH=$PATH:$WA/h
	cd $WA
}


function g() {

    [ -e "${HOME}/.px-user.env" ] && source ${HOME}/.px-user.env 
    
	setup_branch portworx/$1
	cd $WA
}

function d() {
	setup_branch "docker/docker"
	cd $WA
}

function make_tags() {
	(
	 cd $WA
	 ctags -R .
	 mkdir $WA/.cscope
	 find $WA -name '*.c' -o -name '*.h' -o -name '*.cc' -o -name '*.cpp' -o -name '*go' > $WA/.cscope/cscope.files
	 cd $WA/.cscope
	 cscope -b
	)
}

function doff() {
	sudo systemctl stop docker  && \
	sudo umount /dev/xvdg
}

function don() {
	sudo rm -rf /var/lib/docker && \
	sudo mkdir /var/lib/docker && \
	sudo mount /dev/xvdg /var/lib/docker &&  \
	sudo systemctl start docker
}

function pxdinstall() {
	sudo install $WA/storage/bin/pxd /usr/local/bin/pxd
	sudo install $WA/src/gdfs/pxd/px.ko /opt/pxd
	sudo install $WA/src/gdfs/overlayfs/overlay.ko /opt/pxd
}

function tarc() {
	if [ x"$1" == x ]; then
		echo "usage: tarc <outputfile>"
	else
		tar  -cvzf $1 `git status | grep "modified\|new" | awk -F: '{print $2}'`
	fi
}

function set_weave_env() {
    stat /usr/local/bin/weave &> /dev/null
    if [ $? -eq 0 ]; then
        eval $(/usr/local/bin/weave proxy-env)
    fi
}

# to use protoeasy for now, you must have docker installed locally or in a vm
# if running docker using docker-machine etc, replace 192.168.10.10 with the ip of the vm
# if running docker locally, replace 192.168.10.10 with 0.0.0.0
export PROTOEASY_ADDRESS=0.0.0.0:6789

export EDITOR=vim

launch-protoeasy() {
  docker rm -f protoeasy || true
  docker run -d -p 6789:6789 --name=protoeasy quay.io/pedge/protoeasy
}



source ~/aliases

if [ -f "$(brew --prefix)/opt/bash-git-prompt/share/gitprompt.sh" ]; then
  __GIT_PROMPT_DIR=$(brew --prefix)/opt/bash-git-prompt/share
  source "$(brew --prefix)/opt/bash-git-prompt/share/gitprompt.sh"
fi

if [ -f $(brew --prefix)/etc/bash_completion ]; then
  . $(brew --prefix)/etc/bash_completion
fi

cover () { 
    go test -tags unittest -coverprofile=profile.out $@ && go tool cover -html=profile.out
}


