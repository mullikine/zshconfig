#zmodload zsh/datetime
#setopt promptsubst
#PS4='+$EPOCHREALTIME %N:%i> '
## set the trace prompt to include seconds, nanoseconds, script name and line number
## This is GNU date syntax; by default Macs ship with the BSD date program, which isn't compatible
##PS4='+$(date "+%s:%N") %N:%i> '
## save file stderr to file descriptor 3 and redirect stderr (including trace
## output) to a file with the script's PID as an extension
#exec 3>&2 2>/tmp/startlog.$$
## set options to turn on tracing and expansion of commands contained in the prompt
#setopt xtrace prompt_subst

HISTFILE=$VAS/programs/zsh/dotfiles/.zsh_history

export BULK=/export/bulk/local-home/smulliga
#export TERM=xterm-256color

if [ -z "$ATHAME_ENABLED" ]; then
    export ATHAME_ENABLED=0
fi

autoload up-line-or-beginning-search
autoload down-line-or-beginning-search
zle -N up-line-or-beginning-search
zle -N down-line-or-beginning-search

setopt rmstarsilent
setopt extended_glob # disabling this will not disable **, but having this unset will disable the evil # sign. echo yo #yo, echo yo#yo. so evil
disable -p \#     # this disables the pound sign only!
setopt no_hist_save_by_copy
#setopt inc_append_history
setopt share_history
setopt no_inc_append_history
setopt no_append_history
#setopt append_history no_inc_append_history no_share_history
setopt null_glob

# To stop bailing on the command when it fails to match a glob pattern.
# Put this option in your .zshrc:
setopt NO_NOMATCH
# So important I've defined it twice
alias -g noglob git
# To get git log ^production master (which is, coincidentally, also
# exactly what git's 'double dot' syntax does: git log
# production..master) to work by disabling extended globbing:
# setopt NO_EXTENDED_GLOB

# Disable fucking pattern removal -- extended_glob is the source of the
# problem
# set -k # holy shit this didn't work. i'm losing my mind
# setopt nointeractivecomments # neither did this
# echo yo#yo is different from echo yo #yo
# setopt nonull_glob # this is the problem to echo yo#yo but not to echo yo #yo
# This was the problem...
# setopt extended_glob # disabling this will not disable **, but having this unset will disable the evil # sign. echo yo #yo, echo yo#yo. so evil
# This is an even better solution!
# disable -p \#     # this disables the pound sign only!

setopt interactivecomments

typeset +x CWD
export HIST_IGNORE_ALL_DUPS
export DISABLE_AUTO_UPDATE="true"
export DISABLE_AUTO_TITLE="true"
#plugins=(command-not-found git ssh-completion)
# This one is slow. But it's also really useful. I should value
# usefulness over speed for zsh.
#command-not-found

#svn git
# disabled-plugins:
# zsh-syntax-highlighting
#source $ZSH/oh-my-zsh.sh


if test -f "$MYGIT/oh-my-zsh/oh-my-zsh.sh"; then
    export ZSH=$MYGIT/oh-my-zsh
    export ZSH_THEME="more-minimal" # - fav
    plugins=(command-not-found git ssh-completion)
    source $MYGIT/oh-my-zsh/oh-my-zsh.sh
fi

# Not suer why the plugins are not loading
plugins+=(zsh-autosuggestions)

# This works
. $ZSH_CUSTOM/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh

unsetopt correct_all

# Disable mouse! I want to be able to scroll up the terminal.
# plugins=(mouse)
# . $VAS/source/git/oh-my-zsh/custom/plugins/mouse.zsh
# zle-toggle-mouse

if [ -f ~/.bash_aliases ]; then
    . ~/.bash_aliases
fi
if [ -f ~/.zsh_aliases ]; then
    . ~/.zsh_aliases
fi
if [ -f ~/.shell_aliases ]; then
    . ~/.shell_aliases
fi
if [ -f ~/.shellrc ]; then
    . ~/.shellrc
fi
if [ -f ~/.shell_functions ]; then
    . ~/.shell_functions
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

fpath=($HOME/.zsh_completion.d $fpath)

# This makes zsh lag (but it looks important):
# zstyle :compinstall filename '$HOME/.zshrc'
# autoload -Uz compinit
# compinit

rationalise-dot() {
    if [[ $LBUFFER = *.. ]]; then
        LBUFFER+=/..
    else
        LBUFFER+=.
    fi
}
settitle() {
    printf "\033k$1\033\\"
}

unsetopt autocd
unsetopt auto_name_dirs


# cd function
cd () {
    ret=0

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
        if [ -z "$@" ]; then
            CWD="$HOME"
        else
            CWD="$@"
        fi
        # silence to stop vim gf complaining. can't be bothered finding the real reason
        # enable again
        builtin cd "$CWD"
        ret="$?"
        CWD="`pwd`"
    fi

    . $HOME/scripts/libraries/when-cd.sh

    return "$ret"
}

