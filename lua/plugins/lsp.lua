return {
  -- Mason : Gestionnaire de packages LSP
  {
    "williamboman/mason.nvim",
    config = function()
      require("mason").setup({
        ui = {
          icons = {
            package_installed = "✓",
            package_pending = "➜",
            package_uninstalled = "✗"
          }
        }
      })
    end,
  },

  -- Mason-LSPconfig : Pont entre Mason et lspconfig
  {
    "williamboman/mason-lspconfig.nvim",
    dependencies = { "williamboman/mason.nvim" },
    config = function()
      require("mason-lspconfig").setup({
        -- Installation automatique des LSP servers (NOMS LSPCONFIG)
        ensure_installed = {
          "ts_ls",              -- TypeScript/JavaScript
          "html",               -- HTML
          "cssls",              -- CSS
          "tailwindcss",        -- TailwindCSS
          "eslint",             -- ESLint
          "jsonls",             -- JSON
        },
        -- Installation automatique
        automatic_installation = true,
      })
    end,
  },
  
  -- LSP Configuration
  {
    "neovim/nvim-lspconfig",
    dependencies = { "williamboman/mason-lspconfig.nvim" },
    config = function()
      local lspconfig = require("lspconfig")
      
      -- Configuration commune pour tous les LSP
      local on_attach = function(client, bufnr)
        -- Raccourcis LSP
        local opts = { buffer = bufnr }
        vim.keymap.set("n", "gd", vim.lsp.buf.definition, opts)
        vim.keymap.set("n", "gr", vim.lsp.buf.references, opts)
        vim.keymap.set("n", "gi", vim.lsp.buf.implementation, opts)
        vim.keymap.set("n", "K", vim.lsp.buf.hover, opts)
        vim.keymap.set("n", "<leader>rn", vim.lsp.buf.rename, opts)
        vim.keymap.set("n", "<leader>ca", vim.lsp.buf.code_action, opts)
      end
      
      -- Configuration TypeScript/JavaScript AMÉLIORÉE
      lspconfig.ts_ls.setup({
        on_attach = on_attach,
        filetypes = { "javascript", "javascriptreact", "typescript", "typescriptreact" },

        -- CONFIGURATION MAGIQUE POUR AUTO-IMPORT CROSS-FICHIER
        init_options = {
          maxTsServerMemory = 4096, -- Plus de mémoire pour de gros projets
          preferences = {
            includeCompletionsForModuleExports = true,
            includeCompletionsWithInsertText = true,
            importModuleSpecifierPreference = "relative",
          },
          suggestFromUnimportedLibraries = true, -- CLEF pour l'import même fichiers fermés
          implicitProjectConfiguration = {
            checkJs = true,
            target = "ES2020",
            module = "ESNext",
            allowSyntheticDefaultImports = true,
            moduleResolution = "node",
            jsx = "react-jsx"
          }
        },

        settings = {
          typescript = {
            suggest = {
              autoImports = true,
              includeCompletionsForModuleExports = true,
              includeCompletionsWithInsertText = true,
            },
            preferences = {
              includePackageJsonAutoImports = "auto",
              includeCompletionsForModuleExports = true,
              includeCompletionsWithInsertText = true,
              inlayHints = {
                includeInlayParameterNameHints = "all",
                includeInlayParameterNameHintsWhenArgumentMatchesName = false,
                includeInlayFunctionParameterTypeHints = true,
                includeInlayVariableTypeHints = true,
                includeInlayPropertyDeclarationTypeHints = true,
                includeInlayFunctionLikeReturnTypeHints = true,
                includeInlayEnumMemberValueHints = true,
              },
            },
            workspaceSymbols = {
              scope = "allOpenProjects",
            },
          },
          javascript = {
            suggest = {
              autoImports = true,
              includeCompletionsForModuleExports = true,
              includeCompletionsWithInsertText = true,
            },
            preferences = {
              includePackageJsonAutoImports = "auto",
              includeCompletionsForModuleExports = true,
              includeCompletionsWithInsertText = true,
            },
          },
        },

        capabilities = vim.tbl_extend("force", 
          require('cmp_nvim_lsp').default_capabilities(),
          {
            workspace = {
              symbol = {
                dynamicRegistration = true,
                symbolKind = {
                  valueSet = {1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26}
                }
              }
            }
          }
        ),
      })
      
      -- Configuration HTML
      lspconfig.html.setup({
        on_attach = on_attach,
        filetypes = { "html" },
      })
      
      -- Configuration CSS
      lspconfig.cssls.setup({
        on_attach = on_attach,
        filetypes = { "css", "scss", "less" },
      })
      
      -- Configuration TailwindCSS
      lspconfig.tailwindcss.setup({
        on_attach = on_attach,
        filetypes = { "html", "css", "javascript", "javascriptreact", "typescript", "typescriptreact" },
      })
      
      -- Configuration ESLint
      lspconfig.eslint.setup({
        on_attach = on_attach,
        filetypes = { "javascript", "javascriptreact", "typescript", "typescriptreact" },
      })
      
      -- Configuration JSON
      lspconfig.jsonls.setup({
        on_attach = on_attach,
        filetypes = { "json", "jsonc" },
      })

      -- Autocmd pour forcer la re-scan du projet (optionnel si tu veux vraiment booster le rescan, mais pas obligatoire avec la config ci-dessus)
      vim.api.nvim_create_autocmd({"BufEnter", "BufWinEnter", "DirChanged"}, {
        pattern = {"*.js", "*.jsx", "*.ts", "*.tsx"},
        callback = function()
          vim.defer_fn(function()
            local clients = vim.lsp.get_active_clients({ name = "ts_ls" })
            for _, client in pairs(clients) do
              if client.server_capabilities.workspaceSymbolProvider then
                client.request("workspace/symbol", { query = "" }, function() end)
              end
            end
          end, 100)
        end
      })

      -- Raccourci pour forcer la re-scan manuelle
      vim.keymap.set("n", "<leader>ls", function()
        local clients = vim.lsp.get_active_clients({ name = "ts_ls" })
        for _, client in pairs(clients) do
          if client.server_capabilities.workspaceSymbolProvider then
            client.request("workspace/symbol", { query = "" }, function()
              print("TypeScript workspace rescanned!")
            end)
          end
        end
      end, { desc = "Rescanner le workspace TypeScript" })

      -- Raccourci pour workspace symbol search
      vim.keymap.set("n", "<leader>fs", function()
        vim.lsp.buf.workspace_symbol()
      end, { desc = "Chercher des symboles dans le workspace" })

      -- Génération auto de jsconfig.json à l'ouverture d'un fichier JS/TS
      vim.api.nvim_create_autocmd("FileType", {
        pattern = { "javascript", "typescript", "javascriptreact", "typescriptreact" },
        callback = function()
          local jsconfig = vim.fn.getcwd() .. "/jsconfig.json"
          if vim.fn.filereadable(jsconfig) == 0 then
            local config = {
              compilerOptions = {},
              exclude = { "dist" }
            }
            local json = vim.fn.json_encode(config)
            vim.fn.writefile({json}, jsconfig)
          end
        end,
      })
    end,
  },
  
  -- nvim-cmp : Autocomplétion stable et modulaire AMÉLIORÉE
  {
    "hrsh7th/nvim-cmp",
    dependencies = {
      "hrsh7th/cmp-nvim-lsp",
      "hrsh7th/cmp-buffer",
      "hrsh7th/cmp-path",
      "L3MON4D3/LuaSnip",
      "saadparwaiz1/cmp_luasnip",
      "rafamadriz/friendly-snippets",
    },
    config = function()
      local cmp = require("cmp")
      local luasnip = require("luasnip")
      require("luasnip.loaders.from_vscode").lazy_load()

      cmp.setup({
        snippet = {
          expand = function(args)
            luasnip.lsp_expand(args.body)
          end,
        },
        mapping = {
          ["<Down>"] = cmp.mapping.select_next_item(),
          ["<Up>"] = cmp.mapping.select_prev_item(),
          ["<CR>"] = cmp.mapping.confirm({ select = true }),
          ["<C-Space>"] = cmp.mapping.complete(),
          ["<Tab>"] = function(fallback)
            if luasnip.jumpable(1) then
              luasnip.jump(1)
            else
              fallback()
            end
          end,
          ["<S-Tab>"] = function(fallback)
            if luasnip.jumpable(-1) then
              luasnip.jump(-1)
            else
              fallback()
            end
          end,
        },
        sources = cmp.config.sources({
          { name = "nvim_lsp", priority = 1000 },
          { name = "luasnip", priority = 750 },
          { 
            name = "buffer", 
            priority = 500,
            option = {
              get_bufnrs = function()
                local bufs = {}
                for _, buf in ipairs(vim.api.nvim_list_bufs()) do
                  if vim.api.nvim_buf_is_loaded(buf) and vim.api.nvim_buf_is_valid(buf) then
                    local name = vim.api.nvim_buf_get_name(buf)
                    if name and not name:match("node_modules") 
                       and not name:match("%.git/") 
                       and not name:match("/dist/")
                       and not name:match("/build/") then
                      table.insert(bufs, buf)
                    end
                  end
                end
                return bufs
              end
            }
          },
          { name = "path", priority = 250 },
        }),
      })
    end,
  },
  
  -- Conform : Formatage automatique avec Prettier (RÉACTIVÉ)
  {
    "stevearc/conform.nvim",
    config = function()
      require("conform").setup({
        formatters_by_ft = {
          javascript = { "prettier" },
          javascriptreact = { "prettier" },
          typescript = { "prettier" },
          typescriptreact = { "prettier" },
          html = { "prettier" },
          css = { "prettier" },
          scss = { "prettier" },
          json = { "prettier" },
          jsonc = { "prettier" },
          markdown = { "prettier" },
        },
        format_on_save = {
          timeout_ms = 500,
          lsp_fallback = true,
        },
      })
      vim.keymap.set("n", "<leader>f", function()
        require("conform").format({ async = true, lsp_fallback = true })
      end, { desc = "Formater le fichier" })
    end,
  },
  
  -- LSP Signature : Signature help avec positionnement absolu
  {
    "ray-x/lsp_signature.nvim",
    event = "InsertEnter",
    config = function()
      require("lsp_signature").setup({
        floating_window = true,
        floating_window_above_cur_line = false,
        floating_window_off_x = function()
          return vim.api.nvim_win_get_width(0) - 85
        end,
        floating_window_off_y = function()
          return vim.fn.winheight(0) - 10
        end,
        max_width = 80,
        max_height = 8,
        border = "single",
        fix_pos = true,
        always_trigger = true,
        auto_close_after = nil,
        doc_lines = 3,
        handler_opts = {
          border = "single"
        },
        hint_enable = false,
        zindex = 200,
      })
    end,
  },
}
