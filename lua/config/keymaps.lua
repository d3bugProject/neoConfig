
local opt = {noremap = true, silent = true}
-- ======================================================
-- CONFIGURATION DES RACCOURCIS CLAVIER
-- ======================================================
--
--
--
-- ======================================================
-- Reload config
-- -- ======================================================

-- Keymap manuel pour recharger la config (optionnel)
vim.keymap.set('n', '<leader>r', function()
  local current_file = vim.fn.expand('%:p')
  
  -- Vérifie si le fichier existe et est un fichier lua
  if current_file == '' then
    vim.notify("Aucun fichier à recharger", vim.log.levels.WARN)
    return
  end
  
  if not current_file:match('%.lua$') then
    vim.notify("Ce n'est pas un fichier Lua", vim.log.levels.WARN)
    return
  end
  
  -- Sauvegarde d'abord si le fichier est modifié
  if vim.bo.modified then
    vim.cmd('write')
  end
  
  -- Recharge le fichier
  local ok, err = pcall(vim.cmd, 'source ' .. current_file)
  if ok then
    vim.notify("Config rechargée ! ⚡", vim.log.levels.INFO)
  else
    vim.notify("Erreur lors du rechargement: " .. err, vim.log.levels.ERROR)
  end
end, { desc = 'Reload current lua file' })

-- Keymap pour recharger complètement Neovim (plus radical)
vim.keymap.set('n', '<leader>R', function()
  local config_path = vim.fn.stdpath('config') .. '/init.lua'
  local ok, err = pcall(vim.cmd, 'source ' .. config_path)
  if ok then
    vim.notify("Configuration complète rechargée ! 🚀", vim.log.levels.INFO)
  else
    vim.notify("Erreur: " .. err, vim.log.levels.ERROR)
  end
end, { desc = 'Reload full config' })




-- ======================================================
-- GESTION DES PANES/SPLITS
-- ======================================================

-- Alt + v : Split vertical + nouveau fichier vide
vim.keymap.set("n", "<A-v>", function()
  vim.cmd("vsplit")           -- Créer un split vertical
  vim.cmd("enew")             -- Ouvrir un nouveau fichier vide
end, { desc = "Split vertical + nouveau fichier" })

-- Alt + h : Split horizontal + nouveau fichier vide
vim.keymap.set("n", "<A-h>", function()
  vim.cmd("split")            -- Créer un split horizontal
  vim.cmd("enew")             -- Ouvrir un nouveau fichier vide
end, { desc = "Split horizontal + nouveau fichier" })

-- Alt + x : Fermer le pane actuel
vim.keymap.set("n", "<A-x>", "<cmd>close<CR>", { desc = "Fermer le pane actuel" })

