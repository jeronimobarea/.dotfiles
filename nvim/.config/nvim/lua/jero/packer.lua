-- This file can be loaded by calling `lua require('plugins')` from your init.vim
local ensure_packer = function()
    local fn = vim.fn
    local install_path = fn.stdpath("data") .. "/site/pack/packer/start/packer.nvim"
    if fn.empty(fn.glob(install_path)) > 0 then
        fn.system({ "git", "clone", "--depth", "1", "https://github.com/wbthomason/packer.nvim", install_path })
        vim.cmd [[packadd packer.nvim]]
        print("Installing packer close and reopen Neovim...")
        return true
    end
    return false
end

local packer_bootstrap = ensure_packer()

vim.cmd([[
  augroup packer_user_config
    autocmd!
    autocmd BufWritePost plugins.lua source <afile> | PackerCompile
  augroup end
]])

-- Use a protected call so we don't error out on first use
local status_ok, packer = pcall(require, "packer")
if not status_ok then
    return
end

-- Have packer use a popup window
packer.init({
    display = {
        open_fn = function()
            return require("packer.util").float({ border = "single" })
        end
    }
})

return packer.startup(function(use)
    -- Packer can manage itself
    use("wbthomason/packer.nvim")

    -- THEME
    use("ellisonleao/gruvbox.nvim")

    use({
        "nvim-lualine/lualine.nvim",
        requires = {
            "nvim-tree/nvim-web-devicons",
        }
    })

    -- TELESCOPE
    use({
        "nvim-telescope/telescope.nvim",
        requires = {
            "nvim-lua/plenary.nvim",
        },
    })

    use({
        "nvim-telescope/telescope-file-browser.nvim",
        requires = {
            "nvim-lua/plenary.nvim",
            "nvim-telescope/telescope.nvim",
        },
    })

    -- GIT
    -- nvim v0.7.2
    use({ "lewis6991/gitsigns.nvim" })
    use({
        "kdheepak/lazygit.nvim",
        requires = {
            "nvim-lua/plenary.nvim",
            "nvim-telescope/telescope.nvim",
        },
    })

    -- TREESITTER
    use({
        "nvim-treesitter/nvim-treesitter",
        run = function()
            local ts_update = require("nvim-treesitter.install").update({ with_sync = true })
            ts_update()
        end
    })
    use("nvim-treesitter/nvim-treesitter-context")

    use("ray-x/guihua.lua") -- recommended if need floating window support

    use({
        "aserowy/tmux.nvim",
        config = function()
            return require("tmux").setup()
        end
    })

    -- LSP
    use({
        "VonHeikemen/lsp-zero.nvim",
        branch = "v2.x",
        requires = {
            -- LSP Support
            { "neovim/nvim-lspconfig" }, -- Required
            {
                -- Optional
                "williamboman/mason.nvim",
                run = ":MasonUpdate"                 -- :MasonUpdate updates registry contents
            },
            { "williamboman/mason-lspconfig.nvim" }, -- Optional

            -- Autocompletion
            { "hrsh7th/nvim-cmp" },
            { "hrsh7th/cmp-buffer" },
            { "hrsh7th/cmp-path" },
            { "saadparwaiz1/cmp_luasnip" },
            { "hrsh7th/cmp-nvim-lsp" },
            { "hrsh7th/cmp-nvim-lua" },
            { "rafamadriz/friendly-snippets" },

            -- Snippets
            { "L3MON4D3/LuaSnip" },
        }
    })

    -- LANGUAGE SPECIFIC
    use({
        "ray-x/go.nvim",
        run = ":lua require('go.install').update_all_sync()"
    })

    use({
        "windwp/nvim-autopairs",
        config = function()
            require("nvim-autopairs").setup()
        end
    })

    -- DEBUGGER
    use({
        "rcarriga/nvim-dap-ui",
        requires = {
            "mfussenegger/nvim-dap",
        },
    })
    use({
        "nvim-telescope/telescope-dap.nvim",
        requires = {
            "nvim-telescope/telescope.nvim",
        },
    })

    -- Automatically set up your configuration after cloning packer.nvim
    -- Put this at the end after all plugins
    if packer_bootstrap then
        require("packer").sync()
    end
end)
