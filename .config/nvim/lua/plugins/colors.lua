return {
    {
        "catppuccin/nvim",
        lazy = false,
        name = "catppuccin",
        -- optionally set the colorscheme within lazy config
        -- init = function()
        --     vim.cmd([[colorscheme catppuccin-mocha]])
        --     local util = require("marko.util.colors")
        --     util.colourMyPencils()
        -- end
    },
    {
        "rose-pine/neovim",
        name = "rose-pine",
    },
    {
        "vague2k/vague.nvim",
        lazy = false,
        priority = 1000,
        config = function()
            vim.cmd([[colorscheme vague]])
            require("marko.util.colors").colourMyPencils()
        end
    },
    { "rebelot/kanagawa.nvim" }
}
