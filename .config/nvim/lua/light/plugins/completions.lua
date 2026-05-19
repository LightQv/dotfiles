return {
	"saghen/blink.cmp",
	dependencies = { "rafamadriz/friendly-snippets" },
	version = "1.*",
	---@module 'blink.cmp'
	opts = {
		-- NOTE :h blink-cmp-config-keymap for defining your own keymap
		keymap = {
			preset = "super-tab",
			["<CR>"] = { "accept", "fallback" },
		},
		appearance = {
			nerd_font_variant = "mono",
		},
		completion = {
			list = {
				selection = {
					preselect = false,
					auto_insert = false,
				},
			},
			documentation = {
				auto_show = true,
				auto_show_delay_ms = 50,
				window = {
					min_width = 30,
					border = "rounded",
				},
			},
			ghost_text = { enabled = true },
			menu = {
				min_width = 50,
				border = "rounded",
				scrollbar = true,
			},
		},
		sources = {
			default = { "path", "lsp", "snippets", "buffer" },
		},
		fuzzy = { implementation = "prefer_rust_with_warning" },
	},
	opts_extend = { "sources.default" },
}
