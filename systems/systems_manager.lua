do
    local systemManager = {}

    --Convenience function to put the entities from multiple managers into one
    --table. Also returns a table referencing the entities index in the new table to
    --its manager's index in the manager table, and its id in that manager,
    --which is handy if you want to remove the entity from the manager.
    function systemManager.getEntities(entityManagers, signature)
        local entities = {}
        local indexToManagerId = {}
        local n = 1
        for k,v in ipairs(entityManagers) do
            local e = v:getEntsFromSig(signature)
            for kk,vv in pairs(e) do
                entities[n] = vv
                indexToManagerId[n] = {manager = k, id = kk}
                n = n + 1
            end
        end

        return entities, indexToManagerId
    end

    --add all systems to the manager here
    systemManager.levelCollisionSystem = dofile("systems/level_collision_system.lua")
    systemManager.movementSystem = dofile("systems/movement_system.lua")
    systemManager.levelNavSystem = dofile("systems/level_nav_system.lua")
    systemManager.playerSystem = dofile("systems/player_system.lua")
    systemManager.drawSystem = dofile("systems/draw_system.lua")
    systemManager.lineCollisionSystem = dofile("systems/line_collision_system.lua")

    return systemManager
end
