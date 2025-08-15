-- Point d'entrée principal de Neovim

-- ======================================================
-- CONFIGURATION DE LA TOUCHE LEADER
-- ======================================================
-- Définir Space (espace) comme touche leader
-- Doit être fait AVANT de charger les plugins
vim.g.mapleader = " "
vim.g.maplocalleader = " "
vim.fn.sign_define("NvimTreeDiagnosticErrorIcon", {text = "", texthl = "DiagnosticSignError"})
vim.fn.sign_define("NvimTreeDiagnosticWarnIcon",  {text = "", texthl = "DiagnosticSignWarn"})
vim.fn.sign_define("NvimTreeDiagnosticInfoIcon",  {text = "", texthl = "DiagnosticSignInfo"})
vim.fn.sign_define("NvimTreeDiagnosticHintIcon",  {text = "", texthl = "DiagnosticSignHint"})
-- Dans ton init.lua
vim.opt.showmatch = true      -- Active le matching
vim.opt.matchtime = 2         -- Durée en dixièmes de seconde (0.2s)



-- Charger la configuration de l'interface utilisateur
require("config.ui")

-- Charger les options générales (clipboard, etc.)
require("config.options")

-- Charger la configuration des plugins
require("plugins")

-- Charger les raccourcis clavier personnalisés
require("config.keymaps")

-- Chargement manuel des diagnostics
require("plugins.diagnostics")

