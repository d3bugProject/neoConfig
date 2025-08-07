-- ======================================================
-- NAVIGATION PLUGINS
-- Neo-tree, Telescope, Hop, Oil
-- ======================================================

return {
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
              local node = state.tree:get_node()
              if node.type == "file" then
                state.commands.open(state)
                -- Fermer neo-tree après ouverture d'un fichier
                vim.cmd("Neotree close")
              else
                state.commands.toggle_node(state)
              end
            end,
            ["o"] = {
              "toggle_node",
              nowait = false,
            },
            ["<esc>"] = "cancel",
            ["P"] = { "toggle_preview", config = { use_float = true, use_image_nvim = false } },
            ["l"] = "focus_preview",
            ["S"] = "open_split",
            ["s"] = "open_vsplit",
            ["t"] = "open_tabnew",
            ["w"] = "open_with_window_picker",
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
}
