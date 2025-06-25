-- gitsync/config.lua
local M = {}

-- Default configuration
local config = {
	remote_user = "patchbot",
	remote_host = "your.server.com",
	remote_dir = "/srv/sync",
	patch_filename = "patch.diff",
}

-- Get current project name from cwd
local function get_project_name()
	return vim.fn.fnamemodify(vim.fn.getcwd(), ":t")
end

-- Get full remote path for patch file
function M.get_remote_path()
	return string.format(
		"%s@%s:%s/%s",
		config.remote_user,
		config.remote_host,
		config.remote_dir,
		get_project_name(),
		config.patch_filename
	)
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
