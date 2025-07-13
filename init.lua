local widget = require(... .. ".widget")
local core = require(... .. ".core")
local history = require(... .. ".history")
local helpers = require(... .. ".helpers")

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
	describe_history = function()
		return helpers.inspect(history:load_history())
	end,
	copy_active_color_to_clipboard = function()
		core.copy_active_color_to_clipboard()
	end,
	copy_index_to_clipboard = function(index)
		history:copy_index_to_clipboard(index)
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
