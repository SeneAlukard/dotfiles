return {
  "p00f/clangd_extensions.nvim",
  ft = { "c", "cpp", "objc", "objcpp", "cuda", "proto" },
  dependencies = { "neovim/nvim-lspconfig" },
  config = function()
    require("clangd_extensions").setup({
      inlay_hints = {
        inline = true,
        parameter_hints_prefix = "◂ ",
        other_hints_prefix = "▸ ",
      },
      ast = {
        role_icons = {
          type = "🄣",
          declaration = "🄓",
          expression = "🄔",
          statement = "🄢",
          specifier = "🄪",
          -- Add more here
        },
        kind_icons = {
          Compound = "🄲",
          Recovery = "🅁",
          TranslationUnit = "🅄",
          PackExpansion = "🄿",
          TemplateTypeParm = "🅃",
          -- Add more here
        },
      },
      memory_usage = {
        border = "rounded",
      },
      symbol_info = {
        border = "rounded",
      },
    })
  end,
}
