" Visual
syntax on
set number
set relativenumber
set guicursor=i:block
set cc=80
set showmatch
set equalalways " Always set split tabs with equal
autocmd VimResized * wincmd =

" Text search
set ignorecase
set smartcase
set hlsearch
set incsearch
set ruler

" Common
filetype plugin indent on
set encoding=utf-8
set ttyfast
set autochdir

" Ignore files
set wildignore+=**/.git/*

" Tabs
set tabstop=4
set softtabstop=4
set shiftwidth=4
set expandtab
set autoindent

" Themes
" Gruvbox
colorscheme gruvbox
hi Normal guibg=none

noremap <leader>t <cmd>belowright 20split term://zsh<cr>
noremap <leader>q <cmd>:q<cr>
tnoremap <Esc> <C-\><C-n>

