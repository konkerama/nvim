# Neovim Config Review — Improvements

Review of this kickstart-based config, focused on Go + Terraform/Terragrunt work.

**Severity tags:** 🔴 bug / silent collision · 🟠 redundancy or conflict · 🟡 polish / behavior to reconsider · 🔵 optional addition.

**Star counts are approximate (early 2026 knowledge) and prefixed with `~`.** Verify on GitHub before acting.

---

## 1. Keymap collisions & dead maps 🔴

`lua/custom/keymaps.lua` is `require`d at the very end of `init.lua` (`require("custom")`), so its maps run **last and win** over anything set earlier. That silently kills three maps:

| Key | Loser (dead) | Winner (active) | Fix |
|-----|--------------|-----------------|-----|
| `<leader>q` | `init.lua:192` → diagnostic quickfix list (`vim.diagnostic.setloclist`) | `keymaps.lua:375` → `:q` Quit | Rename one. Quit is fine as `<leader>q`; move the diagnostic list to `<leader>Q` or `<leader>xq`. |
| `<leader>sr` | `grug-far.lua:7` → Search & Replace | `telescope.lua:72` → `builtin.resume` | grug-far still works via `<leader>S`, but its `sr` binding is dead. Pick one — e.g. grug-far on `<leader>sR`. |
| `<leader>ya` | `keymaps.lua:358` → `ggVGy` | `keymaps.lua:359` → `gg"+yG` | Two definitions back-to-back; line 358 never fires. Delete it. |

Also worth noting (not collisions, but smells):
- `<leader>sa` = "Select entire file" (`keymaps.lua:361`) sits inside the `<leader>s` **[S]earch** which-key group — semantic mismatch. Consider `<leader>a` or a different prefix.
- `<leader>Rd` (neotest debug-nearest) and `<leader>dt` (dap-go debug-test, from `kickstart/plugins/debug.lua:44`) do the **same thing** two different ways. Harmless, but pick one mental model.

---

## 2. Redundant / conflicting plugins 🟠

### 2a. `vim-go` fights the modern stack — strongest issue here
`lua/custom/plugins/go.lua` loads `fatih/vim-go` (~16k★) and `charlespascoe/vim-go-syntax`. But Go is **already** fully served by:
- `gopls` (LSP, via `lspconfig.lua`)
- `gofmt` on save (via `conform.lua`)
- `neotest-golang` (tests)
- treesitter `go`/`gomod`/`gosum` parsers (syntax + indent)

vim-go duplicates all of that, and its default `g:go_fmt_autosave = 1` runs **gofmt on save again** — so Go files get formatted by both conform and vim-go. It also wants `:GoInstallBinaries` and ships its own gopls plumbing that can clash with `vim.lsp`.

**Recommendation:** drop `vim-go` entirely. If you miss specific commands (struct-tag add/remove, `:GoImpl`, `:GoFillStruct`), reach for **`ray-x/go.nvim`** (~3.5k★) which is built on top of gopls/treesitter rather than replacing them — or just use gopls code actions. `vim-go-syntax` is also largely redundant with the treesitter `go` parser; keep only if you can point to a concrete highlight it adds.

### 2b. `Comment.nvim` is redundant
`lua/custom/plugins/comment.lua` loads `numToStr/Comment.nvim` (~3.5k★). Neovim has **built-in commenting since 0.10** (`gc`, `gcc`, `gco`, dot-repeat, treesitter-aware `commentstring`). You're on 0.12.2. Remove the plugin; the keymaps are identical.

### 2c. `golangci-lint` is installed but never runs
`lspconfig.lua` force-installs `golangci-lint` via mason-tool-installer, but nothing invokes it: `kickstart.plugins.lint` is commented out (`init.lua:543`) and gopls doesn't run golangci-lint natively. So it's dead weight. Either:
- enable `require("kickstart.plugins.lint")` and add a `golangcilint` linter for `go`, or
- drop the install line if you don't want linting.

### 2d. Git tooling stack is heavy
Active: `vim-fugitive` + `vim-rhubarb` (needed for `:GBrowse`) + `lazygit.nvim` + `gitsigns` + `diffview.nvim`, with `neogit` sitting in `disabled.lua`. That's five overlapping tools. Not wrong, but if `lazygit` is your daily driver, fugitive is mostly there for `:GBrowse` (rhubarb) and `FugitiveHead()` (used by the neo-tree winbar). Worth a conscious "do I use all of these" pass.

### 2e. `diffview.nvim` is loaded but unreachable
`diffview.lua` declares the plugin with no `cmd`/`keys`/`event`, so lazy loads it **eagerly at startup** and there are **no keymaps** to open it (only `:DiffviewOpen`). Either lazy-load it (`cmd = { "DiffviewOpen", "DiffviewFileHistory" }`) and add a keymap, or remove it.

---

## 3. Behavior worth reconsidering 🟡

