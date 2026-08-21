return {
	"goolord/alpha-nvim",
	event = "VimEnter",
	config = function()
		local alpha = require("alpha")
		local dashboard = require("alpha.themes.dashboard")
		local colors = require("catppuccin.palettes").get_palette("mocha")
		local dashboard_group = vim.api.nvim_create_augroup("AlphaDashboard", { clear = true })
		local original_guicursor
		local actions = {
			{
				shortcut = "SPC e",
				label = "  Toggle file explorer",
				lhs = "<leader>e",
				command = "<cmd>Neotree toggle<CR>",
			},
			{
				shortcut = "SPC ff",
				label = "󰱼  Find File",
				lhs = "<leader>ff",
				command = "<cmd>Telescope find_files<CR>",
			},
			{
				shortcut = "SPC fw",
				label = "  Find Word",
				lhs = "<leader>fw",
				command = "<cmd>Telescope live_grep<CR>",
			},
			{
				shortcut = "SPC Sr",
				label = "  Last Session from CWD",
				lhs = "<leader>Sr",
				command = "<cmd>AutoSession restore<CR>",
			},
		}
		local cursor_anchor = {
			type = "button",
			val = "",
			on_press = function() end,
			opts = {
				position = "center",
				cursor = 0,
			},
		}

		local function hide_cursor()
			if original_guicursor then
				return
			end

			original_guicursor = vim.o.guicursor
			vim.api.nvim_set_hl(0, "AlphaCursor", { bg = "#1e1e2e" })
			vim.o.guicursor = "a:ver1-AlphaCursor"
		end

		local function restore_cursor()
			if not original_guicursor then
				return
			end

			vim.o.guicursor = original_guicursor
			original_guicursor = nil
		end

		-- Current theme: uncomment this block and comment the Evangelion block to restore it.
		--[[
		local theme = {
			header = {
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
			},
			footer = "󱐋󱐋󱐋",
			header_color = colors.mauve,
			button_color = colors.sky,
			shortcut_color = colors.mauve,
			footer_color = colors.mauve,
			padding = 4,
		}
		]]

		-- Evangelion theme: comment this block when enabling the current theme above.
		local theme = {
			header = {
				"⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢀⣠⣴⣶⣶⣿⣶⣿⣿⣾⣿⣿⣿⣶⠂⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀",
				"⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢰⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣁⡀⢀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀",
				"⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢴⣿⡀⠀⠀⠀⠀⠀⠀⠀⢸⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣶⣶⣤⡀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀",
				"⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠙⢿⣦⡀⠀⠀⠀⠀⠀⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣦⡄⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀",
				"⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠉⠳⣄⣀⣀⣠⣾⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣦⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀",
				"⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠈⠻⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⡿⠛⠉⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀",
				"⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠒⠲⢶⣶⡀⠀⠀⠀⠐⠒⣶⠒⠂⠒⢶⣾⠛⢿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣯⣍⣙⠛⠛⠋⠉⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀",
				"⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢸⡿⣿⣦⡀⠀⠀⠀⣿⠀⠀⠀⢸⣿⠀⠀⠙⢿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣷⣶⣄⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀",
				"⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢸⡇⠈⠻⣿⣦⡀⠀⣿⠀⠀⠀⢸⣿⠶⠶⠶⢶⡟⢿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⡀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀",
				"⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢸⡇⠀⠀⠈⠻⣿⣦⣿⠀⠀⠀⢸⣿⠀⠀⠀⠀⠃⠀⡉⠻⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀",
				"⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢀⣸⣇⠀⠀⠀⠀⠈⠻⣿⠀⠀⢀⣸⣿⣀⣀⣀⣀⣠⡾⠁⠀⠈⠻⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⡇⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀",
				"⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠉⠉⠉⠉⠀⠀⠀⠀⠀⠉⠀⠀⠉⠉⠩⠭⣭⣭⣭⣭⣥⣄⡀⠀⠤⣬⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⡆⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀",
				"⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⣿⣿⠀⠀⠈⢿⣿⡄⠀⠈⢿⣿⡻⣿⣿⣿⣿⣿⣿⣿⣿⣿⡇⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀",
				"⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⣿⣿⠀⣀⣠⣿⠿⠁⠀⠀⠈⢿⣷⡀⠙⢿⣿⣿⣿⣿⣿⣿⣯⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀",
				"⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⣿⣿⠉⠻⣿⣆⠀⠀⠀⠀⠀⠈⢿⣷⡀⣰⠟⢿⣿⣿⣿⣿⡇⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀",
				"⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⣿⣿⠀⠀⠈⢿⣷⣄⠀⠀⠀⠀⠈⢿⣷⡏⠀⠀⠙⢿⣿⣿⣇⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀",
				"⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⣠⡲⣄⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠐⠒⠛⠛⠒⠂⠀⠀⠙⠛⠓⠒⠀⠀⠀⠈⠛⠀⠀⠀⠀⠀⠙⠻⣿⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀",
				"⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠈⠊⣞⢥⠄⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢀⣔⢖⡤⠈⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀",
				"⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠫⡾⡧⣢⣄⡀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢀⣠⣺⣺⠿⠋⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀",
				"⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠘⠺⠽⡱⣴⠂⣤⣀⡀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢀⣀⣤⠶⣪⣗⠤⠉⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀",
				"⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠈⠁⠚⠘⠾⢾⡁⣰⢰⣰⡠⡆⣶⣶⠒⣴⡏⠻⠟⠼⠑⠃⠁⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀",
				"⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠈⠉⠉⠉⠁⠉⠁⠁⠉⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀",
			},
			footer = "GOD'S IN HIS HEAVEN. ALL'S RIGHT WITH THE WORLD.",
			header_color = colors.red,
			button_color = colors.green,
			shortcut_color = colors.mauve,
			footer_color = colors.red,
			padding = 3,
		}
		local braille_blank = "⠀"
		local left_padding = math.huge
		local right_padding = math.huge

		for _, line in ipairs(theme.header) do
			local length = vim.fn.strchars(line)
			local left = 0
			local right = 0

			while left < length and vim.fn.strcharpart(line, left, 1) == braille_blank do
				left = left + 1
			end
			while right < length - left and vim.fn.strcharpart(line, length - right - 1, 1) == braille_blank do
				right = right + 1
			end

			left_padding = math.min(left_padding, left)
			right_padding = math.min(right_padding, right)
		end

		for index, line in ipairs(theme.header) do
			theme.header[index] = vim.fn.strcharpart(
				line,
				left_padding,
				vim.fn.strchars(line) - left_padding - right_padding
			)
		end

		-- Header
		vim.api.nvim_set_hl(0, "AlphaHeader", { fg = theme.header_color })
		dashboard.section.header.opts.hl = "AlphaHeader"
		dashboard.section.header.val = theme.header

		-- Actions
		vim.api.nvim_set_hl(0, "AlphaButton", { fg = theme.button_color, bold = true })
		vim.api.nvim_set_hl(0, "AlphaShortcut", { fg = theme.shortcut_color, italic = true })
		dashboard.section.buttons.val = function()
			local rows = {}
			local width = math.min(70, math.max(1, vim.api.nvim_win_get_width(0) - 10))

			for _, action in ipairs(actions) do
				local gap =
					math.max(1, width - vim.fn.strdisplaywidth(action.label) - vim.fn.strdisplaywidth(action.shortcut))
				local shortcut_start = #action.label + gap
				table.insert(rows, {
					type = "text",
					val = action.label .. string.rep(" ", gap) .. action.shortcut,
					opts = {
						position = "center",
						hl = {
							{ "AlphaButton", 0, shortcut_start },
							{ "AlphaShortcut", shortcut_start, -1 },
						},
					},
				})
			end

			return rows
		end

		-- Footer
		vim.api.nvim_set_hl(0, "AlphaFooter", { fg = theme.footer_color })
		dashboard.section.footer = {
			type = "text",
			val = theme.footer,
			opts = {
				position = "center",
				hl = "AlphaFooter",
			},
		}

		-- Layout
		local function centered_layout(sections)
			local height = vim.fn.winheight(0)
			local content_height = 0

			for _, section in ipairs(sections) do
				if section.type == "padding" then
					content_height = content_height + section.val
				elseif type(section.val) == "function" then
					content_height = content_height + #actions
				elseif type(section.val) == "table" then
					content_height = content_height + #section.val
				elseif section.val then
					content_height = content_height + 1
				end
			end

			local padding_top = math.max(0, math.floor((height - content_height) / 2))
			return vim.list_extend({ { type = "padding", val = padding_top } }, sections)
		end

		dashboard.opts.layout = centered_layout({
			dashboard.section.header,
			{ type = "padding", val = theme.padding },
			dashboard.section.buttons,
			{ type = "padding", val = theme.padding },
			dashboard.section.footer,
			cursor_anchor,
		})
		dashboard.opts.opts.keymap = {
			press = {},
			queue_press = {},
		}
		dashboard.opts.opts.setup = function()
			local buffer = vim.api.nvim_get_current_buf()
			hide_cursor()
			vim.api.nvim_create_autocmd("BufEnter", {
				group = dashboard_group,
				buffer = buffer,
				callback = hide_cursor,
			})
			vim.api.nvim_create_autocmd("BufLeave", {
				group = dashboard_group,
				buffer = buffer,
				callback = restore_cursor,
			})
			for _, action in ipairs(actions) do
				vim.keymap.set("n", action.lhs, action.command, {
					buffer = true,
					desc = action.label,
					noremap = true,
					silent = true,
					nowait = true,
				})
			end
		end

		alpha.setup(dashboard.opts)
	end,
}
