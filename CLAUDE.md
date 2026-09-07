# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What this is

A personal Neovim config forked from **kickstart.nvim**, heavily customized for **Go** and **Terraform/Terragrunt/OpenTofu** workflows. Unlike upstream kickstart's single-file philosophy, this fork has been split: `init.lua` keeps only the kickstart base, and everything custom lives under `lua/custom/`.

## Layout

- `init.lua` (~600 lines) — options, base keymaps, the lazy.nvim bootstrap, and the kickstart plugin specs that are still configured inline (gitsigns, which-key, conform base, blink.cmp, tokyonight, todo-comments, mini.nvim, guess-indent). Ends with `require("custom")`.
- `lua/custom/init.lua` — loads `custom.options` then `custom.keymaps`.
- `lua/custom/options.lua` — non-plugin options and autocmds (EOF behavior, Go EOF fix, `*.tf`/`*.tfvars` → `terraform` filetype).
- `lua/custom/keymaps.lua` (~400 lines) — hand-written keymaps, functions, and autocmds. The Neo-tree sidebar logic, git-browse helpers, autosave, folding, and Go indentation all live here.
- `lua/custom/plugins/*.lua` — one file per plugin. **This directory is loaded** via `{ import = "custom.plugins" }` in `init.lua`; it is the place to add a plugin.
- `lua/kickstart/plugins/*.lua` — optional kickstart modules. Active: `debug`, `indent_line`, `lint`, `neo-tree`, `gitsigns`. `autopairs` is commented out (mini.pairs is used instead).
- `lazy-lock.json` — committed plugin lockfile (43 plugins). Changing it means a plugin version bump.
- `.github/copilot-instructions.md` — editing rules; see below.

Two files carry `opts` for a plugin also specced in `init.lua` (lazy.nvim deep-merges them): `custom/plugins/conform.lua` and `custom/plugins/which-key.lua`. Check both places before concluding a setting is absent.

## Plugin management

lazy.nvim, bootstrapped inside `init.lua`. Leader is `<Space>`, set before lazy loads so leader-prefixed plugin `keys` resolve correctly.

There is no build/lint/test command — it's a config. To validate changes:

```sh
nvim --headless "+Lazy! sync" +qa     # install/update plugins, surface spec errors
nvim --headless +qa                   # load config headless; nonzero/stderr = startup error
```

Inside Neovim: `:Lazy`, `:Mason`, `:checkhealth`, `:ConformInfo` (formatter resolution). `lua/kickstart/health.lua` backs `:checkhealth kickstart`.

## LSP (`lua/custom/plugins/lspconfig.lua`)

Native Neovim 0.11+ APIs (`vim.lsp.config` + `vim.lsp.enable`), not the old lspconfig setup calls. Servers live in a `servers` table whose keys feed `mason-tool-installer`: `gopls`, `terraformls`, `tflint`, `yamlls`, `lua_ls`, `stylua`. Extra tools force-installed: `goimports`, `gofumpt`, `golangci-lint`, `actionlint`.

Terraform specifics, all custom:
- `terraform_root_dir` anchors to the **git repository root** so every module shares one workspace and one LSP process. It must call `on_dir(path)` — a returned value is silently ignored under the 0.11 API and the server never starts.
- `terraform_publish_diagnostics` filters noise warnings listed in `terraform_warning_filters`.
- `terraform_on_attach` nils semantic tokens (treesitter handles highlighting).
- `terraformls` runs with `-log-file /dev/null`. terraform-ls writes its job-scheduler trace to stderr, and Neovim records every LSP stderr line into `lsp.log` at ERROR level, which grew the log to 2.4GB. Do not remove this flag. (`tflint` is still mildly chatty on stderr but at far lower volume.)

`grd` is Goto Definition (capability-gated), `grV`/`grv` open declaration/definition in a vertical split, `<leader>th` toggles inlay hints. Telescope binds `grr`/`gri`/`grd`/`grt`/`gO`/`gW` on LspAttach in its own file.

## Formatting (conform.nvim)

Split between `init.lua` (kickstart base: `notify_on_error`, `lua → stylua`, `<leader>f`) and `lua/custom/plugins/conform.lua` (the real config). `format_on_save` is **enabled** for everything except `c`/`cpp`, with `timeout_ms = 4000` and `lsp_format = "fallback"`.

Per-filetype: `go/gomod/gowork → gofmt`, `terraform`/`terraform-vars` → **`tofu_fmt`** (this user runs OpenTofu, not terraform), `hcl`/`terragrunt` → `terragrunt_hclfmt`. `tofu_fmt` is a custom formatter definition with `stdin = false` — snap-confined tofu's `fmt -` exits 2 and writes nothing.

`<leader>f` formats manually; `<leader>W` (`:noa w`) saves bypassing format autocmds.

## Filetypes

- `*.tf` / `*.tfvars` → `terraform` (autocmd in `custom/options.lua`).
- `*.hcl` → **`terragrunt`**, a distinct filetype registered to the `hcl` treesitter parser (`custom/plugins/treesitter.lua`). Conform's `terragrunt` entry and the autosave skip list both key off this.
- `vim.o.fixendofline = false` globally, with a Go-only `BufWritePre` autocmd restoring `endofline`/`fixendofline` so gofmt's final newline survives.

