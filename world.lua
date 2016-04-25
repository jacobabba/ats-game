do
    local w = {}

    --maps the ids from the levelGrids to the color,
    w.tileTypes = {
        {255, 255, 255},
        {247, 39, 39}
    }
    
    w.levelGrid = {}
    w.levelX = 1
    w.levelY = 1
    w.shiftX = 0
    w.shiftY = 0

    w.playerSpawn = {levelX=1, levelY=1, tileX=1, tileY=1}

    function w:getCurrentLevel()
        return self.levelGrid[self.levelX][self.levelY]
    end
    
    --make a new level with coords x,y in the world
    --uses g as the level's grid
    function w:newLevel(x, y, grid, entities)
        self.levelGrid[x] = self.levelGrid[x] or {}
        if self.levelGrid[x][y] then error("attempt to add a level that already exists") end
    
        local l = {}
    
        grid = grid or {}
        for i=1,LEVEL_WIDTH do
            grid[i] = grid[i] or {}
            for j=1,LEVEL_HEIGHT do
                grid[i][j] = grid[i][j] or 0
            end
        end
        l.tileGrid = grid

        l.entityManager = ENTITY_MANAGER_CLASS:newManager()
        for k,v in ipairs(entities or {}) do
            l.entityManager:addEntity(v, k)
        end

        self.levelGrid[x][y] = l
    end

    function w:getEntityManager(levelX, levelY)
        return self.levelGrid[levelX][levelY].entityManager
    end
    
    --TODO: optimize this...
    function w:drawLevel()
        local l = self.levelGrid[self.levelX][self.levelY]
        local s = TILE_SIZE
        for i=1,LEVEL_WIDTH do
            for j=1,LEVEL_HEIGHT do
                if l.tileGrid[i][j] ~= 0 then
                    love.graphics.setColor(self.tileTypes[l.tileGrid[i][j]])
                    love.graphics.rectangle("fill", (i-1)*s+self.shiftX,
                                            (j-1)*s+self.shiftY, s, s)
                end
            end
        end
    
        --if we're shifting we need to draw other levels
        if self.shiftX ~= 0 or self.shiftY ~= 0 then
            local xs = ((self.shiftX < 0) and 1) or ((self.shiftX > 0) and -1) or 0
            local ys = ((self.shiftY < 0) and 1) or ((self.shiftY > 0) and -1) or 0
            local lw = LEVEL_WIDTH * TILE_SIZE
            local lh = LEVEL_HEIGHT * TILE_SIZE

            l = self.levelGrid[self.levelX+xs][self.levelY+ys]
            for i=1,LEVEL_WIDTH do
                for j=1,LEVEL_HEIGHT do
                    if l.tileGrid[i][j] == 1 then
                        love.graphics.rectangle("fill", (i-1)*s+self.shiftX+xs*lw,
                                                (j-1)*s+self.shiftY+ys*lh, s, s)
                    end
                end
            end
        end
    end
    
    function w:changeLevel(x, y)
        if x == -1 then
            self.levelX = self.levelX - 1
            self.shiftX = self.shiftX - LEVEL_WIDTH * TILE_SIZE
        elseif x == 1 then
            self.levelX = self.levelX + 1
            self.shiftX = self.shiftX + LEVEL_WIDTH * TILE_SIZE
        end
    
        if y == -1 then
            self.levelY = self.levelY - 1
            self.shiftY = self.shiftY - LEVEL_HEIGHT * TILE_SIZE
        elseif y == 1 then
            self.levelY = self.levelY + 1
            self.shiftY = self.shiftY + LEVEL_HEIGHT * TILE_SIZE
        end
    
        if self.levelGrid[self.levelX] == nil 
        or self.levelGrid[self.levelX][self.levelY] == nil then
            error("player entered a level that doesn't exist!")
        end
    end

    function w:update()
        self.shiftX = self.shiftX*0.90
        self.shiftY = self.shiftY*0.90

        if self.shiftX < .5 and self.shiftX > -.5 then self.shiftX = 0 end
        if self.shiftY < .5 and self.shiftY > -.5 then self.shiftY = 0 end
    end

    --load the world from a file (s)
    function w:loadWorld(s)
        function _levelEntry(levelX, levelY, grid, entities)
            self:newLevel(levelX, levelY, grid, entities)
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
