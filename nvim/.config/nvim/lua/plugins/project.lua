return {
  "ahmedkhalf/project.nvim",
  config = function()
    require("project_nvim").setup({
      detection_methods = { "pattern", "lsp" },
      patterns = { ".git", "Makefile", "package.json" },
      show_hidden = false,
    })
    -- Integrate with telescope
    require("telescope").load_extension("projects")
  end,
  keys = {
    { "<leader>fp", "<cmd>Telescope projects<cr>", desc = "Find Projects" },
  },
}
