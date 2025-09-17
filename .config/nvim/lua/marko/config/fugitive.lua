local M = {}

M.setup = function()
	vim.keymap.set("n", "<leader>gs", vim.cmd.Git)

	local actions = require("telescope.actions")
	local action_state = require("telescope.actions.state")
	local finders = require("telescope.finders")
	local pickers = require("telescope.pickers")
	local sorters = require("telescope.sorters")
	local utils = require("telescope.utils")

	local git_delete = function(opts)
		opts = opts or {}

		local results = utils.get_os_command_output({ "git", "branch" })
		local branches = results

		pickers
			.new(opts, {
				prompt_title = "Git Delete Branch",
				finder = finders.new_table({
					results = branches,
					entry_maker = function(line)
						return {
							value = line,
							ordinal = line,
							display = line,
						}
					end,
				}),
				sorter = sorters.get_generic_fuzzy_sorter(),
				attach_mappings = function(prompt_bufnr, _)
					local switch_selection = function()
						local selection = action_state.get_selected_entry()
						actions.close(prompt_bufnr)
						local selected_branch = selection.value:gsub("%s+", ""):gsub("%*", "")
						vim.cmd("Git branch -d " .. selected_branch)
					end

					-- Use telescope actions to handle key mappings
					actions.select_default:replace(switch_selection)

					return true
				end,
			})
			:find()
	end

	local git_switch = function(opts)
		opts = opts or {}

		local results = utils.get_os_command_output({ "git", "branch" })
		local branches = results

		pickers
			.new(opts, {
				prompt_title = "Git Switch",
				finder = finders.new_table({
					results = branches,
					entry_maker = function(line)
						return {
							value = line,
							ordinal = line,
							display = line,
						}
					end,
				}),
				sorter = sorters.get_generic_fuzzy_sorter(),
				attach_mappings = function(prompt_bufnr, _)
					local switch_selection = function()
						local selection = action_state.get_selected_entry()
						actions.close(prompt_bufnr)
						local selected_branch = selection.value:gsub("%s+", ""):gsub("%*", "")
						vim.cmd("Git switch " .. selected_branch)
					end

					-- Use telescope actions to handle key mappings
					actions.select_default:replace(switch_selection)

					return true
				end,
			})
			:find()
	end

	local git_switch_remote = function(opts)
		opts = opts or {}

		local results = utils.get_os_command_output({ "git", "branch", "-r" })
		local branches = results

		pickers
			.new(opts, {
				prompt_title = "Git Switch Remote",
				finder = finders.new_table({
					results = branches,
					entry_maker = function(line)
						return {
							value = line,
							ordinal = line,
							display = line,
						}
					end,
				}),
				sorter = sorters.get_generic_fuzzy_sorter(),
				attach_mappings = function(prompt_bufnr, _)
					local switch_selection = function()
						local selection = action_state.get_selected_entry()
						actions.close(prompt_bufnr)
						local selected_branch = selection.value:gsub("%s+", ""):gsub("%*", "")
						vim.cmd("Git checkout " .. selected_branch .. " --track")
					end

					-- Use telescope actions to handle key mappings
					actions.select_default:replace(switch_selection)

					return true
				end,
			})
			:find()
	end

	local git_show_origin_file = function(opts)
		opts = opts or {}

		local results = utils.get_os_command_output({ "git", "branch", "-r" })
		local branches = {}
		
		for _, line in ipairs(results) do
			local clean_line = line:gsub("%s+", "")
			if clean_line:match("^origin/") and not clean_line:match("HEAD") then
				table.insert(branches, clean_line)
			end
		end

		pickers
			.new(opts, {
				prompt_title = "Select Origin Branch",
				finder = finders.new_table({
					results = branches,
					entry_maker = function(line)
						return {
							value = line,
							ordinal = line,
							display = line,
						}
					end,
				}),
				sorter = sorters.get_generic_fuzzy_sorter(),
				attach_mappings = function(prompt_bufnr, _)
					local select_branch = function()
						local selection = action_state.get_selected_entry()
						actions.close(prompt_bufnr)
						local selected_branch = selection.value

						local success, file_results = pcall(utils.get_os_command_output, { "git", "ls-tree", "-r", "--name-only", selected_branch })
						
						if not success or #file_results == 0 then
							vim.notify("No files found in branch: " .. selected_branch, vim.log.levels.WARN)
							return
						end
						
						pickers
							.new(opts, {
								prompt_title = "Select File from " .. selected_branch,
								finder = finders.new_table({
									results = file_results,
									entry_maker = function(line)
										return {
											value = line,
											ordinal = line,
											display = line,
										}
									end,
								}),
								sorter = sorters.get_generic_fuzzy_sorter(),
								attach_mappings = function(file_prompt_bufnr, _)
									local select_file = function()
										local file_selection = action_state.get_selected_entry()
										actions.close(file_prompt_bufnr)
										local selected_file = file_selection.value
										
										local show_success = pcall(vim.cmd, "Git show " .. selected_branch .. ":" .. selected_file)
										if not show_success then
											vim.notify("Failed to show file: " .. selected_file .. " from " .. selected_branch, vim.log.levels.ERROR)
										end
									end

									actions.select_default:replace(select_file)
									return true
								end,
							})
							:find()
					end

					actions.select_default:replace(select_branch)
					return true
				end,
			})
			:find()
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
