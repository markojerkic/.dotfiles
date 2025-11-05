-- Command to make the current file executable
vim.api.nvim_create_user_command('ChmodX', function()
    local file = vim.fn.expand('%:p')
    if file ~= '' then
        vim.fn.system({'chmod', '+x', file})
        print('Made ' .. vim.fn.expand('%:t') .. ' executable')
    else
        print('No file to make executable')
    end
end, {})
