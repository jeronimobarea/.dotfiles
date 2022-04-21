" Visual
syntax on
set number
set relativenumber
set guicursor=i:block
set cc=80
set showmatch

" Text search
set ignorecase
set smartcase
set hlsearch
set incsearch
set ruler

" Common
set encoding=utf-8
set ttyfast

" Tabs
set tabstop=4
set softtabstop=4
set shiftwidth=4
set expandtab

call plug#begin(expand('~/.vim/plugged'))

" Git
Plug 'f-person/git-blame.nvim'
Plug 'tpope/vim-fugitive'
Plug 'airblade/vim-gitgutter'

" Cmp
" Use release branch (recommend)
Plug 'neoclide/coc.nvim', {'branch': 'release'}

" Lsp
Plug 'neovim/nvim-lspconfig'
Plug 'hrsh7th/cmp-nvim-lsp'
Plug 'hrsh7th/cmp-buffer'
Plug 'hrsh7th/nvim-cmp'

" Treesitter
Plug 'nvim-treesitter/nvim-treesitter', {'do': ':TSUpdate'}

" Telescope
Plug 'nvim-lua/popup.nvim'
Plug 'nvim-lua/plenary.nvim'
Plug 'nvim-telescope/telescope.nvim'
Plug 'nvim-telescope/telescope-fzy-native.nvim'

" Snippets
Plug 'Raimondi/delimitMate' " Automatically closes quotes, parenthesis, etc.
Plug 'sbdchd/neoformat'

" Theme
Plug 'Yggdroot/indentLine' " Add's a line in every indentation
Plug 'gruvbox-community/gruvbox'
Plug 'nvim-lualine/lualine.nvim'
" If you want to have icons in your statusline choose one of these
Plug 'kyazdani42/nvim-web-devicons'

" Languages stuff
Plug 'darrikonn/vim-gofmt'

call plug#end()

" Plugin config
lua require("configs")

" Coc
" GoTo code navigation.
nmap <silent> gd <Plug>(coc-definition)
nmap <silent> gy <Plug>(coc-type-definition)
nmap <silent> gi <Plug>(coc-implementation)
nmap <silent> gr <Plug>(coc-references)

" Themes
" Gruvbox
colorscheme gruvbox

" Treesitter
lua require'nvim-treesitter.configs'.setup { highlight = { enable = true }, incremental_selection = { enable = true }, textobjects = { enable = true }}

" Telescope
" Find files using Telescope command-line sugar.
nnoremap <leader>ff <cmd>Telescope find_files<cr>
nnoremap <leader>fg <cmd>Telescope live_grep<cr>
nnoremap <leader>fb <cmd>Telescope buffers<cr>
nnoremap <leader>fh <cmd>Telescope help_tags<cr>

