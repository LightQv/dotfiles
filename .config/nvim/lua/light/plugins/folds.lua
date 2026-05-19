return {
	"kevinhwang91/nvim-ufo",
	dependencies = { "kevinhwang91/promise-async" },
	event = "BufReadPost",
	config = function()
		vim.opt.foldenable = true
		vim.opt.foldlevel = 99
		vim.opt.foldminlines = 1
		vim.opt.foldmethod = "expr"
		vim.opt.foldexpr = "v:lua.vim.treesitter.foldexpr()"
		vim.opt.foldcolumn = "0"
		vim.opt.fillchars:append({
			fold = " ", -- caractère vide à l'intérieur du foldcolumn
			foldopen = "▼", -- symbole quand le fold est ouvert
			foldclose = "▶", -- symbole quand il est fermé
			foldsep = " ", -- pas de séparateur vertical
		})

		vim.api.nvim_set_hl(0, "FoldColumn", { fg = "#cba6f7", italic = true })
		vim.api.nvim_set_hl(0, "Folded", { fg = "#cba6f7", italic = true })

		local ufo = require("ufo")
		ufo.setup({
			provider_selector = function(_, filetype, _)
				return { "treesitter", "indent" }
			end,

			fold_virt_text_handler = function(virtText, lnum, endLnum, width, truncate)
				local newVirtText = {}
				local icon = " ▼ "
				local suffix = icon
				local sufWidth = vim.fn.strdisplaywidth(suffix)
				local targetWidth = width - sufWidth
				local curWidth = 0
				for _, chunk in ipairs(virtText) do
					local chunkText = chunk[1]
					local chunkWidth = vim.fn.strdisplaywidth(chunkText)
					if targetWidth > curWidth + chunkWidth then
						table.insert(newVirtText, chunk)
					else
						chunkText = truncate(chunkText, targetWidth - curWidth)
						table.insert(newVirtText, { chunkText, chunk[2] })
						break
					end
					curWidth = curWidth + chunkWidth
				end
				table.insert(newVirtText, { suffix, "Folded" })
				return newVirtText
			end,
		})

		vim.keymap.set("n", "za", function()
			vim.cmd.normal({ args = { "za" }, bang = true })
		end, { desc = "Toggle fold under cursor" })

		local ts = vim.treesitter

		local function toggle_blocks_by_query(lang, query)
			local parser = ts.get_parser(0, lang)
			if not parser then
				return
			end
			local tree = parser:parse()[1]
			local root = tree:root()
			local q = ts.query.parse(lang, query)

			local ranges = {}
			for _, node in q:iter_captures(root, 0, 0, -1) do
				local sr, _, er, _ = node:range()
				table.insert(ranges, { sr, er })
			end
			if #ranges == 0 then
				return
			end

			table.sort(ranges, function(a, b)
				return a[1] < b[1]
			end)
			local groups = { { ranges[1][1], ranges[1][2] } }
			for i = 2, #ranges do
				local prev = groups[#groups]
				local cur = ranges[i]
				if cur[1] <= prev[2] + 1 then
					prev[2] = math.max(prev[2], cur[2])
				else
					table.insert(groups, { cur[1], cur[2] })
				end
			end

			local curpos = vim.api.nvim_win_get_cursor(0)
			for _, g in ipairs(groups) do
				vim.api.nvim_win_set_cursor(0, { g[1] + 1, 0 })
				vim.cmd.normal({ args = { "za" }, bang = true })
			end
			vim.api.nvim_win_set_cursor(0, curpos)
		end

		-- zd → docstrings
		vim.keymap.set("n", "zd", function()
			toggle_blocks_by_query(
				"python",
				[[
        ((expression_statement (string)) @fold
          (#match? @fold "^\"\"\""))
      ]]
			)
		end, { desc = "Toggle docstrings" })

		-- zA → methods / classes
		vim.keymap.set("n", "zA", function()
			toggle_blocks_by_query(
				"python",
				[[
        ((function_definition) @fold)
      ]]
			)
		end, { desc = "Toggle functions" })
	end,
}
