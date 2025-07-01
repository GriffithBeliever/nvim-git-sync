-- gitsync/connection.lua
local uv = vim.loop
local config = require("gitsync.config")

local M = {}

local connected = false
local retry_timer = nil

function M.is_connected()
	if connected then
		vim.notify("[GitSync] Connected to " .. config.get("remote_host"))
	else
		vim.notify("[GitSync] Not Connected")
	end
	return connected
end

function M.check_remote_alive()
	local sock = uv.new_tcp()
	local new_status = connected
	sock:connect(config.get("remote_host"), config.get("remote_port"), function(err)
		sock:close()
		if not err then
			if not connected then
				vim.notify("[GitSync] Connected to " .. config.get("remote_host"))
				new_status = true
			end
		else
			if connected then
				vim.notify("[GitSync] Lost Connection to remote")
				new_status = false
			end
		end

		if new_status ~= connected then
			connected = new_status
			-- vim.schedule(function()
			-- 	vim.cmd("redrawstatus")
			-- end)
		end
	end)
end

function try_connect() end

function M.force_connect()
	try_connect()
end

function M.connect()
	if not config.get("auto_connect") then
		return
	end

	try_connect()

	if not retry_timer then
		retry_timer = uv.new_timer()
		retry_timer:start(
			config.get("reconnect_interval"),
			config.get("reconnect_interval"),
			vim.schedule_wrap(function()
				if not connected and config.get("auto_connect") then
					try_connect()
				end
			end)
		)
	end
end

function M.disconnect()
	if retry_timer then
		retry_timer:stop()
		retry_timer:close()
		retry_timer = nil
	end
	connected = false
	vim.notify("[GitSync] Disconnected from remote")
end

return M
