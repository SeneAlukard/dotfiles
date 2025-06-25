-- Add this to your init.lua or create a separate file (e.g., pseudocode.lua) and require it

-- Variables to track state
local pseudocode_buffer = nil
local pseudocode_window = nil
local current_file_pseudocode = {} -- Map file paths to their pseudocode buffers

-- Function to toggle pseudocode notepad for the current file
function TogglePseudocode()
  -- Get current file path and information
  local current_file = vim.fn.expand('%:p')
  local file_name = vim.fn.expand('%:t')
  local file_dir = vim.fn.expand('%:p:h')

  -- If no file is open, use a default location
  if current_file == "" then
    vim.api.nvim_echo({ { "No file open. Please open a file first.", "WarningMsg" } }, true, {})
    return
  end

  -- If the window exists and is valid, close it
  if pseudocode_window ~= nil and vim.api.nvim_win_is_valid(pseudocode_window) then
    vim.api.nvim_win_close(pseudocode_window, true)
    pseudocode_window = nil
    return
  end

  -- Get or create the buffer for this file
  if current_file_pseudocode[current_file] == nil or
      not vim.api.nvim_buf_is_valid(current_file_pseudocode[current_file]) then
    -- Create a new buffer for pseudocode
    pseudocode_buffer = vim.api.nvim_create_buf(false, true)
    vim.api.nvim_buf_set_name(pseudocode_buffer, "Pseudocode: " .. file_name)

    -- Set buffer options
    vim.api.nvim_buf_set_option(pseudocode_buffer, "filetype", "markdown")
    vim.api.nvim_buf_set_option(pseudocode_buffer, "bufhidden", "hide")

    -- Create the pseudocode filename
    local pseudocode_file = file_dir .. "/.pseudocode." .. file_name .. ".md"

    -- Try to load existing content if it exists
    if vim.fn.filereadable(pseudocode_file) == 1 then
      -- Read existing file
      local lines = vim.fn.readfile(pseudocode_file)
      vim.api.nvim_buf_set_lines(pseudocode_buffer, 0, 0, false, lines)
    else
      -- Add header to the buffer
      local header = {
        "# Pseudocode for " .. file_name,
        "",
        "File: " .. current_file,
        "Created: " .. os.date("%Y-%m-%d %H:%M"),
        "",
        "## Algorithm Overview",
        "",
        "## Steps",
        "",
        "1. ",
        "",
        "## Edge Cases",
        "",
        "## Notes",
        "",
      }
      vim.api.nvim_buf_set_lines(pseudocode_buffer, 0, 0, false, header)
    end

    -- Store the buffer
    current_file_pseudocode[current_file] = pseudocode_buffer
  else
    -- Use existing buffer
    pseudocode_buffer = current_file_pseudocode[current_file]
  end

  -- Calculate dimensions for the floating window (60% of editor size)
  local width = math.floor(vim.api.nvim_get_option("columns") * 0.6)
  local height = math.floor(vim.api.nvim_get_option("lines") * 0.6)

  -- Calculate starting position to center the window
  local row = math.floor((vim.api.nvim_get_option("lines") - height) / 2)
  local col = math.floor((vim.api.nvim_get_option("columns") - width) / 2)

  -- Window options
  local opts = {
    relative = "editor",
    width = width,
    height = height,
    row = row,
    col = col,
    style = "minimal",
    border = "rounded",
    title = " Pseudocode for " .. file_name .. " ",
    title_pos = "center"
  }

  -- Create the window
  pseudocode_window = vim.api.nvim_open_win(pseudocode_buffer, true, opts)

  -- Set window-local options
  vim.api.nvim_win_set_option(pseudocode_window, "winblend", 0)
  vim.api.nvim_win_set_option(pseudocode_window, "cursorline", true)
  vim.api.nvim_win_set_option(pseudocode_window, "signcolumn", "no")

  -- Create pseudocode file path
  local pseudocode_file = file_dir .. "/.pseudocode." .. file_name .. ".md"

  -- Auto-save the buffer content to a file
  vim.api.nvim_create_autocmd({ "TextChanged", "TextChangedI" }, {
    buffer = pseudocode_buffer,
    callback = function()
      -- Save to file in the same directory as the original file
      local lines = vim.api.nvim_buf_get_lines(pseudocode_buffer, 0, -1, false)
      vim.fn.writefile(lines, pseudocode_file)
    end
  })

  -- Also save when closing the window
  vim.api.nvim_create_autocmd("WinClosed", {
    pattern = tostring(pseudocode_window),
    callback = function()
      local lines = vim.api.nvim_buf_get_lines(pseudocode_buffer, 0, -1, false)
      vim.fn.writefile(lines, pseudocode_file)
      pseudocode_window = nil
    end,
    once = true
  })
end

-- Map <leader>nn to toggle the pseudocode notepad
vim.api.nvim_set_keymap('n', '<leader>nn',
  ':lua TogglePseudocode()<CR>',
  { noremap = true, silent = true })

-- You can also add a command for it
vim.api.nvim_create_user_command('Pseudocode', TogglePseudocode, {})
