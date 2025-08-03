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

-- Initialise Lazy.nvim avec les plugins de navigation
-- Cette fonction setup() va gérer tous les plugins que nous ajouterons plus tard
require("lazy").setup({
  
  -- ======================================================
  -- NAVIGATION PRINCIPALE - NEO-TREE
  -- ======================================================
  {
    "nvim-neo-tree/neo-tree.nvim",
    branch = "v3.x",
    dependencies = {
      "nvim-lua/plenary.nvim",        -- Fonctions utilitaires requises
      "nvim-tree/nvim-web-devicons",  -- Icônes de fichiers
      "MunifTanjim/nui.nvim",        -- Composants UI pour neo-tree
    },
    config = function()
      -- Configuration de neo-tre
      require("neo-tree").setup({
        -- Fermer automatiquement si c'est le dernier buffer
        close_if_last_window = false,
        -- Position de l'arbre (left, right, float)
        window = {
          position = "left",
          width = 30,
          -- Mappings personnalisés dans neo-tree
          mappings = {
            -- Désactiver le mapping 'f' par défaut de neo-tree
            ["f"] = "noop",
            -- Garder les autres mappings utiles
            ["<space>"] = {
              "toggle_node",
              nowait = false,
            },
            ["<2-LeftMouse>"] = "open",
            ["<cr>"] = function(state)
              -- Fonction personnalisée pour Enter : ouvrir le fichier et fermer neo-tree
              local node = state.tree:get_node()
              if node.type == "file" then
                -- Ouvrir le fichier
                require("neo-tree.sources.filesystem.commands").open(state)
                -- Fermer neo-tree après ouverture
                require("neo-tree.command").execute({ action = "close" })
              else
                -- Si c'est un dossier, comportement normal (expand/collapse)
                require("neo-tree.sources.filesystem.commands").toggle_node(state)
              end
            end,
            ["o"] = "open",
            ["S"] = "open_split",
            ["s"] = "open_vsplit",
            ["t"] = "open_tabnew",
            ["C"] = "close_node",
            ["z"] = "close_all_nodes",
            ["Z"] = "expand_all_nodes",
            ["a"] = {
              "add",
              config = {
                show_path = "none"
              }
            },
            ["A"] = "add_directory",
            ["d"] = "delete",
            ["r"] = "rename",
            ["y"] = "copy_to_clipboard",
            ["x"] = "cut_to_clipboard",
            ["p"] = "paste_from_clipboard",
            ["c"] = "copy",
            ["m"] = "move",
            ["q"] = "close_window",
            ["R"] = "refresh",
            ["?"] = "show_help",
          },
        },
        -- Configuration filesystem avec fichiers cachés forcés
        filesystem = {
          filtered_items = {
            visible = true,           -- Rendre les éléments filtrés visibles
            hide_dotfiles = false,    -- NE PAS cacher les fichiers commençant par .
            hide_gitignored = false,  -- NE PAS cacher les fichiers dans .gitignore
            hide_by_name = {
              "node_modules",         -- Exclure seulement node_modules
              ".git",                 -- Exclure seulement le dossier .git (pas .gitignore)
            },
            hide_by_pattern = {},     -- Aucun pattern à cacher
            always_show = {           -- Toujours afficher ces fichiers
              ".gitignore",
              ".env",
              ".eslintrc",
              ".prettierrc",
              ".nvmrc",
              ".babelrc",
            },
            never_show = {},          -- Aucun fichier à ne jamais afficher
          },
          -- Forcer l'affichage des fichiers cachés par défaut
          follow_current_file = {
            enabled = true,
          },
          group_empty_dirs = false,
          hijack_netrw_behavior = "disabled",  -- DÉSACTIVÉ pour éviter l'ouverture automatique
          use_libuv_file_watcher = true,
        },
        -- Options d'affichage par défaut
        default_component_configs = {
          filesystem = {
            show_hidden_count = false,  -- Ne pas afficher le compteur "X hidden files"
          },
        },
      })
      
      -- Fonction intelligente pour la touche 'f' - Version corrigée avec API officielle
      local function smart_tree_toggle()
        -- Vérifie si neo-tree est visible dans la fenêtre actuelle
        local current_winid = vim.api.nvim_get_current_win()
        local current_buf = vim.api.nvim_win_get_buf(current_winid)
        local current_filetype = vim.api.nvim_buf_get_option(current_buf, 'filetype')
        
        if current_filetype == 'neo-tree' then
          -- Si on est dans neo-tree, le fermer
          vim.cmd("Neotree close")
        else
          -- Vérifier si neo-tree est ouvert quelque part
          local tree_visible = false
          for _, win in ipairs(vim.api.nvim_list_wins()) do
            local buf = vim.api.nvim_win_get_buf(win)
            local ft = vim.api.nvim_buf_get_option(buf, 'filetype')
            if ft == 'neo-tree' then
              tree_visible = true
              break
            end
          end
          
          if tree_visible then
            -- Si neo-tree est ouvert ailleurs, y aller et révéler le fichier
            vim.cmd("Neotree focus")
            vim.cmd("Neotree reveal")
          else
            -- Si neo-tree n'est pas ouvert, l'ouvrir et révéler le fichier
            vim.cmd("Neotree show")
            vim.cmd("Neotree reveal")
          end
        end
      end
      
      -- Raccourcis clavier pour neo-tree
      vim.keymap.set("n", "f", smart_tree_toggle, { desc = "Toggle Neo-tree intelligemment" })
      vim.keymap.set("n", "F", "<cmd>Neotree close<CR>", { desc = "Fermer Neo-tree dans tous les cas" })
    end,
  },

  -- ======================================================
  -- RECHERCHE DE FICHIERS - TELESCOPE
  -- ======================================================
  {
    "nvim-telescope/telescope.nvim",
    tag = "0.1.8",
    dependencies = { "nvim-lua/plenary.nvim" },
    config = function()
      -- Configuration de telescope - Version restaurée et simplifiée
      require("telescope").setup({
        defaults = {
          -- Configuration minimale qui fonctionne sans dépendances externes
          file_ignore_patterns = {
            "node_modules/",        -- Exclure node_modules
            "%.git/",              -- Exclure .git/
            "%.lock",              -- Exclure fichiers .lock
          },
        },
        pickers = {
          find_files = {
            -- Options pour afficher les fichiers cachés
            hidden = true,          -- Afficher les fichiers cachés
            no_ignore = true,       -- Ignorer .gitignore pour voir les fichiers cachés
          },
        },
      })
      
      -- Raccourci pour recherche de fichiers
      vim.keymap.set("n", "<leader><leader>", "<cmd>Telescope find_files<CR>", { desc = "Rechercher fichiers" })
    end,
  },

  -- ======================================================
  -- NAVIGATION RAPIDE - HOP
  -- ======================================================
  {
    "smoka7/hop.nvim",
    version = "*",
    config = function()
      -- Configuration de hop
      require("hop").setup()
      
      -- Raccourci pour hop (m + caractères)
      vim.keymap.set("n", "m", "<cmd>HopChar1<CR>", { desc = "Hop vers caractère" })
    end,
  },

  -- ======================================================
  -- TERMINAL FLOTTANT - TOGGLETERM
  -- ======================================================
  {
    "akinsho/toggleterm.nvim",
    version = "*",
    config = function()
      -- Configuration du terminal flottant
      require("toggleterm").setup({
        size = 20,
        open_mapping = [[<leader>t]],  -- Space + t
        hide_numbers = true,
        direction = "float",           -- Terminal flottant
        float_opts = {
          border = "curved",
          winblend = 0,
        },
      })
      
      -- Raccourci pour terminal flottant
      vim.keymap.set("n", "<leader>t", "<cmd>ToggleTerm<CR>", { desc = "Terminal flottant" })
    end,
  },

  -- ======================================================
  -- NAVIGATION ALTERNATIVE - OIL.NVIM (TEST)
  -- ======================================================
  {
    "stevearc/oil.nvim",
    config = function()
      -- Configuration d'oil.nvim
      require("oil").setup({
        -- DÉSACTIVATION DU HIJACKING AUTOMATIQUE
        default_file_explorer = false,  -- Ne pas remplacer netrw par défaut
        
        -- Colonnes à afficher - Version épurée (icône + nom seulement)
        columns = {
          "icon",    -- Icône du type de fichier
          -- Permissions, taille et date supprimées pour un affichage épuré
        },
        -- Utiliser les raccourcis clavier par défaut d'Oil
        use_default_keymaps = true,
        view_options = {
          -- Afficher les fichiers cachés
          show_hidden = false,
        },
      })
      
      -- Raccourci pour oil.nvim (Space + o)
      vim.keymap.set("n", "<leader>o", "<cmd>Oil<CR>", { desc = "Ouvrir Oil.nvim" })
    end,
  },

  -- ======================================================
  -- INTERFACE - SÉLECTEUR DE BUFFERS SNIPE (MINIMALISTE)
  -- ======================================================
  {
    "leath-dub/snipe.nvim",
    config = function()
      -- Configuration de snipe
      local snipe = require("snipe")
      snipe.setup({
        -- Interface de snipe
        ui = {
          max_width = -1, -- -1 = largeur automatique
          -- Position de la fenêtre (centre, top, bottom)
          position = "topleft",
          -- Style de bordure
          open_win_override = {
            border = "single", -- single, double, rounded, solid, shadow
            title = " Buffers ",
            title_pos = "center",
          },
        },
        -- Touches pour la sélection rapide
        hints = {
          -- Dictionnaire des touches (ordre de priorité)
          dictionary = "asdfjklqwertyuiopzxcvbnm",
        },
        -- Tri des buffers
        sort = "last", -- last, default
        -- Production de sons (optionnel)
        producer = "default", -- default, lsp
      })
      
      -- Raccourci pour ouvrir snipe avec Tab
      vim.keymap.set("n", "<Tab>", snipe.open_buffer_menu, { desc = "Sélecteur de buffers snipe" })
      
      -- Alternative avec Space + b
      vim.keymap.set("n", "<leader>b", snipe.open_buffer_menu, { desc = "Sélecteur de buffers snipe (alt)" })
    end,
  },

  -- ======================================================
  -- INTERFACE - BARRE DE STATUT LUALINE
  -- ======================================================
  {
    "nvim-lualine/lualine.nvim",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    config = function()
      -- Configuration de lualine
      require("lualine").setup({
        options = {
          -- Thème de la barre de statut
          theme = "auto",
          -- Séparateurs entre sections
          component_separators = { left = "", right = "" },
          section_separators = { left = "", right = "" },
          -- Désactiver dans certains types de fichiers
          disabled_filetypes = {
            statusline = {},
            winbar = {},
          },
          -- Ignorer le focus pour ces types
          ignore_focus = {},
          -- Toujours diviser la barre de statut
          always_divide_middle = true,
          -- Barre de statut globale
          globalstatus = false,
          -- Actualisation en ms
          refresh = {
            statusline = 1000,
            tabline = 1000,
            winbar = 1000,
          },
        },
        sections = {
          -- Partie gauche
          lualine_a = { "mode" },                    -- Mode actuel (NORMAL, INSERT, etc.)
          lualine_b = { "branch", "diff", "diagnostics" }, -- Git + diagnostics
          lualine_c = { "filename" },                -- Nom du fichier
          -- Partie droite
          lualine_x = { "encoding", "fileformat", "filetype" }, -- Infos fichier
          lualine_y = { "progress" },                -- Pourcentage du fichier
          lualine_z = { "location" },                -- Position du curseur
        },
        inactive_sections = {
          -- Sections pour fenêtres inactives
          lualine_a = {},
          lualine_b = {},
          lualine_c = { "filename" },
          lualine_x = { "location" },
          lualine_y = {},
          lualine_z = {},
        },
        tabline = {},
        winbar = {},
        inactive_winbar = {},
        extensions = { "neo-tree", "toggleterm", "oil" }, -- Extensions supportées
      })
    end,
  },

  -- ======================================================
  -- DÉVELOPPEMENT WEB - LSP ET AUTOCOMPLÉTION (RÉACTIVÉ)
  -- ======================================================
  
  -- Mason : Gestionnaire automatique des LSP servers
  {
    "williamboman/mason.nvim",
    config = function()
      require("mason").setup({
        ui = {
          border = "rounded",
          icons = {
            package_installed = "✓",
            package_pending = "➜",
            package_uninstalled = "✗"
          }
        }
      })
    end,
  },
  
  -- Mason-LSPconfig : Pont entre Mason et lspconfig
  {
    "williamboman/mason-lspconfig.nvim",
    dependencies = { "williamboman/mason.nvim" },
    config = function()
      require("mason-lspconfig").setup({
        -- Installation automatique des LSP servers
        ensure_installed = {
          "ts_ls",              -- TypeScript/JavaScript
          "html",                -- HTML
          "cssls",              -- CSS
          "tailwindcss",        -- TailwindCSS
          "eslint",             -- ESLint
          "jsonls",             -- JSON
        },
        -- Installation automatique
        automatic_installation = true,
      })
    end,
  },
  
  -- LSP Configuration
  {
    "neovim/nvim-lspconfig",
    dependencies = { "williamboman/mason-lspconfig.nvim" },
    config = function()
      local lspconfig = require("lspconfig")
      
      -- Configuration commune pour tous les LSP
      local on_attach = function(client, bufnr)
        -- Raccourcis LSP
        local opts = { buffer = bufnr }
        vim.keymap.set("n", "gd", vim.lsp.buf.definition, opts)
        vim.keymap.set("n", "gr", vim.lsp.buf.references, opts)
        vim.keymap.set("n", "gi", vim.lsp.buf.implementation, opts)
        vim.keymap.set("n", "K", vim.lsp.buf.hover, opts)
        vim.keymap.set("n", "<leader>rn", vim.lsp.buf.rename, opts)
        vim.keymap.set("n", "<leader>ca", vim.lsp.buf.code_action, opts)
      end
      
      -- Configuration TypeScript/JavaScript
      lspconfig.ts_ls.setup({
        on_attach = on_attach,
        filetypes = { "javascript", "javascriptreact", "typescript", "typescriptreact" },
        settings = {
          typescript = {
            preferences = {
              inlayHints = {
                includeInlayParameterNameHints = "all",
                includeInlayParameterNameHintsWhenArgumentMatchesName = false,
                includeInlayFunctionParameterTypeHints = true,
                includeInlayVariableTypeHints = true,
                includeInlayPropertyDeclarationTypeHints = true,
                includeInlayFunctionLikeReturnTypeHints = true,
                includeInlayEnumMemberValueHints = true,
              },
            },
          },
        },
      })
      
      -- Configuration HTML
      lspconfig.html.setup({
        on_attach = on_attach,
        filetypes = { "html" },
      })
      
      -- Configuration CSS
      lspconfig.cssls.setup({
        on_attach = on_attach,
        filetypes = { "css", "scss", "less" },
      })
      
      -- Configuration TailwindCSS
      lspconfig.tailwindcss.setup({
        on_attach = on_attach,
        filetypes = { "html", "css", "javascript", "javascriptreact", "typescript", "typescriptreact" },
      })
      
      -- Configuration ESLint
      lspconfig.eslint.setup({
        on_attach = on_attach,
        filetypes = { "javascript", "javascriptreact", "typescript", "typescriptreact" },
      })
      
      -- Configuration JSON
      lspconfig.jsonls.setup({
        on_attach = on_attach,
        filetypes = { "json", "jsonc" },
      })
    end,
  },
  
  -- Blink.cmp : Autocomplétion moderne (RÉACTIVÉ)
  {
    "saghen/blink.cmp",
    lazy = false,
    dependencies = "rafamadriz/friendly-snippets",
    version = "v0.*",
    config = function()
      require("blink.cmp").setup({
        -- Configuration des touches
        keymap = {
          preset = "default", -- Utiliser le preset par défaut pour éviter les conflits
          
          -- Remplacer seulement les touches nécessaires
          ["<Up>"] = { "select_prev", "fallback" },
          ["<Down>"] = { "select_next", "fallback" },
          ["<CR>"] = { "accept", "fallback" },
        },
        
        -- Apparence du menu
        appearance = {
          use_nvim_cmp_as_default = true,
          nerd_font_variant = "mono",
        },
        
        -- Sources de complétion avec priorités
        sources = {
          default = { "lsp", "path", "snippets", "buffer" },
          providers = {
            lsp = {
              name = "LSP",
              module = "blink.cmp.sources.lsp",
              score_offset = 100, -- Priorité maximale
            },
            path = {
              name = "Path",
              module = "blink.cmp.sources.path",
              score_offset = 50,
            },
            snippets = {
              name = "Snippets",
              module = "blink.cmp.sources.snippets",
              score_offset = 25,
            },
            buffer = {
              name = "Buffer",
              module = "blink.cmp.sources.buffer",
              score_offset = 10, -- Priorité minimale
            },
          },
        },
        
        -- Configuration des snippets
        snippets = {
          expand = function(snippet) vim.snippet.expand(snippet) end,
          active = function(filter)
            if filter and filter.direction then
              return vim.snippet.active({ direction = filter.direction })
            end
            return vim.snippet.active()
          end,
          jump = function(direction) vim.snippet.jump(direction) end,
        },
        
        -- Configuration de la completion
        completion = {
          accept = {
            auto_brackets = {
              enabled = true,
            },
          },
          menu = {
            draw = {
              treesitter = { "lsp" },
              columns = { { "label", "label_description", gap = 1 }, { "kind_icon", "kind" } },
            },
          },
          documentation = {
            auto_show = true,
            auto_show_delay_ms = 200,
          },
        },
        
        -- Configuration des signatures (DÉSACTIVÉE - remplacée par lsp_signature.nvim)
        signature = {
          enabled = false,  -- Désactivé au profit de lsp_signature.nvim
        },
      })
    end,
  },
  
  -- Conform : Formatage automatique avec Prettier (RÉACTIVÉ)
  {
    "stevearc/conform.nvim",
    config = function()
      require("conform").setup({
        -- Formatters par type de fichier
        formatters_by_ft = {
          javascript = { "prettier" },
          javascriptreact = { "prettier" },
          typescript = { "prettier" },
          typescriptreact = { "prettier" },
          html = { "prettier" },
          css = { "prettier" },
          scss = { "prettier" },
          json = { "prettier" },
          jsonc = { "prettier" },
          markdown = { "prettier" },
        },
        
        -- Formatage automatique à la sauvegarde
        format_on_save = {
          timeout_ms = 500,
          lsp_fallback = true,
        },
      })
      
      -- Raccourci Space+f pour formater manuellement
      vim.keymap.set("n", "<leader>f", function()
        require("conform").format({ async = true, lsp_fallback = true })
      end, { desc = "Formater le fichier" })
    end,
  },
  
  -- LSP Signature : Signature help avec positionnement absolu
  {
    "ray-x/lsp_signature.nvim",
    event = "InsertEnter",
    config = function()
      require("lsp_signature").setup({
        -- Position de la fenêtre flottante
        floating_window = true,
        floating_window_above_cur_line = false,  -- Forcer en bas
        
        -- Positionnement précis (selon documentation officielle)
        floating_window_off_x = function()
          -- Position à droite de l'écran
          return vim.api.nvim_win_get_width(0) - 85  -- 85 chars depuis la gauche
        end,
        floating_window_off_y = function()
          -- Position en bas de l'écran  
          return vim.fn.winheight(0) - 10  -- 10 lignes depuis le haut
        end,
        
        -- Style et taille
        max_width = 80,
        max_height = 8,
        border = "single",
        
        -- Comportement
        fix_pos = true,                         -- Position fixe
        always_trigger = true,                  -- Toujours déclencher
        auto_close_after = nil,                 -- Ne pas fermer automatiquement
        doc_lines = 3,                          -- Lignes de documentation
        
        -- Style
        handler_opts = {
          border = "single"
        },
        
        -- Désactiver les hints virtuels
        hint_enable = false,
        
        -- Z-index pour être au-dessus
        zindex = 200,
      })
    end,
  },

})
