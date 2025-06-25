-- gitsync/patch.lua
local M = {}
local Job = require("plenary.job")

-- Generate a git patch file and return its path
function M.create_patch()
	local cwd = vim.fn.getcwd()
	local patch_path = cwd .. "/.gitsync/patch.diff"
	vim.fn.mkdir(cwd .. "/.gitsync", "p")

	Job:new({
		command = "git",
		args = { "diff" },
		cwd = cwd,
		on_exit = function(j, return_val)
			if return_val == 0 then
				local patch = table.concat(j:result(), "\n")
				local f = io.open(patch_path, "w")
				f:write(patch)
				f:close()
				print("[GitSync] Patch written to " .. patch_path)
			else
				print("[GitSync] Failed to create patch")
			end
		end,
	}):sync()

	return patch_path
end

-- Apply a patch to current working directory
function M.apply_patch(path)
	local cwd = vim.fn.getcwd()

	if vim.fn.isdirectory(cwd .. "/.git") == 0 then
		print("[GitSync] Not a Git repository: " .. cwd)
		return
	end

	Job:new({
		command = "git",
		args = { "apply", path },
		cwd = cwd,
		on_exit = function(_, code, _)
			if code == 0 then
				print("[GitSync] Patch applied.")
				vim.cmd("checktime")
			else
				print("[GitSync] Failed to apply patch")
			end
		end,
	}):start()
end

return M
