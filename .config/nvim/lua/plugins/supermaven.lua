return {
	"supermaven-inc/supermaven-nvim",
	config = function()
		require("supermaven-nvim").setup({
			keymaps = {
				accept_suggestion = "<C-a>",
				clear_suggestion = "<C-]>",
				accept_word = "<C-j>",
			},
			color = {
				suggestion_color = "#d799dd",
				cterm = 13,
			},
			ignore_filetypes = { "log" },
		})
	end,
}
