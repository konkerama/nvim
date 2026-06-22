-- CUSTOM: lazydev configures lua_ls on the fly for editing this Neovim config —
-- proper completion/types for the vim API and plugin modules. Completion source is
-- wired into blink.cmp via init.lua (sources.providers.lazydev).
---@module 'lazy'
---@type LazySpec
return {
	"folke/lazydev.nvim",
	ft = "lua",
	opts = {
		library = {
			-- Load luvit types when the `vim.uv` word is found.
			{ path = "${3rd}/luv/library", words = { "vim%.uv" } },
		},
	},
}
