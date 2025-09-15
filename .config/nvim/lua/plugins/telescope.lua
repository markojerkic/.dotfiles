return {
    {
        'nvim-telescope/telescope.nvim',
        dependencies = {
            'nvim-lua/plenary.nvim'
        },
        config = function()
            require('marko.config.telescope')
            require("marko.config.background-image").setup()
            require("marko.config.sessionizer").setup()
        end,
    },
    {
        'nvim-telescope/telescope-ui-select.nvim',
        dependencies = {
            'nvim-telescope/telescope.nvim',
        },
        config = function()
            -- This is your opts table
            require("telescope").setup {
                extensions = {
                    ["ui-select"] = {
                        require("telescope.themes").get_dropdown()
                    }
                }
            }
            -- To get ui-select loaded and working with telescope, you need to call
            -- load_extension, somewhere after setup function:
            require("telescope").load_extension("ui-select")
        end
    },
    {

        'nvim-telescope/telescope-dap.nvim',
        dependencies = {
            'nvim-telescope/telescope.nvim',
        }
    }
}
