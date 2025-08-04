

-- Diagnostics natifs Neovim (config avant lspsaga)
vim.diagnostic.config({
  virtual_text = {
    prefix = "●",
    spacing = 2,
  },
  signs = false, -- pas de signes custom pour éviter les warnings
  underline = {
    underline = false,
    undercurl = true, -- active le soulignement en vague
  },
  update_in_insert = false,
  severity_sort = true,
  float = {
    border = "rounded",
    source = "always",
    header = "",
    prefix = "",
  },
})
