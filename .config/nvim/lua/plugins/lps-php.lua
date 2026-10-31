return {
  "neovim/nvim-lspconfig",
  config = function()
    require("lspconfig").intelephense.setup({
      cmd = { "intelephense", "--stdio" },
      root_dir = require("lspconfig.util").root_pattern("composer.json", ".git"),
    })
  end
}