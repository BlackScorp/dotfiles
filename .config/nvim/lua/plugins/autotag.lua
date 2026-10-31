return {
  "windwp/nvim-ts-autotag",
  ft = { "html", "xml", "vue", "twig", "javascript", "typescript" }, -- nur diese Filetypes
  config = function()
    require("nvim-ts-autotag").setup({})
  end
}