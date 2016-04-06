--simply applies movement to an entity based on its velocity
--signature: transform, movement

do
    local movementSystem = function (self, entityManagers)
        local entities, indexToManagerId = 
            self.getEntities(entityManager, {"transform", "motion"})
        
        for k,v in ipairs(entities) do
            v.transform.x = v.transform.x + v.motion.xVelocity
            v.transform.y = v.transform.y + v.motion.yVelocity
        end
    end

    return movementSystem
end
