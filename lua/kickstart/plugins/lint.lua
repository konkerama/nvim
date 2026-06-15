---@module 'lazy'
---@type LazySpec
return {

  { -- Linting
    'mfussenegger/nvim-lint',
    event = { 'BufReadPre', 'BufNewFile' },
    config = function()
      local lint = require 'lint'
      lint.linters_by_ft = {
        markdown = { 'markdownlint' },
        go = { 'golangcilint' },
      }

      -- To allow other plugins to add linters to require('lint').linters_by_ft,
      -- instead set linters_by_ft like this:
      -- lint.linters_by_ft = lint.linters_by_ft or {}
      -- lint.linters_by_ft['markdown'] = { 'markdownlint' }
      --
      -- However, note that this will enable a set of default linters,
      -- which will cause errors unless these tools are available:
      -- {
      --   clojure = { "clj-kondo" },
      --   dockerfile = { "hadolint" },
      --   inko = { "inko" },
      --   janet = { "janet" },
      --   json = { "jsonlint" },
      --   markdown = { "vale" },
      --   rst = { "vale" },
      --   ruby = { "ruby" },
      --   terraform = { "tflint" },
      --   text = { "vale" }
      -- }
      --
      -- You can disable the default linters by setting their filetypes to nil:
      -- lint.linters_by_ft['clojure'] = nil
      -- lint.linters_by_ft['dockerfile'] = nil
      -- lint.linters_by_ft['inko'] = nil
      -- lint.linters_by_ft['janet'] = nil
      -- lint.linters_by_ft['json'] = nil
      -- lint.linters_by_ft['markdown'] = nil
      -- lint.linters_by_ft['rst'] = nil
      -- lint.linters_by_ft['ruby'] = nil
      -- lint.linters_by_ft['terraform'] = nil
      -- lint.linters_by_ft['text'] = nil

      -- Create autocommand which carries out the actual linting
      -- on the specified events.
      -- NOTE (custom): trigger only on read/save, NOT on InsertLeave/BufEnter.
      -- golangci-lint runs over the whole package and is too slow to run on every
      -- insert-leave or buffer switch.
      local lint_augroup = vim.api.nvim_create_augroup('lint', { clear = true })
      vim.api.nvim_create_autocmd({ 'BufReadPost', 'BufWritePost' }, {
        group = lint_augroup,
        callback = function()
          -- Only run the linter in buffers that you can modify in order to
          -- avoid superfluous noise, notably within the handy LSP pop-ups that
          -- describe the hovered symbol using Markdown.
          if not vim.bo.modifiable then return end
          -- nvim-lint's golangcilint builtin resolves its args ONCE at plugin load
          -- via getArgs() (shells out to `golangci-lint version` + `go env GOMOD`).
          -- On machines where golangci-lint isn't on $PATH yet at load time (mac:
          -- mason bin not prepended before BufReadPre fires), getArgs() returns nil,
          -- args = nil, --issues-exit-code=0 is never sent, and golangci-lint exits
          -- with the issue count (e.g. 3) → "exited with code 3". Re-require the
          -- builtin at lint time (when PATH is ready) so getArgs() re-runs correctly.
          -- Version-agnostic: the builtin handles v1/v2 internally.
          if vim.bo.filetype == 'go' then
            package.loaded['lint.linters.golangcilint'] = nil
            lint.linters.golangcilint = require 'lint.linters.golangcilint'
          end
          lint.try_lint()
        end,
      })

      -- actionlint only understands GitHub Actions workflow files, so scope it to
      -- .github/workflows/*.{yml,yaml} instead of linting all YAML.
      vim.api.nvim_create_autocmd({ 'BufReadPost', 'BufWritePost' }, {
        group = lint_augroup,
        pattern = { '*/.github/workflows/*.yml', '*/.github/workflows/*.yaml' },
        callback = function()
          if vim.bo.modifiable then lint.try_lint 'actionlint' end
        end,
      })
    end,
  },
}
