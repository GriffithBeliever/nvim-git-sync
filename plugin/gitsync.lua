-- plugin/gitsync.lua
-- Define Neovim user commands for GitSync

local gitsync = require("gitsync")

-- Highlight groups for the dot
vim.api.nvim_set_hl(0, "GitSyncConnected", { fg = "#00ff00" })
vim.api.nvim_set_hl(0, "GitSyncDisconnected", { fg = "#ff0000" })

--- Run on Open
vim.api.nvim_create_autocmd("VimEnter", {
	callback = function()
		local ok, gitsync = pcall(require, "gitsync")
		if ok then
			gitsync.open_tunnel()
		end
	end,
})

vim.api.nvim_create_user_command("GitSyncConnect", function()
	gitsync.open_tunnel()
end, { desc = "Openning tunnel to remote" })

vim.api.nvim_create_user_command("GitSyncDisconnect", function()
	gitsync.close_tunnel()
end, { desc = "Closing tunnel to remote" })

vim.api.nvim_create_user_command("GitSyncMatch", function()
	gitsync.match()
end, { desc = "Checking if local project root has a remote" })

vim.api.nvim_create_user_command("GitSyncProject", function()
	gitsync.sync_project()
end, { desc = "Sync local project to remote" })

---------------------------------------------------------------------------
--- Outdated functions ---

vim.api.nvim_create_user_command("GitSyncConnectedOutdated", function()
	gitsync.is_connected()
end, { desc = "Checking connection to remote" })

vim.api.nvim_create_user_command("GitSyncConnectOutdated", function()
	gitsync.connect()
end, { desc = "Connecting to remote" })

vim.api.nvim_create_user_command("GitSyncDisconnectOutdated", function()
	gitsync.disconnect()
end, { desc = "Disconnecting from remote" })

vim.api.nvim_create_user_command("GitSyncSend", function()
	gitsync.send_patch()
end, { desc = "Send git patch to remote" })

vim.api.nvim_create_user_command("GitSyncApply", function()
	gitsync.apply_patch()
end, { desc = "Apply incoming git patch" })
