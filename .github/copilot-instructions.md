# Neovim Config Instructions

- If a repository has a `.editorconfig`, respect it instead of adding custom overrides for EOF behavior.
- Outside `.editorconfig` rules, avoid changes that create EOF-only diffs.
- Do not enable format-on-save or save-time rewrite hooks unless the user explicitly requests them.
- Do not use legacy `EditorConfig_*` globals for Neovim EOF behavior; they are not the control surface for Neovim 0.11 built-in EditorConfig.
- Avoid broad non-Go EOF preservation autocmds; they interact badly with other save hooks and are hard to reason about.
- For Go, prefer a deterministic Go-only save path (`gofmt`) when the user explicitly wants strict gofmt behavior.
- When formatting does not trigger, verify the exact filetype mapping and formatter executable availability before adding more autocmd logic.
- Be careful with lazy-loading formatter plugins on `BufWritePre`; first-save behavior can be misleading.
- Validate formatting behavior with a headless save repro before adding additional complexity.
- Keep changes minimal and consistent with the existing Lua style in this repo.
- When editing `init.lua`, prefer small targeted changes over broad refactors.