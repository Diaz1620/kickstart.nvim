return {
  {
    'neovim/nvim-lspconfig',
    dependencies = {
      'williamboman/mason.nvim',
      'williamboman/mason-lspconfig.nvim',
      'hrsh7th/cmp-nvim-lsp',
      'hrsh7th/cmp-buffer',
      'hrsh7th/cmp-path',
      'hrsh7th/cmp-cmdline',
      'hrsh7th/nvim-cmp',
      'L3MON4D3/LuaSnip',
      'saadparwaiz1/cmp_luasnip',
      'j-hui/fidget.nvim',
    },

    config = function()
      local cmp_lsp = require 'cmp_nvim_lsp'
      local capabilities = vim.tbl_deep_extend('force', {}, vim.lsp.protocol.make_client_capabilities(), cmp_lsp.default_capabilities())

      require('fidget').setup {}
      require('mason').setup()

      -- Apply capabilities to all servers (new API)
      vim.lsp.config('*', { capabilities = capabilities })

      vim.lsp.config('lua_ls', {
        settings = {
          Lua = {
            diagnostics = {
              globals = { 'vim', 'it', 'describe', 'before_each', 'after_each' },
            },
          },
        },
      })

      vim.lsp.config('emmet_ls', {
        filetypes = { 'html', 'typescriptreact', 'javascriptreact', 'css', 'sass', 'scss', 'liquid' },
        init_options = {
          html = {
            options = {
              ['bem.enabled'] = true,
            },
          },
        },
      })

      vim.lsp.config('shopify_theme_ls', {
        cmd = { vim.fn.expand '~/.local/bin/shopify-theme-language-server' },
        init_options = {
          themeCheck = {
            checkOnChange = false,
          },
        },
      })

      require('mason-lspconfig').setup {
        ensure_installed = {
          'lua_ls',
          'ts_ls',
          'emmet_ls',
          'tailwindcss',
          'gopls',
          'shopify_theme_ls',
        },
        automatic_enable = {
          exclude = { 'rust_analyzer' },
        },
      }

      vim.diagnostic.config {
        float = {
          focusable = false,
          style = 'minimal',
          border = 'rounded',
          source = 'always',
          header = '',
          prefix = '',
        },
        virtual_text = false,
      }

      vim.api.nvim_create_autocmd('LspAttach', {
        callback = function(args)
          vim.keymap.set('n', '<leader>ra', vim.lsp.buf.rename, { buffer = args.buf })
          vim.keymap.set({ 'n', 'v' }, '<space>ca', vim.lsp.buf.code_action, { buffer = args.buf })

          -- prevent loading LSP for minified VBT files
          local buf_info = vim.fn.getbufinfo(args.buf)
          local buf_name = buf_info[1].name
          local exclude_pattern = {
            'assets/global.vbt.js',
            'assets/global.vbt.css',
          }
          for _, name in ipairs(exclude_pattern) do
            if string.match(buf_name, name) then
              vim.cmd 'LspStop'
            end
          end
        end,
      })
    end,
  },

  {
    'dense-analysis/ale',
    config = function()
      local g = vim.g

      g.ale_ruby_rubocop_auto_correct_all = 1

      g.ale_linters = {
        ruby = { 'rubocop', 'ruby' },
        lua = { 'lua_language_server' },
        liquid = 'all',
      }
    end,
  },
}
