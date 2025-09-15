local M = {}

local function check_requirements()
    local chafa = vim.fn.executable('chafa')
    if chafa == 0 then
        print("chafa is not installed. Running `sudo apt install chafa`")
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

    local image_preview = function(opts)
        opts = opts or {}

        -- Use Telescope's built-in file picker with a specific path
        builtin.find_files({
            prompt_title = "Images in WP",
            cwd = "~/Slike/WP",
            file_ignore_patterns = { "*" }, -- Clear any ignore patterns
            previewer = previewers.new_termopen_previewer({
                get_command = function(entry)
                    local width = math.floor(vim.o.columns / 2.2)
                    local height = math.floor(width * 0.3) -- Calculate proportional height
                    print("Image size: " .. string.format('%dx%d', width, height))

                    return {
                        'chafa',
                        entry.path,
                        '--format', 'symbols',
                        '--symbols', 'vhalf',
                        '--size', string.format('%dx%d', width, height),
                        '--stretch'
                    }
                end
            }),
            attach_mappings = function(prompt_bufnr)
                actions.select_default:replace(function()
                    local selection = require('telescope.actions.state').get_selected_entry()
                    actions.close(prompt_bufnr)

                    if selection and selection.path then
                        -- run in new process
                        vim.fn.jobstart(string.format('cb %s', selection.path))
                    end
                end)
                return true
            end
        })
    end

    -- Global keymapping
    vim.keymap.set({ "n", "t" }, '<C-b>', image_preview, { noremap = true, silent = false })
end

return M
