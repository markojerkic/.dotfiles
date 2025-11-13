return {
    "dsych/blanket.nvim",
    dependencies = { "manoelcampos/xml2lua" },
    config = function()
        require("blanket").setup({
            -- can use env variables and anything that could be interpreted by expand(), see :h expandcmd()
            -- OPTIONAL
            -- report_path = vim.fn.getcwd().."/target/site/jacoco/jacoco.xml",
            report_path = vim.fn.expand("./**/jacocoTestReport.xml")
        })
    end
}
