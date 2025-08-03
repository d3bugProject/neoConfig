-- Point d'entrée principal de Neovim

-- ======================================================
-- CONFIGURATION DE LA TOUCHE LEADER
-- ======================================================
-- Définir Space (espace) comme touche leader
-- Doit être fait AVANT de charger les plugins
vim.g.mapleader = " "
vim.g.maplocalleader = " "

-- Charger la configuration de l'interface utilisateur
require("config.ui")

-- Charger la configuration des plugins
require("plugins")

-- Charger les raccourcis clavier personnalisés
require("config.keymaps")
