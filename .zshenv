############ -*- Mode: shell-script; coding: euc-jp -*- ####
# ~ippei/.zshenv
#   written by kishida@imat.eng.osaka-cu.ac.jp
# last-modified: 2006/06/11 23:18:30.
# 修正、改変、再配布何でも可
# cf: man zshall, zshoptions
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
#export JLESSCHARSET="japanese-sjis"
export MANPATH="/usr/local/man:/usr/X11R6/man:/usr/share/man"
export NLSPATH="/usr/local/man:/usr/X11R6/man:/usr/share/man"
export INFOPATH="$HOME/info:/usr/share/info:/usr/local/info"
#export HTTP_HOME="$HOME/.w3m/bookmark.html" # for w3m
export FTP_PASSIVE_MODE="NO"
#export LC_ALL="ja_JP.eucJP"	# subversionに必要
#export LC_ALL="C"	# subversionに必要
#export LC_CTYPE="ja_JP.eucJP"	# jman など
#export LC_CTYPE="ja_JP.UTF-8"
#export LC_CTYPE="cp932"
#export LC_ALL="cp932"
#export LC_CTYPE="ja_JP.EUC"	# ←subversion で接続できなくなる
#export LANG="C"
#export LANG="ja_JP.eucJP" # vim でエラー：リルが出せない。.vimrc enc で対処
#export LANG="ja_JP.EUC"
#export LANG="japanese" # vim でエラー：ラリルレロが出せない。
export LANG="ja_JP.UTF-8" # or ja_JP.UTF8
#export LC_ALL="ja_JP.UTF-8"
#export LANG="cp932" # or ja_JP.UTF8
#export XMODIFIERS="@im=skkinput"
#export GNUSTEP_USER_ROOT="$HOME/.GNUstep"

#export LIBRARY_PATH="/home/asano/tbb/tbb20_20080408oss_src/build/linux_ia32_gcc_cc4.1.2_libc2.6_kernel2.6.21_release"
export LD_LIBRARY_PATH="/opt/intel_fc_80/lib:/opt/intel_fc_81/lib:\
/usr/lib:/usr/lib/compat/aout:\
/usr/X11R6/lib:/usr/X11R6/lib/aout:\
/usr/local/lib:/usr/local/lib/compat/pkg"

#### $PAGER	"less"  
# less -M はページのステータス(何ページ目か)の表示
if which lv >& /dev/null ; then
  #export PAGER="lv -Os"
  export PAGER="lv"
else
  export PAGER="less -RM --quiet -x2"
fi
#if which jless >& /dev/null ; then
#    export PAGER="jless -RM --quiet -x2"
#elif which less >& /dev/null ;  then
#    export PAGER="less -RM --quiet -x2"
#else
#    export PAGER="more -x2"
#fi

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

#### LS_COLORS
#export LS_COLORS="no=00:fi=00:di=01;04;34;40:ln=01;36:pi=40;33:so=01;35:do=01;35:bd=40;33;01:cd=40;33;01:or=40;31;01:mi=01;05;37;41:su=37;41:sg=30;43:tw=30;42:ow=34;42:st=37;44:ex=01;32:*.cmd=01;32:*.exe=01;32:*.com=01;32:*.btm=01;32:*.bat=01;32:*.sh=01;32:*.csh=01;32:*.tar=01;31:*.tgz=01;31:*.svgz=01;31:*.arj=01;31:*.taz=01;31:*.lzh=01;31:*.lzma=01;31:*.zip=01;31:*.z=01;31:*.Z=01;31:*.dz=01;31:*.gz=01;31:*.bz2=01;31:*.tbz2=01;31:*.bz=01;31:*.tz=01;31:*.deb=01;31:*.rpm=01;31:*.jar=01;31:*.rar=01;31:*.ace=01;31:*.zoo=01;31:*.cpio=01;31:*.7z=01;31:*.rz=01;31:*.jpg=01;35:*.jpeg=01;35:*.gif=01;35:*.bmp=01;35:*.pbm=01;35:*.pgm=01;35:*.ppm=01;35:*.tga=01;35:*.xbm=01;35:*.xpm=01;35:*.tif=01;35:*.tiff=01;35:*.png=01;35:*.mng=01;35:*.pcx=01;35:*.mov=01;35:*.mpg=01;35:*.mpeg=01;35:*.m2v=01;35:*.mkv=01;35:*.ogm=01;35:*.mp4=01;35:*.m4v=01;35:*.mp4v=01;35:*.vob=01;35:*.qt=01;35:*.nuv=01;35:*.wmv=01;35:*.asf=01;35:*.rm=01;35:*.rmvb=01;35:*.flc=01;35:*.avi=01;35:*.fli=01;35:*.gl=01;35:*.dl=01;35:*.xcf=01;35:*.xwd=01;35:*.yuv=01;35:*.svg=01;35:*.aac=00;36:*.au=00;36:*.flac=00;36:*.mid=00;36:*.midi=00;36:*.mka=00;36:*.mp3=00;36:*.mpc=00;36:*.ogg=00;36:*.ra=00;36:*.wav=00;36:"

#### Ruby cygwin用
export RUBYOPT=

#### w3m
#export OUTPUT_CHARSET=sjis
#export OUTPUT_CHARSET=utf-8

#### 個人用設定を読み込む
if [ -e ~/.zshenv_private ]; then
    source ~/.zshenv_private
fi
