---@module 'lazy'
---@type LazySpec
return {
	"MagicDuck/grug-far.nvim",
	opts = {},
	keys = {
		{ "<leader>sr", "<cmd>GrugFar<cr>", desc = "Search & Replace" },
		{ "<leader>S", "<cmd>GrugFar<cr>", desc = "Search & Replace" },
		-- open with current word pre-filled
		-- {
		-- 	"<leader>sw",
		-- 	function()
		-- 		require("grug-far").open({ prefills = { search = vim.fn.expand("<cword>") } })
		-- 	end,
		-- 	desc = "Search & Replace (cword)",
		-- },
		-- open scoped to current file
		-- {
		-- 	"<leader>sf",
		-- 	function()
		-- 		require("grug-far").open({ prefills = { paths = vim.fn.expand("%") } })
		-- 	end,
		-- 	desc = "Search & Replace (current file)",
		-- },
	},
}
