return {
	"tzachar/highlight-undo.nvim",
	opts = {
		hlgroup = "HighlightUndo",
		duration = 150,
		ignored_filetypes = { "neo-tree", "fugitive", "TelescopePrompt", "mason", "lazy" },
		keymaps = {
			{ "n", "u", "undo", {} }, -- If you remap undo/redo, change this
			{ "n", "<C-r>", "redo", {} },
		},
	},
	config = function(_, opts)
		require("highlight-undo").setup(opts)

		-- Also flash on yank.
		vim.api.nvim_create_autocmd("TextYankPost", {
			desc = "Highlight yanked text",
			pattern = "*",
			callback = function()
				vim.hl.on_yank()
			end,
		})
	end,
}
