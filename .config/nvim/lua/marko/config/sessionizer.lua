local M = {}

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

    local builtin = require('telescope.builtin')
    local actions = require('telescope.actions')
    local previewers = require('telescope.previewers')

    local dir_preview = function(opts)
        opts = opts or {}

        -- Create a custom finder that uses stribog-select
        builtin.find_files({
            prompt_title = "Directories",
            find_command = { "stribog-options" },
            previewer = previewers.new_termopen_previewer({
                get_command = function(entry)
                    -- You can customize the preview command here
                    -- This example uses 'ls' to show directory contents
                    return {
                        'ls',
                        '-la',
                        entry.path
                    }
                end
            }),
            attach_mappings = function(prompt_bufnr)
                actions.select_default:replace(function()
                    local selection = require('telescope.actions.state').get_selected_entry()
                    actions.close(prompt_bufnr)
                    if selection and selection.path then
                        -- Run tmux-sessionizer with the selected path
                        vim.fn.jobstart(string.format('tmux-sessionizer %s', selection.path))
                    end
                end)
                return true
            end
        })
    end

    -- Global keymapping
    vim.keymap.set({ "n", "t" }, '<C-f>', dir_preview, { noremap = true, silent = false })
end

return M
