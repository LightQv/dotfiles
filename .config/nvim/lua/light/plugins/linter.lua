return {
	"mfussenegger/nvim-lint",
	event = { "BufReadPre", "BufNewFile" },
	config = function()
		local lint = require("lint")

		lint.linters_by_ft = {
			javascript = { "eslint_d" },
			typescript = { "eslint_d" },
			vue = { "eslint_d" },
		}

		local lint_augroup = vim.api.nvim_create_augroup("lint", { clear = true })

		local function try_linting()
			local linters = lint.linters_by_ft[vim.bo.filetype]
			lint.try_lint(linters)
		end

		vim.api.nvim_create_autocmd({ "BufEnter", "BufWritePost", "InsertLeave" }, {
			group = lint_augroup,
			callback = function()
				try_linting()
			end,
		})

		vim.keymap.set("n", "<leader>ll", function()
			try_linting()
		end, { desc = "Trigger linting for current file" })
	end,
}
