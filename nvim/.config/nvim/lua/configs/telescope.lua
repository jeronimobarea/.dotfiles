local telescope = require('telescope')

telescope.setup {
    pickers = {
        find_files = {
            hidden = true
        }
    },
    defaults = {
        file_ignore_patterns = {
            ".git"
        }
    }
}

