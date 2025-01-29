local bufnr = 18

vim.api.nvim_create_autocmd("BufWritePost", {
  group = vim.api.nvim_create_augroup("WeX", { clear = true }),
  pattern = "main.cpp",
  callback = function()
    vim.api.nvim_buf_set_lines(bufnr, 0, 0, false, { "output of: main.cpp" })
    vim.fn.jobstart({ "gcc", "run", "main.cpp" })
  end,
})
