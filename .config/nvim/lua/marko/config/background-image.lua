local M = {}
local Snacks = require("snacks")

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

    local image_preview = function(opts)
        opts = opts or {}

        -- Get image files from the WP directory
        local wp_dir = vim.fn.expand("~/Slike/WP")
        local cmd = string.format("find '%s' -type f \\( -name '*.jpg' -o -name '*.png' -o -name '*.jpeg' -o -name '*.gif' -o -name '*.bmp' \\)", wp_dir)
        local results = vim.fn.systemlist(cmd)
        local images = {}
        
        for _, image in ipairs(results) do
            if image and image ~= "" and not image:match("^find:") then
                table.insert(images, {
                    text = vim.fn.fnamemodify(image, ":t"),
                    file = image,
                    path = image,
                })
            end
        end

        print("Found " .. #images .. " images in " .. wp_dir)
        
        if #images == 0 then
            vim.notify("No images found in " .. wp_dir, vim.log.levels.WARN)
            return
        end

        Snacks.picker.pick({
            items = images,
            prompt = "Images in WP",
            format = "text",
            preview = "image",
            confirm = function(picker, item)
                picker:close()
                if item and item.path then
                    -- run in new process
                    local job_id = vim.fn.jobstart(string.format('cb %s', item.path), {
                        on_exit = function(_, exit_code)
                            if exit_code == 0 then
                                vim.notify("Image copied: " .. vim.fn.fnamemodify(item.path, ":t"), vim.log.levels.INFO)
                            else
                                vim.notify("Failed to copy image (exit code: " .. exit_code .. ")", vim.log.levels.ERROR)
                            end
                        end
                    })
                    if job_id == 0 then
                        vim.notify("Invalid command: cb", vim.log.levels.ERROR)
                    elseif job_id == -1 then
                        vim.notify("Command 'cb' not executable", vim.log.levels.ERROR)
                    end
                end
            end
        })
    end

    -- Global keymapping
    vim.keymap.set({ "n", "t" }, '<C-b>', image_preview, { noremap = true, silent = false })
end

return M
