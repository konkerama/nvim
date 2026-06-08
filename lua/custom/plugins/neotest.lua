---@module 'lazy'
---@type LazySpec
return {
	"nvim-neotest/neotest",
	ft = { "go" },
	dependencies = {
		"nvim-neotest/nvim-nio",
		"nvim-lua/plenary.nvim",
		"antoinemadec/FixCursorHold.nvim",
		"nvim-treesitter/nvim-treesitter",
		{
			"fredrikaverpil/neotest-golang",
			version = "*",
			build = function()
				vim.system({ "go", "install", "gotest.tools/gotestsum@latest" }):wait()
			end,
		},
	},
	keys = {
		{
			"<leader>Rn",
			function()
				require("neotest").run.run()
			end,
			desc = "Run [N]earest test",
		},
		{
			"<leader>Rf",
			function()
				require("neotest").run.run(vim.fn.expand("%"))
			end,
			desc = "Run current test [F]ile",
		},
		{
			"<leader>Rp",
			function()
				require("neotest").run.run(vim.fn.expand("%:p:h"))
			end,
			desc = "Run current [P]ackage tests",
		},
		{
			"<leader>Ra",
			function()
				local file_path = vim.fn.expand("%:p")
				local root = vim.fs.root(file_path, { "go.work", "go.mod", ".git" }) or vim.fn.getcwd()
				require("neotest").run.run(root)
			end,
			desc = "Run [A]ll tests",
		},
		{
			"<leader>Rl",
			function()
				require("neotest").run.run_last()
			end,
			desc = "Run [L]ast test",
		},
		{
			"<leader>Ro",
			function()
				require("neotest").output.open({ last_run = true, enter = true, auto_close = true })
			end,
			desc = "Open last test [O]utput",
		},
		{
			"<leader>Rs",
			function()
				require("neotest").summary.toggle()
			end,
			desc = "Toggle test [S]ummary",
		},
		{
			"<leader>Rd",
			function()
				require("neotest").run.run({ suite = false, strategy = "dap" })
			end,
			desc = "[D]ebug nearest test",
		},
	},
	config = function()
		local neotest_ns = vim.api.nvim_create_namespace("neotest")
		vim.diagnostic.config({
			virtual_text = {
				format = function(diagnostic)
					local message = diagnostic.message:gsub("\n", " "):gsub("\t", " "):gsub("%s+", " ")
					return message:gsub("^%s+", "")
				end,
			},
		}, neotest_ns)

		require("neotest").setup({
			adapters = {
				require("neotest-golang")({
					runner = "gotestsum",
					dap_mode = "dap-go",
				}),
			},
		})
	end,
}
