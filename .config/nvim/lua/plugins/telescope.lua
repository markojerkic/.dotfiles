local config = {
    dashboard = {
        enabled = true,

        sections = {
            { section = "header" },
            { icon = " ", title = "Keymaps", section = "keys", indent = 2, padding = 1 },
            { icon = " ", title = "Recent Files", cwd = true, section = "recent_files", indent = 2, padding = 1 },
            {
                icon = " ",
                title = "Git Status",
                section = "terminal",
                enabled = function()
                    return Snacks.git.get_root() ~= nil
                end,
                cmd = "git status --short --branch --renames",
                height = 5,
                padding = 1,
                ttl = 5 * 60,
                indent = 3,
            },

            { section = "startup" },
        },
    },
    notifier = { enabled = true },
    quickfile = { enabled = false },
    statuscolumn = { enabled = false },
    words = { enabled = false },
    picker = {
        -- Custom layout with preview on top
        layout = {
            layout = {
                backdrop = false,
                width = 0.5,
                min_width = 80,
                height = 0.8,
                min_height = 30,
                box = "vertical",
                border = "rounded",
                title = "{title} {live} {flags}",
                title_pos = "center",
                { win = "preview", title = "{preview}", height = 0.4, border = "bottom" },
                { win = "input", height = 1, border = "bottom" },
                { win = "list", border = "none" },
            }
        },
        sources = {
            files = {
                hidden = true,
                ignored = true,
                exclude = {
                    "%.crt$",
                    "%.csr$",
                    "%.key$",
                    "%.lockb$",
                    "%.lock$",
                    "%.min%.css$",
                    "%.min%.js$",
                    "%.cert$",
                    "%.ico$",
                    "%.png$",
                    "%.jpg$",
                    "api/v1",
                }
            }
        }
    }
}

return {
    "folke/snacks.nvim",
    priority = 1000,
    lazy = false,
    opts = config,
    keys = {
        { "<C-p>", function() require("snacks").picker.files() end, desc = "Find Files" },
        { "<leader>pg", function() require("snacks").picker.grep() end, desc = "Grep" },
        { "<leader>pf", function() require("snacks").picker.git_files() end, desc = "Git Files" },
        { "<leader>pc", function()
            require("snacks").picker.colorschemes({
                confirm = function(picker, item)
                    picker:close()
                    if item then
                        picker.preview.state.colorscheme = nil
                        vim.schedule(function()
                            vim.cmd("colorscheme " .. item.text)
                            vim.notify("Colorscheme: " .. item.text)
                            vim.cmd("ColorMyPencils")
                        end)
                    end
                end
            })
        end, desc = "Colorscheme" },
        { "<leader>tr", function() require("snacks").picker.resume() end, desc = "Resume Picker" },
        { "<leader>t", function() require("snacks").picker() end, desc = "Pickers" },
        { "<leader>pp", function() require("snacks").picker.help() end, desc = "Help" },
    },
    config = function(_, opts)
        require("snacks").setup(opts)
        require("marko.config.background-image").setup()
        require("marko.config.sessionizer").setup()
    end,
}
