--this system handles the collisions between rigid entities and the level
--component signature: transform, movement, rigid

do
    --NOTE: for two moving objects, find point at which they share an x/y coord, and check if the two lines intersect.
    
    --[[
        Since the only level objects that can alter the player's trajectory are
        on a grid, and it is guaranteed that the player can only move over one
        horizontal and one vertical gridline per frame, we can optimize this
        quite a bit.
    
        We construct two parallelograms whose top and bottom sides are the player
        square's leading sides (based on velocity), and the projected player
        square's leading sides. (One for vertical collisions and one for horizontal
        collisions).
    
        We then check if the parallelograms pass through any gridlines, and if the
        grid-box it passes into is occupied, then a collision has happened. We check
        which grid areas it passes through by defining left and right critical points
        (for vertical collisions) which is where the parallelogram edges intersect
        with the gridline.
    
        ex: for downward velocity, the vertical collision visualized
    
        *bottom side of current player 
        (p1)_____________|______(p2) 
            \            |      \
             \(cl)       |       \(cr)
     (cy)-----\-------------------\-------- grid line passed!
               \         |         \
            (p3)\________|__________\(p4)
                         |           
            *bottom side of projected player
    
        Cl and cr are the critical points, and since each lies on a different
        horizontal section, we check if the grid space under each of them is 
        occupied.
    
        geometrically,
    
        cl.x = (cy-p1.y)/(p3.y-p1.y)*(p3.x-p1.x) + p1.x
        cr.x = cl.x + (p2.x-p1.x)
    
        Also, we need to figure out whether a vertical or horizontal collision
        happened first, because the player should be stopped at the first collision.
        We can define another variable ct (critical time) for vertical and horizontal
        collisions, and apply whichever collision has a smaller ct (or exists).
    
        In the example,
        cty = (cy-p1.y)/(p3.y-p1.y)
    
        We can also compute ct first and substitue it in when computing cl.
    --]]
    
    --TODO:clean these functions up
    
    --returns 1 if no collision happens, otherwise returns the time that 
    --the collision happened
    local function findSingleAxisCollision(level, pX, pW, pVX, pY, pH, pVY, invert) 
        -- TODO: document this better
        if pVY == 0 then return nil end
        local startLineX1 = pX
        local startLineX2 = pX + pW
        local endLineX1 = pX+pVX
        local startLineY, mod
    
        if pVY < 0 then
            startLineY = pY
            mod = -1
        else
            startLineY = pY + pH
            mod = 1
        end
        local endLineY = startLineY + pVY
    
        local cy = mod*endLineY - (mod*endLineY)%20
        
        if mod*startLineY > cy then
            return nil
        else
            -- We are crossing a grid line
            local cty, clx, crx, xcoordl, xcoordr, ycoord
    
            cty = (cy-mod*startLineY)/(mod*endLineY - mod*startLineY)
            clx = cty*(endLineX1-startLineX1) + startLineX1
            crx = clx + (startLineX2-startLineX1)
            
            if invert then
                ycoordl = math.ceil((clx-clx%20)/20 + 1)
                ycoordr = math.ceil(crx/20)
                xcoordr = mod*cy/20
                if mod == 1 then 
                    xcoordr = xcoordr+1 
                end
                xcoordl = xcoordr 
            else
                xcoordl = math.ceil((clx-clx%20)/20 + 1)
                xcoordr = math.ceil(crx/20)
                ycoordr = mod*cy/20
                if mod == 1 then 
                    ycoordr = ycoordr+1 
                end
                ycoordl = ycoordr 
            end
    
            if level[xcoordl] and level[xcoordl][ycoordl] == 1 
            or level[xcoordr] and level[xcoordr][ycoordr] == 1 then
                --collision!
                return cty
            else
                return 1
            end
        end
    end
 
    local levelCollisionSystem = function (self, entityManagers, world)
        local entities, indexToManagerId =
            self.getEntities(entityManagers, {"transform", "movement", "rigid"})

        for k,v in ipairs(entities) do
            --find vertical collision
            local cty = findSingleAxisCollision(world.getCurrentLevel(), 
                                                v.transform.xPosition, v.transform.width, 
                                                v.motion.xVelocity, 
                                                v.transform.yPosition, v.transform.height, 
                                                v.motion.yVelocity, false) 
        
            --find horizontal collision
            local ctx = findSingleAxisCollision(world.getCurrentLevel(), 
                                                v.transform.yPosition, v.transform.height, 
                                                v.motion.yVelocity, 
                                                v.transform.xPosition, v.transform.width, 
                                                v.motion.xVelocity, true) 
        
            if ctx <= cty then --horizontal happened first
                local tpX = v.transform.xPosition + v.motion.xVelocity*ctx
                local tpY = v.transform.yPosition + v.motion.yVelocity*ctx
        
                cty = findSingleAxisCollision(world.getCurrentLevel(),
                                              tpX, v.transform.width, 0, tpY, 
                                              v.transform.height, 
                                              v.motion.yVelocity*(1-ctx), false) 
        
                if cty ~= nil then
                    cty = ctx + (1-ctx)*cty
                else
                    cty = 1
                end
            elseif ctx > cty then --vertical happened first
                local tpX = v.transform.xPosition + v.motion.xVelocity*cty
                local tpY = v.transform.yPosition + v.motion.yVelocity*cty
        
                ctx = findSingleAxisCollision(world.getCurrentLevel(),
                                              tpY, v.transform.height, 0, tpX, 
                                              v.transform.width, 
                                              v.motion.xVelocity*(1-cty), true) 
        
                if ctx ~= nil then
                    ctx = cty + (1-cty)*ctx
                else
                    ctx = 1
                end
            end

            v.motion.xVelocity = v.motion.xVelocity * ctx
            v.motion.yVelocity = v.motion.yVelocity * cty
        end
    end

    return levelCollisionSystem
end
