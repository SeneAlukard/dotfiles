local M = {}

local term_win = nil -- Store the floating terminal window ID

local function get_make_dir()
  local buf_path = vim.fn.expand("%:p:h") -- directory of current buffer
  local parent_build = buf_path .. "/../build/Makefile"
  local cwd_build = vim.fn.getcwd() .. "/build/Makefile"
  local cwd = vim.fn.getcwd() .. "/Makefile"

  if vim.fn.filereadable(parent_build) == 1 then
    return buf_path .. "/../build"
  elseif vim.fn.filereadable(cwd_build) == 1 then
    return vim.fn.getcwd() .. "/build"
  elseif vim.fn.filereadable(cwd) == 1 then
    return "."
  else
    return nil
  end
end

M.make_if_exists = function()
  local make_dir = get_make_dir()
  if not make_dir then
    vim.notify("❌ No Makefile found (tried ../build, build, .)", vim.log.levels.WARN)
    return
  end

  vim.notify("✅ Makefile found in: " .. make_dir .. ". Running make...", vim.log.levels.INFO)

  local current_win = vim.api.nvim_get_current_win()
  local current_buf = vim.api.nvim_get_current_buf()

  -- Create a floating window for the terminal
  local width = vim.o.columns * 0.8
  local height = vim.o.lines * 0.3
  local col = (vim.o.columns - width) / 2
  local row = (vim.o.lines - height) / 2

  local opts = {
    relative = "editor",
    width = math.floor(width),
    height = math.floor(height),
    col = math.floor(col),
    row = math.floor(row),
    style = "minimal",
    border = "rounded",
  }

  local term_buf = vim.api.nvim_create_buf(false, true)
  term_win = vim.api.nvim_open_win(term_buf, true, opts)
  vim.api.nvim_buf_set_name(term_buf, "Make Output")

  -- Use make -C to change directory
  vim.fn.termopen("make -C " .. vim.fn.fnameescape(make_dir))

  -- Auto-close terminal when the current file (buffer) is closed
  vim.api.nvim_create_autocmd("BufDelete", {
    buffer = current_buf,
    callback = function()
      local win_list = vim.api.nvim_list_wins()
      if #win_list > 1 then
        if vim.api.nvim_win_is_valid(term_win) then
          vim.api.nvim_win_close(term_win, true)
        end
      else
        if vim.api.nvim_win_is_valid(term_win) then
          vim.api.nvim_win_close(term_win, true)
        end
        vim.cmd("quit")
      end
    end,
  })

  vim.api.nvim_set_current_win(current_win)
end

vim.keymap.set("n", "<F5>", M.make_if_exists, { desc = "Run nearest Makefile (F5)" })

vim.keymap.set("n", "<Leader>t", function()
  if term_win and vim.api.nvim_win_is_valid(term_win) then
    vim.api.nvim_set_current_win(term_win)
    vim.notify("Focused on the terminal window.")
  else
    vim.notify("❌ No terminal window open.")
  end
end, { desc = "Focus on the floating terminal (Leader + t)" })

vim.keymap.set("n", "<Esc>", function()
  if term_win and vim.api.nvim_win_is_valid(term_win) then
    vim.api.nvim_win_close(term_win, true)
    vim.notify("Closed the floating terminal.")
  else
    vim.notify("❌ No terminal window open.")
  end
end, { desc = "Close the floating terminal (Esc)" })

return M
