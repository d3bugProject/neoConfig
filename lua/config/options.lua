vim.api.nvim_create_autocmd("BufWritePre", {
  pattern = { "*.js", "*.jsx", "*.ts", "*.tsx" },
  callback = function()
  end,
})
vim.api.nvim_create_autocmd("BufWritePost", {
  pattern = { "*.js", "*.jsx", "*.ts", "*.tsx" },
  callback = function()
    -- D'abord, organise les imports (tu gardes cette commande)
    vim.cmd("TSToolsOrganizeImports")
    -- Puis, attend un court instant et force un re-scan du workspace pour l'auto-import
    vim.defer_fn(function()
      local clients = vim.lsp.get_active_clients({ name = "ts_ls" })
      for _, client in pairs(clients) do
        if client.server_capabilities.workspaceSymbolProvider then
          client.request("workspace/symbol", { query = "" }, function() end)
        end
      end
    end, 150)
  end,
  desc = "Organise les imports et force le rescan du workspace TypeScript après chaque sauvegarde JS/TS"
})
-- ======================================================
-- OPTIONS NEOVIM - Configuration générale
-- ======================================================

-- Active le presse-papiers système (copier/coller entre Neovim et OS)
vim.opt.clipboard = "unnamedplus"

-- Options supplémentaires utiles pour le développement JS/TS
vim.opt.expandtab = true      -- Utilise des espaces au lieu des tabs
vim.opt.shiftwidth = 2        -- Indentation de 2 espaces
vim.opt.tabstop = 2           -- Tab = 2 espaces
vim.opt.softtabstop = 2       -- Tab en mode insertion = 2 espaces

-- Numéros de ligne
vim.opt.number = true         -- Numéros de ligne
vim.opt.relativenumber = true -- Numéros relatifs

-- Recherche
vim.opt.ignorecase = true     -- Ignore la casse dans la recherche
vim.opt.smartcase = true      -- Mais la respecte si majuscule présente

-- Affichage
vim.opt.cursorline = true     -- Surligne la ligne courante
vim.opt.wrap = false          -- Pas de retour à la ligne automatique

-- Affichage des indentations et espaces
vim.opt.list = true           -- Active l'affichage des caractères invisibles
 vim.opt.listchars = {
   tab = "  ",               -- Tabs invisibles
   --space = "·",              -- Espaces avec points discrets
   trail = "·",              -- Espaces en fin de ligne
   extends = "…",            -- Plus discret
   precedes = "…"
 }
--vim.opt.listchars = {
--  tab = "→ ",                 -- Affiche les tabs avec →
--  space = "·",                -- Affiche les espaces avec ·
--  trail = "•",                -- Affiche les espaces en fin de ligne avec •
--  extends = "▸",              -- Caractère quand la ligne dépasse à droite
--  precedes = "◂",             -- Caractère quand la ligne dépasse à gauche
--  nbsp = "␣"                  -- Affiche les espaces insécables
--}

-- Alternative plus discrète (optionnel, décommentez si vous préférez)
-- vim.opt.listchars = {
--   tab = "  ",               -- Tabs invisibles
--   space = "·",              -- Espaces avec points discrets
--   trail = "·",              -- Espaces en fin de ligne
--   extends = "…",            -- Plus discret
--   precedes = "…"
-- }
--
--
--
-- ======================================================
-- AUTO-RELOAD DE LA CONFIGURATION
-- ======================================================

-- Recharge automatiquement la config après sauvegarde
vim.api.nvim_create_autocmd("BufWritePost", {
  pattern = {
    "**/nvim/lua/**/*.lua",     -- Tous les fichiers lua dans nvim/lua/
    "**/nvim/lua/config/*.lua", -- Spécifiquement le dossier config
    "**/nvim/lua/plugins/*.lua", -- Spécifiquement le dossier plugins
    "**/nvim/snippets/*.json",  -- Fichiers snippets JSON
    "**/nvim/init.lua",         -- Fichier init.lua principal
  },
  callback = function()
    -- Sauvegarde la position actuelle
    local cursor_pos = vim.api.nvim_win_get_cursor(0)
    
    -- Recharge la configuration
    vim.cmd("source %")
    
    -- Affiche un message de confirmation
    vim.notify("Configuration rechargée ! 🔄", vim.log.levels.INFO)
    
    -- Restaure la position du curseur
    vim.api.nvim_win_set_cursor(0, cursor_pos)
  end,
  desc = "Auto-reload Neovim config"
})
