return {
    {
        "williamboman/mason.nvim",
        lazy = false,
        config = true,
    },

    -- Autocompletion
    {
        "L3MON4D3/LuaSnip",
        -- follow latest release.
        version = "v2.*", -- Replace <CurrentMajor> by the latest released major (first number of latest release)
        -- install jsregexp (optional!).
        build = "make install_jsregexp",
    },
    {
        "hrsh7th/nvim-cmp",
        lazy = false,
        priority = 100,
        dependencies = {
            {
                "L3MON4D3/LuaSnip",
                "rafamadriz/friendly-snippets",
                "onsails/lspkind.nvim",
                "hrsh7th/cmp-nvim-lsp",
                "hrsh7th/cmp-path",
                "hrsh7th/cmp-vsnip",
                "hrsh7th/vim-vsnip",
                "hrsh7th/cmp-buffer",
                "saadparwaiz1/cmp_luasnip",
            },
        },
        config = function()
            -- Here is where you configure the autocompletion settings.
            -- And you can configure cmp even more, if you want to.
            local cmp = require("cmp")

            cmp.setup({
                sources = {
                    { name = "nvim_lsp" },
                    { name = "nvim_lsp_signature_help" },
                    { name = "vsnip" },
                    { name = "path" },
                    { name = "buffer" },
                    { name = "supermaven" },
                },
                snippet = {
                    expand = function(args)
                        require("luasnip").lsp_expand(args.body)
                    end,
                },
                -- formatting = lsp_zero.cmp_format({ details = true }),
                mapping = cmp.mapping.preset.insert({
                    ["<C-Space>"] = cmp.mapping.complete(),
                    ["<C-y>"] = cmp.mapping.confirm({ select = true }),
                    ["<CR>"] = cmp.mapping.confirm({ select = true }),
                    ["<C-u>"] = cmp.mapping.scroll_docs(-4),
                    ["<C-d>"] = cmp.mapping.scroll_docs(4),
                    ["<Tab>"] = nil,
                    ["<S-Tab>"] = nil,
                }),
            })

            -- Setup up vim-dadbod
            cmp.setup.filetype({ "sql" }, {
                sources = {
                    { name = "vim-dadbod-completion" },
                    { name = "buffer" },
                },
            })

            local ls = require("luasnip")
            ls.config.set_config({
                history = false,
                updateevents = "TextChanged,TextChangedI",
            })
        end,
    },

    -- LSP
    {
        "neovim/nvim-lspconfig",
        cmd = { "LspInfo", "LspInstall", "LspStart" },
        event = { "BufReadPre", "BufNewFile" },
        dependencies = {
            { "hrsh7th/cmp-nvim-lsp" },
            { "williamboman/mason-lspconfig.nvim" },
        },
        config = function()
            -- This is where all the LSP shenanigans will live
            local keymaps = require("marko.config.lsp")

            vim.api.nvim_create_autocmd('LspAttach', {
                desc = 'LSP actions',
                callback = function(event)
                    local opts = { buffer = event.buf }
                    keymaps.lsp_keymap(opts)
                end
            })

            require("mason-lspconfig").setup({
                ensure_installed = { "eslint", "jdtls", "ts_ls", "angularls", "lua_ls", "gopls" },
                handlers = {
                    -- this first function is the "default handler"
                    -- it applies to every language server without a "custom handler"
                    function(server_name)
                        require("lspconfig")[server_name].setup({})
                    end,

                    ts_ls = function()
                        require("lspconfig").ts_ls.setup({
                            settings = {
                                typescript = {
                                    inlayHints = {
                                        includeInlayParameterNameHints = "all",
                                        includeInlayParameterNameHintsWhenArgumentMatchesName = true,
                                        includeInlayFunctionParameterTypeHints = true,
                                        includeInlayVariableTypeHints = false,
                                        includeInlayVariableTypeHintsWhenTypeMatchesName = false,
                                        includeInlayPropertyDeclarationTypeHints = false,
                                        includeInlayFunctionLikeReturnTypeHints = false,
                                        includeInlayEnumMemberValueHints = false,
                                    },
                                },
                                javascript = {
                                    inlayHints = {
                                        includeInlayParameterNameHints = "all",
                                        includeInlayParameterNameHintsWhenArgumentMatchesName = true,
                                        includeInlayFunctionParameterTypeHints = true,
                                        includeInlayVariableTypeHints = true,
                                        includeInlayVariableTypeHintsWhenTypeMatchesName = true,
                                        includeInlayPropertyDeclarationTypeHints = true,
                                        includeInlayFunctionLikeReturnTypeHints = true,
                                        includeInlayEnumMemberValueHints = true,
                                    },
                                },
                            },
                        })
                    end,

                    -- this is the "custom handler" for `lua_ls`
                    lua_ls = function()
                        require("lspconfig").lua_ls.setup({})
                    end,
                },
            })
        end,
    },

    {
        "mrshmllow/document-color.nvim",
        config = function()
            require("document-color").setup({
                -- Default options
                mode = "background", -- "background" | "foreground" | "single"
            })
        end,
    },

    {
        "rcarriga/nvim-dap-ui",
        config = function()
            local dap, dapui = require("dap"), require("dapui")
            dap.listeners.after.event_initialized["dapui_config"] = function()
                dapui.open()
            end
            dap.listeners.before.event_terminated["dapui_config"] = function()
                dapui.close()
            end
            dap.listeners.before.event_exited["dapui_config"] = function()
                dapui.close()
            end

            vim.keymap.set("n", "<leader>dl", function()
                dapui.setup()
                dapui.toggle()
            end, {})

            vim.fn.sign_define("DapBreakpoint", { text = "" })
        end,
        dependencies = { "mfussenegger/nvim-dap", "nvim-neotest/nvim-nio" },
    },
}
