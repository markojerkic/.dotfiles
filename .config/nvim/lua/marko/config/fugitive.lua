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
