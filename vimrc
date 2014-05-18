" Plugins
set nocompatible
filetype off
set rtp+=~/.vim/bundle/vundle/
call vundle#rc()

" Bundles
Bundle 'gmarik/vundle'
Bundle 'tpope/vim-endwise'
Bundle 'tpope/vim-git'
Bundle 'tpope/vim-surround'
Bundle 'Blackrush/vim-gocode'
" Bundle 'chriskempson/base16-vim'
Bundle 'altercation/vim-colors-solarized'


filetype plugin indent on    " To ignore plugin indent changes, instead use:
                             " filetype plugin on

" Only do this part when compiled with support for autocommands.
if has("autocmd")
    " Use filetype detection and file-based automatic indenting.
    filetype plugin indent on

    " Use actual tab chars in Makefiles.
    autocmd FileType make set tabstop=8 shiftwidth=8 softtabstop=0 noexpandtab
endif

" For everything else, use a tab width of 4 space chars.
set tabstop=4                 " The width of a TAB is set to 4.
                              " Still it is a \t. It is just that
                              " Vim will interpret it to be having
                              " a width of 4.
set shiftwidth=4              " Indents will have a width of 4.
set softtabstop=4             " Sets the number of columns for a TAB.
set expandtab                 " Expand TABs to spaces.
syntax on

" Theme
syntax enable
set background=dark
colorscheme solarized
set ruler                     " show the line number on the bar
set more                      " use more prompt
set autoread                  " watch for file changes
"set number                    " line numbers

set hidden
set noautowrite               " don't automagically write on :next
set lazyredraw                " don't redraw when don't have to
set showmode
set showcmd
set nocompatible              " vim, not vi
set scrolloff=5               " keep at least 5 lines above/below
set sidescrolloff=5           " keep at least 5 lines left/right
set history=200
set backspace=indent,eol,start
set linebreak
set cmdheight=2               " command line two lines high
set undolevels=1000           " 1000 undos
set updatecount=100           " switch every 100 chars
set complete=.,w,b,u,U,t,i,d  " do lots of scanning on tab completion
set ttyfast                   " we have a fast terminal
set noerrorbells              " No error bells please
set shell=zsh
set fileformats=unix
set ff=unix
set wildmode=longest:full
set wildmenu                  " menu has tab completion
let maplocalleader=','        " all my macros start with ,
set laststatus=2


" searching
set incsearch                 " incremental search
set ignorecase                " search ignoring case
set hlsearch                  " highlight the search
set showmatch                 " show matching bracket
set diffopt=filler,iwhite     " ignore all whitespace and sync
  
" backup
set backup
set backupdir=~/.vim/backup

let &viminfo='%,h,"4,''4,f0,/99,:' . &history 
"           | |  |   |  |  |       +command-line history saved 
"           | |  |   |  |  +search history saved 
"           | |  |   |  +marks 0-9,A-Z 0=NOT saved 
"           | |  |   +files saved for marks 
"           | |  +lines saved each register (old name for <, vi6.2) 
"           | +disable 'hlsearch' loading viminfo 
"           +save/restore buffer list 

" spelling
if v:version >= 700
  " Enable spell check for text files
  autocmd BufNewFile,BufRead *.txt setlocal spell spelllang=en
endif

" mappings
" toggle list mode
nmap <LocalLeader>tl :set list!<cr>
" toggle paste mode
nmap <LocalLeader>pp :set paste!<cr>