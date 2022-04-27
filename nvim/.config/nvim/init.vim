call plug#begin(expand('~/.vim/plugged'))

" Git
Plug 'f-person/git-blame.nvim'
Plug 'tpope/vim-fugitive' 
Plug 'airblade/vim-gitgutter'
Plug 'kdheepak/lazygit.nvim'

" Tmux
Plug 'christoomey/vim-tmux-navigator'

" Cmp
Plug 'neoclide/coc.nvim', {'branch': 'release'}

" Lsp
Plug 'neovim/nvim-lspconfig'
Plug 'hrsh7th/cmp-nvim-lsp'
Plug 'hrsh7th/cmp-buffer'
Plug 'hrsh7th/nvim-cmp'

" Nerdtree
Plug 'preservim/nerdtree'
Plug 'Xuyuanp/nerdtree-git-plugin'

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
Plug 'fatih/vim-go'

" Debbuger
Plug 'mfussenegger/nvim-dap'

call plug#end()

" Plugin config
lua require("configs")