if [ -n "$CWD" ] && ! test "$CWD" = "$(pwd)"; then
    printf -- "%s\n" "Inherited CWD: $CWD" | mnm 1>&2

    cd "$CWD"
else
    CWD="$(pwd)"
fi

# I uncommented this. Why? Maybe ranger.
#if [ -n "$CWD" ]; then
#    builtin cd "$CWD"
#else
#    CWD="`pwd`"
#fi
#Try this:
#It will do `cd` if CWD unset, which goes to home anyway.
#needs to come after cd(){}

echo -en "\e[0;37m"
# pwd # show pwd on start
echo -en "\e[0m"

zstyle ':completion:history-words:*' list no
zstyle ':completion:history-words:*' menu yes
zstyle ':completion:history-words:*' remove-all-dups yes
zstyle ":completion:*:descriptions" format "%B%d%b"

# # This had been causing me hell. It's gone now
# zle -N rationalise-dot
# bindkey . rationalise-dot

bindkey '^W' kill-region
bindkey '^[w' copy-region-as-kill
bindkey "\e/" _history-complete-older
#bindkey "\e/" tmux-pane-words-prefix
bindkey "\e," _history-complete-newer
#bindkey "\e[A" history-beginning-search-backward
#bindkey "\e[B" history-beginning-search-forward
bindkey "\e[A" up-line-or-beginning-search
bindkey "\e[B" down-line-or-beginning-search
bindkey "\eOA" up-line-or-beginning-search
bindkey "\eOB" down-line-or-beginning-search
#[[ -n "${key[Up]}" ]] && bindkey "${key[Up]}" history-beginning-search-backward
#[[ -n "${key[Down]}" ]] && bindkey "${key[Down]}" history-beginning-search-forward
[[ -n "${key[Up]}"      ]]  && bindkey   "${key[Up]}"       up-line-or-beginning-search
[[ -n "${key[Down]}"    ]]  && bindkey   "${key[Down]}"    down-line-or-beginning-search

# bindings
# {{{
function toggle-athame() {
    if ! [ "$ATHAME_ENABLED" == "0" ]; then
        export ATHAME_ENABLED=0
    else
        export ATHAME_ENABLED=1
    fi
    #if ! [ "$ATHAME_ENABLED" == "0" ]; then export ATHAME_ENABLED=0; else export ATHAME_ENABLED=1; fi
}
#
## Doesn't work because it doesn't run the command in the current shell.
#autoload -z toggle-athame
#zle -N toggle-athame
#bindkey "\el" toggle-athame

# This isn't ideal but
#bindkey -s "^[l" "^A^Kif ! [ \"\$ATHAME_ENABLED\" == \"0\" ]; then export ATHAME_ENABLED=0; else export ATHAME_ENABLED=1; fi\r"
#bindkey -s "^[l" "^A^Ktoggle-athame\r^Y"
#bindkey -s "^[l" "^A^Ktoggle-athame\r"

#function edit-command-line() {
#    # overrides /home/shane/local/share/zsh/4.3.12-test-2/functions/edit-command-line
#    # so that we use a custom vim for editing the command line
#
#    local tmpfile=${TMPPREFIX:-/tmp/zsh}ecl$$
#
#    print -R - "$PREBUFFER$BUFFER" >$tmpfile
#    exec </dev/tty
#
#    tmux-linevim.sh "$tmpfile"
#    print -Rz - "$(<$tmpfile)"
#
#    command rm -f $tmpfile
#    zle send-break		# Force reload from the buffer stack
#}


function edit-command-line() {
    # overrides /home/shane/local/share/zsh/4.3.12-test-2/functions/edit-command-line
    # so that we use a custom vim for editing the command line

    tf_zle="$(ux mktemp zle sh)"
    # ns "$tf_zle"

    print -R - "$PREBUFFER$BUFFER" > "$tf_zle"

    # printf -- "%s\n" "$PREBUFFER$BUFFER" | tm -tout nw -n zsh2 "vim -" # Works
    # print -R - "$PREBUFFER$BUFFER" | tm -tout nw -n zsh3 "vim -" # Works
    # tm -t nw -n zle4 "cat '$tf_zle' | vim -"
    # tm -t nw "vim \"$tf_zle\""

    # Do I really want this to be inside another tmux or can I use the entire pane?
    # tm -t sph -n zle4 "e c '$tf_zle' || pak"
    tm -f -t sph -n zle4 "vim '$tf_zle' || pak"

    # tm -te sph -pak -n zle4 "pak"

    # This enabled use of vim within a command but if I'm using tmux,
    # this dosen't matter.
    exec </dev/tty

    # vim "$tf_zle"

    # tm -tout nw -n zle "vim $tf_zle" | cat
    print -Rz - "$(<$tf_zle)"

    command rm -f "$tf_zle"
    zle send-break		# Force reload from the buffer stack
}