### 3a. Autosave-on-`InsertLeave` triggers format-on-save 🔴-ish
`keymaps.lua:229` writes the buffer on **every** `InsertLeave`:
```lua
vim.api.nvim_create_autocmd("InsertLeave", { pattern = "*", command = "silent! write" })
```
Every write fires conform's `format_on_save`. Consequences:
- Leaving insert mode in a `.tf`/`.hcl` file runs `terragrunt_hclfmt` synchronously — up to the **4000ms** timeout you set — which can freeze the UI mid-edit.
- It saves (and reformats) half-finished code, creating git churn and moving your cursor.

Consider: save on `BufLeave`/`FocusLost` instead, debounce it, or use a dedicated plugin (e.g. `pocco81/auto-save.nvim` ~1k★, which has built-in debouncing and conditions). At minimum, exclude the slow filetypes.

### 3b. `have_nerd_font = false` → no icons anywhere
`init.lua:94`. With this off, `nvim-web-devicons` is disabled (`telescope.lua:28`), mini.statusline runs icon-less, and lazy/gitsigns use ASCII. If you install a Nerd Font in your terminal and flip this to `true`, the whole UI gets icons for free — biggest visual win for one line.

### 3c. Modeline vs actual style mismatch
`init.lua:583` and `keymaps.lua:4` both end/start with:
```
-- vim: ts=2 sts=2 sw=2 et
```
But these files use **tabs**, and you now enforce tabs via `stylua.toml`. Anyone opening these in vanilla vim gets 2-space-expandtab and will fight stylua on the next `make fmt`. Update the modelines to `ts=4 sw=4 noet` or just delete them.

### 3d. Neo-tree window management is a 230-line bespoke system
`keymaps.lua` lines ~7–227 implement: sidebar focus toggle, git-branch winbar, debounced source refresh, cwd-from-arg, and auto-recreate-editor-pane-if-only-neo-tree-remains. It works, but it's the **single largest complexity/maintenance hotspot** in the config and it's fighting neo-tree's own model with scheduled callbacks on `WinClosed`/`BufEnter`/`TabEnter`. If you ever find it flaky, **`stevearc/oil.nvim`** (~5k★, edit the filesystem as a buffer) or `snacks.nvim`'s explorer sidestep most of this machinery. Not urgent — just flagging where the risk concentrates.

### 3e. `q` → `<nop>`, `Q` → `q`
`keymaps.lua:386-389` disables macro recording on `q`. It's commented, so it's intentional — just be aware it surprises anyone (including future-you) who muscle-memories `q` for macros. Fine to keep.

---

## 4. Gaps & optional additions 🔵

Ordered by fit for your config-tinkering + Go workflow.

| Plugin | Stars (~) | Why it fits |
|--------|-----------|-------------|
| **autopairs** (enable `kickstart.plugins.autopairs`, or `mini.pairs` since you already run mini.nvim) | mini.nvim ~5k | You have no auto-pairing today. `mini.pairs` is one line and you already load mini. |
| **folke/lazydev.nvim** | ~1.7k | Proper completion/types for the Neovim Lua API while editing *this config*. Replaces the hand-rolled `lua_ls` library setup in `lspconfig.lua`. High value for a config you actively tinker with. |
| **folke/trouble.nvim** | ~5.8k | A real diagnostics/quickfix/LSP-references panel. Complements your grep-heavy telescope flow; much nicer than `setloclist` for working through gopls/tflint diagnostics. |
| **nvim-treesitter/nvim-treesitter-textobjects** | ~1.6k | `vif`/`daf`/`]m` function & argument textobjects. You already run treesitter; this makes Go/HCL editing far faster. |
| **folke/flash.nvim** | ~4.5k | Fast in-buffer jump/motion. You have no motion enhancer; pairs well with the no-mouse hjkl ethos. |
| **ray-x/go.nvim** | ~3.5k | *Only if* you drop vim-go but still want struct tags / fill-struct / impl on top of gopls. |
| **stevearc/oil.nvim** | ~5k | *Only if* the neo-tree machinery (3d) becomes a maintenance burden. |

Already-present and good — no change needed: `blink.cmp`, `conform`, `gitsigns`, `which-key`, `mini.ai`/`mini.surround`/`mini.statusline`, `todo-comments`, `guess-indent`, `telescope` (+ fzf-native).

---

## 5. Quick-win checklist

Cheap, high-confidence, low-risk:

- [ ] Resolve the three keymap collisions in §1 (especially `<leader>q`).
- [ ] Remove `Comment.nvim` (§2b) — built-in `gc` covers it.
- [ ] Decide vim-go's fate (§2a) — drop it or accept the double-format/overlap.
- [ ] Wire up or remove `golangci-lint` (§2c).
- [ ] Lazy-load or remove `diffview` (§2e).
- [ ] Fix the two modelines (§3c) so they don't fight stylua.
- [ ] Scope or debounce the `InsertLeave` autosave (§3a).

Medium effort, real payoff:

- [ ] Install a Nerd Font + `have_nerd_font = true` (§3b).
- [ ] Add `mini.pairs` and `lazydev.nvim` (§4).
