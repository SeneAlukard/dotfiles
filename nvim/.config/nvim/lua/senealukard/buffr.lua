-- Utility function to get file information
local function get_file_info()
  return {
    filename = vim.fn.expand('%:t'),   -- Current filename
    filepath = vim.fn.expand('%:p:h'), -- Path to file
    basename = vim.fn.expand('%:t:r'), -- Filename without extension
    extension = vim.fn.expand('%:e'),  -- File extension
  }
end

-- Setup and manage the output buffer/window
local function setup_output_display()
  local current_win = vim.api.nvim_get_current_win()
  local output_buf_name = 'CompileOutput'
  local output_buf = -1

  -- Find existing buffer
  for _, buf in ipairs(vim.api.nvim_list_bufs()) do
    if vim.api.nvim_buf_get_name(buf):match(output_buf_name .. '$') then
      output_buf = buf
      break
    end
  end

  -- Create buffer if needed
  if output_buf == -1 or not vim.api.nvim_buf_is_valid(output_buf) then
    output_buf = vim.api.nvim_create_buf(false, true)
    vim.api.nvim_buf_set_name(output_buf, output_buf_name)
    vim.api.nvim_buf_set_option(output_buf, 'buftype', 'nofile')
    vim.api.nvim_buf_set_option(output_buf, 'bufhidden', 'hide')
    vim.api.nvim_buf_set_option(output_buf, 'swapfile', false)
  end

  -- Clear buffer
  if vim.api.nvim_buf_is_valid(output_buf) then
    vim.api.nvim_buf_set_lines(output_buf, 0, -1, false, {})
  end

  -- Find or create window
  local output_win = nil
  for _, win in ipairs(vim.api.nvim_list_wins()) do
    if vim.api.nvim_win_get_buf(win) == output_buf then
      output_win = win
      break
    end
  end

  if not output_win then
    vim.cmd('botright 10split')
    output_win = vim.api.nvim_get_current_win()
    vim.api.nvim_win_set_buf(output_win, output_buf)
  else
    vim.api.nvim_win_set_height(output_win, 10)
  end

  -- Create append function
  local function append_output(text)
    if not vim.api.nvim_buf_is_valid(output_buf) then
      return
    end

    local lines = vim.split(text, '\n')
    lines = vim.tbl_filter(function(line) return line ~= '' end, lines)

    if #lines == 0 then
      return
    end

    local line_count = vim.api.nvim_buf_line_count(output_buf)
    vim.api.nvim_buf_set_lines(output_buf, line_count, line_count, false, lines)

    if output_win and vim.api.nvim_get_current_win() == output_win then
      vim.api.nvim_win_set_cursor(output_win, { line_count + #lines, 0 })
    end
  end

  return current_win, output_win, append_output
end

-- Compile only function - for debugging (uses .out extension)
local function compile_only()
  -- Save file first
  vim.cmd('write')

  -- Get file info
  local file_info = get_file_info()

  -- Setup display
  local current_win, _, append_output = setup_output_display()

  -- Determine compiler
  local compiler = (file_info.extension == 'c') and 'gcc' or 'g++'

  -- Use .out extension for debugging (DAP expects this)
  local output = file_info.basename .. '.out'

  -- Start compilation with debug symbols
  append_output('🚀 Compiling ' .. file_info.filename .. ' with ' .. compiler .. ' (debug build)...')

  -- Compile with debug flags
  vim.fn.jobstart({ compiler, '-g', '-Wall', '-Wextra', file_info.filename, '-o', output }, {
    cwd = file_info.filepath,
    stdout_buffered = true,
    stderr_buffered = true,
    on_stderr = function(_, data)
      if data and #data > 0 and data[1] ~= '' then
        append_output('⚠️ ' .. table.concat(data, '\n'))
      end
    end,
    on_exit = function(_, exit_code)
      if exit_code == 0 then
        append_output('✅ Debug build successful: ' .. output)
        append_output('🔍 Binary ready at: ' .. file_info.filepath .. '/' .. output)
        append_output('🐛 You can now start debugging with DAP')
      else
        append_output('❌ Debug build failed!')
      end

      -- Return to original window
      if vim.api.nvim_win_is_valid(current_win) then
        vim.api.nvim_set_current_win(current_win)
      end
    end,
  })
end

-- Compile and run - for normal execution (uses .run extension)
local function compile_and_run()
  -- Save file first
  vim.cmd('write')

  -- Get file info
  local file_info = get_file_info()

  -- Setup display
  local current_win, _, append_output = setup_output_display()

  -- Determine compiler
  local compiler = (file_info.extension == 'c') and 'gcc' or 'g++'

  -- Use .run extension for regular execution to avoid conflicts with DAP
  local output = file_info.basename .. '.run'

  -- Start compilation
  append_output('🚀 Compiling ' .. file_info.filename .. ' with ' .. compiler .. ' (regular build)...')

  -- Compile and run
  vim.fn.jobstart({ compiler, '-O2', '-Wall', '-Wextra', file_info.filename, '-o', output }, {
    cwd = file_info.filepath,
    stdout_buffered = true,
    stderr_buffered = true,
    on_stderr = function(_, data)
      if data and #data > 0 and data[1] ~= '' then
        append_output('⚠️ ' .. table.concat(data, '\n'))
      end
    end,
    on_exit = function(_, exit_code)
      if exit_code == 0 then
        append_output('✅ Compilation successful!')
        append_output('🔍 Running ' .. output .. '...')
        append_output('----------------------------------------')

        -- Run the program
        vim.fn.jobstart({ './' .. output }, {
          cwd = file_info.filepath,
          stdout_buffered = true,
          stderr_buffered = true,
          on_stdout = function(_, data)
            if data and #data > 0 and data[1] ~= '' then
              append_output(table.concat(data, '\n'))
            end
          end,
          on_stderr = function(_, err)
            if err and #err > 0 and err[1] ~= '' then
              append_output('❌ ' .. table.concat(err, '\n'))
            end
          end,
          on_exit = function(_, code)
            append_output('----------------------------------------')
            append_output('🏁 Program exited with code: ' .. code)

            -- Return to original window
            if vim.api.nvim_win_is_valid(current_win) then
              vim.api.nvim_set_current_win(current_win)
            end
          end,
        })
      else
        append_output('❌ Compilation failed!')

        -- Return to original window
        if vim.api.nvim_win_is_valid(current_win) then
          vim.api.nvim_set_current_win(current_win)
        end
      end
    end,
  })
end

-- Auto-compile on save
vim.api.nvim_create_autocmd('BufWritePost', {
  group = vim.api.nvim_create_augroup('AutoCompile', { clear = true }),
  pattern = { '*.c', '*.cpp', '*.cc', '*.cxx' },
  callback = compile_and_run
})


-- F6 key mapping for compiling C/C++ without running
vim.keymap.set('n', '<F6>', function()
  -- Save file before compiling
  vim.cmd('write')

  -- Get file information
  local filename = vim.fn.expand('%:t')   -- Current filename
  local filepath = vim.fn.expand('%:p:h') -- Path to file
  local basename = vim.fn.expand('%:t:r') -- Filename without extension
  local extension = vim.fn.expand('%:e')  -- File extension

  -- Determine compiler based on file type
  local compiler = (extension == 'c') and 'gcc' or 'g++'

  -- Use .out extension for debug builds
  local output = basename .. '.out'

  -- Display compilation message
  print('🔨 Compiling ' .. filename .. ' for debugging...')

  -- Compile with debug symbols
  vim.fn.jobstart({ compiler, '-g', '-Wall', '-Wextra', filename, '-o', output }, {
    cwd = filepath,
    on_exit = function(_, exit_code)
      if exit_code == 0 then
        print('✅ Compilation successful. Binary ready for debugging: ' .. output)
      else
        print('❌ Compilation failed!')
      end
    end
  })
end, { desc = 'Compile for Debugging' })
