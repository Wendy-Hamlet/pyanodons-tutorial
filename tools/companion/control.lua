-- Py tutorial companion. Two actions, each both a shortcut and a console command:
--   import (/pt-book):   puts the tutorial's blueprint book into the cursor. In single player the
--                        mod scripts are reloaded from disk first (game.reload_mods), so a book
--                        written by `node tools/bp-sync.js push` while the game runs is picked up.
--   export (/pt-export): writes the held blueprint book or blueprint (an item, or a record taken
--                        from the blueprint library) to script-output/py-tutorial-companion/
--                        export.txt, for `node tools/bp-sync.js pull`.
-- It also records the game as it is played (recorder.lua).

local recorder = require("recorder")

local EXPORT_FILE = "py-tutorial-companion/export.txt"

local found, book = pcall(require, "book")
if not found then book = nil end

--- Turns `stack` into the tutorial book. Returns import_stack's result (0 clean, -1 with errors,
--- 1 failed), or nil when no book has been pushed yet.
local function fill(stack)
  if not book then return nil end
  stack.set_stack({ name = "blueprint-book" })
  local result = stack.import_stack(book.string)
  if result == 1 then stack.clear() end
  return result
end

--- Writes an exported string; with `player_index`, only on that player's machine.
local function write_export(text, player_index)
  helpers.write_file(EXPORT_FILE, text, false, player_index)
end

local function give_book(player)
  if not book then
    player.print({ "py-tutorial-companion.no-book" })
    return
  end
  if not (player.cursor_stack and player.clear_cursor()) then
    player.print({ "py-tutorial-companion.cursor-busy" })
    return
  end
  local result = fill(player.cursor_stack)
  if result == 1 then
    player.print({ "py-tutorial-companion.import-failed" })
    return
  end
  player.print({ "py-tutorial-companion.imported", book.count, book.generated })
  if result == -1 then player.print({ "py-tutorial-companion.import-warnings" }) end
end

local function deliver_pending()
  script.on_event(defines.events.on_tick, nil)
  local pending = storage.pending or {}
  storage.pending = nil
  for index in pairs(pending) do
    local player = game.get_player(index)
    if player then give_book(player) end
  end
end

local function watch_pending()
  if storage.pending then script.on_event(defines.events.on_tick, deliver_pending) end
end

local function request_import(player)
  if game.is_multiplayer() then
    -- reload_mods does nothing in multiplayer: hand out the book loaded with the save.
    give_book(player)
    return
  end
  storage.pending = storage.pending or {}
  storage.pending[player.index] = true
  -- Takes effect after this handler returns; the reloaded script's on_load sees the request.
  game.reload_mods()
end

local function export_held(player)
  local record, stack = player.cursor_record, player.cursor_stack
  local ok, text, label = pcall(function()
    if record then return record.export_record(), record.label end
    if stack and stack.valid_for_read and (stack.is_blueprint_book or stack.is_blueprint) then
      return stack.export_stack(), stack.label
    end
  end)
  if not ok then
    player.print({ "py-tutorial-companion.export-failed", tostring(text) })
    return
  end
  if not text or text == "" then
    player.print({ "py-tutorial-companion.nothing-held" })
    return
  end
  write_export(text, player.index)
  player.print({ "py-tutorial-companion.exported", label or "?", EXPORT_FILE })
end

script.on_init(recorder.on_init)
script.on_configuration_changed(recorder.on_configuration_changed)
script.on_load(watch_pending)
recorder.register()

script.on_event(defines.events.on_lua_shortcut, function(event)
  local player = game.get_player(event.player_index) --[[@as LuaPlayer]]
  if event.prototype_name == "pt-import-book" then
    request_import(player)
  elseif event.prototype_name == "pt-export-held" then
    export_held(player)
  end
end)

commands.add_command("pt-book", { "py-tutorial-companion.command-book" }, function(command)
  local player = command.player_index and game.get_player(command.player_index)
  if player then request_import(player) end
end)

commands.add_command("pt-export", { "py-tutorial-companion.command-export" }, function(command)
  local player = command.player_index and game.get_player(command.player_index)
  if player then export_held(player) end
end)

-- For the check scripts (tools/check-companion.ps1, check-recorder.ps1), which have no player.
remote.add_interface("py-tutorial-companion", {
  fill = fill, write_export = write_export, set_test_limits = recorder.set_test_limits,
})
