local M = {}

local config = require("gitsync.config")

local function get_nvim_project_root()
	-- LazyVim often sets 'vim.g.root_dir' if you're using a project management plugin
	if vim.g.root_dir and vim.g.root_dir ~= "" then
		return vim.g.root_dir
	end
	-- Fallback to current working directory
	return vim.fn.getcwd()
end

function M.is_project_match()
	local local_root = get_nvim_project_root()
	local remote_expected_path = config.get("remote_project_path")
	local master_socket_path = config.get("master_socket_path")

	if not local_root or not remote_expected_path then
		vim.notify(
			"[GitSync] Project path check failed: Local root or remote path not configured.",
			vim.log.levels.WARN
		)
		return false
	end

	if not master_socket_path then
		vim.notify(
			"[GitSync] SSH ControlMaster socket details not found. Is the tunnel master running?",
			vim.log.levels.ERROR
		)
		return false
	end

	-- Normalize paths for comparison (remove trailing slashes, resolve '..', etc.)
	-- This is a basic normalization. For robust checks, consider `vim.fs.normalize` (Neovim 0.10+)
	-- or more advanced path manipulation.
	local local_root_name = vim.fn.fnamemodify(local_root, ":t")

	-- Construct the ssh command
	local ssh_cmd = string.format(
		'ssh -S %s -p %s %s@%s ls "%s"', -- use -vvv for debugging
		master_socket_path,
		config.get("remote_port"),
		config.get("remote_user"),
		config.get("remote_host"),
		remote_expected_path
	)

	local handle = io.popen(ssh_cmd)
	if not handle then
		vim.notify("[GitSync] Failed to execute SSH (tunneled) command", vim.log.levels.ERROR)
		return false
	end

	local result = handle:read("*a")
	handle:close()

	vim.notify("Local " .. local_root_name)
	vim.notify("Local " .. result)

	for dir in result:gmatch("[^\r\n]+") do
		vim.notify("remote " .. dir)
		vim.notify("Local " .. local_root_name)
		if dir == local_root_name then
			vim.notify("[GitSync] Match found in remote folder: " .. dir, vim.log.levels.INFO)
			return true
		end
	end

	vim.notify("[GitSync] No matching project found remotely", vim.log.levels.WARN)
	return false
end

return M
