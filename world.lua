do
    local w = {}
    w.LEVEL_HEIGHT = 30
    w.LEVEL_WIDTH = 40
    w.TILE_SIZE = 20
    
    w.levelGrid = {}
    w.levelX = 1
    w.levelY = 1
    w.shiftX = 0
    w.shiftY = 0

    w.playerSpawn = {levelX=1, levelY=1, tileX=1, tileY=1}
    
    --make a new level with coords x,y in the world
    --uses g as the level's grid
    function w:newLevel(x, y, g)
        self.levelGrid[x] = self.levelGrid[x] or {}
        if self.levelGrid[x][y] then error("attempt to add a level that already exists") end
    
        local l = {}
    
        g = g or {}
        for i=1,self.LEVEL_WIDTH do
            g[i] = g[i] or {}
            for j=1,self.LEVEL_HEIGHT do
                g[i][j] = g[i][j] or 0
            end
        end
        l.tileGrid = g
    
        self.levelGrid[x][y] = l
    end
    
    function w:drawLevel(shiftX, shiftY)
        local l = self.levelGrid[self.levelX][self.levelY]
        local s = self.TILE_SIZE
        for i=1,self.LEVEL_WIDTH do
            for j=1,self.LEVEL_HEIGHT do
                if l.tileGrid[i][j] == 1 then
                    love.graphics.rectangle("fill", (i-1)*s+shiftX, (j-1)*s+shiftY, s, s)
                end
            end
        end
    
        --if we're shifting we need to draw other levels
        local xs = 0
        local ys = 0
        local lw = self.LEVEL_WIDTH * self.TILE_SIZE
        local lh = self.LEVEL_HEIGHT * self.TILE_SIZE
    
        if shiftX < 0 then xs = 1
        elseif shiftX > 0 then xs = -1 end
    
        if shiftY < 0 then ys = 1
        elseif shiftY > 0 then ys = -1 end
    
        if shiftX ~= 0 or shiftY ~= 0 then
            l = self.levelGrid[self.levelX+xs][self.levelY+ys]
            for i=1,self.LEVEL_WIDTH do
                for j=1,self.LEVEL_HEIGHT do
                    if l.tileGrid[i][j] == 1 then
                        love.graphics.rectangle("fill", (i-1)*s+shiftX+xs*lw, (j-1)*s+shiftY+ys*lh, s, s)
                    end
                end
            end
        end
    
    end
    
    function w:changeLevel(x, y)
        if x == -1 then
            self.levelX = self.levelX - 1
        elseif x == 1 then
            self.levelX = self.levelX + 1
        end
    
        if y == -1 then
            self.levelY = self.levelY - 1
        elseif y == 1 then
            self.levelY = self.levelY + 1
        end
    
        if self.levelGrid[self.levelX] == nil or self.levelGrid[self.levelX][self.levelY] == nil then
            error("player entered a level that doesn't exist!")
        end
    end
    
    
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
    
    --returns nil if no collision happens, otherwise returns the time that the collision happened
    function w:findSingleAxisCollision(pX, pW, pVX, pY, pH, pVY, invert) 
        -- TODO: document this better
        local level = self.levelGrid[self.levelX][self.levelY].tileGrid
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
    
            if level[xcoordl] and level[xcoordl][ycoordl] == 1 or level[xcoordr] and level[xcoordr][ycoordr] == 1 then
                --collision!
                return cty
            end
        end
    end
    
    --findLevelCollisions returns:
    --  ctx - time of x collision (1 if no collision)
    --  cty - time of y collision (1 if no collision)
    --  xCol - true if there was an x collision
    --  yCol - true if there was a y collision
    function w:findLevelCollisions(pX, pY, pVX, pVY, pW, pH)
        --find vertical collision
        local cty = self:findSingleAxisCollision(pX, pW, pVX, pY, pH, pVY, false) 
    
        --find horizontal collision
        local ctx = self:findSingleAxisCollision(pY, pH, pVY, pX, pW, pVX, true) 
    
        if ctx == nil and cty == nil then --no collision
            return 1, 1
        elseif ctx ~= nil and (cty == nil or ctx < cty) then --horizontal happened first
            local tpX = pX + pVX*ctx
            local tpY = pY + pVY*ctx
    
            cty = self:findSingleAxisCollision(tpX, pW, 0, tpY, pH, pVY*(1-ctx), false) 
    
            if cty ~= nil then
                cty = ctx + (1-ctx)*cty
            else
                cty = 1
            end
    
            return ctx, cty
        elseif cty ~= nil and (ctx == nil or ctx > cty) then --vertical happened first
            local tpX = pX + pVX*cty
            local tpY = pY + pVY*cty
    
            ctx = self:findSingleAxisCollision(tpY, pH, 0, tpX, pW, pVX*(1-cty), true) 
    
            if ctx ~= nil then
                ctx = cty + (1-cty)*ctx
            else
                ctx = 1
            end
    
            return ctx, cty
        else --both happened at the same time
            return ctx, cty
        end
    end
    
    --load the world from a file (s)
    function w:loadWorld(s)
        function _levelEntry(levelX, levelY, g)
            self:newLevel(levelX, levelY, g)
        end

        function _playerSpawn(levelX, levelY, tileX, tileY)
            self.playerSpawn.levelX = levelX
            self.playerSpawn.levelY = levelY
            self.levelX = levelX
            self.levelY = levelY
            self.playerSpawn.tileX = tileX
            self.playerSpawn.tileY = tileY
        end

        dofile(s)
    end
    
    return w
end
