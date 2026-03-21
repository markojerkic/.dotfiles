vim.opt_local.tabstop = 2
vim.opt_local.shiftwidth = 2
vim.opt_local.expandtab = true

local home = os.getenv("HOME")
local root_markers = { ".git", "mvnw", "gradlew" }

local ok_cmp, cmp_nvim_lsp = pcall(require, "cmp_nvim_lsp")
if not ok_cmp then
    return
end

local ok_jdtls, jdtls = pcall(require, "jdtls")
if not ok_jdtls then
    return
end

local root_dir = require("jdtls.setup").find_root(root_markers)
if root_dir == "" then
    return
end

local function first_glob(pattern)
    local matches = vim.fn.glob(pattern, false, true)
    if type(matches) == "table" and #matches > 0 then
        return matches[1]
    end
    return ""
end

local function existing(path)
    return path ~= "" and vim.fn.filereadable(path) == 1
end

local function get_lombok_javaagent()
    local mason_lombok = home .. "/.local/share/nvim/mason/packages/jdtls/lombok.jar"
    if existing(mason_lombok) then
        return "-javaagent:" .. mason_lombok
    end

    local m2_lombok = first_glob(home .. "/.m2/repository/org/projectlombok/lombok/*/*.jar")
    if existing(m2_lombok) then
        return "-javaagent:" .. m2_lombok
    end

    return nil
end

local function get_bundles()
    local bundles = {}

    local java_dap = first_glob(home .. "/.local/share/nvim/mason/packages/java-debug-adapter/extension/server/*.jar")
    if java_dap ~= "" then
        table.insert(bundles, java_dap)
    end

    local java_test = vim.fn.glob(home .. "/.local/share/nvim/mason/packages/java-test/extension/server/*.jar", false,
        true)
    if type(java_test) == "table" then
        vim.list_extend(bundles, java_test)
    end

    return bundles
end

local launcher = first_glob(home .. "/.local/share/nvim/mason/packages/jdtls/plugins/org.eclipse.equinox.launcher_*.jar")
if not existing(launcher) then
    vim.notify("jdtls launcher jar not found in mason", vim.log.levels.WARN)
    return
end

local jdtls_config = home .. "/.local/share/nvim/mason/packages/jdtls/config_linux"
if vim.fn.isdirectory(jdtls_config) ~= 1 then
    vim.notify("jdtls config_linux not found in mason", vim.log.levels.WARN)
    return
end

local capabilities = vim.lsp.protocol.make_client_capabilities()
capabilities.textDocument.completion.completionItem.snippetSupport = false
capabilities = cmp_nvim_lsp.default_capabilities(capabilities)

local extended = jdtls.extendedClientCapabilities
extended.resolveAdditionalTextEditsSupport = true

local workspace_dir = home
    .. "/.cache/jdtls-compile/"
    .. vim.fn.fnamemodify(root_dir, ":h:t")
    .. "/"
    .. vim.fn.fnamemodify(root_dir, ":t")

local function open_dap_ui()
    local ok_dapui, dapui = pcall(require, "dapui")
    if ok_dapui then
        dapui.open()
    end
end

local config = {
    cmd = {
        "java",
        "-Declipse.application=org.eclipse.jdt.ls.core.id1",
        "-Dosgi.bundles.defaultStartLevel=4",
        "-Declipse.product=org.eclipse.jdt.ls.core.product",
        "-Dlog.protocol=true",
        "-Dlog.level=ALL",
        "-Xms1g",
        "--add-modules=ALL-SYSTEM",
        "--add-opens",
        "java.base/java.util=ALL-UNNAMED",
        "--add-opens",
        "java.base/java.lang=ALL-UNNAMED",
        "-jar",
        launcher,
        "-configuration",
        jdtls_config,
        "-data",
        workspace_dir,
    },
    root_dir = root_dir,
    capabilities = capabilities,
    settings = {
        java = {
            format = {
                enabled = true,
                settings = {
                    url = vim.fn.stdpath("config") .. "/formater/google-java-format.xml",
                    profile = "GoogleStyle",
                },
            },
            inlayHints = {
                parameterNames = {
                    enabled = "all",
                    exclusions = { "this" },
                },
            },
        },
        signatureHelp = { enabled = true },
        completion = {
            favoriteStaticMembers = {
                "org.junit.jupiter.api.Assertions.*",
                "java.util.Objects.requireNonNull",
                "java.util.Objects.requireNonNullElse",
                "org.mockito.Mockito.*",
                "org.hamcrest.MatcherAssert.assertThat",
                "org.hamcrest.Matchers.*",
                "org.hamcrest.CoreMatchers.*",
            },
            importOrder = { "java", "jakarta", "javax", "com", "org" },
        },
    },
    init_options = {
        bundles = get_bundles(),
        extendedClientCapabilities = extended,
    },
    on_attach = function(_, bufnr)
        pcall(jdtls.setup_dap, { hotcodereplace = "auto" })
        require("marko.config.lsp").lsp_keymap({ buffer = bufnr, silent = true, remap = false })
    end,
}