-- Shift + Tab : Navigation entre splits (cycle dans l'onglet)
vim.keymap.set("n", "<S-Tab>", "<C-w>w", { desc = "Split suivant (cycle)" })

-- Alt + Left/Right : Navigation entre onglets Neovim
vim.keymap.set("n", "<A-Left>", "<cmd>tabprevious<CR>", { desc = "Onglet précédent" })
vim.keymap.set("n", "<A-Right>", "<cmd>tabnext<CR>", { desc = "Onglet suivant" })

-- Alt + Up/Down : Navigation entre splits verticaux (optionnel)
vim.keymap.set("n", "<A-Up>", "<C-w>k", { desc = "Split du haut" })
vim.keymap.set("n", "<A-Down>", "<C-w>j", { desc = "Split du bas" })

-- Alt + - : Réduire la largeur du pane
vim.keymap.set("n", "<A-->", "<cmd>vertical resize -5<CR>", { desc = "Réduire largeur pane" })

-- Alt + = : Augmenter la largeur du pane
vim.keymap.set("n", "<A-=>", "<cmd>vertical resize +5<CR>", { desc = "Augmenter largeur pane" })

-- ======================================================
-- RACCOURCIS DE SÉLECTION
-- ======================================================

-- Ctrl + a : Sélectionner tout le buffer (comme dans VSCode/Sublime)
vim.keymap.set(
  "n",
  "<C-a>",
  "gg<S-v>G",
  { desc = "Sélectionner tout le buffer (mode normal)" }
)

-- ======================================================
-- GESTION DES TABS (ONGLETS NEOVIM) - CORRIGÉ
-- ======================================================

-- Alt + t : Nouvel onglet Neovim
vim.keymap.set("n", "<A-t>", "<cmd>tabnew<CR>", { desc = "Nouvel onglet" })

-- Ctrl + w : Fermer l'onglet actuel
vim.keymap.set("n", "<C-w>", "<cmd>tabclose<CR>", { desc = "Fermer onglet" })

-- Raccourcis numériques pour navigation directe (Alt + 1, Alt + 2, etc.)
for i = 1, 9 do
  vim.keymap.set("n", "<A-" .. i .. ">", "<cmd>" .. i .. "tabnext<CR>", 
    { desc = "Aller à l'onglet " .. i })
end

-- ======================================================
-- GESTION DES BUFFERS - VERSION SNIPE MINIMALISTE
-- ======================================================

-- Navigation native entre buffers (sans interface)
vim.keymap.set("n", "<C-Tab>", "<cmd>bprevious<CR>", { desc = "Buffer précédent" })

-- Alt + w : Fermer le buffer actuel
vim.keymap.set("n", "<A-w>", "<cmd>bdelete<CR>", { desc = "Fermer buffer" })

-- Space + B : Fermer tous les buffers sauf l'actuel
vim.keymap.set("n", "<leader>B", "<cmd>%bdelete|edit#|bdelete#<CR>", { desc = "Fermer autres buffers" })

-- Space + bn : Nouveau buffer
vim.keymap.set("n", "<leader>bn", "<cmd>enew<CR>", { desc = "Nouveau buffer" })

-- ======================================================
-- RACCOURCIS DE SAUVEGARDE/FERMETURE
-- ======================================================

-- ======================================================
-- RACCOURCIS DE FERMETURE SIMPLES ET EFFICACES
-- ======================================================

-- x : Fermer le buffer actuel
vim.keymap.set("n", "x", ":w<CR>:bd<CR>",opt,  { noremap = true, desc = "Save and close buffer", nowait = true })

-- xx : Fermer tous les buffers
vim.keymap.set("n", "xx", ":bufdo bd<CR>", opt, { noremap = true, desc = 'close all buffers' })

-- X : Fermer la fenêtre/split actuel
vim.keymap.set("n", "X", ":close<CR>", { desc = "Fermer fenêtre" })

-- q + w : Quitter et sauvegarder tout
vim.keymap.set("n", "Q", function()
  vim.cmd("wall")             -- Sauvegarder tous les fichiers
  vim.cmd("qall")             -- Quitter tous les buffers
end, { desc = "Sauvegarder tout et quitter" })

-- q + x : Quitter sans sauvegarder
vim.keymap.set("n", "qx", "<cmd>qall!<CR>", { desc = "Quitter sans sauvegarder" })

-- ======================================================
-- RACCOURCIS SUPPLÉMENTAIRES - VERSION NATIVE
-- ======================================================

-- Navigation entre buffers alternative (native)
vim.keymap.set("n", "[b", "<cmd>bprevious<CR>", { desc = "Buffer précédent (alt)" })
vim.keymap.set("n", "]b", "<cmd>bnext<CR>", { desc = "Buffer suivant (alt)" })

-- Navigation entre onglets alternative  
vim.keymap.set("n", "[t", "<cmd>tabprevious<CR>", { desc = "Onglet précédent (alt)" })
vim.keymap.set("n", "]t", "<cmd>tabnext<CR>", { desc = "Onglet suivant (alt)" })

-- Liste des buffers ouverts
vim.keymap.set("n", "<leader>bl", "<cmd>buffers<CR>", { desc = "Liste des buffers" })

-- ======================================================
-- RACCOURCIS DE RESIZE AVANCÉS
-- ======================================================

-- Ctrl + flèches : Redimensionner les panes avec plus de précision
vim.keymap.set("n", "<C-Up>", "<cmd>resize +2<CR>", { desc = "Augmenter hauteur pane" })
vim.keymap.set("n", "<C-Down>", "<cmd>resize -2<CR>", { desc = "Réduire hauteur pane" })
vim.keymap.set("n", "<C-Left>", "<cmd>vertical resize -2<CR>", { desc = "Réduire largeur pane" })
vim.keymap.set("n", "<C-Right>", "<cmd>vertical resize +2<CR>", { desc = "Augmenter largeur pane" })

-- ======================================================
-- RACCOURCIS DE NAVIGATION DANS LES PANES
-- ======================================================

-- Ctrl + hjkl : Navigation directionnelle entre panes (alternative à Tab)
vim.keymap.set("n", "<C-h>", "<C-w>h", { desc = "Aller au pane de gauche" })
vim.keymap.set("n", "<C-j>", "<C-w>j", { desc = "Aller au pane du bas" })
vim.keymap.set("n", "<C-k>", "<C-w>k", { desc = "Aller au pane du haut" })
vim.keymap.set("n", "<C-l>", "<C-w>l", { desc = "Aller au pane de droite" })

-- ======================================================
-- RACCOURCIS UTILITAIRES
-- ======================================================

-- Escape pour effacer le highlight de recherche
vim.keymap.set("n", "<Esc>", "<cmd>nohlsearch<CR>", { desc = "Effacer highlight recherche" })

-- Ctrl + s : Sauvegarder rapidement
vim.keymap.set("n", "<C-s>", "<cmd>w<CR>", { desc = "Sauvegarder fichier" })
vim.keymap.set("i", "<C-s>", "<Esc><cmd>w<CR>a", { desc = "Sauvegarder fichier (mode insertion)" })

-- Shift + s : Sauvegarder tous les buffers
vim.keymap.set("n", "<S-s>", "<cmd>wall<CR>", { desc = "Sauvegarder tous les buffers" })

-- Space + f : Formater le document avec Prettier
vim.keymap.set("n", "<leader>f", function()
  -- Vérifier si conform est disponible
  local conform_ok, conform = pcall(require, "conform")
  if conform_ok then
    conform.format({ async = true, lsp_fallback = true })
  else
    -- Fallback sur LSP si conform n'est pas disponible
    vim.lsp.buf.format({ async = true })
  end
end, { desc = "Formater le document" })

-- Space + l : Aller à une ligne spécifique
vim.keymap.set("n", "<leader>l", function()
  vim.ui.input({ prompt = "Aller à la ligne : " }, function(input)
    if input and input ~= "" then
      local line_num = tonumber(input)
      if line_num and line_num > 0 then
        vim.cmd("normal! " .. line_num .. "G")
      else
        vim.notify("Numéro de ligne invalide", vim.log.levels.ERROR)
      end
    end
  end)
end, { desc = "Aller à la ligne numéro" })

-- ======================================================
-- RACCOURCIS Affichage
-- ======================================================

vim.keymap.set('n', '<leader>l', ':set list!<CR>',opt,  { desc = 'Toggle whitespace display' })


-- ======================================================
-- INFORMATIONS SUR LES RACCOURCIS
-- ======================================================

-- Fonction d'aide pour afficher tous les raccourcis personnalisés
local function show_custom_keymaps()
  local custom_maps = {
    "=== NAVIGATION PANES/SPLITS ===",
    "Alt+v : Split vertical + nouveau fichier",
    "Alt+h : Split horizontal + nouveau fichier", 
    "Alt+x : Fermer pane",
    "Tab : Naviguer entre panes",
    "Alt+, : Réduire largeur | Alt+- : Augmenter largeur",
    "",
    "=== GESTION ONGLETS ===",
    "Alt+t : Nouveau tab",
    "Alt+Left/Right : Navigation onglets",
    "Alt+1-9 : Aller à onglet spécifique",
    "Alt+w : Fermer onglet",
    "Space+b : Sélectionner onglet | Space+B : Fermer autres",
    "",
    "=== SAUVEGARDE/FERMETURE ===",
    "qw : Sauvegarder tout et quitter",
    "qx : Quitter sans sauvegarder",
    "Ctrl+s : Sauvegarder rapidement",
  }
  
  for _, line in ipairs(custom_maps) do
    print(line)
  end
end

-- Commande pour afficher l'aide
vim.api.nvim_create_user_command("Keymaps", show_custom_keymaps, { desc = "Afficher les raccourcis personnalisés" })

-- Raccourci pour afficher l'aide : Space + ?
vim.keymap.set("n", "<leader>?", show_custom_keymaps, { desc = "Afficher aide raccourcis" })
