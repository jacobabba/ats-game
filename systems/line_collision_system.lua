--This system checks if any "state actors" pass through a line.
--If there is a collision, swap the state of the line and the actor.

--To prevent glitches where the actors can pass through the line
--without swapping, if the actor starts on a critical point and is 
--going in a negative direction, then the next critical point is where
--the player is starting. If the player is on a critical point and is
--going in a positive direction, then the next critical point is the
--next point to the right. 

--Moreover, if the actor is going in a
--positive direction and lands exactly on the next critical line,
--then we perform a swap. If the actor is going in the negative
--direction and lands on the next critical line, then don't 
--perform the swap.

do
    local lineCollisionSystem = function (self, entityManagers, world)
        local lines, lineIndexToManagerId =
            self.getEntities(entityManagers, {"line", "colorState"})

        local stateActors, stateActorIndexToManagerId =
            self.getEntities(entityManagers, {"transform", "motion", "colorState"})

        --Find which tile "centers" each actor is passing through,
        --and then find if there's a line at those centers.
        --Based on the algorithm from the level collision system.
        for k,v in ipairs(stateActors) do
            --the only point that matters on the actor is its center
            local prevx = v.transform.xPosition + v.transform.width/2
            local nextx = prevx + v.motion.xVelocity
            local modx = (v.motion.xVelocity > 0) and 1
                or (v.motion.xVelocity < 0) and -1
                or 0

            local prevy = v.transform.yPosition + v.transform.height/2
            local nexty = prevy + v.motion.yVelocity
            local mody = (v.motion.yVelocity > 0) and 1
                or (v.motion.yVelocity < 0) and -1
                or 0

            --Find the next critical point in the direction the player is moving.
            local cx = (modx*prevx-modx*TILE_SIZE/2)%TILE_SIZE
            if cx == 0 and modx == -1 then cx = 20 end
            cx = prevx-modx*(cx-TILE_SIZE)

            --Find if the actor passed the critical point
            while modx == 1 and cx <= nextx or modx == -1 and cx > nextx do
                --the coordinates of the tile where cx resides
                local tilex = cx/TILE_SIZE + .5
                local ctx = (cx-prevx)/(nextx-prevx)
                local tiley = math.ceil((ctx*(nexty-prevy)+prevy)/TILE_SIZE)

                --find if a line of this type exists on this tile
                for _,linev in ipairs(lines) do
                    for _,segv in ipairs(linev.line.segments) do
                        if segv.height and segv.x == tilex
                        and tiley>=segv.y and tiley<segv.y+segv.height then
                            --line collision
                            local temp = v.colorState.state
                            v.colorState.state = linev.colorState.state
                            linev.colorState.state = temp

                            --update linked lines
                            for _,linkv in pairs(linev.line.links or {}) do
                                local e = world:getEntityManager(linkv.levelx, linkv.levely)
                                e = e.getEntity(linkv.uid)
                                if e then e.colorState.state = temp end
                            end
                        end
                    end
                end

                cx = cx + modx*TILE_SIZE
            end
        end
    end

    return lineCollisionSystem
end
