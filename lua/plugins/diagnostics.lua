-- ======================================================
-- RACCOURCIS DIAGNOSTICS
-- ======================================================

local keymap = vim.keymap -- API moderne pour les mappings

-- <leader>e : Afficher l'erreur courante dans un popup en bas à droite
keymap.set("n", "<leader>e", function()
  vim.diagnostic.open_float(nil, {
    focus = false,
    scope = "line",
    border = "rounded",
    anchor = "SE", -- Sud-Est (en bas à droite)
    close_events = { "BufLeave", "CursorMoved", "InsertEnter", "FocusLost" },
  })
end, { desc = "Afficher l'erreur courante (popup)" })

-- <leader>y : Copier le texte de l'erreur courante dans le presse-papiers
keymap.set("n", "<leader>y", function()
  local curr = vim.api.nvim_get_current_buf()
  local line = vim.api.nvim_win_get_cursor(0)[1] - 1
  local diags = vim.diagnostic.get(curr, { lnum = line })
  if #diags > 0 then
    vim.fn.setreg('+', diags[1].message)
    vim.notify("Erreur copiée dans le presse-papiers !", vim.log.levels.INFO)
  else
    vim.notify("Aucune erreur à cette ligne.", vim.log.levels.WARN)
  end
end, { desc = "Copier le texte de l'erreur courante" })

-- ======================================================
-- DIAGNOSTICS - Icônes et couleurs personnalisés
-- Améliore la lisibilité des erreurs, warnings, infos et hints dans la gutter
-- Inspiré de d3bugProject/nvim_dotfiles et des configs NvChad
-- ======================================================

-- ======================================================
-- DIAGNOSTICS - Icônes et couleurs personnalisés
-- Améliore la lisibilité des erreurs, warnings, infos et hints dans la gutter
-- Inspiré de d3bugProject/nvim_dotfiles et des configs NvChad
-- ======================================================


-- Définition moderne des signes diagnostics (API Lua)
local signs = {
  Error = { text = "" },   -- Icône rouge (NerdFont)
  Warn  = { text = "" },   -- Icône jaune
  Hint  = { text = "󰌵" },   -- Icône bleue
  Info  = { text = "" },   -- Icône cyan
}

-- Couleurs personnalisées pour chaque type de diagnostic (adaptez selon votre thème)
local diagnostic_colors = {
  Error = "#ff5555", -- Rouge vif
  Warn  = "#e0af68", -- Jaune/orangé
  Hint  = "#7aa2f7", -- Bleu
  Info  = "#5fd7ff", -- Cyan
}

for type, opts in pairs(signs) do
  local hl = "DiagnosticSign" .. type
  vim.api.nvim_set_hl(0, hl, { fg = diagnostic_colors[type], bg = "NONE" })
  vim.fn.sign_define(hl, { text = opts.text, texthl = hl, numhl = "" })
end

vim.diagnostic.config({
  virtual_text = {
    prefix = "●", -- Petit point coloré
    spacing = 2,
  },
  signs = true,
  underline = true,
  update_in_insert = false,
  severity_sort = true,
  float = {
    border = "rounded",
    source = "always",
    header = "",
    prefix = "",
  },
})
