# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What this is

A personal Neovim config forked from **kickstart.nvim**. Despite kickstart's "single small file" philosophy, this fork keeps nearly all real configuration in `init.lua` (~2000 lines). It is heavily customized for **Go** and **Terraform/Terragrunt** workflows.

## Layout

- `init.lua` — the config. Plugin specs (lazy.nvim), LSP, formatting, and all custom keymaps/functions live here. Read it top-to-bottom to understand behavior; there is no separate module per concern.
- `lua/kickstart/plugins/*.lua` — optional kickstart modules. Active ones are `require`d near line 1144: `debug`, `indent_line`, `neo-tree`, `gitsigns`. `lint` and `autopairs` exist but are commented out.
- `lua/custom/plugins/init.lua` — kickstart's drop-in extension point. **Currently empty** (`return {}`) and the `{ import = 'custom.plugins' }` line is commented out, so files here are NOT loaded. To add a plugin, either add a spec inline in `init.lua` (the pattern this fork actually uses) or re-enable the custom import.
- `lazy-lock.json` — committed plugin lockfile. Changing it means a plugin version bump.
- `.github/copilot-instructions.md` — editing rules; see below.

## Plugin management

lazy.nvim, bootstrapped inside `init.lua` (line ~261). Leader is `<Space>`; set before lazy loads, so leader-prefixed plugin `keys` are correct.

There is no build/lint/test command for this repo — it's a config. To validate changes:

```sh
nvim --headless "+Lazy! sync" +qa     # install/update plugins, surface spec errors
nvim --headless +qa                   # load config headless; nonzero/stderr = startup error
```

Inside Neovim: `:Lazy` (plugins), `:Mason` (tools/LSPs), `:checkhealth`, `:ConformInfo` (formatter resolution). `lua/kickstart/health.lua` backs `:checkhealth kickstart`.

## LSP

Uses native Neovim 0.11 APIs (`vim.lsp.config` + `vim.lsp.enable`), not the old lspconfig setup calls. Servers are defined in a `servers` table (~line 749); keys feed `mason-tool-installer` for auto-install. Configured: `gopls`, `terraformls`, `tflint`, `yamlls`, `lua_ls`. Extra CLI tools force-installed: `goimports`, `gofumpt`, `golangci-lint`, `actionlint`.

Terraform/Terragrunt has nontrivial custom logic: a custom `root_dir` walking up for `terragrunt.hcl`/`*.tf`, a `publishDiagnostics` handler that filters out noise warnings (`terraform_warning_filters`), and `on_attach` that nils semantic tokens.

## Formatting (conform.nvim)

`format_on_save` is **enabled** for everything except `c`/`cpp`, with `lsp_format = "fallback"`. Per-filetype formatters: `lua→stylua`, `go/gomod/gowork→gofmt`, `terraform→terraform_fmt`, `hcl/terragrunt→terragrunt_hclfmt`. `<leader>f` formats manually; `<leader>W` (`:noa w`) saves bypassing format autocmds.

## Custom keymaps & functions (bottom of init.lua, ~line 1850+)

These are hand-written, not from a plugin — preserve their behavior when editing:
- **Terminal** (toggleterm): `<leader>t` focus toggle, `<C-\>` visibility toggle (works in normal + terminal mode). Logic in `toggle_terminal_focus`/`toggle_terminal_visibility`.
- **Git browse-causing-commit**: `<leader>gB` runs `git blame` on the current line, resolves the commit, and opens it via fugitive's `GBrowse`. Handles the gitsigns-blame pane by finding the source buffer. `<leader>gg`→LazyGit.
- **Go indentation autocmd**: forces real tabs (`expandtab=false`, ts/sw=4) for go filetypes — don't "fix" this to spaces.
- Folding uses treesitter (`foldexpr=v:lua.vim.treesitter.foldexpr()`, `foldlevel=99`).
- `q` is mapped to `<nop>` and `Q` records macros (swapped to prevent accidental recording).

## Go test running (neotest + neotest-golang, gotestsum runner)

`ft = { "go" }`. Keymaps under `<leader>R*`: `Rn` nearest, `Rf` file, `Rp` package, `Ra` all (resolves go.work/go.mod root), `Rl` last, `Ro` output, `Rs` summary, `Rd` debug-nearest (DAP).

## Completion / AI

blink.cmp (`default` preset, `<C-y>` accept) + LuaSnip. Copilot via `copilot.lua` with inline suggestions (`<C-y>` accept, `<M-w>`/`<M-j>` word/line); an autocmd hides Copilot suggestions while the blink menu is open. Several AI plugins (CopilotChat, CodeCompanion) are present but commented out.

## Editing rules (from .github/copilot-instructions.md)

- Respect `.editorconfig` if present (none currently); otherwise avoid EOF-only diffs and don't add EOF-preservation autocmds.
- Do NOT add format-on-save or save-time rewrite hooks unless explicitly asked.
- Keep changes small and targeted in `init.lua` — prefer surgical edits over refactors; match the existing Lua style.
- For Telescope, scope hidden-file searches with `search_dirs` (e.g. `{ ".", ".github" }`) rather than broad hidden toggles that expose `.git`.
- Avoid `<leader>` mappings in terminal mode (leader is space → input latency in LazyGit); keep terminal toggles on `<C-\>`-style control mappings.
- When formatting won't trigger, verify filetype mapping and formatter executable before adding autocmd logic; validate with a headless save repro.
