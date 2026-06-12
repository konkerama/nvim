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
			local disable_filetypes = { c = true, cpp = true }
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
			terraform = { "terraform_fmt" },
			["terraform-vars"] = { "terraform_fmt" },
			hcl = { "terragrunt_hclfmt" },
			terragrunt = { "terragrunt_hclfmt" },
		},
	},
}
