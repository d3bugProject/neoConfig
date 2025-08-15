-- ======================================================
-- UI PLUGINS
-- Lualine, Snipe buffer selector
-- ======================================================

return {
  -- ======================================================
  -- INTERFACE - SÉLECTEUR DE BUFFERS SNIPE (MINIMALISTE)
  -- ======================================================
  {
    "leath-dub/snipe.nvim",
    config = function()
      -- Configuration de snipe
      local snipe = require("snipe")
      snipe.setup({
        -- Interface de snipe
        ui = {
          max_width = -1, -- -1 = largeur automatique
          -- Position de la fenêtre (centre, top, bottom)
          position = "topleft",
          -- Style de bordure
          open_win_override = {
            border = "single", -- single, double, rounded, solid, shadow
            title = " Buffers ",
            title_pos = "center",
          },
        },
        -- Touches pour la sélection rapide
        hints = {
          -- Dictionnaire des touches (ordre de priorité)
          dictionary = "asdfjklqwertyuiopzxcvbnm",
        },
        -- Tri des buffers
        sort = "last", -- last, default
        -- Production de sons (optionnel)
        producer = "default", -- default, lsp
      })
      
      -- Raccourci pour ouvrir snipe avec Tab
      vim.keymap.set("n", "<Tab>", snipe.open_buffer_menu, { desc = "Sélecteur de buffers snipe" })
      
      -- Alternative avec Space + b
      vim.keymap.set("n", "<leader>b", snipe.open_buffer_menu, { desc = "Sélecteur de buffers snipe (alt)" })
    end,
  },

  -- ======================================================
  -- INTERFACE - BARRE DE STATUT LUALINE
  -- ======================================================
  {
    "nvim-lualine/lualine.nvim",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    config = function()
      -- Configuration de lualine
      require("lualine").setup({
        options = {
          -- Thème de la barre de statut
          theme = "auto",
          -- Séparateurs entre sections
          component_separators = { left = "", right = "" },
          section_separators = { left = "", right = "" },
          -- Désactiver dans certains types de fichiers
          disabled_filetypes = {
            statusline = {},
            winbar = {},
          },
          -- Ignorer le focus pour ces types
          ignore_focus = {},
          -- Toujours diviser la barre de statut
          always_divide_middle = true,
          -- Barre de statut globale
          globalstatus = false,
          -- Actualisation en ms
          refresh = {
            statusline = 1000,
            tabline = 1000,
            winbar = 1000,
          },
        },
        sections = {
          -- Partie gauche
          lualine_a = { "mode" },                    -- Mode actuel (NORMAL, INSERT, etc.)
          lualine_b = { "branch", "diff", "diagnostics" }, -- Git + diagnostics
          lualine_c = { "filename" },                -- Nom du fichier
          -- Partie droite
          lualine_x = { "encoding", "fileformat", "filetype" }, -- Infos fichier
          lualine_y = { "progress" },                -- Pourcentage du fichier
          lualine_z = { "location" },                -- Position du curseur
        },
        inactive_sections = {
          -- Sections pour fenêtres inactives
          lualine_a = {},
          lualine_b = {},
          lualine_c = { "filename" },
          lualine_x = { "location" },
          lualine_y = {},
          lualine_z = {},
        },
        tabline = {},
        winbar = {},
        inactive_winbar = {},
        extensions = { "neo-tree", "toggleterm", "oil" }, -- Extensions supportées
      })
    end,
  },

  -- ======================================================
  -- rainbow delimiters
  -- ======================================================
  {
    "HiPhish/rainbow-delimiters.nvim",
    config = function()
        -- Configuration ici (voir plus bas)
    end
  },
  -- ======================================================
  -- match parentheses
  -- ======================================================
  {
    "andymass/vim-matchup",
    event = "VeryLazy",
    config = function()
      vim.g.matchup_matchparen_offscreen = { method = "popup" }
      vim.schedule(function()
        vim.cmd("NoMatchParen")
      end)
    end
  },
  -- ======================================================
  -- INTERFACE - THÈME SOLARIZED OSAKA
  -- Thème moderne inspiré de Solarized, avec variantes dark/light.
  -- Apporte une expérience visuelle élégante, lisible et agréable.
  -- https://github.com/craftzdog/solarized-osaka.nvim
  -- ======================================================
  {
    "craftzdog/solarized-osaka.nvim",
    priority = 1000, -- Charger en priorité pour éviter les conflits de couleurs
    config = function()
      -- Activation automatique du thème Solarized Osaka
      vim.cmd.colorscheme("solarized-osaka")
    end,
  },
}
