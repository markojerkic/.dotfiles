return {

    {
        'tpope/vim-dadbod',
        config = function()
            vim.cmd [[ autocmd FileType sql,mysql,plsql lua require('cmp').setup.buffer({ sources = {{ name = 'vim-dadbod-completion' }} }) ]]
        end
    },
    { 'kristijanhusak/vim-dadbod-ui' },
    { 'kristijanhusak/vim-dadbod-completion' },

}
