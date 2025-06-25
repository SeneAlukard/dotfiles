vim.keymap.set("n", "gd", function()
  local params = vim.lsp.util.make_position_params()
  local word = vim.fn.expand("<cword>")

  vim.lsp.buf_request(0, 'textDocument/definition', params, function(err, result, ctx, _)
    if result and not vim.tbl_isempty(result) then
      vim.lsp.util.jump_to_location(result[1], 'utf-8')
    else
      local path = "include/" .. word .. ".hpp" -- Change to "src/" or "lib/" if needed

      vim.ui.input({ prompt = "Create file " .. path .. "? [y/N]: " }, function(input)
        if input and input:lower() == "y" then
          vim.cmd("edit " .. path)

          -- Only write boilerplate if file is empty
          if vim.fn.line("$") == 1 and vim.fn.getline(1) == "" then
            vim.fn.append(0, {
              "#pragma once",
              "",
              "// Auto-generated header for " .. word,
              "",
            })
            vim.cmd("write")
          end
        end
      end)
    end
  end)
end, { desc = "Go to definition or create header file" })
