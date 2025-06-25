return {
  "nvim-treesitter/nvim-treesitter",
  build = ":TSUpdate",
  config = function()
    local config = require("nvim-treesitter.configs")
    config.setup({
      ensure_installed = { "c", "cpp", "lua", "python", "cpp", "latex", "matlab", "verilog", "nix" },

      sync_install = false,

      auto_install = true,

      highligh = {

        enable = true,

        additional_vim_regex_highlighting = false,
      },
    })
  end,
}
