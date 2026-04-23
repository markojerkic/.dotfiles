return {
    {
        "nvim-treesitter/nvim-treesitter",
        main = "nvim-treesitter",
        version = false,
        branch = "main",
        cmd = { "TSUpdateSync", "TSUpdate", "TSInstall", "TSUninstall" },
        dependencies = {
            "nvim-treesitter/nvim-treesitter-context",
            "nvim-treesitter/nvim-treesitter-textobjects",
        },
        build = ":TSUpdate",
        lazy = false,
        opts = {
            install_dir = vim.fn.stdpath("data") .. "/site",
        },
        init = function()
            local ensure_installed = {
                "bash",
                "c",
                "go",
                "gomod",
                "gowork",
                "gosum",
                "diff",
                "html",
                "javascript",
                "jsdoc",
                "json",
                "lua",
                "luadoc",
                "luap",
                "markdown",
                "markdown_inline",
                "python",
                "query",
                "regex",
                "toml",
                "tsx",
                "typescript",
                "vim",
                "vimdoc",
                "xml",
                "yaml",
                "angular",
                "java",
            }

            vim.api.nvim_create_autocmd("FileType", {
                callback = function(args)
                    pcall(vim.treesitter.start, args.buf)
                    vim.bo[args.buf].indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
                end,
            })

            vim.api.nvim_create_autocmd("User", {
                pattern = "VeryLazy",
                once = true,
                callback = function()
                    local treesitter = require("nvim-treesitter")
                    local installed = treesitter.get_installed()
                    local missing = vim.iter(ensure_installed)
                        :filter(function(lang)
                            return not vim.tbl_contains(installed, lang)
                        end)
                        :totable()

                    if #missing > 0 then
                        treesitter.install(missing)
                    end
                end,
            })
        end,
        config = function(_, opts)
            require("nvim-treesitter").setup(opts)
        end,
    },
    {
        "nvim-treesitter/nvim-treesitter-textobjects",
        main = "nvim-treesitter-textobjects",
        branch = "main",
        lazy = false,
        opts = {
            move = {
                set_jumps = true,
            },
        },
        config = function(_, opts)
            require("nvim-treesitter-textobjects").setup(opts)

            local move = require("nvim-treesitter-textobjects.move")

            vim.keymap.set({ "n", "x", "o" }, "]f", function()
                move.goto_next_start("@function.outer", "textobjects")
            end)
            vim.keymap.set({ "n", "x", "o" }, "]c", function()
                move.goto_next_start("@class.outer", "textobjects")
            end)
            vim.keymap.set({ "n", "x", "o" }, "]F", function()
                move.goto_next_end("@function.outer", "textobjects")
            end)
            vim.keymap.set({ "n", "x", "o" }, "]C", function()
                move.goto_next_end("@class.outer", "textobjects")
            end)
            vim.keymap.set({ "n", "x", "o" }, "[f", function()
                move.goto_previous_start("@function.outer", "textobjects")
            end)
            vim.keymap.set({ "n", "x", "o" }, "[c", function()
                move.goto_previous_start("@class.outer", "textobjects")
            end)
            vim.keymap.set({ "n", "x", "o" }, "[F", function()
                move.goto_previous_end("@function.outer", "textobjects")
            end)
            vim.keymap.set({ "n", "x", "o" }, "[C", function()
                move.goto_previous_end("@class.outer", "textobjects")
            end)
        end,
    },
    {
        "davidmh/mdx.nvim",
        dependencies = { "nvim-treesitter/nvim-treesitter" },
    },
}
