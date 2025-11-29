return {
    "stevearc/conform.nvim",
    opts = {},
    config = function()
        local home = os.getenv("HOME")
        local java_setup = require("marko.util.java-formatter").setup()
        local java_formatter_jar = java_setup.jar_path
        local java21_path = java_setup.java_path

        require("conform").setup({
            formatters_by_ft = {
                lua = { "stylua", lsp_format = "fallback" },
                python = { "isort", "black" },
                rust = { "rustfmt", lsp_format = "fallback" },
                java = { "google_java_format_v115", lsp_format = "fallback" },
                markdown = { "prettier" },
                templ = { "templ" },
                javascript = { "prettier", stop_after_first = true },
                javascriptreact = { "prettier", stop_after_first = true },
                typescript = { "prettier", stop_after_first = true },
                typescriptreact = { "prettier", stop_after_first = true },
                tsx = { "prettier", stop_after_first = true },
                json = { "prettier", stop_after_first = true },
                html = { "prettier" },
                css = { "prettier", stop_after_first = true },
                sql = { "psqlfmt", "sqlfmt", stop_after_first = true },
            },
            formatters = {
                google_java_format_v115 = {
                    command = function()
                        return java21_path or "java"
                    end,
                    args = function()
                        if java_formatter_jar then
                            return { "-jar", java_formatter_jar, "-" }
                        else
                            return {}
                        end
                    end,
                    stdin = true,
                    condition = function()
                        return java_formatter_jar ~= nil and java21_path ~= nil
                    end,
                },
                psqlfmt = {
                    command = "sql-formatter",
                    args = { "-l", "postgresql", "-c", home .. "/.config/sql-formatter/.sqlformatter.json" },
                    stdin = true,
                },
                sqlfmt = {
                    command = "sql-formatter",
                    args = { "-c", home .. "/.config/sql-formatter/.sqlformatter.json" },
                    stdin = true,
                },
            },
            format_after_save = function(bufnr)
                local file_ext = vim.api.nvim_buf_get_option(bufnr, "filetype")
                if file_ext == "sql" then
                    return false
                end
                return {
                    lsp_format = "fallback",
                    timeout_ms = 5000,
                }
            end,
            default_format_opts = {
                lsp_format = "fallback",
            },
        })
    end,
}
