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
            end
        end

        return entities, indexToManagerId
    end

    --add all systems to the manager here
    systemManager.levelCollisionSystem = require("level_collision_system.lua")
    systemManager.movementSystem = require("movement_system.lua")

    return systemManager
end
