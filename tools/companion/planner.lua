-- Factory Planner capture. FP's remote interface ("fp-interface") exports only the factory a player
-- has open, so every 30 seconds (and on /pt-fp) each player's open factory is packed and, when it
-- changed, written to script-output/py-tutorial-companion/planner/<name>-<hash>.json: the latest
-- version of each factory, by name. In FP's packed data item amounts are per second and machine
-- amounts are machine counts. tools/planner-summary.js reads the files.

local planner = {}

local INTERFACE = "fp-interface"
local FOLDER = "py-tutorial-companion/planner/"
-- Ticks between checks. With FP's pause option on, no ticks pass while its window is open, so the
-- check comes after the window is closed; /pt-fp writes at once.
planner.EVERY = 1800

-- The last text written per file in this session. Kept out of storage on purpose: it only decides
-- whether a file is written again, which is not game state; after a load each open factory is
-- simply written once more.
local written = {}

function planner.available()
  local api = remote.interfaces[INTERFACE]
  return api ~= nil and api.export_current_factory == true
end

--- The factory name's ASCII letters and digits plus a hash of the whole name, so names in Chinese
--- or with rich text still get distinct files.
local function file_name(name)
  local hash = 5381
  for i = 1, #name do hash = (hash * 33 + name:byte(i)) % 4294967296 end
  local ascii = name:gsub("%[.-%]", ""):gsub("[^%w%-]+", "_"):sub(1, 40)
  return string.format("%s%s-%08x.json", FOLDER, ascii, hash)
end

local function count_lines(floor)
  local n = 0
  for _, line in ipairs(floor and floor.lines or {}) do
    n = n + (line.class == "Floor" and count_lines(line) or 1)
  end
  return n
end

--- Writes the factory `player` has open when it differs from the last write (always with `force`).
--- Returns name, line count, file and whether it was written; nil when FP has nothing to give.
---@param player LuaPlayer
---@param force boolean?
---@param run string? the recorder run, stored with the factory
function planner.capture(player, force, run)
  if not planner.available() then return nil end
  local ok, packed = pcall(remote.call, INTERFACE, "export_current_factory", player.index)
  if not ok or type(packed) ~= "table" then return nil end
  local encoded, text = pcall(helpers.table_to_json, packed)
  if not encoded then return nil end
  local name = packed.name or ""
  local file = file_name(name)
  local lines = count_lines(packed.top_floor)
  if not force and written[file] == text then return name, lines, file, false end
  written[file] = text
  helpers.write_file(file, helpers.table_to_json({
    tick = game.tick, run = run, player = player.name, factory = packed,
  }))
  return name, lines, file, true
end

return planner
