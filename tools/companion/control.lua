-- Py tutorial companion. Two actions, each both a shortcut and a console command:
--   import (/pt-book):   puts the tutorial's blueprint book into the cursor. In single player the
--                        mod scripts are reloaded from disk first (game.reload_mods), so a book
--                        written by `node tools/bp-sync.js push` while the game runs is picked up.
--   export (/pt-export): writes the held blueprint book or blueprint (an item, or a record taken
--                        from the blueprint library) to script-output/py-tutorial-companion/
--                        export.txt, for `node tools/bp-sync.js pull`.
-- One more console command:
--   /pt-shots:           takes the screenshots listed in shots.lua (written by
--                        `node tools/shots.js plan`, picked up the same way as the book) into
--                        script-output/py-tutorial-companion/shots/, for `node tools/shots.js pull`.
--   /pt-fp:              writes the Factory Planner factory you have open to
--                        script-output/py-tutorial-companion/planner/ (planner.lua), for
--                        `node tools/planner-summary.js`.
-- It also records the game as it is played (recorder.lua), including the factory each player has
-- open in Factory Planner, every 30 seconds when it changed.

local recorder = require("recorder")
local planner = require("planner")

local EXPORT_FILE = "py-tutorial-companion/export.txt"

local found, book = pcall(require, "book")
if not found then book = nil end
local found_shots, shots = pcall(require, "shots")
if not found_shots then shots = nil end

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

--- Each listed area with entity info (alt view: recipes, filters, directions), at noon without
--- clouds or fog. The tutorial uses alt-view pictures only.
local function take_shots(player)
  if not shots then
    player.print({ "py-tutorial-companion.no-shots" })
    return
  end
  helpers.remove_path("py-tutorial-companion/shots") -- only this run's pictures are pulled
  for _, s in ipairs(shots) do
    local zoom = s.zoom or 1
    local w, h = s.x2 - s.x1 + 1, s.y2 - s.y1 + 1
    game.take_screenshot({
      player = player, surface = s.surface or "nauvis",
      position = { (s.x1 + s.x2 + 1) / 2, (s.y1 + s.y2 + 1) / 2 },
      resolution = { math.floor(w * 32 * zoom), math.floor(h * 32 * zoom) }, zoom = zoom,
      path = "py-tutorial-companion/shots/" .. s.name .. ".jpg",
      show_entity_info = true, daytime = 0, hide_clouds = true, hide_fog = true,
      force_render = true, anti_alias = true, quality = 90,
    })
  end
  player.print({ "py-tutorial-companion.shots-taken", #shots, shots.generated or "?" })
end

local ACTIONS = { book = give_book, shots = take_shots }

local function deliver_pending()
  script.on_event(defines.events.on_tick, nil)
  local pending = storage.pending or {}
  storage.pending = nil
  for index, action in pairs(pending) do
    local player = game.get_player(index)
    if player then (ACTIONS[action] or give_book)(player) end
  end
end

local function watch_pending()
  if storage.pending then script.on_event(defines.events.on_tick, deliver_pending) end
end

--- Runs `action` ("book" or "shots") for the player with the files as they are on disk now.
local function request(player, action)
  if game.is_multiplayer() then
    -- reload_mods does nothing in multiplayer: use the files loaded with the save.
    ACTIONS[action](player)
    return
  end
  storage.pending = storage.pending or {}
  storage.pending[player.index] = action
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

--- Writes the player's open FP factory; a timeline line when it was written.
local function capture_plan(player, force)
  local name, lines, file, wrote = planner.capture(player, force, recorder.run())
  if wrote then recorder.note("planner", { player = player.name, factory = name, lines = lines, file = file }) end
  return name, lines, file
end

script.on_init(recorder.on_init)
script.on_configuration_changed(recorder.on_configuration_changed)
script.on_load(watch_pending)
recorder.register()
script.on_nth_tick(planner.EVERY, function()
  if not recorder.enabled() then return end
  for _, player in pairs(game.players) do capture_plan(player, false) end
end)

script.on_event(defines.events.on_lua_shortcut, function(event)
  local player = game.get_player(event.player_index) --[[@as LuaPlayer]]
  if event.prototype_name == "pt-import-book" then
    request(player, "book")
  elseif event.prototype_name == "pt-export-held" then
    export_held(player)
  end
end)

commands.add_command("pt-book", { "py-tutorial-companion.command-book" }, function(command)
  local player = command.player_index and game.get_player(command.player_index)
  if player then request(player, "book") end
end)

commands.add_command("pt-export", { "py-tutorial-companion.command-export" }, function(command)
  local player = command.player_index and game.get_player(command.player_index)
  if player then export_held(player) end
end)

commands.add_command("pt-shots", { "py-tutorial-companion.command-shots" }, function(command)
  local player = command.player_index and game.get_player(command.player_index)
  if player then request(player, "shots") end
end)

-- Its messages fall back to English text in a game started before they were added (locale files
-- are read at startup, scripts on every load).
commands.add_command("pt-fp", { "?", { "py-tutorial-companion.command-fp" },
  "Writes the Factory Planner factory you have open to script-output for tools/planner-summary.js." },
  function(command)
    local player = command.player_index and game.get_player(command.player_index)
    if not player then return end
    if not planner.available() then
      player.print({ "?", { "py-tutorial-companion.fp-missing" }, "Factory Planner is not loaded." })
      return
    end
    local name, lines, file = capture_plan(player, true)
    if not name then
      player.print({ "?", { "py-tutorial-companion.fp-none" }, "Open a factory in Factory Planner first." })
    else
      player.print({ "?", { "py-tutorial-companion.fp-written", name, lines, file },
        "Factory \"" .. name .. "\" (" .. lines .. " lines) written to script-output/" .. file })
    end
  end)

-- For the check scripts (tools/check-companion.ps1, check-recorder.ps1), which have no player.
remote.add_interface("py-tutorial-companion", {
  fill = fill, write_export = write_export, set_test_limits = recorder.set_test_limits,
})
