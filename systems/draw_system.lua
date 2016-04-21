--draws all (drawable) entities to the screen
--if we need to draw entities from other levels because of shift,
--then we can get those managers from world

do
    local drawSystem = function (self, entityManagers, world, interpolate)
        local entities, indexToManagerId = 
            self.getEntities(entityManagers, {"drawable"})
        
        for k,v in ipairs(entities) do
            local x, y
            if v.transform then
                x = v.transform.xPosition + world.shiftX
                y = v.transform.yPosition + world.shiftY
                if v.motion then
                    x = x + interpolate*v.motion.xVelocity
                    y = y + interpolate*v.motion.yVelocity
                end
            end

            if v.drawable.drawType == "rectangle" then
                if v.colorState then
                    love.graphics.setColor(COLOR_CODES[v.colorState.state])
                else
                    love.graphics.setColor(255, 255, 255)
                end
                love.graphics.rectangle("fill", x, y, 
                                        v.transform.width, v.transform.height)
            elseif v.drawable.drawType == "line" then
                love.graphics.setColor(COLOR_CODES[v.colorState.state])
                for _,segv in ipairs(v.line.segments) do
                    if segv.width then
                        love.graphics.line(
                            (segv.x-1)*TILE_SIZE,
                            (segv.y-.5)*TILE_SIZE,
                            (segv.x-1+segv.width)*TILE_SIZE,
                            (segv.y-.5)*TILE_SIZE
                        )
                    elseif segv.height then
                        love.graphics.line(
                            (segv.x-.5)*TILE_SIZE,
                            (segv.y-1)*TILE_SIZE,
                            (segv.x-.5)*TILE_SIZE,
                            (segv.y-1+segv.height)*TILE_SIZE
                        )
                    end
                end
            end
        end

        --TODO: if there's a shift, the entities from other screens need to be drawn as well
    end

    return drawSystem
end
