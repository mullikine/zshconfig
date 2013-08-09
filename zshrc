setopt rmstarsilent
setopt extended_glob

#export -n CWD
typeset +x CWD
#doesn't seem to be working:
#export fpath=$fpath /usr/share/zsh/4.3.11/functions
#fpath+=(/opt/local/share/zsh/4.2.7/functions)
#export fpath=$fpath /usr/share/zsh/functions

# Path to your oh-my-zsh configuration.
export ZSH=$HOME/build/versioned/git/oh-my-zsh

# Set to the name theme to load.
# Look in ~/.oh-my-zsh/themes/
#export ZSH_THEME="darkblood"
#export ZSH_THEME="wezm+"
#export ZSH_THEME="eastwood"
#export ZSH_THEME="gallifrey" # - fav
#export ZSH_THEME="minimal" # - fav
#export ZSH_THEME="sunrise"
export ZSH_THEME="more-minimal" # - fav

# isn't really that useful - also doesn't work with CWD env var
# modifications
#export AUTOCD
export HIST_IGNORE_ALL_DUPS

# Set to this to use case-sensitive completion
# export CASE_SENSITIVE="true"

# Uncomment following line to disable weekly auto-update checks
export DISABLE_AUTO_UPDATE="true"

# Uncomment following line if you want to disable colors in ls
# export DISABLE_LS_COLORS="true"

# Uncomment following line if you want to disable autosetting terminal title.
export DISABLE_AUTO_TITLE="true"

# Which plugins would you like to load? (plugins can be found in ~/.oh-my-zsh/plugins/*)
# Example format: plugins=(rails git textmate ruby lighthouse)
plugins=(svn git mercurial osx ruby rails command-not-found)
#plugins=(git ruby rails)

source $ZSH/oh-my-zsh.sh
unsetopt correct_all

# Customize to your needs...
#export PATH=/usr/libexec:/opt/local/bin:/opt/local/sbin:/Users/me/.cabal/bin:/usr/bin:/bin:/usr/sbin:/sbin:/usr/local/bin:/opt/X11/bin:/usr/X11/bin:/usr/libexec:/opt/local/bin:/opt/local/sbin:/Users/me/.cabal/bin:/Users/smulligan/bin:/Users/smulligan/bashscripts:/usr/local/bin:/Users/smulligan/bin:/Users/smulligan/bashscripts:/opt/local/www/cgi-bin

# include profile
if [ -f ~/.profile ]; then
    . ~/.profile
fi
#
## set PATH so it includes user's private bin if it exists
#if [ -d "$HOME/local/bin" ] ; then
#    PATH="$HOME/local/bin:$PATH"
#fi

# include bash_aliases
if [ -f ~/.bash_aliases ]; then
    . ~/.bash_aliases
fi

# include zsh_aliases
if [ -f ~/.zsh_aliases ]; then
    . ~/.zsh_aliases
fi

# include shellrc (for zsh and bash)
if [ -f ~/.shellrc ]; then
    . ~/.shellrc
fi

#ZSH_BOOKMARKS="$HOME/.zsh/cdbookmarks"
#
#function cdb_edit() {
#  $EDITOR "$ZSH_BOOKMARKS"
#}
#
#function cdb() {
#  local index
#  local entry
#  index=0
#  for entry in $(echo "$1" | tr '/' '\n'); do
#    if [[ $index == "0" ]]; then
#      local CD
#      CD=$(egrep "^$entry\\s" "$ZSH_BOOKMARKS" | sed "s#^$entry\\s\+##")
#      if [ -z "$CD" ]; then
#        echo "$0: no such bookmark: $entry"
#        break
#      else
#        cd "$CD"
#      fi
#    else
#      cd "$entry"
#      if [ "$?" -ne "0" ]; then
#        break
#      fi
#    fi
#    let "index++"
#  done
#}
#
#function _cdb() {
#  reply=(`cat "$ZSH_BOOKMARKS" | sed -e 's#^\(.*\)\s.*$#\1#g'`)
#}
#
#compctl -K _cdb cdb

