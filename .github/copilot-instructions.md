# Neovim Config Instructions

- If a repository has a `.editorconfig`, respect it instead of adding custom overrides for EOF behavior.
- Outside `.editorconfig` rules, avoid changes that create EOF-only diffs.
- Do not enable format-on-save or save-time rewrite hooks unless the user explicitly requests them.
- Keep changes minimal and consistent with the existing Lua style in this repo.
- When editing `init.lua`, prefer small targeted changes over broad refactors.