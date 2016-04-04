do
    local function movementSystem(self, entityManagers)
        local entities, indexToManagerId = self.getEntities(entityManager)
        
        for k,v in ipairs(entities) do
            v.transform.x = v.transform.x + v.motion.xVelocity
            v.transform.y = v.transform.y + v.motion.yVelocity
        end
    end

    return movementSystem
end