# M-v
autoload -z edit-command-line
zle -N edit-command-line
bindkey "\ev" edit-command-line


function zsh-tmux-edit-pane {
    # print -R - "$PREBUFFER$BUFFER" | tm -tout -i -S spv "explainshell"
    # tm -te -d capture -tty -clean -editor vs
    tm -te -d capture -clean -noabort - 2>/dev/null | vs +G
    zle send-break		# Force reload from the buffer stack
}

# M-E
autoload -z zsh-tmux-edit-pane
zle -N zsh-tmux-edit-pane
bindkey "\eV" zsh-tmux-edit-pane


function rt-grep() {
    # What does this do?
    exec </dev/tty
    #print -Rz - "unbuffer ack-grep \"\" . | less -rS"
    #print -Rz - "ansigrep -i -- "
    print -Rz - "eack "
    zle send-break		# Force reload from the buffer stack
}

function zshexplainshell {
    print -R - "$PREBUFFER$BUFFER" | tm -tout -i -S spv "explainshell"

    # tf_zle="$(ux mktemp zle sh)"
    # url="https://explainshell.com/explain?cmd=$(print -R - "$PREBUFFER$BUFFER" | urlencode)"
    # tf_man="$(ux tf man || echo /dev/null)"

    # ci elinks-dump "$url" 0</dev/null | sed -n '/^[^ ]/,$p' > "$tf_man"

    # if test -s "$tf_man"; then
    #     tm -d -t spv "vs $tf_man"
    # fi
}

# M-E
autoload -z zshexplainshell
zle -N zshexplainshell
bindkey "\eE" zshexplainshell

function rt-grep() {
    # What does this do?
    exec </dev/tty
    #print -Rz - "unbuffer ack-grep \"\" . | less -rS"
    #print -Rz - "ansigrep -i -- "
    print -Rz - "eack "
    zle send-break		# Force reload from the buffer stack
}

# M-u
autoload -z rt-grep
zle -N rt-grep
bindkey "^[^t" rt-grep

function rt-command-line() {
    # overrides /home/shane/local/share/zsh/4.3.12-test-2/functions/edit-command-line
    # so that we use a custom vim for editing the command line

    tf_zle="$(mktemp ${TMPDIR}/tf_zleXXXXXX || echo /dev/null)"

    print -R - "$PREBUFFER$BUFFER" > $tf_zle

    exec </dev/tty `# see etty`

    tf_zle_contents="$(cat "$tf_zle")"

    if test -n "$tf_zle_contents"; then
        rtcmd -E "$(cat $tf_zle)"
    else
        fz-rtcmd
    fi

    # cat "$tf_zle" | rtcmd
    print -Rz - "$(<$tf_zle)"

    command rm -f "$tf_zle"
    zle send-break		# Force reload from the buffer stack
}

# M-u [u
autoload -z rt-command-line
zle -N rt-command-line
bindkey "\eu" rt-command-line

# overwrite zsh's M-x
# bindkey -s "^[x" "^A^Ksh-hydra\r"

function source-sh-sourse() {
    tf_zle="$(mktemp ${TMPDIR}/tf_zleXXXXXX || echo /dev/null)"

    print -R - "$PREBUFFER$BUFFER" > $tf_zle

    exec </dev/tty `# see etty`

    tf_zle_contents="$(cat "$tf_zle")"

    nvc -E "sh-source | ds -s source-to-source"
    sts="$(gs source-to-source | umn)"
    if test -n "$sts"; then
        . "$(gs source-to-source | umn)"
    fi

    # cat "$tf_zle" | rtcmd
    print -Rz - "$(<$tf_zle)"

    command rm -f "$tf_zle"
    zle send-break		# Force reload from the buffer stack
}

# M-x
autoload -z source-sh-sourse
zle -N source-sh-sourse
bindkey "\ex" source-sh-sourse

# [[google:zle functions]]
bindkey "\eD" backward-kill-word

# M-a
#bindkey -s "^[a" "^A^Kcd \"\`pwd -P\`\";pwd\r"
# bindkey -s "^[a" "^A^Krat-fm\r"
bindkey -s "^[a" "^A^Ksh-apps\r"

bindkey -s "^[\`" "^A^Kis-git && cd \"\$(vc get-top-level)\" && pwd\r"
bindkey -s "^[$" "^A^Kdifftool.sh \`tmux show-buffer|head -1|sed \"s/^\\\[ \t\\\]*//\"|cut -d ' ' -f 1\`\t\\\\\^! "
bindkey -s "^[~" "^A^Kgit commit --amend -m \"\"^B"
bindkey -s "^[" "^A^Kgit amend\r" # C-M-S-~
bindkey -s "^[5" "^A^Kgit show --name-only \`tmux show-buffer|head -1|sed \"s/^\\\[ \t\\\]*//\"|cut -d ' ' -f 1\`\t"
bindkey -s "^[%" "^A^Kgit stash show -u \t"
#bindkey -s "^[y" "^A^Kgit-log.sh\r" #bindkey -s "^[y" "^A^Kgit lg\r"
#
#
#
#tmuxcapture() {
#    #tmux-capture.sh -w
#    tm -te -d capture -clean -history
#}
#zle -N tmuxcapture
#bindkey "^[y" tmuxcapture

