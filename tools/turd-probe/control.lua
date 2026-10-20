-- Reads, one tick after a copy of a save loads (tools/save-probe.ps1), the T.U.R.D. choices of the
-- player force through pyalienlife's own remote interface "pywiki_turd_page": every researched
-- upgrade technology and the sub-technology chosen for it (or none yet), plus the hidden modules
-- and machine replacements the choices put in place. Nothing in the base is changed.

local function out(fmt, ...) log("CF-TURD " .. string.format(fmt, ...)) end

script.on_event(defines.events.on_tick, function()
  script.on_event(defines.events.on_tick, nil)
  local force = game.forces.player
  local iface = "pywiki_turd_page"
  if not remote.interfaces[iface] then out("no interface %s", iface) return end
  local none = remote.call(iface, "get_not_selected_constant")
  local selections = remote.call(iface, "get_turd_selections", force.index)
  local names = {}
  for master in pairs(selections) do names[#names + 1] = master end
  table.sort(names)
  for _, master in ipairs(names) do
    local tech = force.technologies[master]
    local choice = selections[master]
    out("upgrade %s (researched %s): %s", master, tostring(tech and tech.researched),
      choice == none and "NOT SELECTED" or tostring(choice))
  end
  -- every upgrade technology that is not researched yet, so the report lists all of them
  for name, tech in pairs(force.technologies) do
    if not selections[name] and name:match("%-upgrade$") then
      out("not researched: %s (%s)", name, tech.researched and "researched, no entry" or "open")
    end
  end
  for entity, module in pairs(remote.call(iface, "get_unlocked_modules", force.index)) do
    out("hidden module: %s -> %s", entity, module)
  end
  for old, new in pairs(remote.call(iface, "get_machine_replacements", force.index)) do
    out("machine replacement: %s -> %s", old, tostring(new))
  end
  out("done at tick %d", game.tick)
end)
