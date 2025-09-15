local M = {}
local drop_down_theme = require("marko.util.telescope").dropdown

M.lsp_keymap = function(opts)
    local telescope = require('telescope.builtin')
    vim.keymap.set("n", "gd", function() vim.lsp.buf.definition() end, opts)
    vim.keymap.set("n", "<leader>gd", function() telescope.lsp_definitions(drop_down_theme) end, opts)
    vim.keymap.set("n", "gr", function() telescope.lsp_references(drop_down_theme) end, opts)
    vim.keymap.set("n", "<leader>gr", function() vim.lsp.buf.references() end, opts)
    vim.keymap.set("n", "<leader>gtr", function() telescope.lsp_references(drop_down_theme) end, opts)
    vim.keymap.set("n", "gi", function() vim.lsp.buf.implementation() end, opts)
    vim.keymap.set("n", "<leader>gi", function() telescope.lsp_implementations(drop_down_theme) end, opts)

    vim.keymap.set("n", "K", function() vim.lsp.buf.hover() end, opts)
    vim.keymap.set("n", "<A-l>", function()
        require("conform").format({ bufnr = vim.api.nvim_get_current_buf() })
    end, opts)
    vim.keymap.set("n", "<leader>vws", function() vim.lsp.buf.workspace_symbol() end, opts)
    vim.keymap.set("n", "<leader>vd", function() vim.diagnostic.open_float() end, opts)
    vim.keymap.set("n", "[d", function() vim.diagnostic.goto_next() end, opts)
    vim.keymap.set("n", "]d", function() vim.diagnostic.goto_prev() end, opts)
    vim.keymap.set("n", "<leader>ca", function() vim.lsp.buf.code_action() end, opts)
    vim.keymap.set("n", "<leader>rn", function() vim.lsp.buf.rename() end, opts)
    vim.keymap.set("i", "<C-h>", function() vim.lsp.buf.signature_help() end, opts)


    vim.keymap.set('n', '<leader>db', ':lua require"dap".toggle_breakpoint()<CR>')
    vim.keymap.set('n', '<leader>B', ':lua require"dap".set_breakpoint(vim.fn.input("Condition: "))<CR>')
    vim.keymap.set('n', '<leader>bl', ':lua require"dap".set_breakpoint(nil, nil, vim.fn.input("Log: "))<CR>')
    vim.keymap.set('n', '<leader>dr', ':lua require"dap".repl.toggle()<CR>')

    vim.keymap.set('n', 'L', function() require("dapui").eval() end, opts)

    vim.keymap.set('n', '<leader>dc', ':lua require"dap".continue()<CR>')
    vim.keymap.set('n', '<leader>dso', ':lua require"dap".step_over()<CR>')
    vim.keymap.set('n', '<leader>dsi', ':lua require"dap".step_into()<CR>')
    vim.keymap.set('n', '<leader>dsso', ':lua require"dap".step_out()<CR>')
end

return M;
