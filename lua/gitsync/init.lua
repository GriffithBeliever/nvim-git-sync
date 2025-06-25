-- nvim-git-sync/lua/gitsync/init.lua
-- Main entry point for library

local patch = require("gitsync.patch")
local sender = require("gitsync.sender")
local config = require("gitsync.config")

local M = {}

--- Sends the current git diff to the configured remote target
function M.send_patch()
	local patch_path = patch.create_patch()
	if patch_path then
		sender.send(patch_path, config.get_remote_path())
	end
end

--- Applies a patch file in the current working directory
function M.apply_patch()
	patch.apply_patch(config.get_patch_path())
end

return M
