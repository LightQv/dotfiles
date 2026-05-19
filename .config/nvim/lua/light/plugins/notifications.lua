return {
	"rcarriga/nvim-notify",
	opts = function()
		local fps = 144
		return {
			timeout = 2500,
			stages = "fade_in_slide_out",
			fps = fps,
			background_colour = "#000000",
		}
	end,
	config = function(_, opts)
		local notify = require("notify")
		notify.setup(opts)

		vim.notify = notify
		local map = vim.keymap.set

		vim.api.nvim_create_autocmd("FileType", {
			pattern = "notify",
			callback = function(event)
				map("n", "q", "<cmd>close<cr>", { buffer = event.buf, silent = true })
			end,
		})

		map("n", "<leader>nd", function()
			notify.dismiss({ silent = true, pending = true })
		end, { desc = "Dismiss notifications" })

		map("n", "<leader>ny", function()
			local history = notify.history()
			if history and #history > 0 then
				local last = history[#history].message
				vim.fn.setreg("+", last) -- yank to system clipboard
				vim.notify("Yanked last notification to clipboard")
			else
				vim.notify("No notifications in history")
			end
		end, { desc = "Yank last notification" })
	end,
}
