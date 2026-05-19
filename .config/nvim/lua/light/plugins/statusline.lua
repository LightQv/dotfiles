return {
	"rebelot/heirline.nvim",
	dependencies = {
		{
			"Zeioth/heirline-components.nvim",
			opts = {
				icons = {
					TabClose = "󰅙",
					BufferClose = "󰅙",
				},
			},
		},
	},

	opts = function()
		local lib = require("heirline-components.all")

		return {
			opts = {
				disable_winbar_cb = function(args)
					local is_disabled = not require("heirline-components.buffer").is_valid(args.buf)
						or lib.condition.buffer_matches({
							buftype = { "terminal", "prompt", "nofile", "help", "quickfix" },
							filetype = { "neo-tree", "dashboard", "Outline", "aerial", "alpha" },
						}, args.buf)
					return is_disabled
				end,
			},

			-- Tabline (top bar with buffers)
			tabline = {
				condition = function()
					return vim.bo.filetype ~= "alpha" -- disable tabline in alpha
				end,
				lib.component.tabline_conditional_padding(),
				lib.component.tabline_buffers({
					show_all_buffers = true,
					hide_when_empty = false,
					mode = 1,
					filename = {
						fname = function(bufnr)
							local bufs = vim.t.bufs or {}
							local idx
							for i, b in ipairs(bufs) do
								if b == bufnr then
									idx = i
									break
								end
							end
							local name = vim.fn.fnamemodify(vim.api.nvim_buf_get_name(bufnr), ":t")
							if idx and idx <= 9 then
								return idx .. ":" .. name
							end
							return name
						end,
						modify = "",
					},
					on_close = function(bufnr)
						vim.cmd("bdelete " .. bufnr)
					end,
				}),
				lib.component.fill({ hl = { bg = "tabline_bg" } }),
				lib.component.tabline_tabpages(),
			},

			-- Winbar (breadcrumbs etc.)
			winbar = {
				init = function(self)
					self.bufnr = vim.api.nvim_get_current_buf()
				end,
				fallthrough = false,
				{
					condition = function()
						return not lib.condition.is_active()
					end,
					{
						lib.component.neotree(),
						lib.component.compiler_play(),
						lib.component.fill(),
						lib.component.compiler_build_type(),
						lib.component.compiler_redo(),
						lib.component.aerial(),
					},
				},
				{
					lib.component.neotree(),
					lib.component.compiler_play(),
					lib.component.fill(),
					lib.component.breadcrumbs(),
					lib.component.fill(),
					lib.component.compiler_redo(),
					lib.component.aerial(),
				},
			},

			-- Statuscolumn (folds, numbers, signs)
			statusline = {
				fallthrough = false, -- let conditions pick the right block
				-- 1. Hide statusline only in Alpha
				{
					condition = function(self)
						return vim.bo[self and self.bufnr or 0].filetype == "alpha"
					end,
					provider = "",
				},
				-- 2. Normal statusline everywhere else
				{
					hl = { fg = "fg", bg = "bg" },
					{
						hl = function()
							return { bg = lib.hl.mode_bg(), fg = "#1e1e2e", bold = true }
						end,
						{
							provider = function()
								return " " .. lib.provider.mode_text()()
							end,
							update = { "ModeChanged", pattern = "*:*" },
						},
						{
							provider = "",
							hl = function()
								return { bg = "file_info_bg", fg = lib.hl.mode_bg() }
							end,
						},
					},
					{
						hl = { bg = "file_info_bg", fg = "fg" },
						lib.component.file_info({
							filetype = false,
							filename = { fallback = "Empty" },
							file_modified = false,
							file_read_only = false,
							padding = { left = 0, right = 0 },
							surround = { separator = "none", condition = false },
						}),
						{
							provider = "█",
							hl = { bg = "bg", fg = "file_info_bg" },
						},
					},
					lib.component.git_branch({
						padding = { left = 2 },
					}),
					lib.component.git_diff(),
					lib.component.diagnostics(),
					lib.component.fill(),
					{
						provider = function()
							local bufnr = vim.api.nvim_get_current_buf()
							local clients = vim.lsp.get_clients({ bufnr = bufnr })
							local seen = {}
							local names = {}

							for _, client in ipairs(clients) do
								if
									client.attached_buffers[bufnr]
									and not seen[client.name]
									and client.name ~= "null-ls"
								then
									table.insert(names, client.name)
									seen[client.name] = true
								end
							end

							if #names == 0 then
								return ""
							end

							return "  " .. table.concat(names, ", ")
						end,
						hl = { fg = "fg", bold = true },
						update = { "LspAttach", "LspDetach", "BufEnter" },
					},
					{
						provider = function()
							local decoration = vim.g.flutter_tools_decorations
							if not decoration or not decoration.device then
								return ""
							end

							local device = decoration.device
							local name = device.name or device.id or ""
							local platform = device.platform or ""

							if name == "" then
								return ""
							end

							return string.format(" %s (%s)", name, platform)
						end,
						hl = { fg = "fg", bold = true },
						update = { "User", pattern = { "FlutterRun", "FlutterDevices", "FlutterQuit" } },
					},
					lib.component.compiler_state(),
					lib.component.virtual_env(),
					lib.component.nav(),
				},
			},
		}
	end,

	config = function(_, opts)
		vim.o.laststatus = 3

		local heirline = require("heirline")
		local hc = require("heirline-components.all")

		hc.init.subscribe_to_events()

		local colors = hc.hl.get_colors()
		colors.buffer_active_fg = "#a6e3a1"
		colors.buffer_visible_fg = "#cba6f7"
		colors.file_info_bg = "#45475a"

		heirline.load_colors(colors)

		heirline.setup(opts)
	end,
}
