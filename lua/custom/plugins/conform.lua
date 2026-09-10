-- CUSTOM: Extends the kickstart conform spec with additional formatters and tweaks.
-- lazy.nvim deep-merges opts, so the base spec in init.lua provides the kickstart defaults.
---@module 'lazy'
---@type LazySpec
return {
	"stevearc/conform.nvim",
	-- Load earlier so formatters are ready when a file is opened, not just on write.
	event = { "BufReadPre", "BufNewFile" },
	opts = {
		format_on_save = function(bufnr)
			-- CUSTOM: helm templates are Go templates; lsp_format fallback would let a formatter rewrite them.
			local disable_filetypes = { c = true, cpp = true, helm = true }
			if disable_filetypes[vim.bo[bufnr].filetype] then
				return nil
			else
				return {
					timeout_ms = 4000,
					lsp_format = "fallback",
				}
			end
		end,
		formatters_by_ft = {
			go = { "gofmt" },
			gomod = { "gofmt" },
			gowork = { "gofmt" },
			-- CUSTOM: user runs OpenTofu, not terraform.
			terraform = { "tofu_fmt" },
			["terraform-vars"] = { "tofu_fmt" },
			hcl = { "terragrunt_hclfmt" },
			terragrunt = { "terragrunt_hclfmt" },
		},
		formatters = {
			-- CUSTOM: snap-confined tofu's `fmt -` (stdin, conform's default) exits 2 and
			-- writes nothing. File mode works, so force it.
			tofu_fmt = {
				command = "tofu",
				args = { "fmt", "$FILENAME" },
				stdin = false,
			},
		},
	},
}
