-- ======================================================
-- CONFIGURATION DE L'INTERFACE UTILISATEUR
-- ======================================================

-- ======================================================
-- CONFIGURATION STARTUP (DÉMARRAGE PROPRE)
-- ======================================================
-- Désactiver netrw (explorateur natif) complètement
vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1

-- Autocommande pour forcer un buffer vide au démarrage
local startup_group = vim.api.nvim_create_augroup("CleanStartup", { clear = true })

vim.api.nvim_create_autocmd("VimEnter", {
  group = startup_group,
  callback = function()
    -- Si aucun fichier n'est ouvert ou si c'est un dossier
    if vim.fn.argc() == 0 or vim.fn.isdirectory(vim.fn.argv(0)) == 1 then
      -- Créer un nouveau buffer vide
      vim.cmd("enew")
    end
  end,
  desc = "Démarrage sur buffer vide"
})

-- ======================================================
-- PERFORMANCE ET TIMING (CONFIGURATION INTELLIGENTE)
-- ======================================================
-- Configuration timeoutlen dynamique selon le mode
vim.opt.timeoutlen = 1000   -- Valeur par défaut pour mode normal (séquences possibles)
vim.opt.ttimeoutlen = 0     -- Pas de délai pour les codes terminaux
vim.opt.updatetime = 100    -- Mise à jour rapide (défaut: 4000ms)

-- Autocommandes pour timeoutlen intelligent
local timeout_group = vim.api.nvim_create_augroup("SmartTimeout", { clear = true })

-- Passage en mode insertion : timeoutlen = 0 (espace instantané)
vim.api.nvim_create_autocmd("InsertEnter", {
  group = timeout_group,
  callback = function()
    vim.opt.timeoutlen = 0
  end,
  desc = "Timeoutlen 0 en mode insertion"
})

-- Sortie du mode insertion : timeoutlen = 1000 (séquences possibles)
vim.api.nvim_create_autocmd("InsertLeave", {
  group = timeout_group,
  callback = function()
    vim.opt.timeoutlen = 1000
  end,
  desc = "Timeoutlen 1000 hors mode insertion"
})

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

-- ======================================================
-- INDENTATION STYLE NVCHAD
-- Réglages universels pour une indentation cohérente (2 espaces)
-- Ces options assurent la même expérience qu'avec NvChad
-- ======================================================
vim.opt.tabstop = 2        -- Largeur d’un tab affiché (en espaces)
vim.opt.shiftwidth = 2     -- Largeur d’un niveau d’indentation (autoindent, >>, <<)
vim.opt.expandtab = true   -- Utiliser des espaces au lieu de tabulations
vim.opt.smartindent = true -- Indentation intelligente

-- Explications pédagogiques :
-- tabstop      : nombre d’espaces affichés pour une tabulation
-- shiftwidth   : nombre d’espaces pour chaque niveau d’indentation automatique
-- expandtab    : convertit les tabs en espaces (meilleure compatibilité)
-- smartindent  : active l’indentation intelligente selon le langage
