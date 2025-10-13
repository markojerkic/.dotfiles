return {
    "stevearc/conform.nvim",
    opts = {},
    config = function()
        -- Setup Google Java Format v1.17
        local function setup_google_java_format()
            local home = os.getenv("HOME")
            local jar_dir = home .. "/.local/share/nvim/google-java-format"
            local jar_path = jar_dir .. "/google-java-format-1.17.0-all-deps.jar"

            -- Create directory if it doesn't exist
            vim.fn.mkdir(jar_dir, "p")

            -- Download jar if it doesn't exist
            if vim.fn.filereadable(jar_path) == 0 then
                vim.notify("Downloading Google Java Format v1.17.0...")
                local url =
                "https://github.com/google/google-java-format/releases/download/v1.17.0/google-java-format-1.17.0-all-deps.jar"
                local cmd = string.format("curl -L -o '%s' '%s'", jar_path, url)
                local result = vim.fn.system(cmd)
                if vim.v.shell_error == 0 then
                    vim.notify("Google Java Format v1.17.0 downloaded successfully")
                else
                    vim.notify("Failed to download Google Java Format: " .. result, vim.log.levels.ERROR)
                    return nil
                end
            end

            return jar_path
        end

        local java_formatter_jar = setup_google_java_format()
        require("conform").setup({
            formatters_by_ft = {
                lua = { "stylua", lsp_format = "fallback" },
                python = { "isort", "black" },
                rust = { "rustfmt", lsp_format = "fallback" },
                java = { "google_java_format_v115" },
                markdown = { "prettier" },
                templ = { "templ" },
                javascript = { "biome", "prettier", stop_after_first = true },
                javascriptreact = { "biome", "prettier", stop_after_first = true },
                typescript = { "biome", "prettier", stop_after_first = true },
                typescriptreact = { "biome", "prettier", stop_after_first = true },
                tsx = { "biome", "prettier", stop_after_first = true },
                json = { "biome", "prettier", stop_after_first = true },
                html = { "prettier" },
                css = { "biome", "prettier", stop_after_first = true },
                sql = { "psqlfmt", "sqlfmt", stop_after_first = true },
            },
            formatters = {
                google_java_format_v115 = {
                    command = "java",
                    args = function()
                        if java_formatter_jar then
                            return { "-jar", java_formatter_jar, "-" }
                        else
                            return {}
                        end
                    end,
                    stdin = true,
                    condition = function()
                        return java_formatter_jar ~= nil
                    end,
                },
                psqlfmt = {
                    command = "sql-formatter",
                    args = { "-l", "postgresql" },
                    stdin = true,
                },
                sqlfmt = {
                    command = "sql-formatter",
                    args = {},
                    stdin = true,
                },
            },
            format_after_save = function(bufnr)
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
