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

local function get_master_path_from_template(template, user, host, port)
	local path = template
	path = path:gsub("%%r", user)
	path = path:gsub("%%h", host)
	path = path:gsub("%%p", port)
	return path
end

---
-- Sync the root project of current vim, into remote project
-- @return boolean true if sync was successful, false otherwise
---
function M.sync_project()
	vim.notify("[GitSync] Initiating project sync to remote...", vim.log.levels.INFO)
	local nvim_root = get_nvim_project_root()
	if not M.is_project_match() then
		vim.notify("[GitSync] Project doesn't exist on the remote", vim.log.levels.INFO)
	end
	if not nvim_root then
		vim.notify("[GitSync] Local project root not found. Cannot sync.", vim.log.levels.ERROR)
		return false
	end

	local remote_project_path = config.get("remote_project_path")
	if not remote_project_path then
		vim.notify("[GitSync] Remote project path not configured. Cannot sync.", vim.log.levels.ERROR)
		return false
	end

	local local_root_name = vim.fn.fnamemodify(nvim_root, ":t")
	remote_project_path = remote_project_path .. "/" .. local_root_name

	local master_template = config.get("master_socket_path")
	local remote_user = config.get("remote_user")
	local remote_host = config.get("remote_host")
	local remote_port = config.get("remote_port")
	local master_socket_path = get_master_path_from_template(master_template, remote_user, remote_host, remote_port)

	-- Verify the master socket file exists before attempting rsync
	if vim.fn.filereadable(master_socket_path) == 0 then
		vim.notify(
			"[GitSync] SSH ControlMaster socket file not found. Master tunnel might be down.",
			vim.log.levels.ERROR
		)
		vim.notify("Please restart the SSH tunnel master.", vim.log.levels.INFO)
		return false
	end

	local rsync_source = nvim_root .. "/"
	local rsync_destination = string.format("%s@%s:%s", remote_user, remote_host, remote_project_path)
	local ssh_for_rsync = string.format("ssh -S %s", master_socket_path)

	local rsync_excludes = {
		".git/",
		"node_modules/",
		"target/", -- For Rust projects
		"build/", -- For Java/C++ projects
		"__pycache__/", -- For Python
		"*.swp", -- Vim swap files
		"*.bak", -- Backup files
		"*.log", -- Log files
		".DS_Store", -- macOS specific
	}

	local exclude_args_list = {}
	for _, exclude_pattern in ipairs(rsync_excludes) do
		-- Each exclude pattern becomes its own argument in the list
		table.insert(exclude_args_list, '--exclude="' .. exclude_pattern .. '"')
	end

	-- Join all exclude arguments with a single space.
	-- This ensures no leading space on the whole string, and correct spacing between arguments.
	local exclude_args = table.concat(exclude_args_list, " ")
	local rsync_cmd_string = string.format(
		'rsync -avz --progress %s -e "%s" "%s" "%s"',
		exclude_args,
		ssh_for_rsync,
		rsync_source,
		rsync_destination
	)

	vim.notify("[GitSync] Executing rsync command: " .. rsync_cmd_string, vim.log.levels.INFO)
	local handle = io.popen(rsync_cmd_string)
	if not handle then
		vim.notify("[GitSync] Failed to execute rsync command via io.popen.", vim.log.levels.ERROR)
		return false
	end

	local rsync_output = handle:read("*a")
	local success = handle:close()

	if success then
		vim.notify("[GitSync] Project sync successful!", vim.log.levels.INFO)
		vim.notify("Rsync Output:\n" .. rsync_output, vim.log.levels.DEBUG)
		return true
	else
		vim.notify(
			string.format("[GitSync] Project sync FAILED with exit code: %s", tostring(exit_code)),
			vim.log.levels.ERROR
		)

		vim.notify(
			string.format("[GitSync] Project sync FAILED with exit code: %s", tostring(reason)),
			vim.log.levels.ERROR
		)
		vim.notify("Rsync Output:\n" .. rsync_output, vim.log.levels.ERROR)
		return false
	end
end

function M.is_project_match()
	local local_root = get_nvim_project_root()
	local remote_project_path = config.get("remote_project_path")
	local master_socket_path = config.get("master_socket_path")

	if not local_root or not remote_project_path then
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
		remote_project_path
	)

	local handle = io.popen(ssh_cmd)
	if not handle then
		vim.notify("[GitSync] Failed to execute SSH (tunneled) command", vim.log.levels.ERROR)
		return false
	end

	local result = handle:read("*a")
	handle:close()

	for dir in result:gmatch("[^\r\n]+") do
		if dir == local_root_name then
			vim.notify("[GitSync] Match found in remote folder: " .. dir, vim.log.levels.INFO)
			return true
		end
	end

	vim.notify("[GitSync] No matching project found remotely", vim.log.levels.WARN)
	return false
end

return M
