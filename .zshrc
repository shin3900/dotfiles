# last-modified: 2006/06/14 11:35:21.

autoload -U zmv
alias mmv='noglob zmv -W'  # 引数のクォートも面倒なので
zstyle ':completion:*' use-compctl false # compctl形式を使用しない

autoload -U colors; colors      # ${fg[red]}形式のカラー書式を有効化

autoload -Uz VCS_INFO_get_data_git; VCS_INFO_get_data_git 2> /dev/null

hosts=( localhost `hostname` )
#printers=( lw ph clw )
umask 002
cdpath=( ~ )                    # cd のサーチパス

#↓カレントディレクトリに候補がない場合のみ cdpath 上のディレクトリを候補
zstyle ':completion:*:cd:*' tag-order local-directories path-directories
# cf. zstyle ':completion:*:path-directories' hidden true
# cf. cdpath 上のディレクトリは補完候補から外れる

#↓補完時に大小文字を区別しない
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Z}'

WORDCHARS='*?_-.[]~=&;!#$%^(){}<>' #C-w での単語区切りとして認識される文字
#        「*?_-.[]~=/&;!#$%^(){}<>」←WORDCHARS のデフォルト値

#### history
HISTFILE="$HOME/.zhistory"      # 履歴ファイル
HISTSIZE=100000           # メモリ上に保存される $HISTFILE の最大サイズ？
SAVEHIST=100000                  # 保存される最大履歴数

#### option, limit, bindkey
setopt extended_history         # コマンドの開始時刻と経過時間を登録
setopt hist_ignore_dups         # 直前のコマンドと同一ならば登録しない
setopt hist_ignore_all_dups     # 登録済コマンド行は古い方を削除
setopt hist_reduce_blanks # 余分な空白は詰めて登録(空白数違い登録を防ぐ)
#setopt append_history  # zsh を終了させた順にファイルに記録(デフォルト)
#setopt inc_append_history # 同上、ただしコマンドを入力した時点で記録
setopt share_history    # ヒストリの共有。(append系と異なり再読み込み不要、これを設定すれば append 系は不要)
setopt hist_no_store            # historyコマンドは登録しない
setopt hist_ignore_space # コマンド行先頭が空白の時登録しない(直後ならば呼べる)


setopt list_packed              # 補完候補リストを詰めて表示
setopt print_eight_bit          # 補完候補リストの日本語を適正表示
#setopt menu_complete  # 1回目のTAB で補完候補を挿入。表示だけの方が好き
#setopt no_clobber               # 上書きリダイレクトの禁止
setopt no_unset                 # 未定義変数の使用の禁止
setopt no_hup                   # logout時にバックグラウンドジョブを kill しない
setopt no_beep                  # コマンド入力エラーでBEEPを鳴らさない

setopt extended_glob            # 拡張グロブ
setopt numeric_glob_sort        # 数字を数値と解釈して昇順ソートで出力
setopt auto_cd                  # 第1引数がディレクトリだと cd を補完
setopt correct                  # スペルミス補完
setopt no_checkjobs             # exit 時にバックグラウンドジョブを確認しない
#setopt ignore_eof              # C-dでlogoutしない(C-dを補完で使う人用)
setopt pushd_to_home        # 引数なしpushdで$HOMEに戻る(直前dirへは cd - で)
setopt pushd_ignore_dups        # ディレクトリスタックに重複する物は古い方を削除
#setopt pushd_silent   # pushd, popd の度にディレクトリスタックの中身を表示しない
setopt interactive_comments     # コマンド入力中のコメントを認める
setopt auto_pushd				# pushd
#setopt rm_star_silent          # rm * で本当に良いか聞かずに実行
#setopt rm_star_wait            # rm * の時に 10秒間何もしない
#setopt chase_links             # リンク先のパスに変換してから実行。
# setopt sun_keyboard_hack      # SUNキーボードでの頻出 typo ` をカバーする


#limit   coredumpsize    0       # コアファイルを吐かないようにする

stty    erase   '^H'
stty    intr    '^C'
stty    susp    '^Z'

#### bindkey
# bindkey "割当てたいキー" 実行させる機能の名前
bindkey -e    # emacs 風キーバインド(環境変数 EDITOR も反映するが、こっちが優先)
bindkey '^I'    complete-word   # complete on tab, leave expansion to _expand

bindkey '^P' history-beginning-search-backward # 先頭マッチのヒストリサーチ
bindkey '^N' history-beginning-search-forward # 先頭マッチのヒストリサーチ
# run-help が呼ばれた時、zsh の内部コマンドの場合は該当する zsh のマニュアル表示
[ -n "`alias run-help`" ] && unalias run-help
autoload run-help

