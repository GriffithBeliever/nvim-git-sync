-- gitsync/sender.lua
local M = {}

-- Send a patch file to remote using scp
function M.send(local_path, remote_path)
	local cmd = string.format("scp %s %s", local_path, remote_path)
	local result = os.execute(cmd)
	if result == 0 then
		print("[GitSync] Patch sent to remote: " .. remote_path)
	else
		print("[GitSync] Failed to send patch")
	end
end

return M
