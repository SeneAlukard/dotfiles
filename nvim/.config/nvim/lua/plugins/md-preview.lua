return {
  "iamcco/markdown-preview.nvim",
  cmd = { "MarkdownPreviewToggle", "MarkdownPreview", "MarkdownPreviewStop" },
  build = function()
    vim.fn["mkdp#util#install"]()
  end,
  ft = { "markdown" },
  config = function()
    -- Detect browser (Chromium preferred)
    local browser_command = ""
    if vim.fn.executable('chromium') == 1 then
      browser_command = 'chromium'
    elseif vim.fn.executable('google-chrome-stable') == 1 then
      browser_command = 'google-chrome-stable'
    elseif vim.fn.executable('firefox') == 1 then
      browser_command = 'firefox'
    elseif vim.fn.executable('firefox-developer-edition') == 1 then
      browser_command = 'firefox-developer-edition'
    end

    vim.g.mkdp_browser = browser_command

    -- Optional: fallback custom browser function (if mkdp_browser fails)
    vim.cmd([[
      function! OpenBrowser(url)
        echom "Opening browser with URL: " . a:url
        if executable('chromium')
          call system('chromium --new-window ' . a:url . ' &')
        elseif executable('google-chrome-stable')
          call system('google-chrome-stable --new-window ' . a:url . ' &')
        elseif executable('firefox')
          call system('firefox --new-window ' . a:url . ' &')
        else
          echo "No suitable browser found. URL: " . a:url
        endif
      endfunction
    ]])
    -- Uncomment this line to force the fallback browser function
    -- vim.g.mkdp_browserfunc = 'OpenBrowser'

    -- Plugin settings
    vim.g.mkdp_port = '8090'
    vim.g.mkdp_host = '127.0.0.1'
    vim.g.mkdp_echo_preview_url = 1
    vim.g.mkdp_theme = 'dark'
    vim.g.mkdp_auto_start = 0
    vim.g.mkdp_auto_close = 1
    vim.g.mkdp_refresh_slow = 0
    vim.g.mkdp_page_title = '${name}'

    -- Keybindings
    vim.keymap.set('n', '<leader>mdn', function()
      vim.cmd('MarkdownPreview')
      vim.notify('Markdown preview started - URL will be shown below', vim.log.levels.INFO)
    end, { desc = 'Start Markdown Preview' })

    vim.keymap.set('n', '<leader>mds', function()
      vim.cmd('MarkdownPreviewStop')
      vim.notify('Markdown preview stopped', vim.log.levels.INFO)
    end, { desc = 'Stop Markdown Preview' })

    vim.keymap.set('n', '<leader>mdt', '<cmd>MarkdownPreviewToggle<CR>', { desc = 'Toggle Markdown Preview' })

    -- Stop preview cleanly on exit
    vim.api.nvim_create_autocmd('VimLeave', {
      callback = function()
        if vim.fn.exists(':MarkdownPreviewStop') > 0 then
          vim.cmd('MarkdownPreviewStop')
        end
      end
    })
  end
}
