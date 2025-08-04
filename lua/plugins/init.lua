-- ======================================================
-- CONFIGURATION LAZY.NVIM - GESTIONNAIRE DE PLUGINS
-- ======================================================

-- Bootstrap automatique de Lazy.nvim
-- Définit le chemin où Lazy.nvim sera installé (~/.local/share/nvim/lazy/lazy.nvim)
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"

-- Vérifie si Lazy.nvim est déjà installé sur le système
if not vim.loop.fs_stat(lazypath) then
  -- Si Lazy.nvim n'existe pas, le cloner depuis GitHub
  vim.fn.system({
    "git",                                           -- Utilise Git pour cloner
    "clone",                                         -- Commande clone
    "--filter=blob:none",                           -- Clone partiel pour économiser la bande passante
    "https://github.com/folke/lazy.nvim.git",       -- URL du dépôt officiel Lazy.nvim
    "--branch=stable",                              -- Utilise la branche stable (recommandé)
    lazypath,                                       -- Destination du clone
  })
end

-- Ajoute Lazy.nvim au runtime path de Neovim pour qu'il soit accessible
vim.opt.rtp:prepend(lazypath)

require("lazy").setup({
    -- Importer tous les modules de plugins
    { import = "plugins.navigation" },  -- Neo-tree, Telescope, Hop, Oil
    { import = "plugins.ui" },          -- Lualine, Snipe
    { import = "plugins.terminal" },    -- ToggleTerm
    { import = "plugins.lsp" },         -- Mason, LSP, Blink.cmp, Conform, LSP Signature
    { import = "plugins.treesitter" }, -- Treesitter : coloration et indentation avancées
    --{ import = "plugins.diagnostics" }, -- Affichage moderne des erreurs/hints LSP (désactivé, config chargée manuellement)
})
