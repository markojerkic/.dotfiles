local M = {}
local Snacks = require("snacks")

local function check_requirements()
    local stribog = vim.fn.executable('stribog-options')
    local tmux = vim.fn.executable('tmux-sessionizer')

    if stribog == 0 then
        print("stribog-options is not installed")
        return false
    end
    if tmux == 0 then
        print("tmux-sessionizer is not installed")
        return false
    end
    return true
end

function M.setup()
    local has_requirements = check_requirements()
    if not has_requirements then
        return
    end

    local dir_preview = function(opts)
        opts = opts or {}

        -- Get directories from stribog-options
        local results = vim.fn.systemlist({ "stribog-options" })
        local dirs = {}
        
        for _, dir in ipairs(results) do
            if dir and dir ~= "" then
                table.insert(dirs, {
                    text = dir,
                    file = dir,
                    path = dir,
                })
            end
        end

        print("Found " .. #dirs .. " directories")
        
        if #dirs == 0 then
            vim.notify("No directories found from stribog-options", vim.log.levels.WARN)
            return
        end

        Snacks.picker.pick({
            items = dirs,
            prompt = "Directories",
            format = "text",
            preview = "directory",
            confirm = function(picker, item)
                picker:close()
                if item and item.path then
                    -- Run tmux-sessionizer with the selected path
                    vim.fn.jobstart(string.format('tmux-sessionizer %s', item.path))
                end
            end
        })
    end

    -- Global keymapping
    vim.keymap.set({ "n", "t" }, '<C-f>', dir_preview, { noremap = true, silent = false })
end

return M
