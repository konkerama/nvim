-- Custom vim options and autocmds

-- CUSTOM CONFIG:
vim.g.editorconfig = true

-- Do not auto-normalize EOF newlines when writing files.
vim.o.fixendofline = false

local gofmt_on_save = vim.api.nvim_create_augroup("go-fmt-on-save", { clear = true })
vim.api.nvim_create_autocmd("BufWritePre", {
	group = gofmt_on_save,
	pattern = "*.go",
	callback = function(args)
		require("conform").format({
			bufnr = args.buf,
			async = false,
			lsp_format = "fallback",
			formatters = { "gofmt" },
		})
		vim.bo[args.buf].endofline = true
		vim.bo[args.buf].fixendofline = true
	end,
})
