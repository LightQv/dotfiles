return {
	"catppuccin/nvim",
	name = "catppuccin",
	lazy = false, -- start immediately
	priority = 1000, -- before everything else
	opts = {
		flavour = "mocha",
		term_colors = true,
		transparent_background = true,
		auto_integrations = true,
		integrations = {
			telescope = true,
			treesitter = true,
			native_lsp = { enabled = true },
			which_key = true,
			alpha = true,
			noice = true,
			notify = true,
			gitsigns = true,
			cmp = true,
			mason = true,
		},
		-- TODO:
		-- NOTE:
		-- WARNING:
		-- FIXME:
		custom_highlights = function(c)
			return {
				-- Diagnostics
				DiagnosticError = { fg = c.red },
				DiagnosticWarn = { fg = c.yellow },
				DiagnosticInfo = { fg = c.pink },
				DiagnosticHint = { fg = c.sapphire },
				-- Floating Borders
				NormalFloat = { bg = "NONE" },
				FloatBorder = { bg = "NONE" },
				DiagnosticFloatingError = { fg = c.red, bg = "NONE" },
				DiagnosticFloatingWarn = { fg = c.yellow, bg = "NONE" },
				DiagnosticFloatingInfo = { fg = c.pink, bg = "NONE" },
				DiagnosticFloatingHint = { fg = c.sapphire, bg = "NONE" },
				-- General
				Normal = { bg = "NONE" },
				NormalNC = { bg = "NONE" },
				SignColumn = { bg = "NONE" },
				LineNr = { bg = "NONE" },
				EndOfBuffer = { bg = "NONE" },
				Pmenu = { bg = "NONE" },
				PmenuSel = { bg = "NONE" },
				-- Blink
				BlinkCmpMenuBorder = { fg = c.sapphire },
				BlinkCmpDocBorder = { fg = c.sapphire },
				BlinkCmpDocSeparator = { fg = c.pink },
				-- Telescope
				TelescopeNormal = { bg = "NONE" },
				TelescopeBorder = { bg = "NONE" },
				TelescopePromptNormal = { bg = "NONE" },
				TelescopePromptBorder = { bg = "NONE" },
				TelescopeResultsNormal = { fg = c.pink, bg = "NONE", bold = true },
				TelescopePreviewNormal = { bg = "NONE" },
				TelescopeTitle = { fg = c.mauve, bg = "NONE", bold = true },
				-- Mason / Noice / Notify
				MasonNormal = { bg = "NONE" },
				NoicePopup = { bg = "NONE" },
				NotifyBackground = { bg = "NONE" },
				-- Treesitter
				["@tag"] = { fg = c.mauve },
				["@type"] = { fg = c.yellow },
				["@type.builtin.python"] = { fg = c.yellow },
				["@type.builtin.typescript"] = { fg = c.yellow },
				["@type.python"] = { fg = c.yellow },
				["@predefined_type.vue"] = { fg = c.yellow },
				-- WhichKey
				WhichKeyBorder = { fg = c.sapphire },
			}
		end,
	},
	config = function(_, opts)
		require("catppuccin").setup(opts)
		vim.cmd("colorscheme catppuccin")
	end,
}
