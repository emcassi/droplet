local widget = require(... .. ".widget")
local core = require(... .. ".core")
local history = require(... .. ".history")
local helpers = require(... .. ".helpers")
local state = require(... .. ".state")

return {
	widget = widget.widget,
	running = widget.running,
	setup = function()
		history:load_history()
	end,
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
	load_history = function()
		history:load_history()
	end,
	get_history = function()
		return history:get_history()
	end,
	describe_history = function()
		history:load_history()
		return helpers.inspect(history:get_history())
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
	undo_last_action = function()
		history:undo_last_action()
	end,
	clear_active_color = function()
		state.active_color = nil
		state.contrast_color = nil
	end,
}
