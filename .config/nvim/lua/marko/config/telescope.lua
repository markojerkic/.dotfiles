local builtin = require("telescope.builtin")
local drop_down_theme = require("marko.util.telescope").dropdown

vim.keymap.set("n", "<C-p>", function()
    builtin.find_files(drop_down_theme)
end, {})

vim.keymap.set("n", "<leader>pg", function()
    builtin.live_grep(drop_down_theme)
end, {})

vim.keymap.set("n", "<leader>pf", function()
    builtin.git_files(drop_down_theme)
end, {})

-- Helper function for colorscheme selection with callback
local function colorscheme_picker_with_callback(callback)
    builtin.colorscheme(vim.tbl_extend("force", drop_down_theme, {
        enable_preview = true,
        attach_mappings = function(prompt_bufnr, map)
            local actions = require("telescope.actions")
            local action_state = require("telescope.actions.state")

            local function select_colorscheme()
                local selection = action_state.get_selected_entry()
                actions.close(prompt_bufnr)
                vim.cmd("colorscheme " .. selection.value)
                if callback then
                    callback(selection.value)
                end
            end

            map("i", "<CR>", select_colorscheme)
            map("n", "<CR>", select_colorscheme)

            return true
        end,
    }))
end
vim.keymap.set("n", "<leader>pc", function()
    colorscheme_picker_with_callback(function(colorscheme)
        vim.notify("Colorscheme: " .. colorscheme)
        vim.cmd("ColorMyPencils")
    end)
end, {})

vim.keymap.set("n", "<leader>tr", function()
    builtin.resume(drop_down_theme)
end, {})

vim.keymap.set("n", "<leader>t", function()
    vim.cmd("Telescope")
end, {})

vim.keymap.set("n", "<leader>pp", builtin.help_tags, {})

-- Ignore certain files and directories, like .cert and .png, .ico
require("telescope").setup({
    defaults = {
        file_ignore_patterns = {
            "%.crt$",
            "%.csr$",
            "%.key$",
            "%.lockb$",
            "%.lock$",
            -- .min files
            "%.min%.css$",
            "%.min%.js$",
            "%.cert$",
            "%.ico$",
            "%.png$",
            "%.jpg$",
            "api/v1",
        },
    },
})