## Custom keymaps & functions (`lua/custom/keymaps.lua`)

Hand-written, not from a plugin — preserve their behavior when editing:
- **Neo-tree sidebar**: `<leader>e` toggles focus between the left tree and the editor window (falls back to the widest non-tree window). `\` reveals/closes the tree. A winbar shows the Fugitive git branch, refreshed on FileType/BufEnter/DirChanged/FocusGained/TermClose and on `FugitiveChanged`. `ensure_editor_pane_with_neotree` recreates an editor pane if the tree is the only window left. On `VimEnter`, cwd is set from the start argument's project root and the tree is opened.
- **Autosave**: `InsertLeave` writes the buffer, skipping `terraform`/`terragrunt`/`hcl` (their formatters can block up to conform's 4s timeout).
- **Git browse-causing-commit**: `<leader>gB` blames the current line, resolves the commit, and opens it via fugitive's `GBrowse`. Handles the gitsigns-blame pane by finding the source buffer. `<leader>gb` plain `GBrowse` (normal + visual).
- **Go indentation autocmd**: forces real tabs (`expandtab=false`, ts/sw=4) for go filetypes — don't "fix" this to spaces.
- Folding uses treesitter (`foldexpr=v:lua.vim.treesitter.foldexpr()`, `foldlevel=99`).
- `q` is mapped to `<nop>` and `Q` records macros (swapped to prevent accidental recording).
- Whole-file ops `<leader>ya`/`da`/`sa`; no-register variants `<leader>rw`/`dw`/`rl` and `x`; `jk` exits insert mode; `<C-d>`/`<C-u>` keep the cursor centered.

There is **no terminal plugin** — toggleterm was removed. Git TUI work goes through LazyGit (`<leader>gg`).

## Leader-key map

`<leader>s` search (Telescope) · `<leader>g` git · `<leader>h` git hunk (gitsigns) · `<leader>t` toggle · `<leader>d` debug (DAP) · `<leader>R` run tests (neotest) · `<leader>x` Trouble · `gs` mini.surround · `gr` LSP actions. Groups are declared across `init.lua` and `custom/plugins/which-key.lua`.

## Go test running (neotest + neotest-golang, gotestsum runner)

`ft = { "go" }`. Keymaps under `<leader>R*`: `Rn` nearest, `Rf` file, `Rp` package, `Ra` all (resolves go.work/go.mod/.git root), `Rl` last, `Ro` output, `Rs` summary, `Rd` debug-nearest (DAP). DAP itself is `<leader>d*` from `kickstart/plugins/debug.lua`.

## Linting (`lua/kickstart/plugins/lint.lua`)

`golangcilint` for Go, `actionlint` scoped to `.github/workflows/*.{yml,yaml}`. Triggered on `BufReadPost`/`BufWritePost` only — **not** `InsertLeave`/`BufEnter`, because golangci-lint runs over the whole package. The golangcilint builtin is re-`require`d at lint time so its args resolve after Mason's bin is on `$PATH`; without that it exits with the issue count.

## Treesitter (`lua/custom/plugins/treesitter.lua`)

`main` branch, `lazy = false`, parsers installed into `stdpath("data")/lazy/nvim-treesitter`. Parser list adds go/gomod/gosum/gotmpl/hcl/terraform/yaml on top of the kickstart defaults. A `BufWritePost` autocmd resets highlighting on `*.tf,*.tfvars,*.hcl,*.yml,*.yaml` because conform rewrites the whole buffer; `<leader>tH` is the manual escape hatch (capital H — `<leader>th` is the LSP inlay-hint toggle). Textobjects (`af`/`if`/`ac`/`ic`/`aa`/`ia`) and moves (`]m`/`[m`/`]]`/`[[`) come from nvim-treesitter-textobjects.

## Completion / editing plugins

blink.cmp (`default` preset, `<C-y>` accept) + LuaSnip, with `lazydev` as a completion source for the Neovim Lua API. **Copilot has been removed** — there are no AI plugins in this config.

mini.nvim provides `mini.ai`, `mini.surround` (remapped to a `gs` prefix so `s` stays free), `mini.pairs`, and `mini.statusline`. flash.nvim owns `s`/`S`/`r`/`R` for jumps. Other additions: trouble.nvim (`<leader>x*`), diffview (`<leader>gd` toggle, `<leader>gH` file history), grug-far (`<leader>sR` / `<leader>S`), render-markdown, fidget.

## Editing rules (from .github/copilot-instructions.md)

- Respect `.editorconfig` if present (none currently); otherwise avoid EOF-only diffs and don't add EOF-preservation autocmds.
- Do NOT add format-on-save or save-time rewrite hooks unless explicitly asked.
- Keep changes small and targeted — prefer surgical edits over refactors; match the existing Lua style (tabs in `lua/custom/`, two spaces in the untouched `lua/kickstart/` files).
- For Telescope, scope hidden-file searches with `search_dirs` (e.g. `{ ".", ".github" }`) rather than broad hidden toggles that expose `.git`.
- Avoid `<leader>` mappings in terminal mode (leader is space → input latency in LazyGit).
- When formatting won't trigger, verify filetype mapping and formatter executable before adding autocmd logic; validate with a headless save repro.
