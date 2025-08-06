vim.api.nvim_create_autocmd("BufWritePre", {
	pattern = { "*.js", "*.jsx", "*.ts", "*.tsx" },
	callback = function()
		local bufnr = vim.api.nvim_get_current_buf()
		local lines = vim.api.nvim_buf_get_lines(bufnr, 0, -1, false)
		local externals, internals, sidefx, rest = {}, {}, {}, {}
		local external_groups, internal_groups = {}, {}
		
		-- Fonction pour fusionner les imports similaires
		local function merge_imports(groups)
			local merged = {}
			for module, imports_list in pairs(groups) do
				if #imports_list == 1 then
					table.insert(merged, imports_list[1])
				else
					-- Séparer les imports par type
					local default_import, nameds, types = nil, {}, {}
					local quote_style = "'"
					
					for _, import_line in ipairs(imports_list) do
						-- Détecte le style de quotes utilisé
						local q = import_line:match("from%s+(['\"])")
						if q then quote_style = q end
						
						-- Cas 1: import Something from "module"
						local default_only = import_line:match("^import%s+([%w_$]+)%s+from")
						if default_only and not import_line:match("{") then
							default_import = default_only
						end
						
						-- Cas 2: import Something, { named1, named2 } from "module"
						local default_with_named = import_line:match("^import%s+([%w_$]+),%s*{")
						if default_with_named then
							default_import = default_with_named
							local named_part = import_line:match("{(.-)}")
							if named_part then
								for item in named_part:gmatch("([^,]+)") do
									item = item:match("^%s*(.-)%s*$") -- trim
									if item:match("^type%s+") then
										table.insert(types, item:gsub("^type%s+", ""))
									else
										table.insert(nameds, item)
									end
								end
							end
						end
						
						-- Cas 3: import { named1, named2 } from "module"
						local named_only = import_line:match("^import%s+{(.-)}")
						if named_only and not import_line:match("^import%s+[%w_$]+,") then
							for item in named_only:gmatch("([^,]+)") do
								item = item:match("^%s*(.-)%s*$") -- trim
								if item:match("^type%s+") then
									table.insert(types, item:gsub("^type%s+", ""))
								else
									table.insert(nameds, item)
								end
							end
						end
						
						-- Cas 4: import type { Type1, Type2 } from "module"
						local type_only = import_line:match("^import%s+type%s+{(.-)}")
						if type_only then
							for item in type_only:gmatch("([^,]+)") do
								item = item:match("^%s*(.-)%s*$") -- trim
								table.insert(types, item)
							end
						end
					end
					
					-- Reconstruit l'import fusionné
					local parts = {}
					if default_import then
						table.insert(parts, default_import)
					end
					if #nameds > 0 then
						-- Supprime les doublons et trie
						local unique_nameds = {}
						local seen_named = {}
						for _, item in ipairs(nameds) do
							if not seen_named[item] then
								seen_named[item] = true
								table.insert(unique_nameds, item)
							end
						end
						table.sort(unique_nameds)
						local named_str = "{ " .. table.concat(unique_nameds, ", ") .. " }"
						table.insert(parts, named_str)
					end
					
					if #parts > 0 then
						local import_str = "import " .. table.concat(parts, ", ") .. " from " .. quote_style .. module .. quote_style .. ";"
						table.insert(merged, import_str)
					end
					
					-- Ajoute les imports de type séparément si nécessaire
					if #types > 0 then
						-- Supprime les doublons et trie
						local unique_types = {}
						local seen_types = {}
						for _, item in ipairs(types) do
							if not seen_types[item] then
								seen_types[item] = true
								table.insert(unique_types, item)
							end
						end
						table.sort(unique_types)
						local type_str = "import type { " .. table.concat(unique_types, ", ") .. " } from " .. quote_style .. module .. quote_style .. ";"
						table.insert(merged, type_str)
					end
				end
			end
			return merged
		end
		
		for _, line in ipairs(lines) do
			if line:match("^import ") then
				if line:match("^import ['\"]") then
					-- Side effect import
					table.insert(sidefx, line)
				else
					-- Extract module path
					local mod = line:match("from%s+['\"](.-)['\"]")
					if mod then
						if not mod:match("^%.?%./") then
							-- External import
							if not external_groups[mod] then
								external_groups[mod] = {}
							end
							table.insert(external_groups[mod], line)
						else
							-- Internal import
							if not internal_groups[mod] then
								internal_groups[mod] = {}
							end
							table.insert(internal_groups[mod], line)
						end
					else
						-- Fallback pour imports mal formés
						table.insert(internals, line)
					end
				end
			else
				table.insert(rest, line)
			end
		end
		
		-- Fusionne et trie les imports
		externals = merge_imports(external_groups)
		internals = merge_imports(internal_groups)
		table.sort(sidefx)
		table.sort(externals)
		table.sort(internals)
		
		-- Supprime les lignes vides en début de rest
		while rest[1] and rest[1]:match("^%s*$") do 
			table.remove(rest, 1) 
		end
		
		-- Reconstruction du fichier avec espacement approprié
		local new_lines = {}
		
		-- Side effects imports
		for _, l in ipairs(sidefx) do 
			table.insert(new_lines, l) 
		end
		
		-- Séparateur entre side effects et autres imports
		if #sidefx > 0 and (#externals > 0 or #internals > 0) then 
			table.insert(new_lines, "") 
		end
		
		-- External imports
		for _, l in ipairs(externals) do 
			table.insert(new_lines, l) 
		end
		
		-- Séparateur entre external et internal
		if #externals > 0 and #internals > 0 then 
			table.insert(new_lines, "") 
		end
		
		-- Internal imports
		for _, l in ipairs(internals) do 
			table.insert(new_lines, l) 
		end
		
		-- Séparateur entre imports et reste du code
		if (#sidefx > 0 or #externals > 0 or #internals > 0) and #rest > 0 then 
			table.insert(new_lines, "") 
		end
		
		-- Reste du code
		for _, l in ipairs(rest) do 
			table.insert(new_lines, l) 
		end
		
		vim.api.nvim_buf_set_lines(bufnr, 0, -1, false, new_lines)
	end,
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
  tab = "→ ",                 -- Affiche les tabs avec →
  space = "·",                -- Affiche les espaces avec ·
  trail = "•",                -- Affiche les espaces en fin de ligne avec •
  extends = "▸",              -- Caractère quand la ligne dépasse à droite
  precedes = "◂",             -- Caractère quand la ligne dépasse à gauche
  nbsp = "␣"                  -- Affiche les espaces insécables
}

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
