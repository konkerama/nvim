---@module 'lazy'
---@type LazySpec
return {
	-- { "github/copilot.vim", lazy = false },

	-- {
	-- 	"CopilotC-Nvim/CopilotChat.nvim",
	-- 	dependencies = {
	-- 		{ "nvim-lua/plenary.nvim", branch = "master" },
	-- 	},
	-- 	build = "make tiktoken",
	-- 	cmd = {
	-- 		"CopilotChat",
	-- 		"CopilotChatOpen",
	-- 		"CopilotChatClose",
	-- 		"CopilotChatToggle",
	-- 		"CopilotChatPrompts",
	-- 		"CopilotChatModels",
	-- 	},
	-- 	keys = {
	-- 		{ "<leader>cc", "<cmd>CopilotChatToggle<CR>", desc = "Copilot Chat: Toggle" },
	-- 		{ "<leader>cp", "<cmd>CopilotChatPrompts<CR>", desc = "Copilot Chat: Prompts" },
	-- 		{ "<leader>ce", "<cmd>CopilotChat<CR>", desc = "Copilot Chat: Open" },
	-- 		{ "<leader>ce", "<cmd>CopilotChat<CR>", mode = "v", desc = "Copilot Chat: Open" },
	-- 	},
	-- 	opts = {
	-- 		model = "claude-sonnet-4.5",
	-- 		tools = "copilot",
	-- 		resources = { "buffer", "selection", "gitdiff" },
	-- 		diff = "unified",
	-- 		stop_on_function_failure = true,
	-- 		auto_insert_mode = true,
	-- 		mappings = {
	-- 			accept_diff = {
	-- 				normal = "<C-y>",
	-- 				insert = "<C-y>",
	-- 			},
	-- 		},
	-- 		window = {
	-- 			layout = "vertical",
	-- 			width = 0.45,
	-- 		},
	-- 	},
	-- },

	{
		"zbirenbaum/copilot.lua",
		cmd = "Copilot",
		event = "InsertEnter",
		config = function(_, opts)
			require("copilot").setup(opts)

			local blink_copilot_group = vim.api.nvim_create_augroup("kickstart-copilot-blink", { clear = true })

			vim.api.nvim_create_autocmd("User", {
				group = blink_copilot_group,
				pattern = "BlinkCmpMenuOpen",
				callback = function()
					vim.b.copilot_suggestion_hidden = true
				end,
			})

			vim.api.nvim_create_autocmd("User", {
				group = blink_copilot_group,
				pattern = "BlinkCmpMenuClose",
				callback = function()
					vim.b.copilot_suggestion_hidden = false
				end,
			})
		end,
		opts = {
			suggestion = {
				enabled = true,
				auto_trigger = true,
				hide_during_completion = true,
				debounce = 75,
				keymap = {
					accept = "<C-y>",
					accept_word = "<M-w>",
					accept_line = "<M-j>",
					next = "<M-]>",
					prev = "<M-[>",
					dismiss = "<C-]>",
				},
			},

			panel = { enabled = true },
		},
	},
}
