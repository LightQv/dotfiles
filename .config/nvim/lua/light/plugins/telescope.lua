return {
	"nvim-telescope/telescope.nvim",
	branch = "0.1.x",
	dependencies = {
		"nvim-lua/plenary.nvim",
		{ "nvim-telescope/telescope-fzf-native.nvim", build = "make" },
		"echasnovski/mini.icons",
		"folke/todo-comments.nvim",
		"rcarriga/nvim-notify",
	},
	config = function()
		local has_mini, mini_icons = pcall(require, "mini.icons")
		if has_mini then
			mini_icons.setup()
			if not vim.g.have_nerd_font then
				vim.g.have_nerd_font = true
			end
			-- Let telescope and other plugins use mini.icons instead of devicons
			require("mini.icons").mock_nvim_web_devicons()
		end

		local telescope = require("telescope")
		local actions = require("telescope.actions")

		local trouble = require("trouble")
		local trouble_telescope = require("trouble.sources.telescope")

		telescope.setup({
			defaults = {
				path_display = function(_, path)
					local tail = require("telescope.utils").path_tail(path)
					local dir = vim.fn.fnamemodify(path, ":h")
					if dir == "." then
						return tail
					end
					return string.format("%s ~ %s", tail, dir)
				end,
				sorting_strategy = "ascending", -- results top-to-bottom
				layout_config = {
					prompt_position = "top", -- search bar on top
				},
				file_ignore_patterns = { "__init__%.py" }, -- ignore __init__.py unless explicitly searched for
				mappings = {
					i = {
						["<C-k>"] = actions.move_selection_previous,
						["<C-j>"] = actions.move_selection_next,

						["<C-q>"] = function(prompt_bufnr)
							local action_state = require("telescope.actions.state")

							actions.smart_send_to_qflist(prompt_bufnr)

							local ok, picker = pcall(action_state.get_current_picker, prompt_bufnr)
							if ok and picker and picker.close then
								picker:close()
							else
								pcall(actions.close, prompt_bufnr)
							end

							vim.schedule(function()
								trouble.open("quickfix")
							end)
						end,

						["<C-t>"] = trouble_telescope.open,
					},
				},
			},
		})

		vim.api.nvim_create_autocmd("FileType", {
			group = vim.api.nvim_create_augroup("TelescopePathHighlight", { clear = true }),
			pattern = "TelescopeResults",
			callback = function(event)
				vim.schedule(function()
					if not vim.api.nvim_buf_is_valid(event.buf) then
						return
					end

					local results_win = vim.fn.bufwinid(event.buf)
					if results_win == -1 then
						return
					end

					vim.fn.matchadd(
						"TelescopeResultsPath",
						[[ \~ \zs.\{-}\ze\%(:\d\+:\d\+\|$\)]],
						200,
						-1,
						{ window = results_win }
					)
				end)
			end,
		})

		telescope.load_extension("fzf")
		telescope.load_extension("notify")

		-- set keymaps
		local keymap = vim.keymap

		keymap.set("n", "<leader>ff", "<cmd>Telescope find_files<cr>", { desc = "Fuzzy find files in cwd" })
		keymap.set("n", "<leader>fF", function()
			require("telescope.builtin").find_files({ hidden = true })
		end, { desc = "Fuzzy find files in cwd (including hidden)" })
		keymap.set("n", "<leader>fw", "<cmd>Telescope live_grep<cr>", { desc = "Find string in cwd" })
		keymap.set("n", "<leader>fc", "<cmd>Telescope grep_string<cr>", { desc = "Find string under cursor in cwd" })
		keymap.set("n", "<leader>ft", "<cmd>TodoTelescope<cr>", { desc = "Find todos" })
		keymap.set("n", "<leader>fg", "<cmd>Telescope git_status<cr>", { desc = "Find Git changes" })
		keymap.set("n", "<leader>fb", "<cmd>Telescope buffers<cr>", { desc = "Find open buffers" })
		keymap.set("n", "<leader>fk", "<cmd>Telescope keymaps<cr>", { desc = "Find keymaps" })
		keymap.set("n", "<leader>f<CR>", function()
			require("telescope.builtin").resume()
		end, { desc = "Telescope resume search" })
		keymap.set("n", "<leader>fn", function()
			telescope.extensions.notify.notify()
		end, { desc = "Browse notifications" })
	end,
}
