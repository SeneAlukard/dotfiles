return {
  "stevearc/aerial.nvim",
  dependencies = {
    "nvim-treesitter/nvim-treesitter",
    "nvim-tree/nvim-web-devicons",
  },
  config = function()
    require("aerial").setup({
      backends = { "lsp", "treesitter", "markdown", "man" },
      layout = {
        max_width = { 40, 0.2 },
        min_width = 20,
        default_direction = "right",
        placement = "edge",
      },
      filter_kind = {
        "Class",
        "Constructor",
        "Enum",
        "Function",
        "Interface",
        "Module",
        "Method",
        "Struct",
      },
      icons = {
        Class = "󰠱 ",
        Enum = " ",
        Function = "󰊕 ",
        Interface = " ",
        Module = " ",
        Method = "󰆧 ",
        Struct = "󰙅 ",
      },
      highlight_on_hover = true,
      show_guides = true,
    })

    vim.keymap.set("n", "<leader>a", "<cmd>AerialToggle<CR>", { desc = "Toggle Code Outline" })
  end,
}
