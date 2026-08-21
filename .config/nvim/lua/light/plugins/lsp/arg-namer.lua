return {
	"neovim/nvim-lspconfig",
	init = function()
		vim.api.nvim_create_autocmd("LspAttach", {
			group = vim.api.nvim_create_augroup("LspArgNamer", { clear = true }),
			callback = function(args)
				if vim.bo[args.buf].filetype ~= "python" then
					return
				end

				local client = vim.lsp.get_client_by_id(args.data.client_id)
				if not client or not client.server_capabilities.signatureHelpProvider then
					return
				end

				local function apply_edit(arg_node, name)
					local start_row, start_col, _, _ = arg_node:range()
					vim.api.nvim_buf_set_text(0, start_row, start_col, start_row, start_col, { name .. "=" })
				end

				local function get_arg_name(signature, param_idx)
					local param = signature.parameters[param_idx + 1]
					if not param then
						return nil
					end
					local label = param.label
					if type(label) == "table" then
						local sig_label = signature.label
						label = string.sub(sig_label, label[1] + 1, label[2])
					end
					return string.match(label, "^([%w_]+)")
				end

				local function handler(err, result, ctx, config)
					if err or not result or not result.signatures or #result.signatures == 0 then
						vim.notify("No signature help available", vim.log.levels.WARN)
						return
					end

					-- Parse Trigger Mode from config (passed via buf_request context if possible, but easier to re-detect or rely on closure)
					-- We'll just re-detect if we are on '(' or assume the intention based on where we requested signature?
					-- Actually, we can check the cursor position again, or better, pass a flag in the context?
					-- 'ctx' is just the LSP context. We can't easily pass custom data unless we wrap the handler.
					-- Let's define the logic based on the *result* and *current cursor*.

					local cursor = vim.api.nvim_win_get_cursor(0)
					local row, col = cursor[1] - 1, cursor[2]
					local line = vim.api.nvim_get_current_line()
					local char = line:sub(col + 1, col + 1)
					local is_batch = (char == "(")

					local signature = result.signatures[(result.activeSignature or 0) + 1]
					if not signature then
						return
					end

					-- Find Argument List Node
					local node = vim.treesitter.get_node()
					local args_node = node
					while args_node do
						local t = args_node:type()
						if t == "argument_list" or t == "arguments" then
							break
						end
						args_node = args_node:parent()
					end

					if not args_node then
						vim.notify("Could not find argument list", vim.log.levels.WARN)
						return
					end

					if is_batch then
						-- Batch Mode: Iterate all children
						local edits = {}
						local child_count = args_node:named_child_count()

						for i = 0, child_count - 1 do
							local child = args_node:named_child(i)
							local node_type = child:type()

							-- Skip if already named
							if
								not (
									node_type == "keyword_argument"
									or node_type == "pair"
									or node_type == "assignment"
								)
							then
								local name = get_arg_name(signature, i)
								-- Skip variadic args (*args) usually shown as *args in label
								if name and not name:match("^%*") then
									table.insert(edits, { node = child, name = name })
								end
							end
						end

						-- Apply in reverse order
						for i = #edits, 1, -1 do
							apply_edit(edits[i].node, edits[i].name)
						end

						if #edits > 0 then
							vim.notify("Named " .. #edits .. " arguments", vim.log.levels.INFO)
						else
							vim.notify("No arguments to name", vim.log.levels.INFO)
						end
					else
						-- Single Mode: Find specific argument under cursor
						-- (Reuse existing logic but simpler now)

						-- We need to find which child index corresponds to our original cursor position
						-- The cursor might have moved slightly but 'node' from get_node() is still reliable?
						-- Actually get_node() uses current cursor.

						-- Find the specific argument node starting from 'node'
						local arg_node = node
						while arg_node do
							local parent = arg_node:parent()
							if parent and parent:id() == args_node:id() then
								break
							end
							arg_node = parent
						end

						if not arg_node then
							return
						end -- Should not happen if we found args_node and aren't on parens

						-- Find index
						local param_idx = 0
						for i = 0, args_node:named_child_count() - 1 do
							local child = args_node:named_child(i)
							if child:id() == arg_node:id() then
								param_idx = i
								break
							end
						end

						local node_type = arg_node:type()
						if node_type == "keyword_argument" or node_type == "pair" or node_type == "assignment" then
							vim.notify("Argument already named", vim.log.levels.INFO)
							return
						end

						local name = get_arg_name(signature, param_idx)
						if name then
							apply_edit(arg_node, name)
						end
					end
				end

				vim.keymap.set("n", "<leader>ln", function()
					local cursor = vim.api.nvim_win_get_cursor(0)
					local row, col = cursor[1] - 1, cursor[2]
					local line = vim.api.nvim_get_current_line()
					local char = line:sub(col + 1, col + 1)

					-- 1. Find opening parenthesis position for reliable context
					local node = vim.treesitter.get_node()
					local args_node = node
					while args_node do
						if args_node:type() == "argument_list" or args_node:type() == "arguments" then
							break
						end
						args_node = args_node:parent()
					end

					if not args_node then
						vim.notify("Cursor not in function arguments", vim.log.levels.WARN)
						return
					end

					-- The argument list usually starts after the opening paren.
					-- Generic strategy: Use the start of the 'argument_list' node.
					local start_row, start_col, _, _ = args_node:range()

					-- Find a client that supports signatureHelp to get the correct encoding
					local clients = vim.lsp.get_clients({ bufnr = 0, method = "textDocument/signatureHelp" })
					if #clients == 0 then
						vim.notify("No LSP client supports signatureHelp", vim.log.levels.WARN)
						return
					end
					local client = clients[1] -- Pick the first one (usually the primary language server)

					local params = vim.lsp.util.make_position_params(0, client.offset_encoding)
					params.position.line = start_row
					params.position.character = start_col + 1 -- Move 1 char inside

					vim.lsp.buf_request(0, "textDocument/signatureHelp", params, handler)
				end, { buffer = args.buf, desc = "LSP: Name argument" })
			end,
		})
	end,
}
