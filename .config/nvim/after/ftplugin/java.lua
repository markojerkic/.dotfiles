-- Set tabs to 2 spaces specifically for Java files
vim.opt_local.tabstop = 2 -- Set tab character width to 2 spaces
vim.opt_local.shiftwidth = 2 -- Set indentation width to 2 spaces
vim.opt_local.expandtab = true -- Use spaces instead of tabs
vim.opt_local.cmdheight = 1 -- more space in the neovim command line for displaying messages

local fn = vim.fn
local capabilities = vim.lsp.protocol.make_client_capabilities()

local status_cmp_ok, cmp_nvim_lsp = pcall(require, "cmp_nvim_lsp")
if not status_cmp_ok then
	return
end
capabilities.textDocument.completion.completionItem.snippetSupport = false
capabilities = cmp_nvim_lsp.default_capabilities(capabilities)

local status, jdtls = pcall(require, "jdtls")
if not status then
	return
end
-- Determine OS
local home = os.getenv("HOME")
WORKSPACE_PATH = home .. "/.cache/jdtls-compile/"
CONFIG = "linux"

-- Find root of project
local root_markers = { ".git", "mvnw", "gradlew" }
local root_dir = require("jdtls.setup").find_root(root_markers)
if root_dir == "" then
	return
end

local is_file_exist = function(path)
	local f = io.open(path, "r")
	return f ~= nil and io.close(f)
end

Get_java_dap = function()
	local base_dir = home .. "/.local/share/nvim/mason/packages/java-debug-adapter/extension/server"
	local launcher_versions = io.popen('find "' .. base_dir .. '" -type f -name "*.jar"')

	if launcher_versions ~= nil then
		local lb_i, lb_versions = 0, {}
		for lb_version in launcher_versions:lines() do
			lb_i = lb_i + 1
			lb_versions[lb_i] = lb_version
		end
		launcher_versions:close()

		if next(lb_versions) ~= nil then
			local launcher_jar = fn.expand(string.format("%s", lb_versions[1]))
			if is_file_exist(launcher_jar) then
				return launcher_jar
			end
		end
	end

	return ""
end

Get_eclipse_equinix_launcher = function()
	local base_dir = home .. "/.local/share/nvim/mason/packages/jdtls/plugins/"
	local launcher_versions =
		io.popen('find "' .. base_dir .. '" -type f -name "org.eclipse.equinox.launcher_1.7.*.jar"')

	if launcher_versions ~= nil then
		local lb_i, lb_versions = 0, {}
		for lb_version in launcher_versions:lines() do
			lb_i = lb_i + 1
			lb_versions[lb_i] = lb_version
		end
		launcher_versions:close()

		if next(lb_versions) ~= nil then
			local launcher_jar = fn.expand(string.format("%s", lb_versions[1]))
			if is_file_exist(launcher_jar) then
				return string.format("%s", launcher_jar)
			end
		end
	end

	return ""
end

Get_lombok_javaagent = function()
	if is_file_exist(home .. "/.local/share/nvim/mason/packages/jdtls/lombok.jar") then
		return string.format("-javaagent:%s", home .. "/.local/share/nvim/mason/packages/jdtls/lombok.jar")
	end

	local lombok_dir = home .. "/.m2/repository/org/projectlombok/lombok/"
	if is_file_exist(lombok_dir) == false then
		return ""
	end

	local lombok_versions = io.popen('ls -1 "' .. lombok_dir .. '" | sort -r')
	if lombok_versions ~= nil then
		local lb_i, lb_versions = 0, {}
		for lb_version in lombok_versions:lines() do
			lb_i = lb_i + 1
			lb_versions[lb_i] = lb_version
		end
		lombok_versions:close()
		if next(lb_versions) ~= nil then
			local lombok_jar = fn.expand(string.format("%s%s/*.jar", lombok_dir, lb_versions[1]))
			if is_file_exist(lombok_jar) then
				return string.format("-javaagent:%s", lombok_jar)
			end
		end
	end
	return ""
end

