local M = {}

M.connected = false

function M.update(state)
	M.connected = state
end

function M.get_dot()
	return "●"
end

function M.get_color()
	vim.notify("color is Green")
	if M.connected then
		vim.notify("color is Green")
		return "Green"
	else
		vim.notify("color is Red")
		return "Red"
	end
end

return M
