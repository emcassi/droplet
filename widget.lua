local wibox = require("wibox")
local beautiful = require("beautiful")
local naughty = require("naughty")

local M = {}

function M.create(config)
	local text = wibox.widget({
		widget = wibox.widget.textbox,
		markup = " Testing testing ",
	})

	local widget = wibox.widget({
		{
			text,
			widget = wibox.container.margin,
			margins = 4,
		},
		widget = wibox.container.background,
		bg = "#d939f2",
		fg = "#000000",
	})

	widget:connect_signal("button::press", function()
		naughty.notify({
			title = "Droplet",
			text = "Droplet Pressed",
			timeout = 10,
			position = "top_right",
		})
	end)

	return widget
end

return M
