# common function initialize start
colors () {
    typeset -Ag color colour
    color=(00 none 01 bold 02 faint 22 normal 03 standout 23 no-standout 04 underline 24 no-underline 05 blink 25 no-blink 07 reverse 27 no-reverse 08 conceal 30 black 40 bg-black 31 red 41 bg-red 32 green 42 bg-green 33 yellow 43 bg-yellow 34 blue 44 bg-blue 35 magenta 45 bg-magenta 36 cyan 46 bg-cyan 37 white 47 bg-white 39 default 49 bg-default)
    local k
    for k in ${(k)color}
    do
            color[${color[$k]}]=$k
    done
    for k in ${color[(I)3?]}
    do
            color[fg-${color[$k]}]=$k
    done
    color[grey]=${color[black]}
    color[fg-grey]=${color[grey]}
    color[bg-grey]=${color[bg-black]}
    colour=(${(kv)color})
    local lc=$'\e[' rc=m
    typeset -Hg reset_color bold_color
    reset_color="$lc${color[none]}$rc"
    bold_color="$lc${color[bold]}$rc"
    typeset -AHg fg fg_bold fg_no_bold
    for k in ${(k)color[(I)fg-*]}
    do
            fg[${k#fg-}]="$lc${color[$k]}$rc"
            fg_bold[${k#fg-}]="$lc${color[bold]};${color[$k]}$rc"
            fg_no_bold[${k#fg-}]="$lc${color[normal]};${color[$k]}$rc"
    done
    typeset -AHg bg bg_bold bg_no_bold
    for k in ${(k)color[(I)bg-*]}
    do
            bg[${k#bg-}]="$lc${color[$k]}$rc"
            bg_bold[${k#bg-}]="$lc${color[bold]};${color[$k]}$rc"
            bg_no_bold[${k#bg-}]="$lc${color[normal]};${color[$k]}$rc"
    done
}
compinit () {
    # undefined
    builtin autoload -XUz
}

function history-search-end {
    integer cursor=$CURSOR mark=$MARK
    
    if [[ $LASTWIDGET = history-beginning-search-*-end ]]; then
        CURSOR=$MARK
    else
        MARK=$CURSOR
    fi
    
    if zle .${WIDGET%-end}; then
        zle .end-of-line
    else
        CURSOR=$cursor
        MARK=$mark
        return 1
    fi
}

# commonfunction initialize end

#autoload colors
colors

# プロンプト
case ${HOST} in
*miniy*)
    PROMPT="%B%{${fg[yellow]}%}[%D{%y/%m/%d %H:%M}]%{${reset_color}%} %{${fg[red]}%}%~$%{${reset_color}%}%b "
#    RPROMPT="%D{%y/%m/%d %H:%M:%S}"
    PROMPT2="%{${fg[red]}%}%_$%{${reset_color}%} "
    SPROMPT="%{${fg[red]}%}%r is correct? [n,y,a,e]:%{${reset_color}%} "
    [ -n "${REMOTEHOST}${SSH_CONNECTION}" ] && 
        RPROMPT="%B%{${fg[cyan]}%}$(echo ${HOST%%.*})%{${reset_color}%}%b"
    ;;
*)
    PROMPT="%{${fg[red]}%}%/$%{${reset_color}%} "
    PROMPT2="%{${fg[red]}%}%_$%{${reset_color}%} "
    SPROMPT="%{${fg[red]}%}%r is correct? [n,y,a,e]:%{${reset_color}%} "
    [ -n "${REMOTEHOST}${SSH_CONNECTION}" ] && 
        PROMPT="%{${fg[yellow]}%}$(echo ${HOST%%.*} | tr '[a-z]' '[A-Z]') ${PROMPT}"
esac

# ctrl + キーを有効化
bindkey -e

# ディレクトリ名だけ打ったときに移動できる
setopt auto_cd

# ディレクトリ移動時にスタックに保存 cd -[tab]で候補が出る。
setopt auto_pushd

# 同じディレクトリをpushdしない
setopt pushd_ignore_dups

# 様々な補完を有効化
setopt correct

# 補完候補を詰めて表示する。
# http://news.mynavi.jp/column/zsh/005/index.html
setopt list_packed

# slashを最後に削除させないようにするため。
# http://news.mynavi.jp/column/zsh/010/index.html
setopt noautoremoveslash

# ビープ音が鳴らないようにする。（不要）
setopt nolistbeep

# historyを入力したところまでのものから検索するためのもの
# autoload history-search-end
zle -N history-beginning-search-backward-end history-search-end
zle -N history-beginning-search-forward-end history-search-end
bindkey "^p" history-beginning-search-backward-end
bindkey "^n" history-beginning-search-forward-end
bindkey "\\ep" history-beginning-search-backward-end
bindkey "\\en" history-beginning-search-forward-end

## historyの基本設定
#
HISTFILE=${HOME}/.zsh_history
HISTSIZE=50000
SAVEHIST=50000
setopt hist_ignore_dups     # ignore duplication command history list
setopt share_history        # share command history data


## Completion configuration
#
fpath=(/usr/share/zsh/functions ${fpath})
autoload -U compinit && compinit


## zsh editor
#
autoload zed


# Screen使用時の設定
case "${TERM}" in screen)
    preexec() {
        # ssh 実行したら実行先ホスト名がタイトルになるようにする
        if [ "${1%% *}" = "ssh" ]; then
            echo -n "\ek@"`echo $1 | cut -f2 -d" " | sed "s/\..*//g"`"\e\\"
        # vimやlessなど,第2プロンプトを開いている場合
        elif [ "${1%% *}" = "vim" -o "${1%% *}" = "less" -o "${1%% *}" = "man" -o "${1%% *}" = "jman" -o ]; then
            echo -n "\ek+${1%% *} "`echo $1 | cut -f2 -d " "| awk '{ if ( length($1) > 10 ) { print substr($1, 0, 8)".."; } else { print $1}}'`"\e\\"
        fi
    }
    precmd() {
        # sshしていない場合はディレクトリの先頭位置
        echo -n "\ek/"`echo ${PWD} | sed "s/.*\///g"| awk '{ if ( length($1) > 10 ) { print substr($1, 0, 8)".."; } else { print $1}}'`"\e\\"
    }
    ;;
esac

# jman用に多バイト用のPAGER設定
if [ -e "/usr/local/bin/jless" ]; then
    export PAGER="jless"
fi
if [ -e "/usr/bin/lv" ]; then
    export PAGER="lv"
fi

# デフォルトjmanにする
if [ -e "/usr/local/bin/jman" ]; then
    export man=jman
fi

# 通常のmanを使う場合
function eman () {
    man -M '/usr/share/man:/usr/local/man:/usr/share/perl/man:/usr/share/openssl/man:/usr/X11R6/man' $1
}
# manのパス設定
export MANPATH=/usr/local/man/ja:/usr/share/man/ja:/usr/share/man:/usr/local/man:/usr/share/openssl/man:/usr/X11R6/man

# commandのパス設定
export PATH=/home/keijsuzu/bin:/sbin:/usr/sbin:/bin:/usr/bin:/usr/local/bin

# ヒストリファイルにコマンドラインだけではなく実行時刻と実行時間も保存する。
setopt extended_history
# スペースで始まるコマンドラインはヒストリに追加しない。
setopt hist_ignore_space
# PROMPT内で変数展開・コマンド置換・算術演算を実行する。
setopt prompt_subst
# コピペしやすいようにコマンド実行後は右プロンプトを消す。
setopt transient_rprompt

## 補完侯補をメニューから選択する。
### select=2: 補完候補を一覧から選択する。
###           ただし、補完候補が2つ以上なければすぐに補完する。
zstyle ':completion:*:default' menu select=2

## 補完候補に色を付ける。
### "": 空文字列はデフォルト値を使うという意味。
zstyle ':completion:*:default' list-colors ""

## 補完方法の設定。指定した順番に実行する。
### _oldlist 前回の補完結果を再利用する。
### _complete: 補完する。
### _match: globを展開しないで候補の一覧から補完する。
### _history: ヒストリのコマンドも補完候補とする。
### _ignored: 補完候補にださないと指定したものも補完候補とする。
### _approximate: 似ている補完候補も補完候補とする。
### _prefix: カーソル以降を無視してカーソル位置までで補完する。
zstyle ':completion:*' completer \
    _oldlist _complete _match _history _ignored _approximate _prefix

## 補完候補をキャッシュする。
zstyle ':completion:*' use-cache yes
## 詳細な情報を使う。
zstyle ':completion:*' verbose yes

## カーソル位置で補完する。
setopt complete_in_word
## globを展開しないで候補の一覧から補完する。
setopt glob_complete
## 補完時にヒストリを自動的に展開する。
setopt hist_expand
## 補完候補がないときなどにビープ音を鳴らさない。
setopt no_beep
## 辞書順ではなく数字順に並べる。
setopt numeric_glob_sort

# ジョブ
## jobsでプロセスIDも出力する。
setopt long_list_jobs

# 単語
## 「/」も単語区切りとみなす。
WORDCHARS=${WORDCHARS:s,/,,}

## globでパスを生成したときに、パスがディレクトリだったら最後に「/」をつける。
setopt mark_dirs

# 実行時間
## 実行したプロセスの消費時間が3秒以上かかったら
## 自動的に消費時間の統計情報を表示する。
REPORTTIME=3

# screen復帰時にソケットを今の接続のものにして復帰する
function screenr () {
    session=`screen -ls | grep "Detached" | awk '{print $1}' | head -1`
    if [ "$session" != "" ]; then
        screen -S $session -X setenv SSH_AUTH_SOCK "$SSH_AUTH_SOCK"
        screen -r $session
    else
        echo "Detached session not found"
        screen -ls
    fi
}


## Alias configuration
setopt complete_aliases     # aliased ls needs if file/dir completions work

alias where="command -v"
alias j="jobs -l"

case "${OSTYPE}" in
freebsd*|darwin*)
    alias ls="ls -G -w"
    ;;
linux*)
    alias ls="ls --color"
    ;;
esac

alias la="ls -a"
alias lf="ls -F"
alias ll="ls -l"
alias l="ls -la"

alias du="du -h"
alias df="df -h"

alias su="su -l"

# less color化
alias less="less -R"

# bashからの起動時だと困るので
export SHELL=`which zsh`

# ssh-agentを再度割り当てる
if [ "$SSH_AUTH_SOCK" -a "$SSH_AUTH_SOCK" != "$HOME/.ssh/auth_sock" ]; then
    export SSH_AUTH_SOCK_ORG=$SSH_AUTH_SOCK
    ln -fs $SSH_AUTH_SOCK $HOME/.ssh/auth_sock
    export SSH_AUTH_SOCK=$HOME/.ssh/auth_sock
fi

# todayを出す
function today { LBUFFER=$LBUFFER'$(date +%Y%m%d)' }
zle -N today
bindkey '^X^T' today

# zshrc以外の設定などを読み込む
[ -f ${HOME}/.zshrc.mine ] && source ${HOME}/.zshrc.mine
