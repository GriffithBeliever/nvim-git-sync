local M = {}

local tunnel_job = nil

local config = require("gitsync.config")

-- Define a directory for your SSH control sockets
-- local control_path_dir = vim.fn.stdpath("run") .. "/ssh_control_masters" example
local control_path_dir = "/private/tmp/ssh_ctrl_masters"

vim.fn.mkdir(control_path_dir, "p") -- Ensure the directory exists

-- Your SSH master command array
function M.open()
	if tunnel_job then
		vim.notify("[GitSync] Tunnel already open")
		return
	end

	-- Define the template for the master socket path.
	-- SSH will expand %r, %h, %p to the actual remote user, host, and port of the tunnel.
	local master_socket_path_template = string.format("%s/%%r@%%h:%%p", control_path_dir)

	local ssh_cmd = {
		"ssh",
		"-S",
		master_socket_path_template,
		"-N",
		"-M",
		"-L",
		"9999:localhost:22",
		config.get("remote_user") .. "@" .. config.get("remote_host"),
		"-p",
		"6667",
	}
	vim.notify(master_socket_path_template)

	-- for graceful shutdown
	tunnel_job = vim.fn.jobstart(ssh_cmd, {
		on_exit = function(_, code)
			tunnel_job = nil
			if code == 0 then
				vim.notify("[GitSync] SSH tunnel closed gracefully")
				return
			else
				vim.notify("[GitSync] SSH tunnel exited with code" .. code)
				return
			end
		end,
	})

	config.set("master_socket_path", master_socket_path_template)
	vim.notify("[GitSync] SSH tunnel opened")
end

function M.close()
	if not tunnel_job then
		vim.notify("[GitSync] No SSH tunnel to close")
		return
	end
	vim.fn.jobstop(tunnel_job)
	tunnel_job = nil
	vim.notify("[GitSync] SSH tunnel closed")
end

function M.is_open()
	return tunnel_job ~= nil
end

return M
