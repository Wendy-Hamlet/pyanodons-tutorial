-- Drives tools/companion without a player (headless runs have none), for tools/check-companion.ps1:
-- fills a blueprint book from the pushed book.lua, reports its contents, exports it unchanged
-- (export.txt) and once more with two edits a player might make (export-edited.txt).

local function out(fmt, ...) log("CF-COMPANION " .. string.format(fmt, ...)) end

script.on_event(defines.events.on_tick, function()
  script.on_event(defines.events.on_tick, nil)
  local inv = game.create_inventory(1)
  local stack = inv[1]
  local result = remote.call("py-tutorial-companion", "fill", stack)
  out("fill result=%s book=%s label=%s description=%s", tostring(result),
    tostring(stack.valid_for_read and stack.is_blueprint_book), tostring(stack.label),
    tostring(stack.blueprint_description))
  local pages = stack.get_inventory(defines.inventory.item_main)
  for i = 1, #pages do
    if pages[i].valid_for_read then
      out("page %d: %s (%d entities, description %d bytes)", i, pages[i].label, pages[i].get_blueprint_entity_count(),
        #(pages[i].blueprint_description or ""))
    end
  end
  remote.call("py-tutorial-companion", "write_export", stack.export_stack())

  -- Edits: drop the last entity of page 2, relabel page 1.
  local entities = pages[2].get_blueprint_entities()
  entities[#entities] = nil
  pages[2].set_blueprint_entities(entities)
  pages[1].label = "Renamed in game"
  helpers.write_file("py-tutorial-companion/export-edited.txt", stack.export_stack())
  inv.destroy()
  out("done")
end)
