local widget = require(... .. ".widget")
local core = require(... .. ".core")
local history = require(... .. ".history")

return {
	widget = widget.widget,
	running = widget.running,
	start = function(interval_ms)
		core.start(interval_ms)
	end,
	stop = function()
		core.stop()
	end,
	save_active_color = function()
		core.save_active_color()
	end,
	save_and_stop = function()
		core.save_active_color()
		core.stop()
	end,
	get_history = function()
		return history:load_history()
	end,
	clear_history = function()
		history:clear_history()
	end,
	delete_from_history = function(id)
		history:delete_from_history(id)
	end,
	delete_index_from_history = function(index)
		history:delete_index_from_history(index)
	end,
}
