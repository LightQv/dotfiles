return {
	"folke/noice.nvim",
	event = "VeryLazy",
	dependencies = {
		"MunifTanjim/nui.nvim",
		"rcarriga/nvim-notify",
	},
	config = function()
		require("noice").setup({
			lsp = {
				progress = { enabled = false },
				hover = { enabled = false },
				signature = { enabled = false },
			},
			notify = {
				enabled = true,
			},
			routes = {
				{
					filter = {
						event = "msg_show",
						kind = { "echo", "echomsg" },
					},
					opts = { skip = true },
				},
			},
			views = {
				notify = {
					backend = "notify", -- use nvim-notify as the display
				},
			},
		})
	end,
}
