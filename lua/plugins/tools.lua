
-- ======================================================
-- TOOLS - Plugins utilitaires (diagnostics, navigation avancée, etc.)
-- ======================================================

return {
  
  -- Auto-pairs (parenthèses, crochets, guillemets automatiques)
  {
    "windwp/nvim-autopairs",
    event = "InsertEnter",
    config = function()
      require("nvim-autopairs").setup {}
    end,
  },
  -- ...autres plugins tools ci-dessous...
  -- Trouble.nvim : affichage moderne et interactif des diagnostics, quickfix, LSP, etc.
  {
    "folke/trouble.nvim",
    opts = {},
    config = function()
      require("trouble").setup {}
      -- Mapping <leader>q pour ouvrir Trouble diagnostics
      vim.keymap.set("n", "<leader>q", function()
        require("trouble").toggle("diagnostics", { position = "bottom", height = 10 })
      end, { desc = "Diagnostics (Trouble, split réduit)" })
    end,
  },



  -- Noice.nvim : UI moderne pour messages, notifications, LSP, historique, etc.
  {
    "folke/noice.nvim",
    opts = function(_, opts)
      opts.routes = opts.routes or {}
      opts.presets = opts.presets or {}
      table.insert(opts.routes, {
        filter = {
          event = "notify",
          find = "No information available",
        },
        opts = { skip = true },
      })
      local focused = true
      vim.api.nvim_create_autocmd("FocusGained", {
        callback = function()
          focused = true
        end,
      })
      vim.api.nvim_create_autocmd("FocusLost", {
        callback = function()
          focused = false
        end,
      })
      table.insert(opts.routes, 1, {
        filter = {
          cond = function()
            return not focused
          end,
        },
        view = "notify_send",
        opts = { stop = false },
      })

      opts.commands = {
        all = {
          -- options for the message history that you get with `:Noice`
          view = "split",
          opts = { enter = true, format = "details" },
          filter = {},
        },
      }

      vim.api.nvim_create_autocmd("FileType", {
        pattern = "markdown",
        callback = function(event)
          vim.schedule(function()
            require("noice.text.markdown").keys(event.buf)
          end)
        end,
      })

      opts.presets.lsp_doc_border = true
    end,
  },

  {
    "rcarriga/nvim-notify",
    opts = {
      timeout = 1000,
      render = "wrapped-compact",
      max_width = 20
    },
    config = function(_, opts)
      local notify = require("notify")
      -- Patch global : toutes les notifications restent si la souris est dessus et max_width=60 par défaut
      vim.notify = function(msg, level, user_opts)
        user_opts = user_opts or {}
        user_opts.keep = user_opts.keep or function()
          local mouse = vim.fn.getmousepos()
          for _, win in ipairs(vim.api.nvim_list_wins()) do
            local config = vim.api.nvim_win_get_config(win)
            if config.relative == "editor" and config.zindex and config.zindex > 150 then
              if mouse.winid == win then
                return true
              end
            end
          end
          return false
        end
        user_opts.max_width = user_opts.max_width or 60
        return notify(msg, level, user_opts)
      end
    end,
  },
-- Auto-close et auto-rename des balises
  {
  "windwp/nvim-ts-autotag",
  event = { "BufReadPre", "BufNewFile" },
  dependencies = { "nvim-treesitter/nvim-treesitter" },
  opts = {
    -- Structure correcte pour nvim-ts-autotag
    opts = {
      enable_close = true,          -- Auto close tags
      enable_rename = true,         -- Auto rename pairs of tags
      enable_close_on_slash = false -- Auto close on trailing </
    },
    -- Configuration par filetype (optionnel)
    per_filetype = {
      ["html"] = {
        enable_close = true
      }
    }
  },
  config = function(_, opts)
    require("nvim-ts-autotag").setup(opts)
  end,
},
  --type script tools pour les autoimport et tt 
  {
  "pmizio/typescript-tools.nvim",
  dependencies = {
    "nvim-lua/plenary.nvim",
    "neovim/nvim-lspconfig",
  },
  ft = { "typescript", "typescriptreact", "javascript", "javascriptreact" },
  opts = {
    -- configuration optionnelle ici selon tes besoins
  },
  config = function(_, opts)
    require("typescript-tools").setup(opts)
    -- Raccourci pour organiser les imports
    vim.keymap.set("n", "<leader>oi", "<cmd>TSToolsOrganizeImports<CR>", { desc = "Organize Imports" })
  end,
}
}
