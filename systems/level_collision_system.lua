--this system handles the collisions between rigid entities and the level
--simply caps the velocity of an entity so that it doesn't go through things,
--so this should be called before the movement system
--component signature: transform, movement, rigid

do
    --NOTE: for two moving objects, find point at which they share 
    --an x/y coord, and check if the two lines intersect.
    
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
    
    --TODO: clean these functions up?
    --TODO: document this better
    --TODO: make sure this isn't buggy
    
    --returns 1 if no collision happens, otherwise returns the fraction of time that 
    --the collision happened
    local function findSingleAxisCollision(level, pX, pW, pVX, pY, pH, pVY, invert) 
        if pVY == 0 then return 1 end
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
    
        local cy = mod*endLineY - (mod*endLineY)%TILE_SIZE
        
        if mod*startLineY > cy then
            return 1
        else
            -- We are crossing a grid line
            local cty, clx, crx, xcoordl, xcoordr, ycoordl, ycoordr
    
            cty = (cy-mod*startLineY)/(mod*endLineY - mod*startLineY)
            clx = cty*(endLineX1-startLineX1) + startLineX1
            crx = clx + (startLineX2-startLineX1)
            
            if invert then
                ycoordl = math.ceil((clx-clx%TILE_SIZE)/TILE_SIZE + 1)
                ycoordr = math.ceil(crx/TILE_SIZE)
                xcoordr = mod*cy/TILE_SIZE
                if mod == 1 then 
                    xcoordr = xcoordr+1 
                end
                xcoordl = xcoordr 
            else
                xcoordl = math.ceil((clx-clx%TILE_SIZE)/TILE_SIZE + 1)
                xcoordr = math.ceil(crx/TILE_SIZE)
                ycoordr = mod*cy/TILE_SIZE
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
        local entities, _ =
            self.getEntities(entityManagers, {"transform", "motion", "rigid"})

        for _,v in ipairs(entities) do
            --find vertical collision
            local cty = findSingleAxisCollision(world:getCurrentLevel().tileGrid,
                                                v.transform.xPosition, v.transform.width, 
                                                v.motion.xVelocity, 
                                                v.transform.yPosition, v.transform.height,
                                                v.motion.yVelocity, false) 
        
            --find horizontal collision
            local ctx = findSingleAxisCollision(world:getCurrentLevel().tileGrid,
                                                v.transform.yPosition, v.transform.height, 
                                                v.motion.yVelocity, 
                                                v.transform.xPosition, v.transform.width, 
                                                v.motion.xVelocity, true) 

            if ctx ~= 1 or cty ~= 1 then --check if a collision happened
                if ctx <= cty then --horizontal happened first
                    local tpX = v.transform.xPosition + v.motion.xVelocity*ctx
                    local tpY = v.transform.yPosition + v.motion.yVelocity*ctx

                    cty = findSingleAxisCollision(world:getCurrentLevel().tileGrid,
                                                  tpX, v.transform.width, 0, tpY, 
                                                  v.transform.height, 
                                                  v.motion.yVelocity*(1-ctx), false) 

                    cty = ctx + (1-ctx)*cty
                elseif ctx > cty then --vertical happened first
                    local tpX = v.transform.xPosition + v.motion.xVelocity*cty
                    local tpY = v.transform.yPosition + v.motion.yVelocity*cty

                    ctx = findSingleAxisCollision(world:getCurrentLevel().tileGrid,
                                                  tpY, v.transform.height, 0, tpX, 
                                                  v.transform.width, 
                                                  v.motion.xVelocity*(1-cty), true) 

                    ctx = cty + (1-cty)*ctx
                end
            end

            --check if we're landing on ground
            if v.motion.yVelocity > 0 and cty ~= 1 then
                v.rigid.isOnGround = true
            else
                v.rigid.isOnGround = false
            end

            v.motion.xVelocity = v.motion.xVelocity * ctx
            v.motion.yVelocity = v.motion.yVelocity * cty
        end
    end

    return levelCollisionSystem
end