bindkey -s "^[K" "^A^Kvc g dt -c\r" #bindkey -s "^[K" "^A^Kgit d --cached\r"
bindkey -s "^[J" "^A^Kf find-file-repo \"*\"^B" # find a file by name in all commits

# I could always make a new binding for that
# M-q is reserved for push command to stack
#bindkey -s "^[q" "^A^Ksh-general\r"
bindkey -s "^[l" "^A^Ksh-general\r"
# bindkey -s "^[l" "^A^Ktp rt-locate"
#
bindkey -s "^[L" "^A^Ksh-ranger-lingo .\r"

bindkey -s "^[j" "^A^Ksh-jump\r"

bindkey -s "^[y" "^A^Ksh-yank\r"
bindkey -s "^[-" "^A^Ksh-signals\r"
bindkey -s "^[&" "^A^Kbg\r"
bindkey -s "^[*" "^A^Kdisown\r"
# bindkey -s "^[*" "^A^Kgit diff !$\t\n"
#
# zle -N my-sh-yank
# my-sh-yank() {
#     # Some like 'hs make' need the tty to run. Need this.
#
#     # If not a tty but TTY is exported from outside, attach the tty
#     if test "$mytty" = "not a tty" && ! [ -z ${TTY+x} ]; then
#         pl "Attaching tty"
#         exec 0<"$TTY"
#         exec 1>"$TTY"
#     else
#         # Otherwise, this probably has its own tty and only needs normal
#         # reattachment (maybe stdin was temporarily redirected)
#         exec </dev/tty
#     fi
#     cmd="$history[$((HISTCMD-1))]"
#
#     echo
#     sh-yank
#
#     return 0
# }
# bindkey "^[y" my-sh-yank

# bindkey -s "^[j" "^A^Kgit log\r"
bindkey -s "^[;" "^A^Ksh-git-hydra\r"
bindkey -s "^[:" "^A^Kgit diff --cached\r"
bindkey -s "^[W" "^A^Kgit dw\r"
bindkey -s "^[M" "^A^Kmagithub\r"
bindkey -s "^[m" "^A^Ksh-git\r"
bindkey -s "^[n" "^A^Ksh-new\r"
# bindkey -s "^[n" "^A^Kmagit rl\r"
bindkey -s "^[w" "^A^Kdired\r"
bindkey -s "^[s" "^A^Kpe\r" # spacemacs
bindkey -s "^[t" "^A^Kgit add -A .\r"
bindkey -s "^[e" "^A^Kgit commit -m \"\"^B"
bindkey -s "^[F" "^A^Kgit log -m -S \"\"^B" # -S Search for changes containing string, -m search merges also

# dump
bindkey -s "^[c" "^A^Kn menu\r"

