-- ======================================================
-- LSP DEVELOPMENT PLUGINS
-- Mason, LSP configs, Blink completion, Conform formatting, LSP Signature
-- ======================================================

return {
  -- ======================================================
  -- DÉVELOPPEMENT WEB - LSP ET AUTOCOMPLÉTION (RÉACTIVÉ)
  -- ======================================================
  
  -- Mason : Gestionnaire automatique des LSP servers
  {
    "williamboman/mason.nvim",
    config = function()
      require("mason").setup({
        ui = {
          border = "rounded",
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
        -- Installation automatique des LSP servers
        ensure_installed = {
          "ts_ls",              -- TypeScript/JavaScript
          "html",                -- HTML
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
      
      -- Configuration TypeScript/JavaScript
      lspconfig.ts_ls.setup({
        on_attach = on_attach,
        filetypes = { "javascript", "javascriptreact", "typescript", "typescriptreact" },
        settings = {
          typescript = {
            preferences = {
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
          },
        },
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
    end,
  },
  
  -- Blink.cmp : Autocomplétion moderne (RÉACTIVÉ)
  {
    "saghen/blink.cmp",
    lazy = false,
    dependencies = "rafamadriz/friendly-snippets",
    version = "v0.*",
    config = function()
      require("blink.cmp").setup({
        -- Configuration des touches
        keymap = {
          preset = "default", -- Utiliser le preset par défaut pour éviter les conflits
          
          -- Remplacer seulement les touches nécessaires
          ["<Up>"] = { "select_prev", "fallback" },
          ["<Down>"] = { "select_next", "fallback" },
          ["<CR>"] = { "accept", "fallback" },
        },
        
        -- Apparence du menu
        appearance = {
          use_nvim_cmp_as_default = true,
          nerd_font_variant = "mono",
        },
        
        -- Sources de complétion avec priorités
        sources = {
          default = { "lsp", "path", "snippets", "buffer" },
          providers = {
            lsp = {
              name = "LSP",
              module = "blink.cmp.sources.lsp",
              score_offset = 100, -- Priorité maximale
            },
            path = {
              name = "Path",
              module = "blink.cmp.sources.path",
              score_offset = 50,
            },
            snippets = {
              name = "Snippets",
              module = "blink.cmp.sources.snippets",
              score_offset = 25,
            },
            buffer = {
              name = "Buffer",
              module = "blink.cmp.sources.buffer",
              score_offset = 10, -- Priorité minimale
            },
          },
        },
        
        -- Configuration des snippets
        snippets = {
          expand = function(snippet) vim.snippet.expand(snippet) end,
          active = function(filter)
            if filter and filter.direction then
              return vim.snippet.active({ direction = filter.direction })
            end
            return vim.snippet.active()
          end,
          jump = function(direction) vim.snippet.jump(direction) end,
        },
        
        -- Configuration de la completion
        completion = {
          accept = {
            auto_brackets = {
              enabled = true,
            },
          },
          menu = {
            draw = {
              treesitter = { "lsp" },
              columns = { { "label", "label_description", gap = 1 }, { "kind_icon", "kind" } },
            },
          },
          documentation = {
            auto_show = true,
            auto_show_delay_ms = 200,
          },
        },
        
        -- Configuration des signatures (DÉSACTIVÉE - remplacée par lsp_signature.nvim)
        signature = {
          enabled = false,  -- Désactivé au profit de lsp_signature.nvim
        },
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