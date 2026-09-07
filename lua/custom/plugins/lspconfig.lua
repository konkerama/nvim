-- CUSTOM: Authoritative nvim-lspconfig config and spec. Lives here (not init.lua) so all of
-- the LSP setup is in one place. Sections marked CUSTOM are additions on top of the upstream
-- kickstart defaults that the rest mirrors.
-- LSP Plugins
---@module 'lazy'
---@type LazySpec
return {
	-- Main LSP Configuration
	"neovim/nvim-lspconfig",
	dependencies = {
		-- Automatically install LSPs and related tools to stdpath for Neovim
		-- Mason must be loaded before its dependents so we need to set it up here.
		-- NOTE: `opts = {}` is the same as calling `require('mason').setup({})`
		{
			"mason-org/mason.nvim",
			---@module 'mason.settings'
			---@type MasonSettings
			---@diagnostic disable-next-line: missing-fields
			opts = {},
		},
		-- Maps LSP server names between nvim-lspconfig and Mason package names.
		"mason-org/mason-lspconfig.nvim",
		"WhoIsSethDaniel/mason-tool-installer.nvim",

		-- Useful status updates for LSP.
		{ "j-hui/fidget.nvim", opts = {} },

		-- Allows extra capabilities provided by blink.cmp
		"saghen/blink.cmp",
	},
	config = function()
		-- Brief aside: **What is LSP?**
		--
		-- LSP is an initialism you've probably heard, but might not understand what it is.
		--
		-- LSP stands for Language Server Protocol. It's a protocol that helps editors
		-- and language tooling communicate in a standardized fashion.
		--
		-- In general, you have a "server" which is some tool built to understand a particular
		-- language (such as `gopls`, `lua_ls`, `rust_analyzer`, etc.). These Language Servers
		-- (sometimes called LSP servers, but that's kind of like ATM Machine) are standalone
		-- processes that communicate with some "client" - in this case, Neovim!
		--
		-- LSP provides Neovim with features like:
		--  - Go to definition
		--  - Find references
		--  - Autocompletion
		--  - Symbol Search
		--  - and more!
		--
		-- Thus, Language Servers are external tools that must be installed separately from
		-- Neovim. This is where `mason` and related plugins come into play.
		--
		-- If you're wondering about lsp vs treesitter, you can check out the wonderfully
		-- and elegantly composed help section, `:help lsp-vs-treesitter`

		--  This function gets run when an LSP attaches to a particular buffer.
		--    That is to say, every time a new file is opened that is associated with
		--    an lsp (for example, opening `main.rs` is associated with `rust_analyzer`) this
		--    function will be executed to configure the current buffer
		vim.api.nvim_create_autocmd("LspAttach", {
			group = vim.api.nvim_create_augroup("kickstart-lsp-attach", { clear = true }),
			callback = function(event)
				-- NOTE: Remember that Lua is a real programming language, and as such it is possible
				-- to define small helper and utility functions so you don't have to repeat yourself.
				--
				-- In this case, we create a function that lets us more easily define mappings specific
				-- for LSP related items. It sets the mode, buffer and description for us each time.
				local map = function(keys, func, desc, mode)
					mode = mode or "n"
					vim.keymap.set(mode, keys, func, { buffer = event.buf, desc = "LSP: " .. desc })
				end

				-- Rename the variable under your cursor.
				--  Most Language Servers support renaming across files, etc.
				map("grn", vim.lsp.buf.rename, "[R]e[n]ame")

				-- Execute a code action, usually your cursor needs to be on top of an error
				-- or a suggestion from your LSP for this to activate.
				map("gra", vim.lsp.buf.code_action, "[G]oto Code [A]ction", { "n", "x" })

				-- CUSTOM: Goto Definition. Most servers (gopls, terraform-ls, lua_ls) implement
				-- textDocument/definition; gate behind capability check so the map only
				-- appears on supporting buffers. Note: `grt` (Neovim 0.11 default) maps to
				-- type_definition, which HCL servers don't implement — use grd on .tf files
				-- to jump from var.x to the matching variable "x" block instead.
				local client = vim.lsp.get_client_by_id(event.data.client_id)
				if client and client:supports_method("textDocument/definition", event.buf) then
					map("grd", vim.lsp.buf.definition, "[G]oto [D]efinition")
				end

				-- WARN: This is not Goto Definition, this is Goto Declaration.
				--  For example, in C this would take you to the header.
				map("grD", vim.lsp.buf.declaration, "[G]oto [D]eclaration")
				-- CUSTOM: open declaration in a vertical split
				map("grV", function()
					vim.cmd.vsplit()
					vim.lsp.buf.declaration()
				end, "[G]oto [V]split [D]eclaration")

				-- The following two autocommands are used to highlight references of the
				-- word under your cursor when your cursor rests there for a little while.
				--    See `:help CursorHold` for information about when this is executed
				--
				-- When you move your cursor, the highlights will be cleared (the second autocommand).
				if client and client:supports_method("textDocument/documentHighlight", event.buf) then
					local highlight_augroup = vim.api.nvim_create_augroup("kickstart-lsp-highlight", { clear = false })
					vim.api.nvim_create_autocmd({ "CursorHold", "CursorHoldI" }, {
						buffer = event.buf,
						group = highlight_augroup,
						callback = vim.lsp.buf.document_highlight,
					})

					vim.api.nvim_create_autocmd({ "CursorMoved", "CursorMovedI" }, {
						buffer = event.buf,
						group = highlight_augroup,
						callback = vim.lsp.buf.clear_references,
					})

					vim.api.nvim_create_autocmd("LspDetach", {
						group = vim.api.nvim_create_augroup("kickstart-lsp-detach", { clear = true }),
						callback = function(event2)
							vim.lsp.buf.clear_references()
							vim.api.nvim_clear_autocmds({ group = "kickstart-lsp-highlight", buffer = event2.buf })
						end,
					})
				end

				-- The following code creates a keymap to toggle inlay hints in your
				-- code, if the language server you are using supports them
				--
				-- This may be unwanted, since they displace some of your code
				if client and client:supports_method("textDocument/inlayHint", event.buf) then
					map("<leader>th", function()
						vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled({ bufnr = event.buf }))
					end, "[T]oggle Inlay [H]ints")
				end
			end,
		})

		-- Enable the following language servers
		--  Feel free to add/remove any LSPs that you want here. They will automatically be installed.
		--  See `:help lsp-config` for information about keys and how to configure
		-- CUSTOM: All servers below (gopls, terraformls, tflint, yamlls) are additions on top of the
		-- kickstart base (stylua, lua_ls). The terraform/yaml helpers below are also custom.
		-- CUSTOM: terraform/tflint warning filters (suppress noisy diagnostics)
		local terraform_warning_filters = {
			"declared but not used",
			"variable has no type",
			"has no type",
		}

		-- NOTE: Neovim 0.11's native vim.lsp.config calls root_dir as
		-- `function(bufnr, on_dir)` and requires `on_dir(path)` to be called;
		-- a returned value is silently ignored and the server never starts.
		-- (This previously `return`ed the dir old-lspconfig style, so
		-- terraform-ls/tflint never attached at all on this config.)
		local function terraform_root_dir(bufnr, on_dir)
			-- Anchor to the git repository root.
			-- This forces all modules to share ONE workspace and ONE LSP process.
			local root = vim.fs.root(bufnr, { ".git" })

			if root then
				return on_dir(root)
			end

			-- Fallback for files outside of a git repository
			local path = vim.api.nvim_buf_get_name(bufnr)
			if not path or path == "" then
				path = vim.uv.cwd()
			end

			local stat = vim.uv.fs_stat(path)
			local dir = (stat and stat.type == "file") and vim.fs.dirname(path) or path

			return on_dir(dir)
		end

		local function terraform_on_attach(client, _)
			-- Treesitter handles highlighting; disabling semantic tokens reduces terraform-ls churn.
			client.server_capabilities.semanticTokensProvider = nil
		end

		local default_publish_diagnostics = vim.lsp.handlers["textDocument/publishDiagnostics"]
		local function terraform_publish_diagnostics(err, result, ctx, config)
			if result and result.diagnostics then
				result.diagnostics = vim.tbl_filter(function(diagnostic)
					local message = (diagnostic.message or ""):lower()
					local is_ignored_warning = false

					for _, filter in ipairs(terraform_warning_filters) do
						if message:find(filter, 1, true) then
							is_ignored_warning = true
							break
						end
					end

					return not is_ignored_warning
				end, result.diagnostics)
			end

			return default_publish_diagnostics(err, result, ctx, config)
		end

		---@type table<string, vim.lsp.Config>
		local servers = {
			-- clangd = {},
			gopls = {},
			-- pyright = {},
			-- rust_analyzer = {},
			--
			-- Some languages (like typescript) have entire language plugins that can be useful:
			--    https://github.com/pmizio/typescript-tools.nvim
			--
			-- But for many setups, the LSP (`ts_ls`) will work just fine
			-- ts_ls = {},

			-- Terraform / Terragrunt
			terraformls = {
				-- CUSTOM: terraform-ls writes its job-scheduler trace to stderr by default, and
				-- Neovim records every LSP stderr line into lsp.log at ERROR level, so the log
				-- grew unbounded (2.4GB). -log-file diverts those logs away from stderr.
				cmd = { "terraform-ls", "serve", "-log-file", "/dev/null" },
				root_dir = terraform_root_dir,
				on_attach = terraform_on_attach,
				handlers = {
					["textDocument/publishDiagnostics"] = terraform_publish_diagnostics,
				},
			},
			tflint = {
				root_dir = terraform_root_dir,
				handlers = {
					["textDocument/publishDiagnostics"] = terraform_publish_diagnostics,
				},
			},

			-- YAML / GitHub Actions
			yamlls = {
				settings = {
					yaml = {
						validate = true,
						hover = true,
						completion = true,
						schemaStore = {
							enable = true,
							url = "https://www.schemastore.org/api/json/catalog.json",
						},
						schemas = {
							["https://json.schemastore.org/github-workflow.json"] = "/.github/workflows/*",
							["https://json.schemastore.org/github-action.json"] = "/action.{yml,yaml}",
						},
					},
				},
			},

			stylua = {}, -- Used to format Lua code

			-- Special Lua Config, as recommended by neovim help docs
			lua_ls = {
				on_init = function(client)
					if client.workspace_folders then
						local path = client.workspace_folders[1].name
						if
							path ~= vim.fn.stdpath("config")
							and (vim.uv.fs_stat(path .. "/.luarc.json") or vim.uv.fs_stat(path .. "/.luarc.jsonc"))
						then
							return
						end
					end

					client.config.settings.Lua = vim.tbl_deep_extend("force", client.config.settings.Lua, {
						runtime = {
							version = "LuaJIT",
							path = { "lua/?.lua", "lua/?/init.lua" },
						},
						workspace = {
							checkThirdParty = false,
							-- NOTE: this is a lot slower and will cause issues when working on your own configuration.
							--  See https://github.com/neovim/nvim-lspconfig/issues/3189
							library = vim.tbl_extend("force", vim.api.nvim_get_runtime_file("", true), {
								"${3rd}/luv/library",
								"${3rd}/busted/library",
							}),
						},
					})
				end,
				settings = {
					Lua = {},
				},
			},
		}

		-- Ensure the servers and tools above are installed
		--
		-- To check the current status of installed tools and/or manually install
		-- other tools, you can run
		--    :Mason
		--
		-- You can press `g?` for help in this menu.
		local ensure_installed = vim.tbl_keys(servers or {})
		vim.list_extend(ensure_installed, {
			-- You can add other tools here that you want Mason to install
			"goimports",
			"gofumpt",
			"golangci-lint",
			"actionlint",
		})

		require("mason-tool-installer").setup({ ensure_installed = ensure_installed })

		for name, server in pairs(servers) do
			vim.lsp.config(name, server)
			vim.lsp.enable(name)
		end
	end,
}