bindkey -s "^[C" "^A^Kcsc\r" # cscope
bindkey -s "^[G" "^A^Kgit log --oneline --grep=\"\"^B" # Search commit messages for regexp.
bindkey -s "^[N" "^A^Kgit grep --break --heading --line-number \"\"^B" # Grep the working tree. If commit is supplied as last argument, grep files in that commit.
# bindkey -s "^[V" "^A^Kgit-grep-all-commits.sh \"\"^B" # Grep all files of ALL repository commits. Very inefficient.
bindkey -s "^[1" "^A^Kgit add -p \t"
bindkey -s "^[2" "^A^Kgit stash\r"
bindkey -s "^[@" "^A^Kgit stash --keep-index\r" # stash but don't clean the index (so can stash again, or commit)
bindkey -s "^[#" "^A^Kgit stash pop\r"
bindkey -s "^[3" "^A^Kgit stash apply\r"
bindkey -s "^[!" "^A^Kgit stash drop \t"
bindkey -s "^[4" "^A^Kgit rebase -i \`tmux show-buffer|head -1|sed \"s/^\\\[ \t\\\]*//\"|cut -d ' ' -f 1\`\t"
bindkey -s "^[8" "^A^Kdifftool.sh \\\\\^!^B^B^B"
bindkey -s "^[9" "^A^Kdifftool.sh HEAD\\\\\^:\n"
bindkey -s "^[)" "^A^Kgit rename -m \`git rev-parse --abbrev-ref HEAD\`\t"
bindkey -s "^[(" "^A^Kgit diff HEAD\\\\\^!\n"
bindkey -s "^[^O" "^A^Kgit checkout \`tmux show-buffer|head -1|sed \"s/^\\\[ \t\\\]*//\"|cut -d ' ' -f 1\`\t\r"
bindkey -s "^[=" "^A^Kgit branch\n"
bindkey "\C-r" history-incremental-pattern-search-backward
bindkey -s "^[r" "^A^Kranger\r"
bindkey -s "^[o" "^A^Kpopd\r"
bindkey -s "^[R" "^E|grep -i "
bindkey -s "^[^g" "^A^Kvgrep -f -- \"\"^B"
# bindkey '\eg' _git-status
#bindkey -s "^[g" "^A^Kvgrep -- \"\"^B"
bindkey -s "^[g" "^A^Kopen -e \"\$(xc | tail -n 1)\"\r"
#bindkey -s "^[m" "^A^Kgit reflog\r"
#bindkey -s "^[n" "^A^Kgit rl\r"
#bindkey -s "^[w" "^A^Kgit s\r"
#bindkey -s "^[9" "^A^Kdifftool.sh HEAD\\\\\^!\n"
#bindkey -s "^[8" "^A^Kgit d !$\t\n"
#bindkey -s "^[9" "^A^Kgit d HEAD\\\\\^!\n"
#bindkey -s "^[$" "^A^Kgit d \`tmux show-buffer|head -1|sed \"s/^\\\[ \t\\\]*//\"|cut -d ' ' -f 1\`\t\\\\\^! "
#bindkey -s "^[g" "^A^Kunbuffer grep -HnR \"\" .|less -rSbb^B^B^B^B"
#bindkey -s "^[g" "^A^Kag --group --color -nR \"\" .|ansivipeb^B^B^B^B"
#bindkey -s "^[g" "^A^Kag --group -nR \"\" .|vim - -c \"set ft=grep | setlocal noautochdir\"bbbbbbb^B^B^B^B"
#bindkey -s "^[s" "^A^Kvimgstatus\r"
#bindkey -s "^[s" "^A^Kgit s\r"
#bindkey -s "^[^t" "^A^Kgit add -u .\r"
#bindkey -s "^[^t" "^A^Kvgrep -i -- \"\"^B"
#bindkey -s "^[^t" "^A^Kgrep-here.sh \"\"^B"
#bindkey -s "^[p" "^A^Kgit checkout @{-1}\r" # Switch to previously checked-out commit.
# this killed my notes folder faaa!!!
#bindkey -s "^[z" "^A^Kgit clean -fd .\r"
#bindkey -s "^[C" "^A^Kgit log -m -G \"\"^B" # -G Search for changes containing regexp, -m search merges also
#bindkey -s "^[y" "^A^Ktmux-capture.sh -v\r"
# Binding to M-k was too annoying
#bindkey -s "^[k" "^A^Kdifftool.sh\r" #bindkey -s "^[k" "^A^Kgit d\r"

# Doesn't work
#tmuxwinhere() {
#    unbuffer tm nw
#}
#zle -N tmuxwinhere
#bindkey "^[	" tmuxwinhere
#
##bindkey -s "^[	" "^A^Kzsh-tmux-window-here.sh\r"

f_tmux_split_h() { tm -d -te sph }
zle -N f_tmux_split_h
bindkey "^[h" f_tmux_split_h

f_tmux_split_v() { tm -d -te spv }
zle -N f_tmux_split_v
bindkey "^[H" f_tmux_split_v

#bindkey -s "^[h" "^A^Kzsh-tmux-split-here.sh\r"
#bindkey -s "^[H" "^A^Kzsh-tmux-split-here.sh -h\r"

bindkey -s "^[Q" "^A^K\`!!\`^A"
# This doesn't contain
bindkey -s "^[S" "^A^Ktp find-here-path \"**\"^B^B"

bindkey -s "^[I" "^A^Ktp find-here-path -:2 \"**\"^B^B"

# arrow keys
bindkey -s "^[[1;3D" "^A^Kpopd\n"
bindkey -s "^[[1;3A" "^A^Kcd ..\n"
bindkey -s "^[[1;3C" "^A^Kranger ..\n"
bindkey -s "^[[1;3B" "^A^K( pwd;echo;ls --color=always -ld * )| less -rS\n"

# git key bindings
#[ -f ~/.git.zsh ] && source ~/.git.zsh

# M-F1 - quit (like vim)
bindkey -s "^[[1;3P" "^A^K^D"
# M-F4 - quit (like vim)
bindkey -s "^[[1;3S" "^A^K^D"
# M-F1 from xterm
bindkey -s "^[[1;9P" "^A^K^D"
# M-F9 - quit (like vim)
bindkey -s "^[[20;3~" "^A^K^D"
# M-F12 - quit (like vim)
bindkey -s "^[[24;3~" "^A^K^D"
# S-F8 - insert date (like vim)
bindkey -s "^[[19;2~" "$(k f8)"
# M-F8 - insert date (like vim)
bindkey -s "^[[19;3~" "$(k f8)"
# work in progress
#bindkey -s "^[" "yank path"

