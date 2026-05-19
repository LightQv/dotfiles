return {
	"numToStr/Comment.nvim",
	opts = {
		---Add a space b/w comment and the line
		padding = true,
		---Whether the cursor should stay at its position
		sticky = true,
		ignore = nil,
		toggler = {
			line = "gcc",
			block = "gbc",
		},
		opleader = {
			line = "gc",
			block = "gb",
		},
		extra = {
			eol = "gcA",
		},
		mappings = {
			basic = true,
			extra = true,
		},
		---Function to call before (un)comment
		pre_hook = nil,
		---Function to call after (un)comment
		post_hook = nil,
	},
}
