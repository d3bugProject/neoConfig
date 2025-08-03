# 📋 CheatSheet - Configuration Neovim Custom

## 🔧 Configuration actuelle implémentée

### **Navigation principale avec Neo-tree**
- `f` : Logique intelligente (ouvre/focus/ferme selon l'état)
- `F` (Maj+f) : Ferme le tree dans tous les cas
- `Space + Space` : Recherche de fichiers avec Telescope
- `m` : Navigation rapide avec Hop vers un caractère
- `Space + t` : Terminal flottant avec ToggleTerm
- `Space + o` : Navigation alternative avec Oil.nvim

---

## 🛠️ Oil.nvim - Navigation par Buffer

### **Concept Oil.nvim**
Oil.nvim transforme les **dossiers en buffers éditables**. Vous pouvez modifier le système de fichiers en éditant directement le buffer comme un fichier texte normal.

### **Raccourci d'accès**
- `Space + o` : Ouvrir Oil.nvim dans le dossier courant

### **📁 Navigation de base**
| Commande | Action |
|----------|--------|
| `<CR>` ou `o` | Ouvrir fichier/dossier |
| `-` | Remonter au dossier parent |
| `_` | Ouvrir le dossier courant dans Oil |
| `<C-p>` | Prévisualiser le fichier |
| `<C-c>` | Fermer Oil |
| `<C-l>` | Rafraîchir |

### **✏️ Édition de fichiers/dossiers**
| Commande | Action |
|----------|--------|
| `<C-s>` | Sauvegarder les changements (appliquer au système) |
| `<C-h>` | Basculer fichiers cachés |
| `g?` | Afficher l'aide |

### **📝 Création/Modification (Mode Édition)**
Dans Oil.nvim, vous pouvez **éditer directement** le buffer :

1. **Créer un fichier** : Ajouter une nouvelle ligne avec le nom
2. **Créer un dossier** : Ajouter une ligne se terminant par `/`
3. **Renommer** : Modifier le nom dans le buffer
4. **Supprimer** : Effacer la ligne complète
5. **Déplacer** : Couper/coller la ligne vers un autre endroit

**Puis appuyer sur `<C-s>` pour appliquer tous les changements !**

### **🚀 Exemple d'utilisation Oil.nvim**

```
# Avant édition du buffer :
📁 documents/
📄 readme.txt
📄 config.json

# Après édition du buffer :
📁 documents/
📁 new_folder/          ← Nouveau dossier créé
📄 readme.md            ← readme.txt renommé
📄 config.json
📄 new_file.js          ← Nouveau fichier créé

# Appuyer sur Ctrl+s applique tous ces changements !
```

---

## 🎯 Fonctionnalités à implémenter (TODO)

### **🖼️ Gestion des panes/splits**
- `Alt + v` : Split vertical + nouveau fichier vide
- `Alt + h` : Split horizontal + nouveau fichier vide
- `Alt + x` : Fermer le pane actuel
- `Tab` : Naviguer entre les panes
- `Alt + ,` et `Alt + -` : Redimensionner les panes

### **📑 Gestion des tabs**
- `Alt + t` : Nouveau tab
- `Alt + Left/Right` : Navigation entre tabs

### **💾 Raccourcis de sauvegarde/fermeture**
- `q + w` : Quitter et sauvegarder tout
- `q + x` : Quitter sans sauvegarder

---

## 📚 Documentation technique

### **Plugins utilisés**
1. **neo-tree.nvim** : Explorateur de fichiers en arbre
2. **telescope.nvim** : Recherche floue de fichiers
3. **hop.nvim** : Navigation rapide par caractère
4. **toggleterm.nvim** : Terminal flottant intégré
5. **oil.nvim** : Navigation par buffer éditable

### **Architecture de la configuration**
```
~/.config/nvim/
├── init.lua                 # Point d'entrée + configuration leader
├── lua/plugins/init.lua     # Configuration Lazy.nvim + plugins
└── cheatSheet.md           # Cette documentation
```

### **Touche Leader**
- **Leader** = `Space` (espace)
- Configurée dans `init.lua` avant le chargement des plugins
- Permet tous les raccourcis `<leader>` = `Space + touche`

---

*Dernière mise à jour : Configuration de base avec navigation Oil.nvim*
