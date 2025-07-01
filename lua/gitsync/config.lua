-- gitsync/config.lua
local M = {}

--- 127.0.0.1:6666
-- Default configuration
local config = {
	remote_user = "devuser",
	remote_host = "127.0.0.1",
	remote_port = "6666",
	remote_dir = "~",
}

M.settings = {
	remote_user = "devuser",
	remote_host = "127.0.0.1",
	remote_port = 6666,
	auto_connect = false,
	reconnect_interval = 15000,
	remote_project_path = "~/projects/", -- Configure the path to the project folder
}

function M.get(key)
	return M.settings[key]
end

function M.set(key, value)
	M.settings[key] = value
end

-- Get current project name from cwd
local function get_project_name()
	return vim.fn.fnamemodify(vim.fn.getcwd(), ":t")
end

-- Get full remote path for patch file
function M.get_remote_path()
	return string.format("%s:%s", config.remote_host, config.remote_port)
end

-- Get local patch file path
function M.get_patch_path()
	return vim.fn.getcwd() .. "/.gitsync/patch.diff"
end

-- Option override from user
function M.setup(user_config)
	config = vim.tbl_deep_extend("force", config, user_config or {})
end

return M
