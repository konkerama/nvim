# Neovim Config Instructions

- Preserve the existing EOF newline state for existing files. Do not add or remove a final newline unless the user explicitly asks for it.
- Respect `.editorconfig` for indentation, line endings, and other formatting rules, but avoid changes that create EOF-only diffs.
- Do not enable format-on-save or save-time rewrite hooks unless the user explicitly requests them.
- Keep changes minimal and consistent with the existing Lua style in this repo.
- When editing `init.lua`, prefer small targeted changes over broad refactors.