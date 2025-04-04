return {
  "folke/trouble.nvim",
  dependencies = { "nvim-tree/nvim-web-devicons" },
  opts = {
    position = "bottom",
    height = 10,
    width = 50,
    icons = true,
    mode = "workspace_diagnostics",
    severity = nil,
    fold_open = "",
    fold_closed = "",
    group = true,
    padding = true,
    cycle_results = true,
    action_keys = {
      close = "q",
      cancel = "<esc>",
      refresh = "r",
      jump = { "<cr>", "<tab>" },
      open_split = { "<c-x>" },
      open_vsplit = { "<c-v>" },
      open_tab = { "<c-t>" },
      jump_close = { "o" },
      toggle_mode = "m",
      toggle_preview = "P",
      hover = "K",
      preview = "p",
      close_folds = { "zM", "zm" },
      open_folds = { "zR", "zr" },
      toggle_fold = { "zA", "za" },
      previous = "k",
      next = "j",
    },
    indent_lines = true,
    auto_open = false,
    auto_close = false,
    auto_preview = true,
    auto_fold = false,
    use_diagnostic_signs = true,
  },
  keys = {
    { "<leader>xx", "<cmd>TroubleToggle<cr>",                       desc = "Toggle Trouble" },
    { "<leader>xd", "<cmd>TroubleToggle document_diagnostics<cr>",  desc = "Document Diagnostics" },
    { "<leader>xw", "<cmd>TroubleToggle workspace_diagnostics<cr>", desc = "Workspace Diagnostics" },
    { "<leader>xq", "<cmd>TroubleToggle quickfix<cr>",              desc = "Quickfix List" },
  },
}
