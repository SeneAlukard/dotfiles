return -- install without yarn or npm
{
  "iamcco/markdown-preview.nvim",
  cmd = { "MarkdownPreviewToggle", "MarkdownPreview", "MarkdownPreviewStop" },
  build = function() vim.fn["mkdp#util#install"]() end,
  ft = { "markdown" },
  config = function()
    vim.keymap.set("n", "<leader>mdn", ":MarkdownPreview<CR>")
    vim.keymap.set("n", "<leader>mds", ":MarkdownPreviewStop<CR>")
  end
}
