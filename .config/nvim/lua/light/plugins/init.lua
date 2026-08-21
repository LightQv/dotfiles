return {
	"nvim-lua/plenary.nvim", -- lua functions that many plugins use
	{
		"christoomey/vim-tmux-navigator",
		init = function()
			vim.g.tmux_navigator_save_on_switch = 1
		end,
	},
}
