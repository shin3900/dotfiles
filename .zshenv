############ -*- Mode: shell-script; coding: utf8 -*- ####
############################################################
# ~/.zshenv には対話的な機能以外の部分を記述すべき
# 例えば、ssh remote ls とかでリモートホストにコマンドを投げる場合は
# ~/.zshenv のみ有効で ~/.zshrc などは有効にならない
# この場合 ~/.zshenv に PATH の設定がなければ ls は実行できない
############################################################
#### ARCHI
if [ -x /usr/bin/uname ] || [ -x /bin/uname ]; then
    case "`uname -sr`" in
        FreeBSD*); export ARCHI="freebsd" ;;
        Linux*);   export ARCHI="linux"   ;;
        CYGWIN*);  export ARCHI="cygwin"  ;;
        IRIX*);    export ARCHI="irix"    ;;
        OSF1*);    export ARCHI="osf1"    ;;
        *);        export ARCHI="dummy"   ;;
    esac
else
    export ARCHI="dummy"
fi

#### HOST
if [ -x /bin/hostname ]; then
    export HOST=`hostname`
fi;
export host=`echo $HOST | sed -e 's/\..*//'`

export UID
export SHELL=`which zsh`
export CC=`which gcc`
export JLESSCHARSET="japanese"
export INFOPATH="$HOME/info:/usr/share/info:/usr/local/info"
export FTP_PASSIVE_MODE="NO"
export LANG="ja_JP.UTF-8" # or ja_JP.UTF8

#### $PAGER	"less"  
# less -M はページのステータス(何ページ目か)の表示
if which lv >& /dev/null ; then
  export PAGER="lv"
else
  export PAGER="less -RM --quiet -x2"
fi

#### $COLORTERM 
export COLORTERM=0
case "$TERM" in 
    xterm*);	COLORTERM=1 ;;  # putty
    mlterm*);	COLORTERM=1 ; TERM='kterm-color';;
    screen*);	COLORTERM=1 ;;
    ct100*);	COLORTERM=1 ;;	# TeraTermPro
    kterm*);	COLORTERM=1 ; TERM='kterm-color'
      export LANG=ja_JP.eucJP;   #w3m とか mutt とかに必要
      export LC_ALL=ja_JP.eucJP;;
    #vim は TERM='kterm' ではカラー化しない
    #screen は TERM='kterm-color' ではタイトルバーに情報表示できない
esac

#### EDITOR
export EDITOR='vi'
# cygwin は vim-nox があるため
#if which vim >& /dev/null ; then	
#    alias vi="vim"
#    #export EDITOR="LC_ALL=ja_JP.EUC vim"
#fi
 
####  path / PATH
# システムから提供される PATH およびユーザが定義する複数の候補から、
# 実際にシステムに存在するディレクトリに対してのみ PATH に追加する
# この際重複チェックを行い、同一のディレクトリが含まれないようにしている
userpath=( \			# 配列に候補を入れる
    $path /bin /sbin /usr/bin /usr/sbin /usr/local/bin /usr/local/sbin \
    $HOME/bin \
	)
addpath=()			# 確定した候補を入れていく受け皿
for i in "${userpath[@]}"; do	# 受け皿に追加していく
    chksame=0
    if [ -d $i ]; then		# システムにディレクトリが存在しなければ飛ばす
	for j in "${path[@]}"; do
	    if [ $i = $j ]; then # 重複しているなら重複フラグを立てておく
		chksame=1
		break
	    fi
	done
	if [ $chksame = 0 ] ; then # 重複フラグが立ってなければ受け皿に追加
	    addpath=( $addpath $i )
	fi
    fi
done
path=( $path $addpath )
unset userpath addpath i chksame # 後始末

#### Ruby cygwin用
export RUBYOPT=

#### 個人用設定を読み込む
if [ -e ~/.zshenv_private ]; then
    source ~/.zshenv_private
fi
