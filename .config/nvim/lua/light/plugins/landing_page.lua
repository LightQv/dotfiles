return {
	"goolord/alpha-nvim",
	event = "VimEnter",
	config = function()
		local alpha = require("alpha")
		local dashboard = require("alpha.themes.dashboard")

		-- Header
		vim.api.nvim_set_hl(0, "AlphaHeader", { fg = "#cba6f7" })
		dashboard.section.header.opts.hl = "AlphaHeader"
		dashboard.section.header.val = {
			"██████╗ ██╗      █████╗ ███████╗██╗███╗   ██╗ ██████╗ ",
			"██╔══██╗██║     ██╔══██╗╚══███╔╝██║████╗  ██║██╔════╝ ",
			"██████╔╝██║     ███████║  ███╔╝ ██║██╔██╗ ██║██║  ███╗",
			"██╔══██╗██║     ██╔══██║ ███╔╝  ██║██║╚██╗██║██║   ██║",
			"██████╔╝███████╗██║  ██║███████╗██║██║ ╚████║╚██████╔╝",
			"╚═════╝ ╚══════╝╚═╝  ╚═╝╚══════╝╚═╝╚═╝  ╚═══╝ ╚═════╝ ",
			"                                                      ",
			"           ███████╗ █████╗ ███████╗████████╗          ",
			"           ██╔════╝██╔══██╗██╔════╝╚══██╔══╝          ",
			"           █████╗  ███████║███████╗   ██║             ",
			"           ██╔══╝  ██╔══██║╚════██║   ██║             ",
			"           ██║     ██║  ██║███████║   ██║             ",
			"           ╚═╝     ╚═╝  ╚═╝╚══════╝   ╚═╝             ",
		}

		-- Buttons
		vim.api.nvim_set_hl(0, "AlphaButton", { fg = "#89dceb", bold = true })
		vim.api.nvim_set_hl(0, "AlphaShortcut", { fg = "#cba6f7", italic = true })
		dashboard.section.buttons.val = {
			dashboard.button("SPC e", "  Toggle file explorer", "<cmd>Neotree toggle<CR>"),
			dashboard.button("SPC ff", "󰱼  Find File", "<cmd>Telescope find_files<CR>"),
			dashboard.button("SPC fw", "  Find Word", "<cmd>Telescope live_grep<CR>"),
			dashboard.button("SPC Sr", "  Last Session from CWD", "<cmd>AutoSession restore<CR>"),
		}
		for _, btn in ipairs(dashboard.section.buttons.val) do
			btn.opts.hl = "AlphaButton"
			btn.opts.hl_shortcut = "AlphaShortcut"
			btn.opts.align_shortcut = "right"
			btn.opts.width = 70
		end

		-- Footer
		dashboard.section.footer = {
			type = "text",
			val = "󱐋󱐋󱐋",
			opts = {
				position = "center",
				hl = "AlphaHeader",
			},
		}

		-- Layout
		local function centered_layout(sections)
			local height = vim.fn.winheight(0)
			local content_height = 0

			for _, section in ipairs(sections) do
				if section.type == "padding" then
					content_height = content_height + section.val
				elseif type(section.val) == "table" then
					content_height = content_height + #section.val
				elseif section.val then
					content_height = content_height + 1
				end
			end

			local padding_top = math.floor((height - content_height) / 2)
			return vim.list_extend({ { type = "padding", val = padding_top } }, sections)
		end

		dashboard.opts.layout = centered_layout({
			dashboard.section.header,
			{ type = "padding", val = 4 },
			dashboard.section.buttons,
			{ type = "padding", val = 4 },
			dashboard.section.footer,
		})

		alpha.setup(dashboard.opts)

		-- Disable folding on alpha buffer
		vim.cmd([[autocmd FileType alpha setlocal nofoldenable]])
	end,
}
