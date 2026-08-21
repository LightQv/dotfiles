vim.g.mapleader = " " -- Leader key

local keymap = vim.keymap

-- General
keymap.set("n", "<leader>w", "<cmd>update<CR>", { desc = "Save" })
keymap.set("n", "<C-q>", "<cmd>quit<CR>", { desc = "Quit" })
keymap.set("i", "jk", "<ESC>", { desc = "Exit insert mode with jk" })
keymap.set("n", "<leader>hh", "<cmd>nohlsearch<CR>", { desc = "Clear search highlights" })
keymap.set("n", "<leader>R", "<cmd>checktime<CR>", { desc = "Check external file changes" })

-- Window management
keymap.set("n", "|", "<C-w>v", { desc = "Split window vertically" }) -- split window vertically
keymap.set("n", "\\", "<C-w>s", { desc = "Split window horizontally" }) -- split window horizontally
keymap.set("n", "<leader>sq", "<cmd>close<CR>", { desc = "Close current split" }) -- close current split window

-- Resize splits
keymap.set("n", "<C-Left>", ":vertical resize -5<CR>", { desc = "Decrease split width" })
keymap.set("n", "<C-Right>", ":vertical resize +5<CR>", { desc = "Increase split width" })
keymap.set("n", "<leader>=", "<C-w>=", { desc = "Make splits equal size" })

-- Buffer navigation
local function buf_navigate(direction)
	local bufs = vim.t.bufs or vim.api.nvim_list_bufs()
	local current_buf = vim.api.nvim_get_current_buf()
	local current_idx

	-- Filter out invalid buffers if using nvim_list_bufs directly
	local valid_bufs = {}
	for _, buf in ipairs(bufs) do
		if vim.api.nvim_buf_is_valid(buf) and vim.bo[buf].buflisted then
			table.insert(valid_bufs, buf)
		end
	end

	for i, buf in ipairs(valid_bufs) do
		if buf == current_buf then
			current_idx = i
			break
		end
	end

	if not current_idx then
		return
	end

	local target_idx = current_idx + direction
	if target_idx > #valid_bufs then
		target_idx = 1
	elseif target_idx < 1 then
		target_idx = #valid_bufs
	end

	vim.api.nvim_set_current_buf(valid_bufs[target_idx])
end

keymap.set("n", "<S-l>", function()
	buf_navigate(1)
end, { desc = "Go to next buffer" })
keymap.set("n", "<S-h>", function()
	buf_navigate(-1)
end, { desc = "Go to previous buffer" })

for i = 1, 9 do
	vim.keymap.set("n", "<leader>" .. i, function()
		local bufs = vim.t.bufs or vim.api.nvim_list_bufs()
		local buf = bufs[i]
		if buf and vim.api.nvim_buf_is_loaded(buf) then
			vim.api.nvim_set_current_buf(buf)
		else
			vim.notify("Buffer " .. i .. " does not exist", vim.log.levels.WARN)
		end
	end, { desc = "Go to buffer " .. i })
end
