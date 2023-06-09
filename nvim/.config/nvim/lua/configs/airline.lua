require("lualine").setup {
    options = {
        component_separators = '',
        section_separators = { left = '', right = '' },
        globalstatus = true,
    },
    sections = {
        lualine_b = {
            'branch',
            {
                'diff',
                colored = true,
                diff_color = {
                    added    = 'DiffAdd',
                    modified = 'DiffChange',
                    removed  = 'DiffDelete',
                },
            },
            {
                'diagnostics',
                sources = { 'nvim_diagnostic', 'nvim_lsp' },
                sections = { 'error', 'warn', 'info', 'hint' },
                colored = true,
                diagnostics_color = {
                    error = 'DiagnosticError',
                    warn  = 'DiagnosticWarn',
                    info  = 'DiagnosticInfo',
                    hint  = 'DiagnosticHint',
                },
                symbols = { error = 'E', warn = 'W', info = 'I', hint = 'H' },
                update_in_insert = false,
                always_visible = false,
            }
        },
        lualine_c = {
            {
                'filename',
                file_status = true,
                path = 1,
                shorting_target = 40,
                symbols = {
                    modified = '[+]',
                    readonly = '[-]',
                    unnamed = '[No Name]',
                }
            }
        },
        lualine_x = { 'encoding' },
    },
}
