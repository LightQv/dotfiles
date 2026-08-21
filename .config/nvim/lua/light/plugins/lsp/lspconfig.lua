return {
	"neovim/nvim-lspconfig",
	event = { "BufReadPre", "BufNewFile" },
	dependencies = {
		"saghen/blink.cmp",
	},
	config = function()
		local keymap = vim.keymap
		local capabilities = require("blink.cmp").get_lsp_capabilities()

		vim.api.nvim_create_autocmd("LspAttach", {
			group = vim.api.nvim_create_augroup("UserLspConfig", { clear = true }),
			callback = function(ev)
				local opts = { buffer = ev.buf, silent = true }
				local client = vim.lsp.get_client_by_id(ev.data.client_id)

				local function lsp_map(lhs, rhs, desc, method)
					if client and client:supports_method(method) then
						opts.desc = desc
						keymap.set("n", lhs, rhs, opts)
					end
				end
				local function telescope_impl()
					local params = vim.lsp.util.make_position_params(0, "utf-16")
					vim.lsp.buf_request(0, "textDocument/implementation", params, function(_, result, _, _)
						if not result or vim.tbl_isempty(result) then
							vim.notify("No implementations found", vim.log.levels.INFO)
							return
						end
						require("telescope.builtin").lsp_implementations()
					end)
				end
				local function telescope_types()
					local params = vim.lsp.util.make_position_params(0, "utf-16")
					vim.lsp.buf_request(0, "textDocument/typeDefinition", params, function(_, result, _, _)
						if not result or vim.tbl_isempty(result) then
							vim.notify("No type definitions found", vim.log.levels.INFO)
							return
						end
						require("telescope.builtin").lsp_type_definitions()
					end)
				end
				local function open_definition_in_split()
					local clients = vim.lsp.get_clients({ bufnr = 0, method = "textDocument/definition" })
					if #clients == 0 then
						vim.notify("No active LSP clients", vim.log.levels.WARN)
						return
					end

					local target_client = clients[1]

					-- Use the correct encoding
					local params = vim.lsp.util.make_position_params(0, target_client.offset_encoding)

					vim.lsp.buf_request(0, "textDocument/definition", params, function(_, result)
						if not result or vim.tbl_isempty(result) then
							vim.notify("No definition found", vim.log.levels.WARN)
							return
						end

						local def = result[1]
						local uri = def.uri or def.targetUri
						local range = def.range or def.targetSelectionRange
						local fname = vim.uri_to_fname(uri)
						local bufnr = vim.uri_to_bufnr(uri)

						if not vim.api.nvim_buf_is_loaded(bufnr) then
							vim.fn.bufload(bufnr)
						end

						-- Reuse existing window if buffer already open
						for _, win in ipairs(vim.fn.win_findbuf(bufnr)) do
							vim.fn.win_gotoid(win)
							vim.api.nvim_win_set_cursor(0, { range.start.line + 1, range.start.character })
							return
						end

						-- Try to find an existing vertical split
						local current_win = vim.api.nvim_get_current_win()
						local wins = vim.api.nvim_list_wins()
						local found_vsplit = false
						for _, win in ipairs(wins) do
							if win ~= current_win then
								local wp = vim.api.nvim_win_get_position(win)
								local cp = vim.api.nvim_win_get_position(current_win)
								if wp[1] == cp[1] and wp[2] ~= cp[2] then
									vim.fn.win_gotoid(win)
									found_vsplit = true
									break
								end
							end
						end

						-- Open a vsplit if none found
						if not found_vsplit then
							vim.cmd("vsplit " .. vim.fn.fnameescape(fname))
						else
							vim.cmd("edit " .. vim.fn.fnameescape(fname))
						end

						vim.api.nvim_win_set_cursor(0, { range.start.line + 1, range.start.character })
					end)
				end

				local function peek_definition()
					local clients = vim.lsp.get_clients({ bufnr = 0, method = "textDocument/definition" })
					if #clients == 0 then
						return
					end
					local target_client = clients[1]

					local params = vim.lsp.util.make_position_params(0, target_client.offset_encoding)
					vim.lsp.buf_request(0, "textDocument/definition", params, function(_, result)
						if not result or vim.tbl_isempty(result) then
							return
						end
						local location = result[1]
						local uri = location.uri or location.targetUri
						local range = location.range or location.targetRange or location.targetSelectionRange

						local bufnr = vim.uri_to_bufnr(uri)
						if not vim.api.nvim_buf_is_loaded(bufnr) then
							vim.fn.bufload(bufnr)
						end

						local start_line = range.start.line
						local line_count = vim.api.nvim_buf_line_count(bufnr)
						local end_line = math.min(start_line + 100, line_count) -- Look ahead further to find fields
						local lines = vim.api.nvim_buf_get_lines(bufnr, start_line, end_line, false)

						local clean_lines = {}
						-- First line: The class/function definition (first line only as requested)
						table.insert(clean_lines, (lines[1]:gsub("^%s+", "")))

						for i = 2, #lines do
							local line = lines[i]
							-- Stop if we hit a method or another class to keep it concise
							if line:match("^%s*def ") or (i > 2 and line:match("^%s*class ")) then
								break
							end

							-- Match field pattern: "name: type"
							-- We only take the first line of the definition (stops at '=', '(', or end of line)
							local field = line:match("^%s*([%w_]+%s*:%s*[^=%(]+)")
							if field then
								table.insert(clean_lines, "  " .. field:gsub("%s+$", ""))
							end

							-- Don't let the preview get too huge
							if #clean_lines > 25 then
								break
							end
						end

						-- Fallback if no fields found (e.g. not a class)
						if #clean_lines <= 1 then
							clean_lines = {}
							for j = 1, math.min(10, #lines) do
								table.insert(clean_lines, lines[j])
							end
						end

						local ft = vim.bo[bufnr].filetype
						vim.lsp.util.open_floating_preview(clean_lines, ft, {
							border = "rounded",
						})
					end)
				end

				-- === Mappings ===
				lsp_map("gr", "<cmd>Telescope lsp_references<CR>", "Show LSP references", "textDocument/references")
				lsp_map("gd", vim.lsp.buf.definition, "Go to definition", "textDocument/definition")
				lsp_map("gD", open_definition_in_split, "Go to definition in split", "textDocument/definition")
				lsp_map("gp", peek_definition, "Peek definition", "textDocument/definition")
				lsp_map("gI", telescope_impl, "Show LSP implementations", "textDocument/implementation")
				lsp_map("gt", telescope_types, "Show LSP type definitions", "textDocument/typeDefinition")

				lsp_map("<leader>la", vim.lsp.buf.code_action, "See available code actions", "textDocument/codeAction")
				lsp_map("<leader>lr", vim.lsp.buf.rename, "Smart rename", "textDocument/rename")

				opts.desc = "Show line diagnostics (focusable)"
				keymap.set("n", "<leader>Ld", function()
					vim.diagnostic.open_float(nil, { focus = true, border = "rounded" })
				end, opts)
				opts.desc = "Show buffer diagnostics"
				keymap.set("n", "<leader>d", "<cmd>Telescope diagnostics bufnr=0<CR>", opts)

				opts.desc = "Go to previous diagnostic"
				keymap.set("n", "[d", function()
					vim.diagnostic.jump({ count = -1 })
				end, opts)

				opts.desc = "Go to next diagnostic"
				keymap.set("n", "]d", function()
					vim.diagnostic.jump({ count = 1 })
				end, opts)

				opts.desc = "Show documentation for symbol"
				keymap.set("n", "K", vim.lsp.buf.hover, opts)

				opts.desc = "Restart LSP"
				keymap.set("n", "<leader>rs", ":LspRestart<CR>", opts)
			end,
		})

		-- === LSP Diagnostics ===
		vim.diagnostic.config({
			virtual_text = {
				spacing = 2,
			},
			signs = {
				text = {
					[vim.diagnostic.severity.ERROR] = " ",
					[vim.diagnostic.severity.WARN] = " ",
					[vim.diagnostic.severity.HINT] = "󰠠 ",
					[vim.diagnostic.severity.INFO] = " ",
				},
			},
			underline = true,
			update_in_insert = false, -- don't show diagnostics while typing
			severity_sort = true,

			float = {
				border = "rounded",
				source = "always",
				header = "",
				prefix = "",
			},
		})

		vim.lsp.config("*", {
			capabilities = capabilities,
		})

		-- === Lua ===
		vim.lsp.config("lua_ls", {
			settings = {
				Lua = {
					-- make the language server recognize "vim" global
					diagnostics = {
						globals = { "vim" },
					},
					completion = {
						callSnippet = "Replace",
					},
				},
			},
		})

		-- === Python ===
		vim.lsp.config("basedpyright", {
			settings = {
				basedpyright = {
					analysis = {
						typeCheckingMode = "basic",
						diagnosticMode = "openFilesOnly",
						autoSearchPaths = true,
						useLibraryCodeForTypes = true,
					},
				},
			},
		})

		-- === Vue/Typescript ===
		local vue_language_server_path = vim.fn.stdpath("data")
			.. "/mason/packages/vue-language-server/node_modules/@vue/language-server"
		local tsserver_filetypes = { "typescript", "javascript", "javascriptreact", "typescriptreact", "vue" }
		local vue_plugin = {
			name = "@vue/typescript-plugin",
			location = vue_language_server_path,
			languages = { "vue" },
			configNamespace = "typescript",
		}
		-- vtsls config
		vim.lsp.config("vtsls", {
			filetypes = tsserver_filetypes,
			settings = {
				vtsls = {
					tsserver = {
						globalPlugins = { vue_plugin },
					},
				},
			},
		})

		-- vue_ls config
		vim.lsp.config("vue_ls", {})
	end,
}
