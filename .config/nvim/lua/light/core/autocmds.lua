local api = vim.api
local reload_group = api.nvim_create_augroup("ExternalFileChanges", { clear = true })

-- Auto-reload files when they change on disk
-- 'autoread' is set in options.lua, but we need to trigger checktime
-- for it to work when the cursor is holding or the window gains focus.
api.nvim_create_autocmd({ "FocusGained", "BufEnter", "CursorHold" }, {
	group = reload_group,
	pattern = "*",
	command = "if mode() != 'c' | checktime | endif",
})
