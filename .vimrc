" vim: set ts=2 sw=2 sts=0:
"-----------------------------------------------------------------------------
set nocompatible

" 文字コード関連
"
" 文字コードの自動認識
if &encoding !=# 'utf-8'
  set encoding=japan
  set fileencoding=japan
endif
if has('iconv')
  let s:enc_euc = 'euc-jp'
  let s:enc_jis = 'iso-2022-jp'
  " iconvがeucJP-msに対応しているかをチェック
  if iconv("\x87\x64\x87\x6a", 'cp932', 'eucjp-ms') ==# "\xad\xc5\xad\xcb"
    let s:enc_euc = 'eucjp-ms'
    let s:enc_jis = 'iso-2022-jp-3'
  " iconvがJISX0213に対応しているかをチェック
  elseif iconv("\x87\x64\x87\x6a", 'cp932', 'euc-jisx0213') ==# "\xad\xc5\xad\xcb"
    let s:enc_euc = 'euc-jisx0213'
    let s:enc_jis = 'iso-2022-jp-3'
  endif
  " fileencodingsを構築
  if &encoding ==# 'utf-8'
    let s:fileencodings_default = &fileencodings
    let &fileencodings = s:enc_jis .','. s:enc_euc .',cp932'
    let &fileencodings = &fileencodings .','. s:fileencodings_default
    unlet s:fileencodings_default
  else
    let &fileencodings = &fileencodings .','. s:enc_jis
    set fileencodings+=utf-8,ucs-2le,ucs-2
    if &encoding =~# '^\(euc-jp\|euc-jisx0213\|eucjp-ms\)$'
      set fileencodings+=cp932
      set fileencodings-=euc-jp
      set fileencodings-=euc-jisx0213
      set fileencodings-=eucjp-ms
      let &encoding = s:enc_euc
      let &fileencoding = s:enc_euc
    else
      let &fileencodings = &fileencodings .','. s:enc_euc
    endif
  endif
  " 定数を処分
  unlet s:enc_euc
  unlet s:enc_jis
endif

" 日本語を含まない場合は fileencoding に encoding を使うようにする
if has('autocmd')
  function! AU_ReCheck_FENC()
    if &fileencoding =~# 'iso-2022-jp' && search("[^\x01-\x7e]", 'n') == 0
      let &fileencoding=&encoding
    endif
  endfunction
  autocmd BufReadPost * call AU_ReCheck_FENC()
endif

" 改行コードの自動認識
set fileformats=dos,unix,mac
" □とか○の文字があってもカーソル位置がずれないようにする
if exists('&ambiwidth')
  set ambiwidth=double
endif

"-----------------------------------------------------------------------------
" プラグイン管理(NeoBundleの設定)
filetype off
if has('vim_starting')
  set rtp+=~/.vim/neobundle/neobundle.vim
endif
call neobundle#rc(expand('~/.vim/neobundle'))

" NeoBundle で管理するプラグインを書いていく
NeoBundle 'Shougo/neobundle.vim'
" guthub にあるプラグイン
NeoBundle 'Shougo/vimproc'
"NeoBundle 'mattn/benchvimrc-vim'
NeoBundle 'Shougo/vimfiler'
"NeoBundle 'Rip-Rip/clang_complete'
"vim本体が+pythonでビルドされている必要あり

NeoBundle 'Shougo/neocomplcache'
NeoBundle 'Shougo/neosnippet'
"NeoBundle 'Shougo/unite.vim'
"NeoBundle 'kana/vim-smartchr'
"NeoBundle 'thinca/vim-ref'
NeoBundle 'thinca/vim-quickrun'
NeoBundle 'tpope/vim-fugitive'
NeoBundle 'dag/vim2hs'
"NeoBundle 'eagletmt/ghcmod-vim'
NeoBundle 'Lokaltog/vim-powerline'
"NeoBundle 'scrooloose/nerdtree'
"NeoBundle 'tpope/vim-speeddating'
" www.vim.org にあるプラグイン
NeoBundle 'molokai'
NeoBundle 'Align'
"NeoBundle 'yanktmp.vim'
"NeoBundle 'L9'
"NeoBundle 'gtags.vim'
" それ以外にある git リポジトリにあるプラグイン
"NeoBundle 'git://git.wincent.com/command-t.git'
filetype plugin indent on
"

" 色テーマ
syntax on
set background=dark
set t_Co=256
colorscheme molokai

" CMake_xxx.txtもcmake用ハイライトを使う
autocmd BufNewFile,BufRead CMakeLists*.txt set filetype=cmake


"全角スペースを可視化
"コメント以外で全角スペースを指定しているので scriptencodingと、
""このファイルのエンコードが一致するよう注意！
"全角スペースが強調表示されない場合、ここでscriptencodingを指定すると良い。
""scriptencoding cp932

"デフォルトのZenkakuSpaceを定義
function! ZenkakuSpace()
  highlight ZenkakuSpace cterm=underline ctermfg=Yellow gui=underline guifg=darkgrey
