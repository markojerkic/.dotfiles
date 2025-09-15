local M = {}

local is_hl = true

M.colourMyPencils = function(colour)
    colour = colour or vim.g.colors_name
    vim.cmd.colorscheme(colour)

    is_hl = true

    vim.api.nvim_set_hl(0, "Normal", { bg = "none" })
    vim.api.nvim_set_hl(0, "NormalFloat", { bg = "none" })
end

M.uncolourMyPencils = function(colour)
    colour = colour or vim.g.colors_name
    vim.cmd.colorscheme(colour)

    is_hl = false

    vim.api.nvim_set_hl(100, "Normal", {})
    vim.api.nvim_set_hl(100, "NormalFloat", {})
end

M.toggleColouredPencils = function()
    if is_hl then
        M.uncolourMyPencils()
    else
        M.colourMyPencils()
    end
    vim.cmd [[ silent !op ]]
end

vim.api.nvim_create_user_command('ColorMyPencils', function()
    M.colourMyPencils()
end, {})
vim.api.nvim_create_user_command('UncolorMyPencils', function()
    M.uncolourMyPencils()
end, {})

return M
