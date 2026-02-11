eval "$(starship init zsh)"

# History settings
HISTSIZE=10000
SAVEHIST=10000
setopt HIST_IGNORE_DUPS SHARE_HISTORY

# PATH exports (consolidated)
export PATH=/opt/bin:$PATH
export PATH=/Users/ericbinnion/jurassictube/jurassictube.sh:$PATH
export PATH="$PATH:$HOME/.composer/vendor/bin"
export PATH="$PATH:$HOME/.local/bin"
export PATH="$PATH:$HOME/Repos/site-gardener"

export EDITOR='nano'

export OPENAI_API_KEY=$(security find-generic-password -a "$USER" -s "OPENAI_API_KEY" -w 2>/dev/null)

# NVM
export NVM_DIR="$HOME/.nvm"
[ -s "/opt/homebrew/opt/nvm/nvm.sh" ] && \. "/opt/homebrew/opt/nvm/nvm.sh"
[ -s "/opt/homebrew/opt/nvm/etc/bash_completion.d/nvm" ] && \. "/opt/homebrew/opt/nvm/etc/bash_completion.d/nvm"

export SBT_OPTS="-DsocksProxyHost=127.0.0.1 -DsocksProxyPort=8080 -Duser.timezone=UTC"
alias phpcsadd='phpcs --config-set installed_paths'
alias phpcsinstallpaths='phpcsadd /Users/ericbinnion/Repos/phpcs-variable-analysis,/Users/ericbinnion/Repos/wpcs'

alias reload='source ~/.zshrc'
alias zshconfig="code ~/.zshrc"
alias ll='ls -lah'

###################
###### a8c ########
###################

export calypso_path='/Users/ericbinnion/Repos/wp-calypso'
export a8c_sandbox_path='/Users/ericbinnion/Repos/automattic-sandbox'
export wpcom_path="$a8c_sandbox_path/wpcom/public_html"
export mc_path="$a8c_sandbox_path/missioncontrol/public_html"
export org_jetpack_path='/Users/ericbinnion/Repos/jetpack'
export woa_path="$org_jetpack_path/tools/docker/mu-plugins/wpcomsh"

alias calypso="cd $calypso_path"
alias calypsoedit="code $calypso_path"
alias calypsostart='calypso && NODE_OPTIONS="--max-old-space-size=8192" yarn start'
alias mc="cd $mc_path"
alias wpcom="cd $wpcom_path"
alias wpcomedit="code $wpcom_path"
alias cdjetpack="cd $org_jetpack_path"
alias cdwoa="cd $woa_path"
alias woaedit="code $woa_path"

# WooCommerce
alias woolocal="cd /Users/ericbinnion/Sites/woo-dev && npx @wordpress/env start"
alias wootunnel="cloudflared tunnel run woo-dev"
alias woodevstart="woolocal && wootunnel"
alias woodevstop="cd /Users/ericbinnion/Sites/woo-dev && npx @wordpress/env stop"
alias woodevlogs="cd /Users/ericbinnion/Sites/woo-dev && npx @wordpress/env logs"
alias woorelease='php ~/.woorelease/woorelease.phar'

alias jtwooup='jurassictube -u ebinnion -s binnionwoodev -h localhost:80'
alias jtwoodown='jurassictube -b -s binnionwoodev'

# WP.com
alias devitup='ssh wpcom-sandbox'
alias unisondown='unison -ui text automattic-sandbox -force ssh://wpdev@ebinnion.dev.dfw.wordpress.com//home -batch'
alias unisync='unison -ui text -repeat 1 automattic-sandbox'

# Jetpack
alias jtup='jurassictube -u ebinnion -s ebinnion -h localhost:80'
alias jtdown='jurassictube -b -s ebinnion'

alias jppnpm='pnpm install && pnpx jetpack cli link'
alias jpdevstart='cdjetpack && jtup && jetpack docker up -d && open https://ebinnion.jurassic.tube/wp-admin && code ./'
alias jpdevstop='cdjetpack && jtdown && jetpack docker down'

alias wowitup='ssh binnionwoa.wordpress.com@ssh.wp.com'

# General

alias pacon='networksetup -setautoproxystate Wi-Fi on && networksetup -setautoproxystate USB-LAN on'
alias pacoff='networksetup -setautoproxystate Wi-Fi off && networksetup -setautoproxystate USB-LAN off'

alias wpenvcli='wp-env run cli'

alias copydir='pwd | pbcopy'

###################
####### Git #######
###################

# Outputs the name of the current branch
# Usage example: git pull origin $(git_current_branch)
# Using '--quiet' with 'symbolic-ref' will not cause a fatal error (128) if
# it's not a symbolic ref, but in a Git repo.
function git_current_branch() {
  local ref
  ref=$(command git symbolic-ref --quiet HEAD 2> /dev/null)
  local ret=$?
  if [[ $ret != 0 ]]; then
    [[ $ret == 128 ]] && return  # no git repo.
    ref=$(command git rev-parse --short HEAD 2> /dev/null) || return
  fi
  echo ${ref#refs/heads/}
}

function squash_commit() {
	echo $( git merge-base $(git_current_branch) trunk )
}
function comparemaster() {
	echo $( git difftool master $(git_current_branch) )
}

alias softreset='git reset --soft HEAD^'
alias hardreset='git reset --hard HEAD^'
alias squash='git rebase --interactive $(squash_commit)'
alias copybranch='echo -n "$(git_current_branch)" | pbcopy'
alias delnotmaster='git branch | grep -v "master" | xargs git branch -D'
alias delnottrunk='git branch | grep -v "trunk" | xargs git branch -D'
alias resetbranch='git fetch --all && git reset --hard origin/$(git_current_branch)'

alias ga='git add'
alias gaa='git add --all'
alias gc='git commit'
alias gca='git commit -a'
alias gcam='git commit -a -m'
alias gco='git checkout'
alias ggpush='git push origin "$(git_current_branch)"'
alias gst='git status'
alias gb='git branch'

# pnpm
export PNPM_HOME="/Users/ericbinnion/Library/pnpm"
case ":$PATH:" in
  *":$PNPM_HOME:"*) ;;
  *) export PATH="$PNPM_HOME:$PATH" ;;
esac
# pnpm end
eval "$(rbenv init -)"

source $HOMEBREW_PREFIX/share/zsh-autosuggestions/zsh-autosuggestions.zsh
