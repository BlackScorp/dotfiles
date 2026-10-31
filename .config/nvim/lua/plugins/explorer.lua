return {
  {
    "folke/snacks.nvim",
    opts = {
      dashboard = { enabled = false },
      explorer = { enabled = true },
      picker = {
        sources = {
          explorer = {
            auto_close = false,
            layout = { preset = "sidebar", preview = false },
          },
        },
      },
    },
  },
}