#### completion
#_cache_hosts=(localhost $HOST hashish loki3 mercury
#  Li He Pt Au Ti{1,2} Ni{1,2} Co{1..8} Zn{1..8}
#  192.168.0.1 192.168.1.1
#)
# ↑(_cache_hosts) ~/.ssh/known_hosts から自動的に取得する

autoload -U compinit; compinit -u
compdef _tex platex             # platex に .tex を


############################################################
## プロンプト設定
unsetopt promptcr       # 改行のない出力をプロンプトで上書きするのを防ぐ
setopt prompt_subst             # ESCエスケープを有効にする

function rprompt-git-current-branch {
  local name st color gitdir action
  if [[ "$PWD" =~ '/\.git(/.*)?$' ]]; then
    return
  fi
  name=`git branch 2> /dev/null | grep '^\*' | cut -b 3-`
  if [[ -z $name ]]; then
    return
  fi
  gitdir=`git rev-parse --git-dir 2> /dev/null`
  action=`VCS_INFO_git_getaction "$gitdir"` && action="($action)"
  st=`git status 2> /dev/null`
  if [[ -n `echo "$st" | grep "^nothing to"` ]]; then
    color=%F{green}
  elif [[ -n `echo "$st" | grep "^nothing added"` ]]; then
    color=%F{yellow}
  elif [[ -n `echo "$st" | grep "^# Untracked"` ]]; then
    color=%B%F{red}
  else
    color=%F{red}
  fi
  echo "$color$name$action%f%b "
}

#if [ $TERM = "kterm-color" ] || [ $TERM = "xterm" ]; then
if [ $COLORTERM = 1 ]; then
  if [ $UID = 0 ] ; then 
    PSCOLOR='00;04;31'
  else
    PSCOLOR='00;04;33'
  fi
  #RPS1=$'%{\e[${PSCOLOR}m%}[%{\e[00m%}`rprompt-git-current-branch`%{\e[${PSCOLOR}m%}%~]%{\e[00m%}'    # 右プロンプト
  RPS1=$'%{\e[${PSCOLOR}m%}[%~]%{\e[00m%}'    # 右プロンプト
  #PS1=$'%{\e]2; %m:%~ \a'$'\e]1;%%: %~\a%}'$'\n%{\e[${PSCOLOR}m%}%n@%m %#%{\e[00m%} '
  #PS1=$'%{\e]2; %m:%~ \a'$'\e]1;%%: %~\a%}'$'\n%{\e[${PSCOLOR}m%}%n@%m ${WINDOW:+"[$WINDOW]"}%#%{\e[00m%} ' #kterm
  PS1=$'%{\e]2; %m:%~ \a'$'\e]1;%%: %~\a%}'$'\n%{\e[${PSCOLOR}m%}%n@%m ${WINDOW:+"[$WINDOW]"}%#%{\e[00m%} '
  # 1個目の $'...' は 「\e]2;「kterm のタイトル」\a」
  # 2個目の $'...' は 「\e]1;「アイコンのタイトル」\a」
  # 3個目の $'...' がプロンプト
  #
  # \e を ESC コード(で置く必要があるかも
  # emacs では C-q ESC, vi では C-v ESC で入力する
  #       \e[00m  初期状態へ
  #       \e[01m  太字    (0は省略可能っぽい)
  #       \e[04m  アンダーライン
  #       \e[05m  blink(太字)
  #       \e[07m  反転
  #       \e[3?m  文字色をかえる
  #       \e[4?m  背景色をかえる
  #               ?= 0:黒, 1:赤, 2:緑, 3:黄, 4:青, 5:紫, 6:空, 7:白
else    
  PS1="%n@%m %~ %# "
fi

############################################################
## alias & function

#### less
alias less="$PAGER"
alias m=less
alias -g L="| less"
alias -g M="| less"
alias les="less"        # for typo


#### man
if which jman >& /dev/null; then
  alias man="LC_ALL=ja_JP.eucJP jman"
fi

#### ps
if [ $ARCHI = "irix" ]; then
  alias psa='ps -ef'
else; 
  alias psa='ps auxw'
fi
function pst() {                # CPU 使用率の高い方から8つ
  psa | head -n 1
  psa | sort -r -n +2 | grep -v "ps -auxww" | grep -v grep | head -n 8
}
function psm() {                # メモリ占有率の高い方から8つ
  psa | head -n 1
  psa | sort -r -n +3 | grep -v "ps -auxww" | grep -v grep | head -n 8
}
function psg() {
  psa | head -n 1
  psa | grep $* | grep -v "ps -auxww" | grep -v grep
}

