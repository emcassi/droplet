local widget = require(... .. ".widget")
local core = require(... .. ".core")

return {
	widget = widget.widget,
	running = widget.running,
	start = function(interval_ms)
		core.start(interval_ms)
	end,
	stop = function()
		core.stop()
	end,
}
