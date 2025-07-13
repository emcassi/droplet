local M = {
	entries = {},
	actions = {},
	undos = {},
}

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

function M:get_history()
	self:load_history()
	local valid_entries = {}
	for _, entry in ipairs(M.entries) do
		if not entry.deletedAt then
			table.insert(valid_entries, entry)
		end
	end

	local valid_actions = {}
	for _, action in ipairs(M.actions) do
		if not action.undone then
			local entry = M:get_entry_by_id(action.entry_id)
			if not entry.undone then
				table.insert(valid_actions, entry)
			end
		end
	end

	return {
		entries = valid_entries,
		actions = valid_actions,
		undos = M.undos,
	}
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
	if data then
		M.entries = data["entries"] or {}
		M.actions = data["actions"] or {}
		M.undos = data["undos"] or {}
	end
end

local function save_history()
	ensure_dir(history_path)
	local file = io.open(history_path, "w")
	if not file then
		return false
	end

	local data = {
		entries = M.entries,
		actions = M.actions,
		undos = M.undos,
	}

	local encoded = json.encode(data, { indent = true })
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
	self:load_history()
	local entry = {
		id = create_id(),
		hex = hex,
		createdAt = os.date("%Y-%m-%d %H:%M:%S"),
		deletedAt = nil,
	}
	table.insert(M.entries, 1, entry)
	return save_history(), entry
end

function M:get_entry_by_id(id)
	self:load_history()
	for _, entry in ipairs(M.entries) do
		if entry.id == id then
			return entry
		end
	end
end

function M:get_entry_by_index(index)
	self:load_history()
	index = index or 1
	if M.entries and index > #M.entries then
		return nil
	end
	return M.entries[index]
end

function M:copy_index_to_clipboard(index)
	self:load_history()
	local entry = M:get_entry_by_index(index)
	if entry then
		awful.spawn.with_shell('echo "' .. entry.hex .. '" | xclip -selection clipboard')
	end
end

local function should_delete(entry)
	return entry.deletedAt and entry.deletedAt < os.date("%Y-%m-%d %H:%M:%S", os.time() - 60 * 60 * 24 * 7)
end

function M:clear_entries()
	self:load_history()
	for i, entry in ipairs(M.entries) do
		if should_delete(entry) then
			table.remove(M.entries, i)
		else
			entry.deletedAt = create_timestamp()
		end
	end
end

function M:delete_entry_by_id(id)
	self:load_history()
	local entry = M:get_entry_by_id(id)
	if entry and should_delete(entry) then
		table.remove(M.entries, entry.id)
	else
		entry.deletedAt = create_timestamp()
	end
	save_history()
end

function M:delete_entry_by_index(index)
	self:load_history()
	local entry = M:get_entry_by_index(index)
	if not entry then
		return
	end
	if should_delete(entry) then
		table.remove(M.entries, index)
	else
		entry.deletedAt = create_timestamp()
	end
	save_history()
end

local function clear_invalid()
	local removed_undos = {}
	for i, undo in ipairs(M.undos) do
		removed_undos[i] = undo.id
		if undo.action_id then
			local action = M:get_action_by_id(undo.action_id)
			if action then
				naughty.notify({
					text = "Undoing: " .. action.type .. " " .. action.entry_id,
					timeout = 5,
					position = "top_right",
					screen = awful.screen.focused(),
				})
				action.undone = true
			end
		end
	end

	for i = #removed_undos, 1, -1 do
		local index = removed_undos[i]
		table.remove(M.undos, i)
	end
	save_history()
end

function M:add_action(action, entry_id)
	local timestamp = create_timestamp()
	clear_invalid()
	table.insert(M.actions, 1, { entry_id = entry_id, type = action, performedAt = timestamp })
	save_history()
end

function M:undo_last_action()
	if #M.actions == 0 then
		return
	end

	for i = 1, #M.actions, 1 do
		local action = M.actions[i]
		if not action.undone then
			self:undo_action(action)
			self:add_undo(action)
			M.actions[i].undone = true
			save_history()
			return
		end
	end
end

function M:undo_action(action)
	if action.type == "add" then
		local entry = M:get_entry_by_id(action.entry_id)
		if entry then
			entry.deletedAt = create_timestamp()
		end
	elseif action.type == "delete" then
		local entry = M:get_entry_by_id(action.entry_id)
		if entry then
			entry.deletedAt = nil
		end
	elseif action.type == "clear" then
		for index in ipairs(action.entry_ids) do
			local entry = M:get_entry_by_id(action.entry_ids[index])
			if entry then
				entry.deletedAt = nil
			end
		end
	end
end

function M:add_undo(action)
	local id = create_id()
	local timestamp = create_timestamp()
	table.insert(M.undos, 1, { id = id, action_id = action.id, performedAt = timestamp })
	save_history()
end

return M
