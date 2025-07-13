local M = {}

local naughty = require("naughty")
local awful = require("awful")
local state = require("droplet.state")
local widget = require("droplet.widget")
local history = require("droplet.history")

function M:start(interval_ms)
	state.running = true
	if state.process then
		if state.process then
			local pid = tonumber(state.process)
			if pid then
				awful.spawn.easy_async_with_shell("kill " .. pid, function()
					state.process = nil
				end)
			end
		end
	end

	local cmd = string.format("python3 .config/awesome/droplet/droplet.py %d", interval_ms or 300)
	state.process = awful.spawn.with_line_callback(cmd, {
		stdout = function(line)
			state.active_color, state.contrast_color = line:match("^(#%x%x%x%x%x%x)%s+(#%x%x%x%x%x%x)")
			if state.active_color and state.contrast_color then
				widget.update()
			end
		end,
		stderr = function(line)
			naughty.notify({
				text = line,
				timeout = 5,
				position = "top_right",
				screen = awful.screen.focused(),
			})
		end,
		exit = function()
			state.running = false
			state.process = nil
		end,
	})
end

function M:stop()
	if state.process then
		local pid = tonumber(state.process)
		if pid then
			awful.spawn.easy_async_with_shell("kill " .. pid, function()
				state.process = nil
				state.running = false
			end)
		end
	end
end

function M:save_active_color()
	if not history:add_to_history(state.active_color) then
		naughty.notify({
			text = "Could not save color",
			timeout = 5,
			position = "top_right",
			screen = awful.screen.focused(),
		})
	end
end

return M
