" basic settings
set tabstop=4
set shiftwidth=4
set autoindent
set expandtab
set noswapfile
inoremap <C-c> <Esc>
nnoremap <Space>. :<C-u>tabedit $MYVIMRC<CR>
set list
set listchars=tab:>-,trail:$
set hlsearch

" plugin settings
" neoBundle plugin
set nocompatible               " be iMproved
filetype off

if has('vim_starting')
  set runtimepath+=~/.vim/bundle/neobundle.vim
    call neobundle#rc(expand('~/.vim/bundle/'))
endif
" ここにNeoBundleで使うプラグインを記述
" 記述が終わったら:NeoBundleInstallでインストール
"NeoBundle 'w0ng/vim-hybrid' " 


filetype plugin indent on     " required!
filetype indent on
syntax on

" my plugin settings
"set nu ff=unix ft=perl
"colorschem hybrid
