vim.api.nvim_create_autocmd("BufWritePost", {
  group = vim.api.nvim_create_augroup("WeX", { clear = true }),
  pattern = "main.cpp",
  callback = function()
    -- Compile main.cpp silently
    vim.fn.jobstart({ "gcc", "main.cpp", "-o", "main.out" }, {
      on_exit = function(_, exit_code)
        if exit_code == 0 then
          -- Run the compiled program only if compilation succeeds
          vim.fn.jobstart({ "./main.out" }, { stdout_buffered = true, stderr_buffered = true })
        end
      end,
    })
  end,
})

