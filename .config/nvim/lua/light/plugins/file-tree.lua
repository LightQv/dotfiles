return {
	{
		"nvim-neo-tree/neo-tree.nvim",
		branch = "v3.x",
		dependencies = {
			"nvim-lua/plenary.nvim",
			"MunifTanjim/nui.nvim",
			"echasnovski/mini.icons",
		},
		config = function()
			vim.keymap.set("n", "<leader>e", "<cmd>Neotree toggle<CR>", { desc = "Toggle Neo-tree" })
			local function toggle_neotree_focus()
				-- If focus is on Neo-tree -> focus previous buffer
				if vim.bo.filetype == "neo-tree" then
					vim.cmd("wincmd p")
					return
				end

				-- If Neo-tree window exist -> focus
				for _, win in ipairs(vim.api.nvim_list_wins()) do
					local buf = vim.api.nvim_win_get_buf(win)
					local ft = vim.api.nvim_buf_get_option(buf, "filetype")
					if ft == "neo-tree" then
						vim.api.nvim_set_current_win(win)
						return
					end
				end

				-- Else open Neo-tree and focus
				vim.cmd("Neotree reveal")
			end

			vim.keymap.set("n", "<leader>o", toggle_neotree_focus, { desc = "Toggle Neo-tree focus" })

			require("neo-tree").setup({
				close_if_last_window = true, -- close if it's the last window
				filesystem = {
					filtered_items = {
						visible = true, -- show hidden files (toggle with H inside Neo-tree)
						hide_dotfiles = false,
						hide_gitignored = true,
					},
					follow_current_file = {
						enabled = true, -- focus the file in the tree when opening
					},
					hijack_netrw_behavior = "open_default", -- replace netrw
				},
				default_component_configs = {
					icon = {
						provider = function(icon, node) -- setup a custom icon provider
							local text, hl
							local mini_icons = require("mini.icons")
							if node.type == "file" then -- if it's a file, set the text/hl
								text, hl = mini_icons.get("file", node.name)
							elseif node.type == "directory" then -- get directory icons
								text, hl = mini_icons.get("directory", node.name)
								-- only set the icon text if it is not expanded
								if node:is_expanded() then
									text = nil
								end
							end

							-- set the icon text/highlight only if it exists
							if text then
								icon.text = text
							end
							if hl then
								icon.highlight = hl
							end
						end,
					},
					git_status = {
						symbols = {
							added = "",
							deleted = "",
							modified = "",
							renamed = "",
							untracked = "",
							ignored = "◌",
							unstaged = "",
							staged = "✓",
							conflict = "",
						},
					},
				},
				window = {
					width = 40,
					mappings = {
						["<CR>"] = "open", -- open file
						["l"] = "open", -- expand/open with l
						["h"] = "close_node",
						["<esc>"] = "revert_preview",
						["P"] = { "toggle_preview", config = { use_float = true } },
						["s"] = "open_split", -- open in horizontal split
						["v"] = "open_vsplit", -- open in vertical split
						["t"] = "open_tabnew", -- open in new tab
						["z"] = "close_all_nodes", -- collapse all
						["R"] = "refresh", -- refresh tree
						["a"] = { "add", config = { show_path = "relative" } }, -- add file
						["A"] = "add_directory", -- add folder
						["d"] = "delete",
						["r"] = "rename",
						["y"] = "copy_to_clipboard",
						["x"] = "cut_to_clipboard",
						["p"] = "paste_from_clipboard",
						["q"] = "close_window",
					},
				},
			})
		end,
	},
	{
		"antosha417/nvim-lsp-file-operations",
		dependencies = {
			"nvim-lua/plenary.nvim",
			"nvim-neo-tree/neo-tree.nvim", -- makes sure that this loads after Neo-tree.
		},
		config = function()
			require("lsp-file-operations").setup()
		end,
	},
	{
		"s1n7ax/nvim-window-picker",
		version = "2.*",
		config = function()
			require("window-picker").setup({
				filter_rules = {
					include_current_win = false,
					autoselect_one = true,
					bo = {
						filetype = { "neo-tree", "neo-tree-popup", "notify" },
						buftype = { "terminal", "quickfix" },
					},
				},
			})
		end,
	},
}
