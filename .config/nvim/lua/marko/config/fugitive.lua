local M = {}
local Snacks = require("snacks")

M.setup = function()
	vim.keymap.set("n", "<leader>gs", vim.cmd.Git)

	local git_delete = function(opts)
		opts = opts or {}

		local results = vim.fn.systemlist({ "git", "branch" })
		local branches = {}

		for _, line in ipairs(results) do
			table.insert(branches, {
				text = line,
				value = line:gsub("%s+", ""):gsub("%*", ""),
			})
		end

		Snacks.picker.pick({
			items = branches,
			prompt = "Git Delete Branch",
			format = "text",
			preview = "git_log",
			confirm = function(picker, item)
				picker:close()
				local selected_branch = item.value
				vim.cmd("Git branch -d " .. selected_branch)
			end
		})
	end

	local git_switch = function(opts)
		opts = opts or {}

		local results = vim.fn.systemlist({ "git", "branch" })
		local branches = {}

		for _, line in ipairs(results) do
			table.insert(branches, {
				text = line,
				value = line:gsub("%s+", ""):gsub("%*", ""),
			})
		end

		Snacks.picker.pick({
			items = branches,
			prompt = "Git Switch",
			format = "text",
			preview = "git_log",
			confirm = function(picker, item)
				picker:close()
				local selected_branch = item.value
				vim.cmd("Git switch " .. selected_branch)
			end
		})
	end

	local git_switch_remote = function(opts)
		opts = opts or {}

		local results = vim.fn.systemlist({ "git", "branch", "-r" })
		local branches = {}

		for _, line in ipairs(results) do
			table.insert(branches, {
				text = line,
				value = line:gsub("%s+", ""):gsub("%*", ""),
			})
		end

		Snacks.picker.pick({
			items = branches,
			prompt = "Git Switch Remote",
			format = "text",
			preview = "git_log",
			confirm = function(picker, item)
				picker:close()
				local selected_branch = item.value
				vim.cmd("Git checkout " .. selected_branch .. " --track")
			end
		})
	end

	local git_show_origin_file = function(opts)
		opts = opts or {}

		local results = vim.fn.systemlist({ "git", "branch", "-r" })
		local branches = {}
		
		for _, line in ipairs(results) do
			local clean_line = line:gsub("%s+", "")
			if clean_line:match("^origin/") and not clean_line:match("HEAD") then
				table.insert(branches, {
					text = clean_line,
					value = clean_line,
				})
			end
		end

		Snacks.picker.pick({
			items = branches,
			prompt = "Select Origin Branch",
			format = "text",
			preview = "git_log",
			confirm = function(picker, item)
				picker:close()
				local selected_branch = item.value

				local success, file_results = pcall(vim.fn.systemlist, { "git", "ls-tree", "-r", "--name-only", selected_branch })
				
				if not success or #file_results == 0 then
					vim.notify("No files found in branch: " .. selected_branch, vim.log.levels.WARN)
					return
				end
				
				local files = {}
				for _, file in ipairs(file_results) do
					table.insert(files, {
						text = file,
						value = file,
						file = file,
					})
				end
				
				Snacks.picker.pick({
					items = files,
					prompt = "Select File from " .. selected_branch,
					format = "text",
					confirm = function(picker2, file_item)
						picker2:close()
						local selected_file = file_item.value
						
						local show_success = pcall(vim.cmd, "Git show " .. selected_branch .. ":" .. selected_file)
						if not show_success then
							vim.notify("Failed to show file: " .. selected_file .. " from " .. selected_branch, vim.log.levels.ERROR)
						end
					end
				})
			end
		})
	end

	vim.api.nvim_create_user_command("GitShowOriginFile", git_show_origin_file, {})

	local Marko_Fugitive = vim.api.nvim_create_augroup("Marko_Fugitive", {})

	local autocmd = vim.api.nvim_create_autocmd

	autocmd("BufWinEnter", {
		group = Marko_Fugitive,
		pattern = "*",
		callback = function()
			if vim.bo.ft ~= "fugitive" then
				return
			end

			local bufnr = vim.api.nvim_get_current_buf()
			local opts = { buffer = bufnr, remap = false }
			vim.keymap.set("n", "<leader>gp", function()
				vim.cmd.Git({ "push" })
			end, opts)

			-- rebase always
			vim.keymap.set("n", "<leader>gP", function()
				vim.cmd.Git({ "pull --rebase" })
			end, opts)

			vim.keymap.set("n", "<leader>fg", git_switch, opts)

			vim.keymap.set("n", "<leader>fd", git_delete, opts)

			vim.keymap.set("n", "<leader>fr", git_switch_remote, opts)

			-- commit, --no-verify
			vim.keymap.set("n", "<leader>nc", function()
				vim.cmd.Git({ "commit --no-verify" })
			end, opts)

			-- NOTE: It allows me to easily set the branch i am pushing and any tracking
			-- needed if i did not set the branch up correctly
			vim.keymap.set("n", "<leader>gt", ":Git push -u origin ", opts)

			-- keymap to create a new branch and set it up to track
			vim.keymap.set("n", "<leader>gs", ":Git switch -c ", opts)
		end,
	})
end

return M
