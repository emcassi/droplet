local M = {}

function M.inspect(value, depth)
	depth = depth or 0
	local indent = string.rep("  ", depth)
	local t = type(value)

	if t == "table" then
		local str = "{\n"
		for k, v in pairs(value) do
			local key = tostring(k)
			str = str .. indent .. "  " .. key .. " = " .. M.inspect(v, depth + 1) .. ",\n"
		end
		return str .. indent .. "}"
	elseif t == "string" then
		return string.format("%q", value)
	else
		return tostring(value)
	end
end

return M
