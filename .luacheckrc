-- luacheck config for a Neovim (LuaJIT) configuration.
std = "luajit"
read_globals = { "vim" }

-- Neovim config idioms produce a lot of intentional noise; silence the benign ones.
ignore = {
	"212", -- unused argument (callbacks often ignore args)
	"213", -- unused loop variable
	"122", -- setting a read-only field of a global (vim.*)
	"631", -- line is too long
}

-- Vendored kickstart files are upstream; don't lint them.
exclude_files = {
	"lua/kickstart/",
	"lazy-lock.json",
}
