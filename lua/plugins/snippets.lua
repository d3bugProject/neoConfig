-- plugins/snippets.lua
-- Charge tous les snippets JSON du dossier snippets et les convertit pour LuaSnip

local ls = require("luasnip")
local s = ls.snippet
local t = ls.text_node
local i = ls.insert_node
local f = ls.function_node
local uv = vim.loop

-- Table pour stocker la correspondance trigger -> import
local snippet_imports = {}

-- Fonction pour ajouter un import littéral en haut du fichier
local function add_import(import_statement)
  if not import_statement or import_statement == "" then return end
  local bufnr = vim.api.nvim_get_current_buf()
  vim.api.nvim_buf_set_lines(bufnr, 0, 0, false, {import_statement})
end

-- Variables spéciales VS Code/TextMate
local function get_special_variable(var_name)
  local special_vars = {
    ["1maj"] = function(args)
      local val = args and args[1] or ""
      if not val or val == "" then return "" end
      return val:sub(1,1):upper() .. val:sub(2)
    end,
    TM_FILENAME_BASE = function()
      local filename = vim.fn.expand("%:t:r")
      return filename ~= "" and filename or "Component"
    end,
    TM_FILENAME_MAJ = function()
      local filename = vim.fn.expand("%:t:r")
      if filename == "" then return "Component" end
      return filename:sub(1,1):upper() .. filename:sub(2)
    end,
    TM_FILENAME = function()
      return vim.fn.expand("%:t")
    end,
    TM_DIRECTORY = function()
      return vim.fn.expand("%:h:t")
    end,
    TM_FILEPATH = function()
      return vim.fn.expand("%:p")
    end,
  }
  
  return special_vars[var_name]
end

-- Parser amélioré pour les snippets avec gestion des échappements
local function parse_snippet_body(body)
  local nodes = {}
  
  -- D'abord, traiter les échappements dans le body
  body = body:gsub("\\n", "\n")  -- Convertir \n en vrais sauts de ligne
  body = body:gsub("\\t", "\t")  -- Convertir \t en vraies tabulations
  body = body:gsub("\\\"", "\"") -- Convertir \" en guillemets
  body = body:gsub("\\'", "'")   -- Convertir \' en apostrophes
  body = body:gsub("\\\\", "\\") -- Convertir \\ en backslash simple
  
  local lines = vim.split(body, "\n", { plain = true })
  
  local placeholder_values = {}
  for line_idx, line in ipairs(lines) do
    local col = 1
    while col <= #line do
      local dollar_pos = line:find("%$", col)
      if not dollar_pos then
        if col <= #line then
          table.insert(nodes, t(line:sub(col)))
        end
        break
      end
      if dollar_pos > col then
        table.insert(nodes, t(line:sub(col, dollar_pos - 1)))
      end
      local after_dollar = line:sub(dollar_pos + 1)
      local brace_content = after_dollar:match("^{([^}]*)}")
      if brace_content then
        local num, default_val = brace_content:match("^(%d+):(.*)$")
        if num then
          table.insert(nodes, i(tonumber(num), default_val))
          placeholder_values[num] = default_val or ""
        elseif brace_content:match("^%d+$") then
          table.insert(nodes, i(tonumber(brace_content)))
          placeholder_values[brace_content] = ""
        elseif brace_content:match("^%d+maj$") then
          local base_num = brace_content:match("^(%d+)maj$")
          table.insert(nodes, f(function(args)
            local val = args[1][1] or ""
            if not val or val == "" then return "" end
            return val:sub(1,1):upper() .. val:sub(2)
          end, {tonumber(base_num)}))
        else
          local var_func = get_special_variable(brace_content)
          if var_func then
            table.insert(nodes, f(var_func, {}))
          else
            table.insert(nodes, t(brace_content))
          end
        end
        col = dollar_pos + 1 + #brace_content + 2
      else
        local num = after_dollar:match("^(%d+)")
        if num then
          table.insert(nodes, i(tonumber(num)))
          placeholder_values[num] = ""
          col = dollar_pos + 1 + #num
        else
          table.insert(nodes, t("$"))
          col = dollar_pos + 1
        end
      end
    end
    if line_idx < #lines then
      table.insert(nodes, t({"", ""}))
    end
  end
  
  return nodes