local get_bundles = function()
	local bundles = {
		vim.fn.glob(Get_java_dap(), true),
	}
	local test_runner_base_dir = home .. "/.local/share/nvim/mason/packages/java-test/extension/server/"
	vim.list_extend(bundles, vim.split(vim.fn.glob(test_runner_base_dir .. "*.jar", true), "\n"))

	return bundles
end

local extendedClientCapabilities = jdtls.extendedClientCapabilities
extendedClientCapabilities.resolveAdditionalTextEditsSupport = true

-- local project_name = vim.fn.fnamemodify(vim.fn.getcwd(), ":p:h:t")

local workspace_dir = WORKSPACE_PATH
	.. vim.fn.fnamemodify(root_dir, ":h:t")
	.. "/"
	.. vim.fn.fnamemodify(root_dir, ":t")
-- See `:help vim.lsp.start_client` for an overview of the supported `config` options.
local config = {
	-- The command that starts the language server
	-- See: https://github.com/eclipse/eclipse.jdt.ls#running-from-the-command-line
	cmd = {

		-- 💀
		"java", -- or '/path/to/java17_or_newer/bin/java'
		-- depends on if `java` is in your $PATH env variable and if it points to the right version.

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
		Get_lombok_javaagent(),

		-- 💀
		"-jar",
		Get_eclipse_equinix_launcher(),

		-- 💀
		"-configuration",
		home .. "/.local/share/nvim/mason/packages/jdtls/config_linux/",

		"-data",
		workspace_dir,
	},
	-- 💀
	-- This is the default if not provided, you can remove it. Or adjust as needed.
	-- One dedicated LSP server & client will be started per unique root_dir
	root_dir = root_dir,
	-- Here you can configure eclipse.jdt.ls specific settings
	-- See https://github.com/eclipse/eclipse.jdt.ls/wiki/Running-the-JAVA-LS-server-from-the-command-line#initialize-request
	-- for a list of options
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
			importOrder = {
				"java",
				"jakarta",
				"javax",
				"com",
				"org",
			},
		},
	},
	-- Language server `initializationOptions`
	-- You need to extend the `bundles` with paths to jar files
	-- if you want to use additional eclipse.jdt.ls plugins.
	--
	-- See https://github.com/mfussenegger/nvim-jdtls#java-debug-installation
	--
	-- If you don't plan on using the debugger or other eclipse.jdt.ls plugins you can remove this
	init_options = {
		bundles = get_bundles(),
	},

	on_attach = function(client, bufnr)
		require("jdtls").setup_dap({ hotcodereplace = "auto" })
	end,
}

-- This starts a new client & server,
-- or attaches to an existing client & server depending on the `root_dir`.
jdtls.start_or_attach(config)

local opts = { silent = true, remap = false }

local lsp_config = require("marko.config.lsp")
lsp_config.lsp_keymap(opts)

vim.cmd(
	"command! -buffer -nargs=? -complete=custom,v:lua.require'jdtls'._complete_compile JdtCompile lua require('jdtls').compile(<f-args>)"
)
vim.cmd(
	"command! -buffer -nargs=? -complete=custom,v:lua.require'jdtls'._complete_set_runtime JdtSetRuntime lua require('jdtls').set_runtime(<f-args>)"
)
vim.cmd("command! -buffer JdtUpdateConfig lua require('jdtls').update_project_config()")
-- vim.cmd "command! -buffer JdtJol lua require('jdtls').jol()"
vim.cmd("command! -buffer JdtBytecode lua require('jdtls').javap()")
-- vim.cmd "command! -buffer JdtJshell lua require('jdtls').jshell()"

local MAVEN_DEBUG_OPTIONS = "-Xdebug -Xrunjdwp:transport=dt_socket,server=y,suspend=y,address=5005"
local GRADLE_DEBUG_OPTIONS = "--debug-jvm"

local function wrap_spring_jvm_args(args)
	return ' -Dspring-boot.run.jvmArguments="' .. args .. '" '
end

