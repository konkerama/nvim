---@module 'lazy'
---@type LazySpec
return {
	"akinsho/toggleterm.nvim",
	version = "*",
	opts = {
		direction = "horizontal",
		size = function(_)
			return math.max(10, math.floor(vim.o.lines * 0.25))
		end,
		persist_size = true,
	},
}
