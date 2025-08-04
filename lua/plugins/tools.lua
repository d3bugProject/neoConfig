-- ======================================================
-- TOOLS - Plugins utilitaires (diagnostics, navigation avancée, etc.)
-- ======================================================

return {
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
    event = "VeryLazy",
    dependencies = {
      "MunifTanjim/nui.nvim", -- Dépendance obligatoire pour les fenêtres flottantes
    },
    opts = {}, -- Config de base, personnalisable ensuite
    
  },
}
