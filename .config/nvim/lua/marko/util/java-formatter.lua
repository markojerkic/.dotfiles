local M = {}

local home = os.getenv("HOME")

-- Find Java 21 from SDKMAN
local function find_java21()
    local sdkman_java = home .. "/.sdkman/candidates/java"

    -- Try to find existing Java 21
    local java21_patterns = {
        "21-tem", -- Temurin
        "21-open", -- OpenJDK
        "21.0", -- Generic 21.0.x
        "21-zulu", -- Zulu
        "21-oracle", -- Oracle
    }

    for _, pattern in ipairs(java21_patterns) do
        local java_path = sdkman_java .. "/" .. pattern .. "/bin/java"
        if vim.fn.executable(java_path) == 1 then
            return java_path
        end
    end

    -- Fallback: find any directory starting with "21"
    local handle = io.popen("ls -d " .. sdkman_java .. "/21* 2>/dev/null | head -1")
    if handle then
        local result = handle:read("*a")
        handle:close()
        if result and result ~= "" then
            local java_path = result:gsub("%s+", "") .. "/bin/java"
            if vim.fn.executable(java_path) == 1 then
                return java_path
            end
        end
    end

    return nil
end

-- Install Java 21 asynchronously
local function install_java21_async(callback)
    if vim.fn.isdirectory(home .. "/.sdkman") ~= 1 then
        vim.notify("SDKMAN not found. Please install SDKMAN first: https://sdkman.io", vim.log.levels.WARN)
        return
    end

    vim.notify("Java 21 not found. Installing via SDKMAN in background...", vim.log.levels.INFO)

    local install_cmd = string.format(
        'bash -c "source %s/.sdkman/bin/sdkman-init.sh && sdk install java 21-tem < /dev/null"',
        home
    )

    vim.fn.jobstart(install_cmd, {
        on_exit = function(_, exit_code)
            if exit_code == 0 then
                vim.notify("Java 21 installed successfully!", vim.log.levels.INFO)
                local java_path = home .. "/.sdkman/candidates/java/21-tem/bin/java"
                if vim.fn.executable(java_path) == 1 then
                    callback(java_path)
                end
            else
                vim.notify("Failed to install Java 21. Please run: sdk install java 21-tem", vim.log.levels.ERROR)
            end
        end,
    })
end

-- Setup Google Java Format
local function setup_google_java_format()
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

-- Setup and return Java formatter configuration
function M.setup()
    local java_formatter_jar = setup_google_java_format()
    local java21_path = find_java21()

    -- If Java 21 not found, install it asynchronously
    if not java21_path then
        install_java21_async(function(new_java_path)
            java21_path = new_java_path
        end)
    end

    return {
        jar_path = java_formatter_jar,
        java_path = java21_path,
    }
end

return M
