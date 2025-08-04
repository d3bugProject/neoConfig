-- ======================================================
-- TREESITTER - Analyse syntaxique avancée
-- Plugin essentiel pour coloration, indentation, et navigation moderne.
-- https://github.com/nvim-treesitter/nvim-treesitter
-- ======================================================

return {
  {
    "nvim-treesitter/nvim-treesitter",
    build = ":TSUpdate",
    config = function()
      require("nvim-treesitter.configs").setup({
        ensure_installed = {
          "lua", "vim", "bash", "javascript", "typescript", "html", "css", "json", "markdown"
        },
        highlight = { enable = true },
        indent = { enable = true },
        incremental_selection = { enable = true },
        autotag = { enable = true },
      })
    end,
  },
}