local lombok = get_lombok_javaagent()
if lombok then
    table.insert(config.cmd, 13, lombok)
end

jdtls.start_or_attach(config)

vim.api.nvim_buf_create_user_command(0, "JdtCompile", function(args)
    jdtls.compile(args.args)
end, { nargs = "?", complete = "custom,v:lua.require'jdtls'._complete_compile" })

vim.api.nvim_buf_create_user_command(0, "JdtSetRuntime", function(args)
    jdtls.set_runtime(args.args)
end, { nargs = "?", complete = "custom,v:lua.require'jdtls'._complete_set_runtime" })

vim.api.nvim_buf_create_user_command(0, "JdtUpdateConfig", function()
    jdtls.update_project_config()
end, {})

vim.api.nvim_buf_create_user_command(0, "JdtBytecode", function()
    jdtls.javap()
end, {})

local maven_debug_options = "-Xdebug -Xrunjdwp:transport=dt_socket,server=y,suspend=y,address=5005"
local gradle_debug_options = "--debug-jvm"
local dap_config_file = home .. "/.config/nvim-jdtls/dap.json"

local function read_dap_configurations()
    if vim.fn.filereadable(dap_config_file) ~= 1 then
        return {}
    end

    local lines = vim.fn.readfile(dap_config_file)
    local ok_decode, decoded = pcall(vim.fn.json_decode, table.concat(lines, "\n"))
    if ok_decode and type(decoded) == "table" then
        return decoded
    end

    return {}
end

local function write_dap_configurations(configurations)
    vim.fn.mkdir(vim.fn.fnamemodify(dap_config_file, ":h"), "p")
    local encoded = vim.fn.json_encode(configurations)
    vim.fn.writefile({ encoded }, dap_config_file)
end

local function attach_to_java_debug()
    local dap = require("dap")
    vim.ui.input({ prompt = "Port: " }, function(port)
        if not port or port == "" then
            return
        end

        dap.configurations.java = {
            {
                type = "java",
                request = "attach",
                name = "Attach to process",
                hostName = "localhost",
                port = port,
            },
        }
        dap.continue()
        open_dap_ui()
    end)
end

vim.api.nvim_buf_create_user_command(0, "RunMavenDebug", function()
    vim.ui.input({ prompt = "Run command: " }, function(command)
        if command and command ~= "" then
            vim.fn.jobstart({ "tmux", "neww", command ..
            ' -Dspring-boot.run.jvmArguments="' .. maven_debug_options .. '"' })
        end
    end)
end, {})

vim.api.nvim_buf_create_user_command(0, "RunGradleDebug", function()
    vim.ui.input({ prompt = "Run command: " }, function(command)
        if command and command ~= "" then
            vim.fn.jobstart({ "tmux", "neww", command .. " " .. gradle_debug_options })
        end
    end)
end, {})

vim.api.nvim_buf_create_user_command(0, "AddDapConfig", function()
    local main_class = vim.fn.input("Main class: ")
    if main_class == "" then
        return
    end

    local module = vim.fn.input("Module: ")
    local configurations = read_dap_configurations()
    table.insert(configurations, { mainClass = main_class, module = module })
    write_dap_configurations(configurations)
    vim.notify("Config added: " .. main_class, vim.log.levels.INFO)
end, {})

vim.api.nvim_buf_create_user_command(0, "DebugSpringBoot", function()
    local configurations = read_dap_configurations()
    local items = {}
    for i, c in ipairs(configurations) do
        table.insert(items, i .. ". " .. c.mainClass .. " - " .. (c.module or ""))
    end

    local selected = vim.fn.inputlist(items)
    local picked = configurations[selected]
    if not picked then
        return
    end

    local dap = require("dap")
    dap.configurations.java = {
        {
            mainClass = picked.mainClass,
            projectName = picked.module,
            name = "Launch " .. picked.mainClass,
            request = "launch",
            type = "java",
        },
    }

    dap.continue()
    open_dap_ui()
end, {})

vim.keymap.set("n", "<leader>dap", attach_to_java_debug, { silent = true, remap = false, buffer = 0 })
vim.keymap.set("n", "<leader>dt", function()
    local jdtls_dap = require("jdtls.dap")
    jdtls_dap.pick_test()
    open_dap_ui()
end, { silent = true, remap = false, buffer = 0 })

vim.api.nvim_buf_create_user_command(0, "TestMethod", function()
    jdtls.test_nearest_method()
    open_dap_ui()
end, {})

vim.api.nvim_buf_create_user_command(0, "TestClass", function()
    jdtls.test_class()
    open_dap_ui()
end, {})
