-- plugin/gitsync.lua
-- Define Neovim user commands for GitSync

local gitsync = require("gitsync")

vim.api.nvim_create_user_command("GitSyncSend", function()
	gitsync.send_patch()
end, { desc = "Send git patch to remote" })

vim.api.nvim_create_user_command("GitSyncApply", function()
	gitsync.apply_patch()
end, { desc = "Apply incoming git patch" })
