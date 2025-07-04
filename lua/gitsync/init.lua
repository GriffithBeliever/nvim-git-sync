-- nvim-git-sync/lua/gitsync/init.lua
-- Main entry point for library

local patch = require("gitsync.patch")
local sender = require("gitsync.sender")
local config = require("gitsync.config")
local connection = require("gitsync.connection")
local tunnel = require("gitsync.tunnel")
local sync = require("gitsync.sync")
local status = require("gitsync.status")

local M = {}

--- Open Tunnel to remote
function M.open_tunnel()
	if not tunnel.is_open() then
		tunnel.open()
		status.update(true)
	end
end

--- Close Tunnel to remote
function M.close_tunnel()
	if tunnel.is_open() then
		tunnel.close()
		status.update(false)
	end
end

--- Check project matches this root project
function M.match()
	if tunnel.is_open() then
		sync.is_project_match()
	end
end

--- Sync local project to remote
function M.sync_project()
	if tunnel.is_open() then
		-- sync.sync_project()
		sync.unison_sync()
	end
end

--- Check Connection to remote
function M.is_connected()
	return connection.check_remote_alive()
end

--- Connect to remote
function M.connect()
	connection.check_remote_alive()
end

function M.force_connect()
	connection.force_connect()
end

--- Disconnect from remote
function M.disconnect()
	connection.disconnect()
end

--- Check the connection to remote
function M.check_connected()
	vim.notify(string.format("Connected %s", config.get_remote_path()), vim.log.levels.INFO)
	config.get_remote_path()
	return true
end

--- Sends the current git diff to the configured remote target
function M.send_patch()
	vim.notify("Hello, world from GitSync!", vim.log.levels.INFO)
	return "hello world"
	-- local patch_path = patch.create_patch()
	-- if patch_path then
	-- sender.send(patch_path, config.get_remote_path())
	-- end
end

--- Applies a patch file in the current working directory
function M.apply_patch()
	patch.apply_patch(config.get_patch_path())
end

return M
