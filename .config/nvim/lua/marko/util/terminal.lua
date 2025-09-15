vim.keymap.set({ 'n', 't' }, '<C-t>', function()
    local current_open_tab = vim.api.nvim_get_current_tabpage()
    local current_tabs = vim.api.nvim_list_tabpages()
    if current_open_tab == 1 then
        if current_tabs[2] == nil then
            vim.cmd([[tabnew]])
            vim.cmd([[terminal]])
        else
            vim.api.nvim_set_current_tabpage(2)
        end
    else
        vim.api.nvim_set_current_tabpage(1)
    end
end)
