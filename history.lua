local M = {}

local json = require("droplet.dkjson")
local naughty = require("naughty")
local lfs = require("lfs")
local history_path = os.getenv("HOME") .. "/.config/awesome/droplet/history.json"
local helpers = require("droplet.helpers")
local awful = require("awful")

local function ensure_dir(path)
	local dir = path:match("(.*/)")
	if dir and not lfs.attributes(dir, "mode") then
		lfs.mkdir(dir)
	end
end

function M:load_history()
	local file = io.open(history_path, "r")
	if not file then
		return {}
	end

	local content = file:read("*a")
	file:close()

	local data, _, err = json.decode(content)
	if err then
		print("Error loading history: " .. err)
		return {}
	end
	return data
end

local function save_history(history)
	ensure_dir(history_path)
	local file = io.open(history_path, "w")
	if not file then
		return false
	end

	local encoded = json.encode(history, { indent = true })
	file:write(encoded)
	file:close()
	return true
end

local function create_id()
	return os.time() * 1000 + math.random(1000)
end

local function create_timestamp()
	return os.date("%Y-%m-%d %H:%M:%S")
end

function M:add_to_history(hex)
	local history = M:load_history()
	local entry = {
		id = create_id(),
		hex = hex,
		pinned = false,
		deleted = false,
		createdAt = os.date("%Y-%m-%d %H:%M:%S"),
		deletedAt = nil,
	}
	table.insert(history, 1, entry)
	if save_history(history) then
		naughty.notify({
			text = helpers.inspect(history),
			timeout = 5,
			position = "top_right",
			screen = awful.screen.focused(),
		})
	end
end

function M:get_entry_by_id(id)
	local history = M:load_history()
	for _, entry in ipairs(history) do
		if entry.id == id then
			return entry
		end
	end
end

function M:get_entry_by_index(index)
	index = index or 1
	local history = M:load_history()
	if history and index > #history then
		return nil
	end
	return history[index]
end

function M:copy_index_to_clipboard(index)
	local entry = M:get_entry_by_index(index)
	if entry then
		awful.spawn.with_shell('echo "' .. entry.hex .. '" | xclip -selection clipboard')
	end
end

local function should_delete(entry)
	return entry.deletedAt and entry.deletedAt < os.date("%Y-%m-%d %H:%M:%S", os.time() - 60 * 60 * 24 * 7)
end

function M:clear_history()
	local history = M:load_history()
	for i, entry in ipairs(history) do
		if should_delete(entry) then
			table.remove(history, i)
		else
			entry.deletedAt = create_timestamp()
		end
	end
end

function M:delete_from_history(id)
	local history = M:load_history()
	local entry = M:get_entry_by_id(id)
	if entry and should_delete(entry) then
		table.remove(history, entry.id)
	else
		entry.deletedAt = create_timestamp()
	end
end

function M:delete_index_from_history(index)
	local history = M:load_history()
	local entry = M:get_entry_by_index(index)
	if not entry then
		return
	end
	if should_delete(entry) then
		table.remove(history, index)
	else
		entry.deletedAt = create_timestamp()
	end
end

return M
