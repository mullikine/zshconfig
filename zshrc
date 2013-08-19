setopt rmstarsilent
setopt extended_glob

typeset +x CWD
export ZSH=$HOME/build/versioned/git/oh-my-zsh
export ZSH_THEME="more-minimal" # - fav
export HIST_IGNORE_ALL_DUPS
export DISABLE_AUTO_UPDATE="true"
export DISABLE_AUTO_TITLE="true"
plugins=(svn git mercurial osx ruby rails command-not-found)
source $ZSH/oh-my-zsh.sh
unsetopt correct_all

if [ -f ~/.profile ]; then
    . ~/.profile
fi
if [ -f ~/.bash_aliases ]; then
    . ~/.bash_aliases
fi
if [ -f ~/.zsh_aliases ]; then
    . ~/.zsh_aliases
fi
if [ -f ~/.shellrc ]; then
    . ~/.shellrc
fi

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

    while _tags; do
        _requested directory-stack && _directory_stack "$suf[@]" && ret=0

        (( ret )) || return 0
    done

    return ret
}

zstyle :compinstall filename '$HOME/.zshrc'
autoload -Uz compinit
compinit
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

bindkey '^W' kill-region
bindkey '^[w' copy-region-as-kill

settitle() {
    printf "\033k$1\033\\"
}

unsetopt autocd
unsetopt auto_name_dirs

if [ -n "$CWD" ]; then
    builtin cd "$CWD"
else
    CWD="`pwd`"
fi

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
        CWD="`pwd`"
    fi
}
echo -en "\e[0;37m"
pwd
echo -en "\e[0m"

zstyle ':completion:history-words:*' list no 
zstyle ':completion:history-words:*' menu yes
zstyle ':completion:history-words:*' remove-all-dups yes
bindkey "\e/" _history-complete-older
bindkey "\e," _history-complete-newer
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
bindkey -s "^[p" "^A^Kgit checkout \`tmux show-buffer\`\t\r"
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
bindkey -s "^[)" "^A^Kgit rename -m \`git rev-parse --abbrev-ref HEAD\`\t"
bindkey -s "^[(" "^A^Kgit diff HEAD\\\\\^!\n"
