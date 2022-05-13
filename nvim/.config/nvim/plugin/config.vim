" Visual
syntax on
set number
set relativenumber
set guicursor=i:block
set cc=80
set showmatch
set cursorline

" Always set split tabs equally even when nvim is resized
set equalalways 
autocmd VimResized * wincmd =

" Text search
set ignorecase
set smartcase
set hlsearch
set incsearch
set ruler

" Common
filetype plugin indent on
set ttyfast
" autocmd BufEnter * silent! :lcd%:p:h " Automatically change the current directory

" Ignore files
set wildignore+=**/.git/*

" Tabs
set tabstop=4
set softtabstop=4
set shiftwidth=4
set expandtab
set autoindent

" Themes
" Disable background
au ColorScheme * hi Normal ctermbg=none guibg=none
au ColorScheme myspecialcolors hi Normal ctermbg=red guibg=red

" Gruvbox
set termguicolors
colorscheme gruvbox
hi Normal guibg=none
let g:gruvbox_contrast_dark = 'hard'
set background=dark

" Remaps
noremap <space>t <cmd>belowright 20split term://zsh<cr>
noremap <space>q <cmd>:q<cr>
tnoremap <Esc> <C-\><C-n>
