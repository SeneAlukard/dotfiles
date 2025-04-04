return {
  "iamcco/markdown-preview.nvim",
  cmd = { "MarkdownPreviewToggle", "MarkdownPreview", "MarkdownPreviewStop" },
  build = function()
    vim.fn["mkdp#util#install"]()
  end,
  ft = { "markdown" },
  config = function()
    -- First, determine the correct browser command for your system
    local browser_command = ""

    -- Check if firefox-developer-edition is available
    if vim.fn.executable('firefox-developer-edition') == 1 then
      browser_command = 'firefox-developer-edition'
      -- Check for regular firefox as fallback
    elseif vim.fn.executable('firefox') == 1 then
      browser_command = 'firefox'
      -- Additional fallbacks if needed
    elseif vim.fn.executable('firefox-developer') == 1 then
      browser_command = 'firefox-developer'
    end

    -- Set the browser directly - this is the simplest approach and often works best
    vim.g.mkdp_browser = browser_command

    -- As a fallback, also define the custom open function
    vim.cmd([[
      function! OpenBrowser(url)
        echom "Opening browser with URL: " . a:url
        if executable('firefox-developer-edition')
          call system('firefox-developer-edition --new-window ' . a:url . ' &')
        elseif executable('firefox')
          call system('firefox --new-window ' . a:url . ' &')
        else
          echo "No suitable browser found. URL: " . a:url
        endif
      endfunction
    ]])

    -- Only use the custom function if direct browser setting doesn't work
    -- vim.g.mkdp_browserfunc = 'OpenBrowser'

    -- Set a specific port for easier debugging
    vim.g.mkdp_port = '8090'
    vim.g.mkdp_host = '127.0.0.1'
    vim.g.mkdp_echo_preview_url = 1

    -- Other settings
    vim.g.mkdp_theme = 'dark'
    vim.g.mkdp_auto_start = 0
    vim.g.mkdp_auto_close = 1
    vim.g.mkdp_refresh_slow = 0
    vim.g.mkdp_page_title = '${name}'

    -- Keybindings with debugging information
    vim.keymap.set('n', '<leader>mdn', function()
      vim.cmd('MarkdownPreview')
      vim.notify('Markdown preview started - URL will be shown below', vim.log.levels.INFO)
    end, { desc = 'Start Markdown Preview' })

    vim.keymap.set('n', '<leader>mds', function()
      vim.cmd('MarkdownPreviewStop')
      vim.notify('Markdown preview stopped', vim.log.levels.INFO)
    end, { desc = 'Stop Markdown Preview' })

    vim.keymap.set('n', '<leader>mdt', '<cmd>MarkdownPreviewToggle<CR>', { desc = 'Toggle Markdown Preview' })

    -- Auto-cleanup on Vim exit
    vim.api.nvim_create_autocmd('VimLeave', {
      callback = function()
        if vim.fn.exists(':MarkdownPreviewStop') > 0 then
          vim.cmd('MarkdownPreviewStop')
        end
      end
    })
  end
}
