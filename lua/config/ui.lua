-- ======================================================
-- CONFIGURATION DE L'INTERFACE UTILISATEUR
-- ======================================================

-- ======================================================
-- NUMÉROTATION DES LIGNES
-- ======================================================
-- Afficher les numéros de ligne
vim.opt.number = true

-- ======================================================
-- CARACTÈRES DE REMPLISSAGE
-- ======================================================
-- Enlever les caractères ~ sur les lignes vides
vim.opt.fillchars = { eob = " " }

-- ======================================================
-- OPTIONS VISUELLES SUPPLÉMENTAIRES (OPTIONNELLES)
-- ======================================================
-- Décommentez les lignes ci-dessous pour activer d'autres améliorations visuelles :

-- Numéros de ligne relatifs (pratique pour la navigation)
-- vim.opt.relativenumber = true

-- Surligner la ligne du curseur
-- vim.opt.cursorline = true

-- Colonnes de guide à 80 et 120 caractères
-- vim.opt.colorcolumn = "80,120"

-- Toujours afficher la colonne des signes (évite le décalage)
-- vim.opt.signcolumn = "yes"

-- Affichage des espaces et tabulations
-- vim.opt.list = true
-- vim.opt.listchars = { tab = "→ ", space = "·", nbsp = "⎵", trail = "•", eol = "↴" }
