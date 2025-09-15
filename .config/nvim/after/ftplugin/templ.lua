vim.filetype.add({ extension = { templ = "templ" } })

vim.keymap.set("n", "<A-l>", function() vim.lsp.buf.format({ name = "templ" }) end, {})
