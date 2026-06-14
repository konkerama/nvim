---@module 'lazy'
---@type LazySpec
return {
	"sindrets/diffview.nvim",
	cmd = { "DiffviewOpen", "DiffviewClose", "DiffviewFileHistory" },
	keys = {
		{
			"<leader>gd",
			function()
				-- Toggle: close if a Diffview tab is already open, otherwise open one.
				local lib = require("diffview.lib")
				if lib.get_current_view() then
					vim.cmd("DiffviewClose")
				else
					vim.cmd("DiffviewOpen")
				end
			end,
			desc = "[G]it [D]iff view (toggle)",
		},
		{ "<leader>gH", "<cmd>DiffviewFileHistory %<cr>", desc = "[G]it file [H]istory" },
	},
}
