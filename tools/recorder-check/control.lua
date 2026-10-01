-- Drives the companion's recorder without a player (tools/check-recorder.ps1): segments of 300
-- bytes with 3 kept, so it rotates within minutes; simulated production every 10 seconds; one
-- research finished by script at minute 5 and another at minute 28.

script.on_init(function()
  remote.call("py-tutorial-companion", "set_test_limits", 300, 3)
end)

local function finish_one_research()
  for _, tech in pairs(game.forces.player.technologies) do
    if tech.enabled and not tech.researched then
      tech.researched = true
      return
    end
  end
end

script.on_nth_tick(600, function(event)
  local stats = game.forces.player.get_item_production_statistics(game.surfaces.nauvis)
  stats.on_flow("iron-plate", 10)
  stats.on_flow("iron-ore", -80)
  if event.tick == 5 * 3600 or event.tick == 28 * 3600 then finish_one_research() end
end)