# Not sure but I think these have no function on the macbook
# Available mappings:
# For the moment, just prevent them from spurting out weird characters
# C-;
bindkey -s "^[[27;5;59~" ";"
# C-:
bindkey -s "^[[27;6;58~" ":"
# C-'
bindkey -s "^[[27;5;39~" "'"
# C-"
bindkey -s "^[[27;6;34~" "\""
# C-,
bindkey -s "^[[27;5;44~" ","
# C-.
bindkey -s "^[[27;5;46~" "."
# C-<
bindkey -s "^[[27;6;60~" "<"
# C->
bindkey -s "^[[27;6;62~" ">"

bindkey "\e[D" backward-kill-word
bindkey "\eOD" backward-kill-word
bindkey "\e[C" kill-word
bindkey "\eOC" kill-word
bindkey "\e^L" kill-word

vi-append-x-selection () { RBUFFER=$(xsel -o -p </dev/null)$RBUFFER; }
zle -N vi-append-x-selection
bindkey -e '\e[1;3R' vi-append-x-selection
vi-yank-x-selection () { print -rn -- $CUTBUFFER | xsel -i -p; }
zle -N vi-yank-x-selection
bindkey -e '\e[1;3Q' vi-yank-x-selection

#source ~/versioned/git/antigen/antigen.zsh

#zmodload -i zsh/parameter
#insert-last-command-output() {
  #LBUFFER+="$(eval $history[$((HISTCMD-1))])"
#}
#zle -N insert-last-command-output
#bindkey "^X^L" insert-last-command-output

zmodload -i zsh/parameter

copy-last-command-output() {
    # Some like 'hs make' need the tty to run. Need this.

    ## If not a tty but TTY is exported from outside, attach the tty
    #if test "$mytty" = "not a tty" && ! [ -z ${TTY+x} ]; then
    #    pl "Attaching tty"
    #    exec 0<"$TTY"
    #    exec 1>"$TTY"
    #else
    #    # Otherwise, this probably has its own tty and only needs normal
    #    # reattachment (maybe stdin was temporarily redirected)
    #    exec </dev/tty
    #fi
    #cmd="$history[$((HISTCMD-1))]"

    # eval "$cmd" | xc -n -i
    #
    zl copy-last-output
}
# This kills the terminal history because I am pressing ^L
# zle -N copy-last-command-output
# bindkey "^X^L" copy-last-command-output
# Need a different command for this.
zle -N copy-last-command-output
bindkey "^X^K" copy-last-command-output
bindkey "^X^L" copy-last-command-output

qtv-term() {
    zl qtv-term
}
zle -N qtv-term
bindkey "^X^H" qtv-term

qtv-last-output() {
    zl qtv-last-output
}
zle -N qtv-last-output
bindkey "^X^V" qtv-last-output

copy-zle() {
  printf -- "%s" "$BUFFER" | xc -i
}

zle -N copy-zle
bindkey "\eY" copy-zle

# M-i
bindkey -s "^[i" "^A^Kcd ..\r"

#. ~/versioned/git/zsh-fuzzy-match/fuzzy-match.zsh
# }}}

# this confused 'ref' and ranger but, after modifying them, they now work

export CWD # this allows CWD (from tmux?) to be accessed in vim via a shell. ie. make new window in tmux then start vim, CWD will be accessible
# Do not export the CWD. It fucks with everything, including ranger, if the CWD is wrong.
# What is making this happen?

