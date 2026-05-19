return {
	"echasnovski/mini.bufremove",
	version = "*",

	config = function()
		local bufremove = require("mini.bufremove")

		-- helper to find index of current buffer
		local function index_of(tbl, val)
			for i, v in ipairs(tbl) do
				if v == val then
					return i
				end
			end
		end

		vim.keymap.set("n", "<leader>cc", function()
			bufremove.delete(0, false)
		end, { desc = "Close current buffer" })

		vim.keymap.set("n", "<leader>C", function()
			local current = vim.api.nvim_get_current_buf()

			for _, buf in ipairs(vim.api.nvim_list_bufs()) do
				if vim.api.nvim_buf_is_loaded(buf) and buf ~= current then
					bufremove.delete(buf, false)
				end
			end
		end, { desc = "Close all except current" })

		vim.keymap.set("n", "<leader>ch", function()
			local bufs = vim.t.bufs or vim.api.nvim_list_bufs()
			local current = vim.api.nvim_get_current_buf()
			local idx = index_of(bufs, current)

			if not idx then
				return
			end

			for i = 1, idx - 1 do
				local b = bufs[i]

				if vim.api.nvim_buf_is_loaded(b) then
					bufremove.delete(b, false)
				end
			end
		end, { desc = "Close buffers to the left" })

		vim.keymap.set("n", "<leader>cl", function()
			local bufs = vim.t.bufs or vim.api.nvim_list_bufs()
			local current = vim.api.nvim_get_current_buf()
			local idx = index_of(bufs, current)

			if not idx then
				return
			end

			for i = idx + 1, #bufs do
				local b = bufs[i]

				if vim.api.nvim_buf_is_loaded(b) then
					bufremove.delete(b, false)
				end
			end
		end, { desc = "Close buffers to the right" })
	end,
}
