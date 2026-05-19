return {
	"folke/which-key.nvim",
	event = "VeryLazy",
	init = function()
		vim.o.timeout = true
		vim.o.timeoutlen = 300
	end,
	opts = {
		notify = true,
		icons = {
			mappings = false, -- disable icons for mappings (correct key name)
			rules = false, -- disable icon rules entirely
			group = "", -- no group icon prefix
			colors = false, -- don’t recolor icons
		},
		spec = {
			{ "<leader>b", group = " Buffers" },
			{ "<leader>f", group = " Find" },
			{ "<leader>g", group = "󰊢 Git" },
			{ "<leader>h", group = " Git signs" },
			{ "<leader>n", group = " Notification" },
			{ "<leader>l", group = " Linter" },
			{ "<leader>L", group = "󰒡 Diagnostics" },
			{ "<leader>m", group = " Mobile" },
			{ "<leader>mf", group = " Flutter" },
			{ "<leader>r", group = " LSP" },
			{ "<leader>s", group = " Split" },
			{ "<leader>S", group = " Session" },
			{ "<leader>x", group = " Trouble" },
		},
		win = {
			border = "rounded",
		},
	},
}
