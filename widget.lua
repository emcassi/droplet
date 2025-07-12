local wibox = require("wibox")
local beautiful = require("beautiful")
local state = require("droplet.state")

local M = {}

local text_widget = wibox.widget({
	widget = wibox.widget.textbox,
	markup = " ",
	font = "FontAwesome 12",
})

local container = wibox.widget({
	{
		text_widget,
		widget = wibox.container.margin,
		margins = 2,
	},
	forced_width = 30,
	bg = beautiful.bg_normal,
	widget = wibox.container.background,
})

M.widget = container

function M.update()
	if not state.active_color then
		text_widget.markup = " "
		container.bg = beautiful.bg_normal
		container.fg = beautiful.fg_normal
		container.forced_width = 30
		return
	end
	text_widget.markup = "  " .. (state.active_color and state.active_color or "        ")
	container.forced_width = 110
	container.bg = state.active_color and state.active_color or beautiful.bg_normal
	container.fg = state.contrast_color and state.contrast_color or beautiful.fg_normal
end

return M