end



-- Charger les snippets JSON
local function load_snippets()
  local snippets = {}
  local snippet_path = vim.fn.stdpath("config") .. "/lua/snippets/"
  
  -- Créer le dossier s'il n'existe pas
  vim.fn.mkdir(snippet_path, "p")
  
  local handle = uv.fs_scandir(snippet_path)
  if not handle then 
    print("Aucun dossier snippets trouvé: " .. snippet_path)
    return snippets 
  end
  
  local files_found = 0
  while true do
    local name = uv.fs_scandir_next(handle)
    if not name then break end
    
    if name:match("%.json$") then
      files_found = files_found + 1
      local file_path = snippet_path .. name
      local file = io.open(file_path, "r")
      
      if file then
        local content = file:read("*a")
        file:close()
        
        local ok, data = pcall(vim.json.decode, content)
        if ok and type(data) == "table" then
          -- Support format array
          if data[1] then
            for _, snip in ipairs(data) do
              if snip.trigger and snip.snippet then
                table.insert(snippets, snip)
                -- Stocker la correspondance trigger -> import
                if snip.import then
                  snippet_imports[snip.trigger] = snip.import
                end
              end
            end
          else
            -- Support format VS Code (objet)
            for key, snip in pairs(data) do
              if snip.prefix and snip.body then
                local body_text = type(snip.body) == "table" and table.concat(snip.body, "\n") or snip.body
                local snippet_data = {
                  trigger = snip.prefix,
                  snippet = body_text,
                  import = snip.import,
                  description = snip.description
                }
                table.insert(snippets, snippet_data)
                if snip.import then
                  snippet_imports[snip.prefix] = snip.import
                end
              end
            end
          end
        else
          print("Erreur JSON dans " .. name .. ": " .. tostring(data))
        end
      else
        print("Impossible de lire " .. file_path)
      end
    end
  end
  
  print("Snippets chargés: " .. #snippets .. " depuis " .. files_found .. " fichiers")
  return snippets
end

-- Charger tous les snippets
local all_snippets = load_snippets()

-- Créer les snippets LuaSnip
local luasnip_snippets = {}
for _, snip in ipairs(all_snippets) do
  local snippet_nodes = parse_snippet_body(snip.snippet)
  if snip.import and snip.import ~= "" then
    table.insert(snippet_nodes, 1, f(function()
      local bufnr = vim.api.nvim_get_current_buf()
      -- Lire les 5 premières lignes pour éviter les doublons
      local lines = vim.api.nvim_buf_get_lines(bufnr, 0, 5, false)
      for _, l in ipairs(lines) do
        if l == snip.import then return "" end
      end
      -- Insérer l'import en haut si absent
      vim.api.nvim_buf_set_lines(bufnr, 0, 0, false, {snip.import})
      return ""
    end, {}))
  end
  table.insert(luasnip_snippets, s(snip.trigger, snippet_nodes))
end

-- Ajouter les snippets à LuaSnip
ls.add_snippets("all", luasnip_snippets)

-- Auto-import déclenché SEULEMENT après expansion réelle de snippet
local last_expansion_time = 0
local pending_import = nil

-- Fonction pour vérifier si un snippet vient vraiment d'être étendu
local function check_real_snippet_expansion()
  local current_time = vim.loop.hrtime()
  local current_line = vim.api.nvim_get_current_line()
  local cursor_pos = vim.api.nvim_win_get_cursor(0)
  
  -- Chercher des signes qu'un snippet a été étendu (pas juste tapé)
  local snippet_indicators = {
    "export default function",
    "<View>",
    "<Text>",
    "useState(",
    "useEffect(",
    "return (",
    "() => {",
  }
  
  local has_snippet_content = false
  for _, indicator in ipairs(snippet_indicators) do
    if current_line:find(indicator, 1, true) then
      has_snippet_content = true
      break
    end
  end
  
  -- Si on détecte du contenu de snippet ET qu'un import est en attente
  if has_snippet_content and pending_import then
    add_import(pending_import)
    pending_import = nil
    last_expansion_time = current_time
  end
end

-- Autocmd pour déclencher l'auto-import SEULEMENT après expansion réelle
vim.api.nvim_create_augroup("SnippetAutoImport", { clear = true })

-- Détecter quand un trigger est tapé (mais pas encore étendu)
vim.api.nvim_create_autocmd("TextChangedI", {
  group = "SnippetAutoImport",
  callback = function()
    local current_line = vim.api.nvim_get_current_line()
    local cursor_pos = vim.api.nvim_win_get_cursor(0)
    local before_cursor = current_line:sub(1, cursor_pos[2])
    
    -- Chercher si on vient de taper un trigger (sans contenu de snippet encore)
    local words = vim.split(before_cursor, "%s+")
    local last_word = words[#words] or ""
    
    -- Si le dernier mot est un trigger connu et qu'il n'y a pas encore de contenu de snippet
    if snippet_imports[last_word] then
      local has_snippet_content = current_line:find("<") or current_line:find("export") or current_line:find("function")
      if not has_snippet_content then
        -- Juste stocker l'import en attente, ne pas l'ajouter maintenant
        pending_import = snippet_imports[last_word]
      else
        -- Le snippet est déjà étendu, ajouter l'import
        check_real_snippet_expansion()
      end
    else
      -- Vérifier si on a du contenu de snippet avec un import en attente
      check_real_snippet_expansion()
    end
  end,
})

-- Backup: utiliser InsertLeave pour les cas où TextChangedI ne suffit pas
vim.api.nvim_create_autocmd("InsertLeave", {
  group = "SnippetAutoImport",
  callback = function()
    if pending_import then
      local current_time = vim.loop.hrtime()
      -- Si on sort du mode insertion et qu'il y a plus de 500ms depuis la dernière expansion
      if current_time - last_expansion_time > 500000000 then
        check_real_snippet_expansion()
      end
    end
  end,
})

-- Utiliser aussi CursorMovedI pour détecter les mouvements dans les placeholders
vim.api.nvim_create_autocmd("CursorMovedI", {
  group = "SnippetAutoImport",
  callback = function()
    check_real_snippet_expansion()
  end,
})

-- Commandes utiles
vim.api.nvim_create_user_command("SnippetsReload", function()
  snippet_imports = {}
  all_snippets = load_snippets()
  luasnip_snippets = {}
  
  for _, snip in ipairs(all_snippets) do
    table.insert(luasnip_snippets, s(snip.trigger, parse_snippet_body(snip.snippet)))
    if snip.import then
      snippet_imports[snip.trigger] = snip.import
    end
  end
  
  ls.add_snippets("all", luasnip_snippets)
  print("Snippets rechargés: " .. #all_snippets .. " snippets, " .. vim.tbl_count(snippet_imports) .. " imports")
end, {})

vim.api.nvim_create_user_command("SnippetsList", function()
  print("=== Snippets chargés ===")
  for i, snip in ipairs(all_snippets) do
    local import_info = snip.import and (" -> " .. snip.import) or ""
    print(string.format("%d. %s: %s%s", i, snip.trigger, snip.snippet:gsub("\n", "\\n"), import_info))
  end
  print("\n=== Imports mappés ===")
  for trigger, import_stmt in pairs(snippet_imports) do
    print(string.format("%s -> %s", trigger, import_stmt))
  end
end, {})

vim.api.nvim_create_user_command("SnippetsDebug", function()
  print("Ligne courante: " .. vim.api.nvim_get_current_line())
  print("Nombre de snippets: " .. #all_snippets)
  print("Nombre d'imports: " .. vim.tbl_count(snippet_imports))
  
  local buf = vim.api.nvim_get_current_buf()
  local lines = vim.api.nvim_buf_get_lines(buf, 0, 10, false)
  print("Premières lignes du buffer:")
  for i, line in ipairs(lines) do
    print(string.format("%d: %s", i, line))
  end
end, {})

-- Remplace $FN par le nom du fichier courant dans le buffer actif
vim.api.nvim_create_autocmd("User", {
  pattern = "LuasnipInsertNodeEnter",
  callback = function()
    local filename = vim.fn.expand("%:t")
    -- Remplace toutes les occurrences de $FN dans la ligne courante
    local line = vim.api.nvim_get_current_line()
    local new_line = line:gsub("%$FN", filename)
    if new_line ~= line then
      vim.api.nvim_set_current_line(new_line)
    end
  end,
})
