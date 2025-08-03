-- ======================================================
-- TERMINAL PLUGINS
-- ToggleTerm floating terminal
-- ======================================================

return {
  -- ======================================================
  -- TERMINAL FLOTTANT - TOGGLETERM
  -- ======================================================
  {
    "akinsho/toggleterm.nvim",
    version = "*",
    config = function()
      -- Configuration du terminal flottant
      require("toggleterm").setup({
        size = 20,
        open_mapping = [[<leader>t]],  -- Space + t
        hide_numbers = true,
        direction = "float",           -- Terminal flottant
        float_opts = {
          border = "curved",
          winblend = 0,
        },
      })
      
      -- Raccourci pour terminal flottant
      vim.keymap.set("n", "<leader>t", "<cmd>ToggleTerm<CR>", { desc = "Terminal flottant" })
    end,
  },
}
