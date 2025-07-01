local M = {}

local tunnel_job = nil

local config = require("gitsync.config")

function M.open()
	if tunnel_job then
		vim.notify("[GitSync] Tunnel already open")
		return
	end

	local ssh_cmd = {
		"ssh",
		"-N",
		"-L",
		"9999:localhost:22",
		config.get("remote_user") .. "@" .. config.get("remote_host"),
		"-p",
		"6667",
	}

	-- for graceful shutdown
	tunnel_job = vim.fn.jobstart(ssh_cmd, {
		on_exit = function(_, code)
			tunnel_job = nil
			if code == 0 then
				vim.notify("[GitSync] SSH tunnel closed gracefully")
			else
				vim.notify("[GitSync] SSH tunnel exited with code" .. code)
			end
		end,
	})

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
