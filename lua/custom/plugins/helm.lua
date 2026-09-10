-- CUSTOM: helm chart support. vim-helm supplies the filetype detection (ft=helm for chart
-- templates and *.tpl, yaml.helm-values for values files) plus the {{/* */}} commentstring, which
-- also keeps yamlls off Go-templated YAML -- its parser reads `{{ }}` as a flow collection and
-- floods the buffer with "Block collections are not allowed within flow collections".
-- Highlighting is treesitter's: gotmpl parser + the combined yaml injection in
-- after/queries/gotmpl/injections.scm. vim-helm's own syntax file is left unused; its legacy
-- groups clash with the treesitter palette (yamlPlainScalar has no color at all).
---@module 'lazy'
---@type LazySpec
return {
	"towolf/vim-helm",
	ft = "helm",
	init = function()
		vim.api.nvim_create_autocmd("FileType", {
			pattern = "helm",
			callback = function(args)
				-- vim-helm flips ft yaml -> helm *after* treesitter attached the yaml parser,
				-- which errors on `{{ }}`; restart on gotmpl. Scheduled so it lands after lazy's
				-- loader and the generic treesitter FileType autocmd in treesitter.lua.
				vim.schedule(function()
					if not vim.api.nvim_buf_is_valid(args.buf) then
						return
					end
					pcall(vim.treesitter.stop, args.buf)
					pcall(vim.treesitter.start, args.buf, "gotmpl")
					-- gotmpl ships no indents.scm, so treesitter.lua's indentexpr rewrites
					-- template lines to tabs on `=`, and an empty indentexpr is worse still (`=`
					-- then falls back to internal C indenting and flattens the chart). "-1" means
					-- "keep the current indent"; 'autoindent' still carries indent to new lines.
					vim.bo[args.buf].indentexpr = "-1"
				end)
			end,
		})
	end,
}
