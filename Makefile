# Authored Lua surface (vendored lua/kickstart/* is upstream and excluded).
LUA_SRC := init.lua lua/custom

.PHONY: fmt fmt-check lint smoke check

## Format authored Lua in place.
fmt:
	stylua $(LUA_SRC)

## Verify formatting without writing (used by CI).
fmt-check:
	stylua --check $(LUA_SRC)

## Static analysis: undefined globals, unused locals, syntax (used by CI).
lint:
	luacheck $(LUA_SRC)

## Load the real config headless to catch load/spec/runtime-config errors.
## Run before pushing. May install plugins on first run (needs network + a C compiler),
## so it is intentionally NOT part of CI.
smoke:
	nvim --headless "+qa"

## Everything that runs without Neovim. This is what CI gates on.
check: fmt-check lint
