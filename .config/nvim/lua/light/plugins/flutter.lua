return {
	"nvim-flutter/flutter-tools.nvim",
	lazy = false,
	dependencies = {
		"nvim-lua/plenary.nvim",
		"stevearc/dressing.nvim", -- optional for vim.ui.select
		"neovim/nvim-lspconfig", -- ensure LspAttach autocmd is registered before dartls attaches
	},
	config = function()
		local has_blink, blink = pcall(require, "blink.cmp")
		local capabilities = has_blink and blink.get_lsp_capabilities() or nil

		local opts = {
			decorations = {
				statusline = {
					device = true,
				},
			},
			dev_log = {
				open_cmd = "10split",
				focus_on_open = false,
			},
			dev_tools = {
				auto_open_browser = true,
			},
			lsp = {
				capabilities = capabilities,
				on_attach = function(_, bufnr)
					local opts = { buffer = bufnr, silent = true }

					opts.desc = "Show LSP references"
					vim.keymap.set("n", "gu", "<cmd>Telescope lsp_references<CR>", opts)

					opts.desc = "Go to definition"
					vim.keymap.set("n", "gd", vim.lsp.buf.definition, opts)

					opts.desc = "Show LSP implementations"
					vim.keymap.set("n", "gI", "<cmd>Telescope lsp_implementations<CR>", opts)

					opts.desc = "Show LSP type definitions"
					vim.keymap.set("n", "gt", "<cmd>Telescope lsp_type_definitions<CR>", opts)

					opts.desc = "See available code actions"
					vim.keymap.set("n", "<leader>la", vim.lsp.buf.code_action, opts)

					opts.desc = "Smart rename"
					vim.keymap.set("n", "<leader>lr", vim.lsp.buf.rename, opts)

					opts.desc = "Show buffer diagnostics"
					vim.keymap.set("n", "<leader>d", "<cmd>Telescope diagnostics bufnr=0<CR>", opts)

					opts.desc = "Show line diagnostics"
					vim.keymap.set("n", "<leader>ld", function()
						vim.diagnostic.open_float(nil, { focus = true, border = "rounded" })
					end, opts)

					opts.desc = "Go to previous diagnostic"
					vim.keymap.set("n", "[d", vim.diagnostic.goto_prev, opts)

					opts.desc = "Go to next diagnostic"
					vim.keymap.set("n", "]d", vim.diagnostic.goto_next, opts)

					opts.desc = "Show documentation for symbol"
					vim.keymap.set("n", "K", vim.lsp.buf.hover, opts)

					opts.desc = "Restart LSP"
					vim.keymap.set("n", "<leader>ls", ":LspRestart<CR>", opts)
				end,
			},
		}
		require("flutter-tools").setup(opts)

		local keymap = vim.keymap

		keymap.set("n", "<leader>mfs", function()
			require("flutter-tools.commands").run({ flavor = "dev" })
		end, { desc = "Run project with DEV flavor" })
		keymap.set("n", "<leader>mfd", "<cmd>FlutterDevices<CR>", { desc = "List of connected devices to select from" })
		keymap.set("n", "<leader>mfl", "<cmd>FlutterLogToggle<CR>", { desc = "Toggle Flutter log buffer" })
		keymap.set("n", "<leader>mfr", "<cmd>FlutterRestart<CR>", { desc = "Restart current project" })
		keymap.set("n", "<leader>mft", "<cmd>FlutterDevTools<CR>", { desc = "Start Dart DevTools server" })
		keymap.set("n", "<leader>mfq", "<cmd>FlutterQuit<CR>", { desc = "End running session" })
	end,
}
