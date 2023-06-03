call plug#begin(expand('~/.vim/plugged'))

" Git
Plug 'f-person/git-blame.nvim'
Plug 'airblade/vim-gitgutter'
Plug 'kdheepak/lazygit.nvim'

" Tmux
Plug 'christoomey/vim-tmux-navigator'

" Lsp
Plug 'neovim/nvim-lspconfig'

Plug 'williamboman/mason.nvim', {'do': ':MasonUpdate'}
Plug 'williamboman/mason-lspconfig.nvim'

Plug 'hrsh7th/cmp-nvim-lsp'
Plug 'hrsh7th/cmp-buffer'
Plug 'hrsh7th/nvim-cmp'
Plug 'L3MON4D3/LuaSnip'
Plug 'onsails/lspkind-nvim'

Plug 'VonHeikemen/lsp-zero.nvim', {'branch': 'v2.x'}

" Languages stuff
Plug 'fatih/vim-go'
Plug 'rust-lang/rust.vim'

" Treesitter
Plug 'nvim-treesitter/nvim-treesitter', {'do': ':TSUpdate'}

" Telescope
Plug 'nvim-lua/popup.nvim'
Plug 'nvim-lua/plenary.nvim'
Plug 'nvim-telescope/telescope.nvim'
Plug 'nvim-telescope/telescope-fzy-native.nvim'
" File browser
Plug 'nvim-telescope/telescope-file-browser.nvim'

" Snippets
Plug 'L3MON4D3/LuaSnip'
Plug 'Raimondi/delimitMate' " Automatically closes quotes, parenthesis, etc.

" Theme
Plug 'Yggdroot/indentLine' " Add's a line in every indentation
Plug 'gruvbox-community/gruvbox'
Plug 'nvim-lualine/lualine.nvim'
Plug 'kyazdani42/nvim-web-devicons'

call plug#end()

" Plugin config
lua require("configs")

