-- CUSTOM: Adds extra key group labels on top of the kickstart base spec.
-- lazy.nvim deep-merges opts, so these are appended to the groups defined in init.lua.
---@module 'lazy'
---@type LazySpec
return {
	"folke/which-key.nvim",
	opts = {
		spec = {
			{ "<leader>d", group = "[D]ebug" },
			{ "<leader>R", group = "[R]un tests" },
			{ "<leader>x", group = "Trouble" },
			{ "gs", group = "[S]urround" },
		},
	},
}
