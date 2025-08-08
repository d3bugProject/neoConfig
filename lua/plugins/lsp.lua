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
        
        -- NOUVEAU : Configuration pour scanner tout le projet
        init_options = {
          preferences = {
            -- Activer les suggestions d'auto-import
            includeCompletionsForModuleExports = true,
            includeCompletionsWithInsertText = true,
          },
        },
        
        settings = {
          typescript = {
            -- NOUVEAU : Options d'auto-import
            suggest = {
              autoImports = true,
              includeCompletionsForModuleExports = true,
              includeCompletionsWithInsertText = true,
            },
            
            -- NOUVEAU : Preferences pour l'indexation complète
            preferences = {
              -- Auto-import preferences
              includePackageJsonAutoImports = "auto", -- auto, on, off
              includeCompletionsForModuleExports = true,
              includeCompletionsWithInsertText = true,
              
              -- Inlay hints (tu avais déjà ça)
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
            
            -- NOUVEAU : Configuration du workspace pour scanner tous les fichiers
            workspaceSymbols = {
              scope = "allOpenProjects", -- Scanner tous les projets ouverts
            },
          },
          
          javascript = {
            -- Même config pour JavaScript
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
        
        -- NOUVEAU : Capacités étendues
        capabilities = vim.tbl_extend("force", 
          require('cmp_nvim_lsp').default_capabilities(),
          {
            -- Activer le support des workspace symbols
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

      -- NOUVEAU : Autocmd pour forcer la re-scan du projet
      vim.api.nvim_create_autocmd({"BufEnter", "BufWinEnter", "DirChanged"}, {
        pattern = {"*.js", "*.jsx", "*.ts", "*.tsx"},
        callback = function()
          -- Forcer le LSP à rescanner le workspace
          vim.defer_fn(function()
            local clients = vim.lsp.get_active_clients({ name = "ts_ls" })
            for _, client in pairs(clients) do
              if client.server_capabilities.workspaceSymbolProvider then
                -- Déclencher une recherche de symboles vide pour forcer l'indexation
                client.request("workspace/symbol", { query = "" }, function() end)
              end
            end
          end, 100)
        end
      })

      -- NOUVEAU : Raccourci pour forcer la re-scan manuelle
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

      -- NOUVEAU : Raccourci pour rechercher des symboles dans tout le projet
      vim.keymap.set("n", "<leader>fs", function()
        vim.lsp.buf.workspace_symbol()
      end, { desc = "Chercher des symboles dans le workspace" })
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
        -- Mappings inspirés de blink.cmp pour une expérience familière
        mapping = {
          ["<Down>"] = cmp.mapping.select_next_item(),    -- Aller à la suggestion suivante
          ["<Up>"] = cmp.mapping.select_prev_item(),      -- Aller à la suggestion précédente
          ["<CR>"] = cmp.mapping.confirm({ select = true }), -- Valider la complétion
          ["<C-Space>"] = cmp.mapping.complete(),         -- Ouvrir le menu de complétion
          -- Navigation contextuelle dans les snippets avec <Tab> et <S-Tab>
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
          -- Buffer étendu MAIS en excluant node_modules
          { 
            name = "buffer", 
            priority = 500,
            option = {
              get_bufnrs = function()
                local bufs = {}
                for _, buf in ipairs(vim.api.nvim_list_bufs()) do
                  -- Vérifier que le buffer est chargé et valide
                  if vim.api.nvim_buf_is_loaded(buf) and vim.api.nvim_buf_is_valid(buf) then
                    local name = vim.api.nvim_buf_get_name(buf)
                    -- Exclure node_modules, .git, dist, build, etc.
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
        -- Formatters par type de fichier
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
        
        -- Formatage automatique à la sauvegarde
        format_on_save = {
          timeout_ms = 500,
          lsp_fallback = true,
        },
      })
      
      -- Raccourci Space+f pour formater manuellement
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
        -- Position de la fenêtre flottante
        floating_window = true,
        floating_window_above_cur_line = false,  -- Forcer en bas
        
        -- Positionnement précis (selon documentation officielle)
        floating_window_off_x = function()
          -- Position à droite de l'écran
          return vim.api.nvim_win_get_width(0) - 85  -- 85 chars depuis la gauche
        end,
        floating_window_off_y = function()
          -- Position en bas de l'écran  
          return vim.fn.winheight(0) - 10  -- 10 lignes depuis le haut
        end,
        
        -- Style et taille
        max_width = 80,
        max_height = 8,
        border = "single",
        
        -- Comportement
        fix_pos = true,                         -- Position fixe
        always_trigger = true,                  -- Toujours déclencher
        auto_close_after = nil,                 -- Ne pas fermer automatiquement
        doc_lines = 3,                          -- Lignes de documentation
        
        -- Style
        handler_opts = {
          border = "single"
        },
        
        -- Désactiver les hints virtuels
        hint_enable = false,
        
        -- Z-index pour être au-dessus
        zindex = 200,
      })
    end,
  },
}