endfunction

if has('syntax')
  augroup ZenkakuSpace
    autocmd!
    " ZenkakuSpaceをカラーファイルで設定するなら次の行は削除
    autocmd ColorScheme       * call ZenkakuSpace()
    " 全角スペースのハイライト指定
    autocmd VimEnter,WinEnter * match ZenkakuSpace /　/
  augroup END
  call ZenkakuSpace()
endif

"-----------------------------------------------------------------------------
" 編集関連
"
"オートインデントする
"set autoindent
"他で書き換えられたら自動で再読み込み
set autoread

" matchit.vim を使用する
source $VIMRUNTIME/macros/matchit.vim

" バイナリ編集モード
" *.binファイルを開くか -b を付けて起動すると16進ダンプ画面で開く"
augroup BinaryXXD
  autocmd!
  autocmd BufReadPre  *.bin let &binary =1
  autocmd BufReadPost * if &binary | silent %!xxd -g 1
  autocmd BufReadPost * set ft=xxd | endif
  autocmd BufWritePre * if &binary | %!xxd -r | endif
  autocmd BufWritePost * if &binary | silent %!xxd -g 1
  autocmd BufWritePost * set nomod | endif
augroup END

" スワップファイルの位置を指定する
set dictionary=


"-----------------------------------------------------------------------------
" 検索関連
"
" 検索文字列が小文字の場合は大文字小文字を区別なく検索する
set ignorecase
" 検索文字列に大文字が含まれている場合は区別して検索する
set smartcase
" 検索時に最後まで行ったら最初に戻る
set wrapscan
" インクリメンタルサーチ
set incsearch

"-----------------------------------------------------------------------------
" 装飾関連
"
"行番号を表示しない
set nonumber
"タブの左側にカーソル表示
set listchars=tab:\ \ 
set list
"タブ幅を設定する
set tabstop=2
set shiftwidth=2
set softtabstop=0
"指定幅で改行
"set textwidth=80
"タブをスペースに変換
set expandtab
"入力中のコマンドをステータスに表示する
set showcmd
"括弧入力時の対応する括弧を表示
set showmatch
"検索結果文字列のハイライトを有効にする
set hlsearch
"ステータスラインを常に表示
set laststatus=2
"ステータスラインに文字コードと改行文字を表示する
"set statusline=%<%f\ %m%r%h%w%{'['.(&fenc!=''?&fenc:&enc).']['.&ff.']'}%=%l,%c%V%8P
" エラーフラッシュとビープ音を無効にする
set visualbell t_vb=
set novisualbell

" 横幅が80行を超えるとハイライトする(cppのみ)
"set colorcolumn=80
"highlight OverLength ctermbg=red ctermfg=white guibg=#592929
"match OverLength /\%81v.\+/
"set textwidth=0
"if exists('&colorcolumn')
"  set colorcolumn=+1
"  autocmd FileType cpp setlocal textwidth=80
"endif

"-----------------------------------------------------------------------------
" 補完関係 

""補完候補を可視化
set wildmenu

" 補完メニューの色
"highlight Pmenu ctermbg=darkgrey
"highlight PmenuSel ctermbg=darkblue
"highlight PmenuSbar ctermbg=darkred
"---- clang
"let g:clang_complete_auto = 1
"let g:clang_use_library   = 1
"let g:clang_library_path  = '/usr/lib'
"let g:clang_user_options  = '2>/dev/null || exit 0'

"---- neocomplcache
" neocomplcache を有効化
let g:neocomplcache_enable_at_startup = 1
" 大文字小文字の区別無し
let g:neocomplcache_enable_smart_case = 1
" _区切りの補完を有効化
let g:neocomplcache_enable_underbar_completion = 1

" インクルード補完のパス
"let g:neocomplcache_include_paths.cpp="$NECO_INC_DIR"
set path+=$NECO_INC_DIR

"" C-h や BSでのポップアップ削除
"inoremap <expr><C-h> neocomplcache#smart_close_popup()
"ポップアップの確定
inoremap <expr><C-y> neocomplcache#close_popup()
" ポップアップのキャンセル
inoremap <expr><C-e> neocomplcache#cancel_popup()

" clang_complete neocomplcache 併用する設定
"let g:neocomplcache_force_overwrite_completefunc=1
"
"if !exists("g:neocomplcache_force_omni_patterns")
"  let g:neocomplcache_force_omni_patterns = {}
"endif
"
"" omnifunc が呼び出される場合の正規表現パターンを設定しておく
"let g:neocomplcache_force_omni_patterns.cpp = '[^.[:digit:] *\t]\%(\.\|->\)\|::'

