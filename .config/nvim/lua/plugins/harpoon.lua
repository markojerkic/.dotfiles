return {
    "ThePrimeagen/harpoon",
    branch = "harpoon2",
    config = function()
        local harpoon = require "harpoon"
        harpoon:setup()


        local settings = {
            -- saves the harpoon file upon every change. disabling is unrecommended.
            save_on_change = true,

            -- sets harpoon to run the command immediately as it's passed to the terminal when calling `sendCommand`.
            enter_on_sendcmd = false,

            -- closes any tmux windows harpoon that harpoon creates when you close Neovim.
            tmux_autoclose_windows = false,

            -- filetypes that you want to prevent from adding to the harpoon list menu.
            excluded_filetypes = { "harpoon" },

            -- set marks specific to each git branch inside git repository
            mark_branch = false,
        };

        harpoon:extend({
            UI_CREATE = function(cx)
                vim.keymap.set("n", "<C-v>", function()
                    harpoon.ui:select_menu_item({ vsplit = true })
                end, { buffer = cx.bufnr })

                vim.keymap.set("n", "<C-x>", function()
                    harpoon.ui:select_menu_item({ split = true })
                end, { buffer = cx.bufnr })

                vim.keymap.set("n", "<C-t>", function()
                    harpoon.ui:select_menu_item({ tabedit = true })
                end, { buffer = cx.bufnr })
            end,
        })

        -- REQUIRED
        harpoon:setup({
            settings = {
                save_on_toggle = true,
            },
            global_settings = settings,
        })
        -- REQUIRED

        vim.keymap.set("n", "<leader>a", function() harpoon:list():add() end)
        vim.keymap.set("n", "<leader>h", function()
            harpoon.ui:toggle_quick_menu(harpoon:list(),
                {
                    border = "rounded",
                    title_pos = "center",
                    ui_width_ratio = 0.90,
                }
            )
        end)

        -- Set <space>1..<space>5 be my shortcuts to moving to the files
        for _, idx in ipairs { 1, 2, 3, 4, 5, 6, 7, 8 } do
            vim.keymap.set("n", string.format("<leader>%d", idx), function()
                harpoon:list():select(idx)
            end)
        end

        local conf = require("telescope.config").values
        local function toggle_telescope(harpoon_files)
            local file_paths = {}
            for _, item in ipairs(harpoon_files.items) do
                table.insert(file_paths, item.value)
            end

            require("telescope.pickers").new({}, {
                prompt_title = "Harpoon",
                finder = require("telescope.finders").new_table({
                    results = file_paths,
                }),
                previewer = conf.file_previewer({}),
                sorter = conf.generic_sorter({}),
            }):find()
        end

        vim.keymap.set("n", "<leader>ph", function() toggle_telescope(harpoon:list()) end,
            { desc = "Open harpoon window" })
    end,
}