function RunMavenDebug()
	vim.ui.input({ prompt = "Run command: " }, function(command)
		vim.cmd("silent !tmux neww " .. command .. wrap_spring_jvm_args(MAVEN_DEBUG_OPTIONS))
	end)
end

function RunGradleDebug()
	vim.ui.input({ prompt = "Run command: " }, function(command)
		vim.cmd("silent !tmux neww " .. command .. " " .. GRADLE_DEBUG_OPTIONS)
	end)
end

function Attach_to_java_debug()
	local dap = require("dap")
	local dapui = require("dapui")
	vim.ui.input({ prompt = "Port: " }, function(port)
		dap.configurations.java = {
			{
				type = "java",
				request = "attach",
				name = "Attach to the process",
				hostName = "localhost",
				port = port,
			},
		}
		dap.continue()

		dapui.setup()
		dapui.open()
	end)
end

local function wrap_dap_ui(runner)
	local dap = require("dap")
	local dapui = require("dapui")
	runner(dap)
	dapui.setup()
	dapui.open()
	dap.continue()
end

vim.api.nvim_create_user_command("TestMethod", function()
	wrap_dap_ui(jdtls.test_nearest_method)
end, {})

vim.api.nvim_create_user_command("TestClass", function()
	wrap_dap_ui(jdtls.test_class)
end, {})

vim.keymap.set("n", "<leader>dap", function()
	Attach_to_java_debug()
end, opts)
vim.keymap.set("n", "<leader>dt", function()
	local jdtls_dap = require("jdtls.dap")
	wrap_dap_ui(jdtls_dap.pick_test)
end, opts)

-- Read the json file at ~/.config/nvim-jdtls/dap.json
local function get_dap_configurations()
	local dap_config_file = home .. "/.config/nvim-jdtls/dap.json"
	local dap_config = {}
	if is_file_exist(dap_config_file) then
		local file = io.open(dap_config_file, "r")

		if file == nil then
			return {}
		end

		local content = file:read("*a")
		file:close()
		dap_config = vim.fn.json_decode(content)
	end
	return dap_config
end

-- Ask user to input main class, and module
-- Save that config to a json file at ~/.config/nvim-jdtls/dap.json
-- Update if already exists
local function add_new_config()
	local main_class = vim.fn.input("Main class: ")
	local module = vim.fn.input("Module: ") or ""
	local new_config = {
		mainClass = main_class,
		module = module,
	}

	local current_config_list = get_dap_configurations()

	-- Append new config to the current list
	table.insert(current_config_list, new_config)

	-- save the file
	local dap_config_file = home .. "/.config/nvim-jdtls/dap.json"

	-- if file, or the parent directory does not exist, create it
	if not is_file_exist(dap_config_file) then
		os.execute("mkdir -p " .. home .. "/.config/nvim-jdtls")
	end

	-- if file does not exist, create it
	local file = io.open(dap_config_file, "w")
	if file == nil then
		return
	end

	file:write(vim.fn.json_encode(current_config_list))
	file:close()
	print("Config added successfully " .. main_class)
end

vim.api.nvim_create_user_command("AddDapConfig", function()
	add_new_config()
end, {})

-- Create a command to list all the configurations
-- Ask user to select one
-- Use telescope to pick
local function list_dap_configurations()
	local dap_config = get_dap_configurations()
	local config_list = {}
	for i, available_config in ipairs(dap_config) do
		table.insert(config_list, i .. ". " .. available_config.mainClass .. " - " .. available_config.module)
	end

	local selected_config = vim.fn.inputlist(config_list)
	return dap_config[selected_config]
end

vim.api.nvim_create_user_command("DebugSpringBoot", function()
	wrap_dap_ui(function(dap)
		local selected_config = list_dap_configurations()
		if selected_config == nil then
			return
		end

		dap.configurations.java = {
			{
				mainClass = selected_config.mainClass,
				projectName = selected_config.module,
				name = "Launch " .. selected_config.mainClass,
				request = "launch",
				type = "java",
			},
		}
	end)
end, {})
