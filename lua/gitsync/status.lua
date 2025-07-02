local M = {}

M.connected = false

function M.update(state)
	M.connected = state
end

function M.get_dot()
	return "●"
end

return M
