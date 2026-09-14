-- CUSTOM: snacks.nvim is pulled in for ONE module: `image`. It renders fenced mermaid
-- blocks (and regular markdown images) inline in the buffer using Ghostty's kitty
-- graphics protocol, shelling out to `mmdc` for mermaid and `magick` for anything that
-- is not already a PNG. Every other snacks module stays disabled.
---@module 'lazy'
---@type LazySpec
return {
	"folke/snacks.nvim",
	priority = 1000,
	lazy = false,
	init = function()
		-- Under tmux, snacks skips escape-sequence probing and asks tmux for the client
		-- terminal name instead, because extended keys swallow the response and
		-- TermResponse never fires (folke/snacks.nvim#2332). That workaround is gated on
		-- `tmux show -g extended-keys` ending in " on" — this setup uses `always`, so the
		-- gate never matches, the probe returns nothing, and snacks leaves the terminal as
		-- "unknown". Ghostty then never matches its entry in snacks' environments table,
		-- unicode placeholders are never used, and images get drawn at the terminal cursor
		-- instead of in the buffer: the diagram lands on top of Neo-tree while the space
		-- reserved for it stays blank.
		--
		-- `SNACKS_<ENV>` short-circuits that detection (snacks/image/terminal.lua, M.env).
		-- The `opts.image.env` field looks like it would do this but nothing reads it.
		if vim.env.TMUX then
			vim.env.SNACKS_GHOSTTY = "1"
		end
	end,
	---@type snacks.Config
	opts = {
		image = {
			doc = {
				-- Explicit even though it matches the default: snacks silently downgrades
				-- `inline` to a float when it can't detect unicode-placeholder support,
				-- which is the first thing to check if diagrams stop appearing under tmux.
				inline = true,
				float = true,
				-- Cells, not pixels. The C4 diagrams are wide `graph LR` canvases, so give
				-- them width and cap the height — 40 rows swallowed most of the pane.
				max_width = 100,
				max_height = 30,
				-- snacks anchors an unconcealed image to the block's CLOSING fence and draws
				-- it as virt_lines there, so a block taller than the window renders nothing
				-- until you scroll all the way to the end of it — and the C4 blocks are ~50
				-- lines. Concealing overlays the image onto the block's own lines instead,
				-- anchored at the opening fence. Moving the cursor into the block still
				-- un-conceals it, so the mermaid source stays editable.
				-- Charts only: math is disabled below, and upstream still calls this
				-- experimental.
				conceal = function(_, type)
					return type == "chart"
				end,
			},
			convert = {
				-- Same as snacks' default, plus an explicit source width. mmdc otherwise
				-- renders these at a size that turns to mush once scaled into the cell box;
				-- 2800px is what the c4-confluence skill uses for the same diagrams.
				mermaid = function()
					local theme = vim.o.background == "light" and "neutral" or "dark"
					-- stylua: ignore
					return { "-i", "{src}", "-o", "{file}", "-b", "transparent", "-t", theme, "-s", "{scale}", "--width", "2800" }
				end,
			},
			-- LaTeX/typst rendering shells out to `tectonic`/`typst`; neither is installed.
			math = { enabled = false },
		},
	},
}
