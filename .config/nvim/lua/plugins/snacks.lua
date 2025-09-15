local config = {
    dashboard = {
        enabled = true,

        sections = {
            { section = "header" },
            { icon = " ", title = "Keymaps", section = "keys", indent = 2, padding = 1 },
            { icon = " ", title = "Recent Files", cwd = true, section = "recent_files", indent = 2, padding = 1 },
            {
                icon = " ",
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
}

return {
    "folke/snacks.nvim",
    priority = 1000,
    lazy = false,
    opts = config,
}
