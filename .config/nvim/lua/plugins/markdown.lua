local previews = {}

return {
  { "iamcco/markdown-preview.nvim", enabled = false },
  {
    "folke/snacks.nvim",
    keys = {
      {
        "<leader>cp",
        function()
          local buffer = vim.api.nvim_get_current_buf()
          if previews[buffer] then
            vim.fn.jobstop(previews[buffer])
            previews[buffer] = nil
            return
          end
          if vim.fn.executable("inlyne") ~= 1 then
            vim.notify("Inlyne ist nicht installiert.", vim.log.levels.ERROR)
            return
          end
          local file = vim.api.nvim_buf_get_name(buffer)
          if file == "" then
            vim.notify("Die Markdown-Datei zuerst speichern.", vim.log.levels.WARN)
            return
          end
          vim.cmd("update")
          local job = vim.fn.jobstart({ "inlyne", file }, {
            on_exit = function(job_id)
              if previews[buffer] == job_id then
                previews[buffer] = nil
              end
            end,
          })
          if job <= 0 then
            vim.notify("Inlyne konnte nicht gestartet werden.", vim.log.levels.ERROR)
            return
          end
          previews[buffer] = job
        end,
        ft = { "markdown", "markdown.mdx" },
        desc = "Markdown Preview (Inlyne)",
      },
    },
  },
}
