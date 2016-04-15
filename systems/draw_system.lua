--draws all (drawable) entities to the screen
--if we need to draw entities from other levels because of shift,
--then we can get those managers from world

do
    local drawSystem = function (self, entityManagers, world, interpolate)
        local entities, indexToManagerId = 
            self.getEntities(entityManagers, {"drawable", "transform"})
        
        for k,v in ipairs(entities) do
            local x = v.transform.xPosition + world.shiftX
            local y = v.transform.yPosition + world.shiftY
            if v.motion then
                x = x + interpolate*v.motion.xVelocity
                y = y + interpolate*v.motion.yVelocity
            end

            if v.drawable.drawType == "rectangle" then
                love.graphics.rectangle("fill", x, y, 
                                        v.transform.width, v.transform.height)
            end
        end

        --TODO: if there's a shift, the entities from other screens need to be drawn as well
    end

    return drawSystem
end