" clang_complete 側の設定
" clang_complete の自動設定を切っておく
" let g:clang_complete_auto=0
""""""ここまで""""

" スニペットの展開(neosnippet)
imap <C-k> <Plug>(neosnippet_expand_or_jump)
smap <C-k> <Plug>(neosnippet_expand_or_jump)

" SuperTab like snippets behavior.
"imap <expr><TAB> neosnippet#expandable() ? "\<Plug>(neosnippet_expand_or_jump)" : pumvisible() ? "\<C-n>" : "\<TAB>"
"smap <expr><TAB> neosnippet#expandable() ? "\<Plug>(neosnippet_expand_or_jump)" : "\<TAB>"

" For snippet_comlete marker.
if has('conceal')
  set conceallevel=2 concealcursor=i
endif

" スニペットの展開(neocomplcache_snippets_expand)
"imap <C-k> <Plug>(neocomplcache_snippets_expand)
"smap <C-k> <Plug>(neocomplcache_snippets_expand)

"-----------------------------------------------------------------------------
" マップ定義
"
"バッファ移動用キーマップ
" F2: 前のバッファ
" F3: 次のバッファ
" F4: バッファ削除
map <F2> <ESC>:bp<CR>
map <F3> <ESC>:bn<CR>
map <F4> <ESC>:bw<CR>

""screenをC-tに設定している時用のタグ戻りキー
nmap <C-\> :pop<CR>

"表示行単位で行移動する
nnoremap j gj
nnoremap k gk

"フレームサイズを怠惰に変更する
map <kPlus> <C-W>+
map <kMinus> <C-W>-

" 挿入モード終了時に IME 状態を保存しない
inoremap <silent> <Esc> <Esc>
inoremap <silent> <C-[> <Esc>

" vimrcの編集と反映
nnoremap <silent> <Space>ev :<C-u>edit $MYVIMRC<CR>
nnoremap <silent> <Space>eg :<C-u>edit $MYGVIMRC<CR>
nnoremap <silent> <Space>rv :<C-u>source $MYVIMRC \| if has('gui_running') \| source $MYGVIMRC \| endif <CR>
nnoremap <silent> <Space>rg :<C-u>source $MYGVIMRC<CR>

" 検索結果ハイライトを消す
" nnoremap <ESC><ESC> :nohlsearch<CR>


" IMPORTANT: win32 users will need to have 'shellslash' set so that latex 
" can be called correctly. 
set shellslash 

"-----------------------------------------------------------------------------
" プラグインの設定

" ref.vim
nmap .ra :<C-u>Ref alc<Space>
let g:ref_alc_start_linenumber = 39 " 表示する行数

" yanktmp.vim
map <silent> sy :call YanktmpYank()<CR>
map <silent> sp :call YanktmpPaste_p()<CR>
map <silent> sP :call YanktmpPaste_P()<CR>


" unite.vim
" 入力モードで開始する
let g:unite_enable_start_insert=1
"let g:unite_enable_split_vertically=1 "縦分割で開く
let g:unite_winheight=20

" バッファ一覧
nnoremap <silent> ,ub :<C-u>Unite buffer<CR>
" ファイル一覧
nnoremap <silent> ,uf :<C-u>UniteWithBufferDir -buffer-name=files file<CR>
" レジスタ一覧
nnoremap <silent> ,ur :<C-u>Unite -buffer-name=register register<CR>
" 最近使用したファイル一覧
nnoremap <silent> ,um :<C-u>Unite file_mru<CR>
" C-gで終了する
au FileType unite nnoremap <silent> <buffer> <C-g> :q<CR>
au FileType unite inoremap <silent> <buffer> <C-g> <ESC>:q<CR>

"" smartchr
"inoremap <buffer> <expr> = smartchr#loop(' = ', ' == ', '=')
"inoremap <buffer> <expr> <S-=> smartchr#loop(' + ', '+')
"inoremap <buffer> <expr> - smartchr#loop(' - ', '-')
"inoremap <buffer> <expr> , smartchr#loop(', ', ',')


"" powerline
" フォント設定が必要
"let g:Powerline_symbols='fancy'

"" quickrun
" 非同期実行の設定
if !has("g:quickrun_config")
  let g:quickrun_config = {}
endif
"let g:quickrun_config._ = {'runner' : 'vimproc'}
let g:quickrun_config = {
\  "_" : {
\      "runner" : "vimproc",
\      "runner/vimproc/updatetime" : 10,
\  },
\}

"-----------------------------------------------------------------------------
" その他

" Vim戦闘力
function! Scouter(file, ...)
  let pat = '^\s*$\|^\s*"'
  let lines = readfile(a:file)
  if !a:0 || !a:1
    let lines = split(substitute(join(lines, "\n"), '\n\s*\\', '', 'g'), "\n")
  endif
  return len(filter(lines,'v:val !~ pat'))
endfunction
command! -bar -bang -nargs=? -complete=file Scouter
\        echo Scouter(empty(<q-args>) ? $MYVIMRC : expand(<q-args>), <bang>0)
command! -bar -bang -nargs=? -complete=file GScouter
\        echo Scouter(empty(<q-args>) ? $MYGVIMRC : expand(<q-args>), <bang>0)


" grepの設定
set grepformat=%f:%l:%m,%f:%l%m,%f\ \ %l%m,%f
set grepprg=grep\ -nh
