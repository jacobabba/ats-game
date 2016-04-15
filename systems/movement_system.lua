--simply applies movement to an entity based on its velocity
--signature: transform, movement

do
    local movementSystem = function (self, entityManagers)
        local entities, indexToManagerId = 
            self.getEntities(entityManagers, {"transform", "motion"})
        
        for k,v in ipairs(entities) do
            v.transform.xPosition = v.transform.xPosition + v.motion.xVelocity
            v.transform.yPosition = v.transform.yPosition + v.motion.yVelocity
        end
    end

    return movementSystem
end