#### ls
#### dircolor
if (which dircolors >& /dev/null) && [ -e $HOME/.dircolors ]; then
  eval `dircolors $HOME/.dircolors` # 色の設定
fi
if which gnuls >& /dev/null ; then
  alias ls="gnuls -F --color=auto --show-control-char"
  alias lscolor='gnuls -F --color=always --show-control-char'
  # 補完リストをカラー化
  zstyle ':completion:*:default' list-colors ${(s.:.)LS_COLORS}
  #zstyle ':completion:*' list-colors ${(s.:.)LS_COLORS} でも良さげ
elif [ $ARCHI = "linux" ] || [ $ARCHI = "cygwin" ]; then
  alias ls="ls -F --color=auto --show-control-char"
  alias lscolor='ls -F --color=always --show-control-char'
  # 補完リストをカラー化
  zstyle ':completion:*:default' list-colors ${(s.:.)LS_COLORS}
else
  alias ls="ls -F"
  alias lscolor='ls -F'
fi
alias sl='ls'
alias l='ls'
alias la='ls -a'
alias ll='ls -al'

function lsl() { ls $* | less }
#function lll() { lscolor -la $* | less }
function lll() { ls -la $* | less }

#### command
alias df='df -h'
if [ $ARCHI = "linux" ] || [ $ARCHI = "cygwin" ]; then
  alias du='du -h --max-depth=1' # 人間に読める表示で, 深さ1の階層まで表示
else
  alias du='du -h -d 1'          # 人間に読める表示で, 深さ1の階層まで表示
fi
alias mv='mv -iv'
#alias  memo    'skkfep -viesc -e jvim3 ~/memo.txt'
function kterm() { /usr/X11R6/bin/kterm -sb -sl 500 -km euc -title kterm@$HOST $* & }
function mlterm() { command mlterm --term=mlterm $* & }
alias xcalc='xcalc &'
alias xterm='xterm &'
#alias w3m="LANG='ja_JP.EUC' w3m -X"
alias w3m="w3m -O UTF-8 -cookie"
alias xinit='ssh-agent xinit'
alias bell="echo '\a'"
alias scr="screen -xRU"
alias view="vim -R"
# short name
alias h='head'
alias t='tail'
alias g='grep'
alias j='jobs'

## global alias
alias -g H='| head'
alias -g T='| tail'
alias -g G='| grep'
alias -g C='| cat -n'
alias -g W='| wc'
alias -g ....='../..'
function cd() { builtin cd $@ && ls; }
function emacs() {command emacs $* &}
alias emasc=emacs
function gv() { command gv $* & }
function xdvi() { command xdvi $* & }
alias cp='cp -iv'
alias dos2unix="nkf --unix -O --overwrite" # euc-jp, LF
alias unix2dos="nkf --windows -O --overwrite" # shift-jis, CRLF

# bell
#function cvsup()       { command cvsup $*       ; echo '\a' }
#function pkgdb()       { command pkgdb $*       ; echo '\a' }
#function portinstall() { command portinstall $* ; echo '\a' }
#function emerge()      { command emerge $*      ; echo '\a' }
#function rsync()       { command rsync $*       ; echo '\a' }
#function ./configure() { command ./configure $* ; echo '\a' }
#
#function dd()          { command dd $*          ; echo '\a' }


#### time
REPORTTIME=8                    # CPUを8秒以上使った時は time を表示
TIMEFMT="\
    The name of this job.             :%J
    CPU seconds spent in user mode.   :%U
    CPU seconds spent in kernel mode. :%S
    Elapsed time in seconds.          :%E
    The  CPU percentage.              :%P"

#### ログインの監視
# log コマンドでも情報を見ることができる
watch=(notme) # (all:全員、notme:自分以外、ユーザ名,@ホスト名、%端末名
              # (列挙；空白区切り、繋げて書くとAND条件)
LOGCHECK=60                     # チェック間隔[秒]
WATCHFMT="%(a:${fg[blue]}Hello %n [%m] [%t]:${fg[red]}Bye %n [%m] [%t])"
# ↑では、a (ログインかログアウトか)で条件分岐している
# %(a:真のメッセージ:偽のメッセージ)
# a,l,n,m,M で利用できる。
# ■使える特殊文字
# %n    ユーザ名
# %a    ログイン/ログアウトに応じて「logged on」/「logged off」
# %l    利用している端末名
# %M    長いホスト名
# %m    短いホスト名
# %S〜%s        〜の間を反転
# %U〜%u        〜の間をアンダーライン
# %B〜%b        〜の間を太字
# %t,%@ 12時間表記の時間
# %T    24時間表記の時間
# %w    日付(曜日 日)
# %W    日付(月/日/年)
# %D    日付(年-月-日)