[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh

stty stop undef
stty start undef
# the following does the same thing (i think) but in one line
stty -ixon

## Used to debug completion functions
#zstyle ‘:completion:*’ verbose yes
#zstyle ‘:completion:*:descriptions’ format ‘%B%d%b’
#zstyle ‘:completion:*:messages’ format ‘%d’
#zstyle ‘:completion:*:warnings’ format ‘No matches for: %d’
#zstyle ‘:completion:*’ group-name ”

# Tmux completion
_tmux_pane_words() {
  compset -q
  local expl
  local -a w
  if [[ -z "$TMUX_PANE" ]]; then
    _message "not running inside tmux!"
    return 1
  fi
  w=( ${(u)=$(tm ngrams)} )
  _wanted values expl 'words from tmux' compadd -a w
}

#zstyle ':completion:*' menu select=5
#zstyle ':completion:*' menu select=10000

zle -C tmux-pane-words-prefix   complete-word _generic
zle -C tmux-pane-words-anywhere complete-word _generic
bindkey '^Xt' tmux-pane-words-prefix
bindkey '^X^X' tmux-pane-words-anywhere
zstyle ':completion:tmux-pane-words-(prefix|anywhere):*' completer _tmux_pane_words
zstyle ':completion:tmux-pane-words-(prefix|anywhere):*' ignore-line current
zstyle ':completion:tmux-pane-words-anywhere:*' matcher-list 'b:=* m:{A-Za-z}={a-zA-Z}'
#zstyle ':completion:tmux-pane-words-(prefix|anywhere):*' menu no select
# End of tmux completion

# export EBL=$BULK/projects/ebl
# export EBL2=$BULK/projects/ebl2
# export EBL3=$BULK/projects/ebl3
# export MYBUILD=/var/cache/crown-build/9239
# export HILTESTHOME=$XB/local-home/hiltest
# export LOCENVLOC=packages/localisation/environmentalLocalisation
# export ENVLOC=environmentalLocalisation
export DOWNLOADS=$BULK/downloads
# export SCRIPTS=$BULK/projects/scripts
# export RESULTSD=/export/bulk/local-home/shared/results
# export WSHIL=$NOTES/ws/hil-nodes
# export PUBCAN="/home/smulliga/Public/Crown Projects/CAN"
# export NETDIR=/home/smulliga/netdir
# export LASER=packages/laser

chr() {
  #[ "$1" -lt 256 ] || return 1
  printf "\\$(printf '%03o' "$1")"
}

ord() {
  LC_CTYPE=C printf '%d' "'$1"
}

#source $VAS/source/git/scripts/tmux/start_tmux.sh

# Overrides for terminfo$
export TERMINFO=~/.terminfo

# This is deprecated, so disable it. Not sure what is setting it.
unset GREP_OPTIONS

## turn off tracing
#unsetopt xtrace
## restore stderr to the value saved in FD 3
#exec 2>&3 3>&-

export DUALMODE=$VAS/projects/dualmode
export SENSING3D=/var/smulliga/projects/3dsensing/packages/3dsensing

. $HOME/scripts/libraries/when-cd.sh

# exec 1> >(mnm)
# exec 2> >(mnm)

# Not that useful
# source $MYGIT/zsh-users/zsh-autosuggestions/zsh-autosuggestions.zsh

zmodload -i zsh/parameter
copy-last-command-with-wd() {
    #echo "cd \"$(pwd)\"; $history[$((HISTCMD-1))]" | xclip -f -i -selection primary &>1 | tmux load-buffer -
    echo "cd \"$(pwd)\"; $history[$((HISTCMD-1))]" | sed 's//\\b/g' | mnm | xc -n -i 2>/dev/null
}
zle -N copy-last-command-with-wd
#bindkey "^[k" copy-last-command-with-wd
bindkey "\ek" copy-last-command-with-wd

# zsh
#     You can access the command buffer from within widgets with the
#     parameters BUFFER, LBUFFER and RBUFFER. BUFFER contains the whole
#     command, while LBUFFER only contains the part left of the current
#     cursor position and RBUFFER the part to the right of the cursor.
#     These parameters can also be modified.
#
#     If you want to insert some text at the cursor position, you can
#     just prepend the desired text to RBUFFER:
#
#     addText () {
#         text_to_add="textGoesHere"
#         RBUFFER=${text_to_add}${RBUFFER}
#     }
#     zle -N addText
#     bindkey '^Z' addText

{
    function zsh-paste-after() {
        # exec </dev/tty

        # This adds it to a new line. Not what I want
        #print -Rz - $(xclip-out.sh)
        # print -Rz - "$(xclip-out.sh | chomp.sh)"
        # print -Rz - ""
        # printf -- "%s\n" "Yo"
        # zle send-break		# Force reload from the buffer stack
        # set -xv

        text_to_add="$(xc -ub | s chomp)"
        RBUFFER="${text_to_add}${RBUFFER}"
    }

    function zsh-paste-before() {
        text_to_add="$(xc -ub | s chomp)"
        LBUFFER="${LBUFFER}${text_to_add}"
    }

    # # I can't use ^Y because zsh actually uses it.
    # # I can't use ^V because zsh uses it to insert literal characters.
    autoload -z zsh-paste-after
    zle -N zsh-paste-after
    bindkey "\eP" zsh-paste-after

    autoload -z zsh-paste-before
    zle -N zsh-paste-before
    bindkey "\ep" zsh-paste-before
}

fzf-dirs() {
    trap func_trap EXIT
    func_trap() {
        tput rc
    }

    tput sc

    F d | mnm | fzf | {
        input="$(cat)"
        if [ -n "$input" ]; then
            # pl "$input" | tm -i -S -tout spv -xargs rifle
            printf -- "%s" "$input" | xc -i
            # printf -- "copied" | ns
            exec </dev/tty
            input="$(printf -- "%s" "$input" | umn)"
            cd "$input"
            pwd
            CWD="$input" zsh
        fi
    }



        #filelist="$(find-all-no-git.sh | fzf -p --multi)"
        #if [ -n "$filelist" ]; then
        #    pl "$filelist" | tm -tout nw 'vim -'
        #    #echo -E "$filelist" | vim -
        #fi

}
zle -N fzf-dirs
bindkey '^Q' fzf-dirs

fzf-files() {
    trap func_trap EXIT
    func_trap() {
        tput rc
    }

    tput sc

    F f -f | mnm | fzf | {
        input="$(cat)"
        if [ -n "$input" ]; then
            # pl "$input" | tm -i -S -tout spv -xargs rifle
            printf -- "%s" "$input" | xc -i
            exec </dev/tty
            rifle -- "$(printf -- "%s" "$input" | umn)"
        fi
    }

        #filelist="$(find-all-no-git.sh | fzf -p --multi)"
        #if [ -n "$filelist" ]; then
        #    pl "$filelist" | tm -tout nw 'vim -'
        #    #echo -E "$filelist" | vim -
        #fi
}
zle -N fzf-files
# bindkey '\e^Q' fzf-files # C-M-q
bindkey '\eq' fzf-files # M-q

function _git-status {
    zle kill-whole-line
    zle -U "git status"
    zle accept-line
}
# Declare the function as a widget
zle -N _git-status

# List zle widgets
# zle -la
# zle -la | grep -P '([^a-z]|\b)git\b'
# # List only user defined widgets
# zle -l

# Emulate bash's PROMPT_COMMAND
# Also, figure this out
#export PROMPT_COMMAND='hpwd=$(history 1); hpwd="${hpwd# *[0-9]*  }"; if [[ ${hpwd%% *} == "cd" ]]; then cwd=$OLDPWD; else cwd=$PWD; fi; hpwd="${hpwd% \#\#\# *} ### $cwd"; history -s "$hpwd"'
#precmd() { eval "$PROMPT_COMMAND" }


# Instruct Python to execute a start up script
# Ensure that the startup script will be able to access COLUMNS
export COLUMNS

disable r
# This will allow me to create a wrapper script called r. Otherwise it
# will use the zsh r builtin.


. ~/.shellrc

. $HOME/scripts/libraries/bash-library.sh

# add this configuration to ~/.zshrc
#export HISTFILE=~/.zsh_history  # ensure history file visibility
export HH_CONFIG=hicolor        # get more colors
#bindkey -s "\C-r" "\eqhh\n"     # bind hh to Ctrl-r (for Vi mode check doc)

export SHELL=zsh
#export SHELL="$(readlink /proc/$$/exe)"


# Why the hell ire there so many /usr/bin in path?
PATH="$(printf -- "%s" "$PATH" | sed ':a;s_:/usr/bin:__g;ta'):/usr/bin"
PATH="$(printf -- "%s" "$PATH" | sed ':a;s_^/usr/bin:__g;ta'):/usr/bin"
PATH="$(printf -- "%s" "$PATH" | sed ':a;s_:/usr/bin$__g;ta'):/usr/bin"
export PATH

# This is so I can run tm commands taken from autofiles file in zsh.
export TM_SESSION_NAME
export PARENT_SESSION_ID
export PARENT_SESSION_NAME
export PARENT_WINDOW_ID

# If you use zsh and Tramp hangs every time you try to connect, try
# placing this in your .zshrc from the remote computer:

if [[ "$TERM" == "dumb" ]]
then
    # When zsh is run in emacs through C-c r, or ("s" shell "shell"), it enters here.

    {
        unsetopt zle
        unsetopt prompt_cr
        # Why was this unset? It stops zsh from displaying the prompt in emacs
        # unsetopt prompt_subst
        unfunction precmd
        unfunction preexec
        PS1="zsh dumb $ $PS1"
    } &>/dev/null
fi

# This only works for bash
# source /home/shane/.bazel/bin/bazel-complete.bash

# this was killing zsh -- bad syntax
# # load .esrc environment # es-shell cant output to shell. this command
# # just outputs its environment
# if [ -f "$HOME/.esrc" ]; then
#     eval "`es -l <<-x
#         sh <<<'export -p'
#     x`"
# fi

# This makes things like eipe work
# "export TTY; echo hi | eipe | cat"
export TTY



# Appears to not work, at least with my version
# . $HOME/source/git/github/hub/etc/hub.zsh_completion


# The next line updates PATH for the Google Cloud SDK.
if [ -f "$HOME$MYGIT/google-cloud-sdk/google-cloud-sdk/path.zsh.inc" ]; then source "$HOME$MYGIT/google-cloud-sdk/google-cloud-sdk/path.zsh.inc"; fi

# The next line enables shell command completion for gcloud.
if [ -f "$DUMP$MYGIT/google-cloud/google-cloud-sdk/completion.zsh.inc" ]; then source "$DUMP$MYGIT/google-cloud/google-cloud-sdk/completion.zsh.inc"; fi

export DISPLAY=:0