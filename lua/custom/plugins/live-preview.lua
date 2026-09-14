-- CUSTOM: browser preview for markdown. The C4 mermaid diagrams in the identity-provider
-- README are wider than a terminal cell grid can show legibly; snacks.image still renders
-- them inline for a glance, this is for actually reading them.
--
-- Picked over selimacerbas/markdown-preview.nvim because this one vendors mermaid.min.js
-- and KaTeX in-repo (static/), so preview works with no network. That one fetches every
-- browser library from a CDN.
---@module 'lazy'
---@type LazySpec
return {
	"brianhuster/live-preview.nvim",
	cmd = "LivePreview",
	keys = {
		{
			"<leader>tp",
			function()
				if require("livepreview").is_running() then
					vim.cmd("LivePreview close")
				else
					vim.cmd("LivePreview start")
				end
			end,
			desc = "[T]oggle markdown [p]review",
		},
	},
	config = function()
		-- No setup() — `livepreview.setup` exists but is deprecated in favour of this.
		require("livepreview.config").set({
			port = 5500,
			address = "127.0.0.1",
			browser = "default",
			sync_scroll = true,
			-- Only used by `:LivePreview pick`. Match the picker the rest of the config uses;
			-- an empty string would auto-detect and could land on snacks.picker instead.
			picker = "telescope",
		})
	end,
}