_tilde () {
    [[ -n "$compstate[quote]" ]] && return 1

    local expl suf ret=1

    if [[ "$SUFFIX" = */* ]]; then
        ISUFFIX="/${SUFFIX#*/}$ISUFFIX"
        SUFFIX="${SUFFIX%%/*}"
        suf=(-S '')
    else
        suf=(-qS/)
    fi

    _tags directory-stack
    #_tags users named-directories directory-stack

    while _tags; do
        #_requested users && _users "$suf[@]" "$@" && ret=0

        #_requested named-directories expl 'named directory' \
        #    compadd "$suf[@]" "$@" -k nameddirs && ret=0

        _requested directory-stack && _directory_stack "$suf[@]" && ret=0

        (( ret )) || return 0
    done

    return ret
}

# The following lines were added by compinstall
zstyle :compinstall filename '$HOME/.zshrc'

autoload -Uz compinit
compinit
# End of lines added by compinstall

# tmuxinator stuff
[[ -s $HOME/.tmuxinator/scripts/tmuxinator ]] && source $HOME/.tmuxinator/scripts/tmuxinator

rationalise-dot() {
    if [[ $LBUFFER = *.. ]]; then
        LBUFFER+=/..
    else
        LBUFFER+=.
    fi
}
zle -N rationalise-dot
bindkey . rationalise-dot

# to get the character sequence, cat or read, then type it
bindkey '^W' kill-region
bindkey '^[w' copy-region-as-kill

# these are for setting the 'xterm title'
settitle() {
    printf "\033k$1\033\\"
}
#
#ssh() {
#    settitle "$*"
#    command ssh "$@"
#}

unsetopt autocd
unsetopt auto_name_dirs

# CWD environment variable stuff
if [ -n "$CWD" ]; then
    builtin cd "$CWD"
else
    CWD="`pwd`"
fi

# CWD environment variable stuff
# This is like the version i put in .bashrc, except has the same changes brought in earlier (from oh-my-zsh possibly)
cd () {
    if [[ "x$*" = "x..." ]]
    then
        cd ../..
    elif [[ "x$*" = "x...." ]]
    then
        cd ../../..
    elif [[ "x$*" = "x....." ]]
    then
        cd ../../..
    elif [[ "x$*" = "x......" ]]
    then
        cd ../../../..
    else
        if [ -z $@ ]; then
            CWD="$HOME"
        else
            CWD="$@"
        fi
        builtin cd "$CWD"
        # don't export because some commands like vifm don't want it
        # instead, use alias for bash and zsh maybe
        CWD="`pwd`"
    fi
}
echo -en "\e[0;37m"
pwd
echo -en "\e[0m"


# Complete in history with M-/, M-,
zstyle ':completion:history-words:*' list no 
zstyle ':completion:history-words:*' menu yes
zstyle ':completion:history-words:*' remove-all-dups yes
bindkey "\e/" _history-complete-older
bindkey "\e," _history-complete-newer

# These are used in older and newer versions of zsh
bindkey "\e[A" history-beginning-search-backward
bindkey "\e[B" history-beginning-search-forward
[[ -n "${key[Up]}" ]] && bindkey "${key[Up]}" history-beginning-search-backward
[[ -n "${key[Down]}" ]] && bindkey "${key[Down]}" history-beginning-search-forward

autoload -z edit-command-line
zle -N edit-command-line
bindkey "\ev" edit-command-line

bindkey "\C-r" history-incremental-pattern-search-backward

bindkey -s "^[i" "^A^Kcd ..\r"
bindkey -s "^[o" "^A^Kpopd\r"
bindkey -s "^[r" "^[[A"

bindkey -s "^[y" "^A^Kgit lg\r"
bindkey -s "^[k" "^A^Kgit d\r"
bindkey -s "^[K" "^A^Kgit d --cached\r"
bindkey -s "^[j" "^A^Kgit log\r"
bindkey -s "^[;" "^A^Kgit diff\r"
bindkey -s "^[:" "^A^Kgit diff --cached\r"
bindkey -s "^[m" "^A^Kgit reflog\r"
bindkey -s "^[n" "^A^Kgit rl\r"
bindkey -s "^[w" "^A^Kgit s\r"
bindkey -s "^[t" "^A^Kgit add .\r"
bindkey -s "^[T" "^A^Kgit add -A .\r"
bindkey -s "^[e" "^A^Kgit commit -m \"\"^B"
bindkey -s "^[p" "^A^Kgit checkout \`tmux show-buffer\`\r"
bindkey -s "^[z" "^A^Kgit clean -f -d .\r"
bindkey -s "^[F" "^A^Kgit log -m -S \"\"^B"
bindkey -s "^[1" "^A^Kgit add -p \t"
bindkey -s "^[2" "^A^Kgit stash\r"
bindkey -s "^[@" "^A^Kgit stash list\r"
bindkey -s "^[3" "^A^Kgit stash pop\r"
bindkey -s "^[#" "^A^Kgit stash apply \t"
bindkey -s "^[!" "^A^Kgit stash drop \t"
bindkey -s "^[4" "^A^Kgit rebase -i \`tmux show-buffer|head -1|sed \"s/^\\\[ \t\\\]*//\"|cut -d ' ' -f 1\`\t"
bindkey -s "^[$" "^A^Kgit d \`tmux show-buffer|head -1|sed \"s/^\\\[ \t\\\]*//\"|cut -d ' ' -f 1\`\t\\\\\^! "
bindkey -s "^[~" "^A^Kgit commit --amend -m \"\"^B"
bindkey -s "^[5" "^A^Kgit show --name-only \`tmux show-buffer|head -1|sed \"s/^\\\[ \t\\\]*//\"|cut -d ' ' -f 1\`\t"
bindkey -s "^[%" "^A^Kgit stash show -u \t"
bindkey -s "^[8" "^A^Kgit d !$\t\n"
bindkey -s "^[*" "^A^Kgit diff !$\t\n"
bindkey -s "^[9" "^A^Kgit d HEAD\\\\\^!\n"
