-- lua/gitsync/statusline.lua
local config = require("gitsync.config")
local connection = require("gitsync.connection")

local M = {}

-- Returns colored dot
function M.render()
	local hl = connection.is_connected() and "%#GitSyncConnected#" or "%#GitSyncDisconnected#"
	return hl .. "●" .. "%*"
end

-- Injects the dot into user's existing statusline
function M.inject()
	local current = vim.o.statusline
	if not current:find("gitsync_status") then
		vim.o.statusline = current .. " %{v:lua.require'gitsync.statusline'.render()}"
	end
end

return M
