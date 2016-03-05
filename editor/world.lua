-----------------------------------------------------------------
-- editor/world.lua
-- Contains the world class for manipulating/checking the status
--     of the world.
-- Author: Jacob Abba
-----------------------------------------------------------------

do
    local w = {}
    w.LEVEL_HEIGHT = 30 --height/width should be bigger than 1 or bad stuff happens
    w.LEVEL_WIDTH = 40
    w.TILE_SIZE = 20
    w.playerSpawn = {levelX=1, levelY=1, tileX=1, tileY=1}

    w.levelGrid = {}

    --sets the tile in the specified level
    function w:setTile(levelX, levelY, x, y, tileType)
        if self.playerSpawn.levelX ~= levelX or self.playerSpawn.levelY ~= levelY
        or self.playerSpawn.tileX ~= x or self.playerSpawn.tileY ~= y then
            self.levelGrid[levelX][levelY].tileGrid[x][y] = tileType
        end
    end

    function w:setSpawn(levelX, levelY, tileX, tileY)
        if self.levelGrid[levelX][levelY].tileGrid[tileX][tileY] == 0 then
            self.playerSpawn.levelX = levelX
            self.playerSpawn.levelY = levelY
            self.playerSpawn.tileX = tileX
            self.playerSpawn.tileY = tileY
        end
    end

    function w:levelExists(levelX, levelY)
        if self.levelGrid[levelX] == nil or self.levelGrid[levelX][levelY] == nil then
            return false
        else
            return true
        end
    end

    --returns false if any of the levels in specified range don't exist, else returns true
    function w:levelsExist(levelX1, levelY1, levelX2, levelY2)
        for i=levelX1,levelX2,(levelX1>levelX2 and -1 or 1) do
            for j=levelY1,levelY2,(levelY1>levelY2 and -1 or 1) do
                if self.levelGrid[i] == nil or self.levelGrid[i][j] == nil then
                    return false
                end
            end
        end

        return true
    end

    --make a new level with coords x,y in the world
    --uses g as the level's grid
    function w:newLevel(levelX, levelY, g)
        self.levelGrid[levelX] = self.levelGrid[levelX] or {}
        if self.levelGrid[levelX][levelY] then error("attempt to add a level that already exists") end

        local l = {}

        g = g or {}
        for i=1,self.LEVEL_WIDTH do
            g[i] = g[i] or {}
            for j=1,self.LEVEL_HEIGHT do
                g[i][j] = g[i][j] or 0
            end
        end
        l.tileGrid = g

        self.levelGrid[levelX][levelY] = l
    end

    --delete a level if it exists
    function w:deleteLevel(levelX, levelY)
        if self.levelGrid[levelX] and self.levelGrid[levelX][levelY] then
            self.levelGrid[levelX][levelY] = nil
        end
    end

    --if expandview is on, then draw this level, and all levels bordering it
    function w:drawLevel(levelX, levelY, showGrid, x, y, scale)
        local s = self.TILE_SIZE*scale --scaled tile size

        if self.levelGrid[levelX] == nil or self.levelGrid[levelX][levelY] == nil then
            love.graphics.setColor(127, 127, 127)
            love.graphics.print("Level doesn't exist. Click to create.", 100+x, 100+y)
        else
            --draw tiles
            local l = self.levelGrid[levelX][levelY]
            love.graphics.setColor(255, 255, 255)
            for i=1,self.LEVEL_WIDTH do
                for j=1,self.LEVEL_HEIGHT do
                    local t = TILE_TYPES[l.tileGrid[i][j]]

                    if t and t.isTile then
                        love.graphics.setColor(t.tileColorR, t.tileColorG, t.tileColorB)
                        love.graphics.rectangle("fill", (i-1)*s+x, (j-1)*s+y, s, s)
                    end
                end
            end

            --draw player spawn
            if levelX == self.playerSpawn.levelX and levelY == self.playerSpawn.levelY then
                love.graphics.setColor(168, 99, 181)
                love.graphics.rectangle("fill", (self.playerSpawn.tileX-1)*s+x, 
                                        (self.playerSpawn.tileY-1)*s+y, s, s)
            end

            --draw grid
            if showGrid then
                love.graphics.setColor(127, 127, 127)

                for i=0,self.LEVEL_HEIGHT do
                    love.graphics.line(x, i*s+y, self.LEVEL_WIDTH*s+x, i*s+y)
                end

                for i=0,self.LEVEL_WIDTH do
                    love.graphics.line(i*s+x, y, i*s+x, self.LEVEL_HEIGHT*s+y)
                end
            end
        end

        love.graphics.setColor(255, 117, 117)
        love.graphics.rectangle("line", x, y, s*self.LEVEL_WIDTH, s*self.LEVEL_HEIGHT)

        love.graphics.print("("..levelX..", "..levelY..")", 10+x, 10+y)
    end

    --load the world from a file (s)
    function w:loadWorld(s)
        function _levelEntry(levelX, levelY, g)
            self:newLevel(levelX, levelY, g)
        end

        function _playerSpawn(levelX, levelY, tileX, tileY)
            self:setSpawn(levelX, levelY, tileX, tileY)
        end

        dofile(s)
    end

    --save the world to a file (s)
    function w:saveWorld(s)
        local f = assert(io.open(s, "w"))

        for i,v in pairs(self.levelGrid) do
            for j,w in pairs(v) do
                f:write("_levelEntry("..i..", "..j..", \n{ ")

                --prime first column
                f:write("{"..w.tileGrid[1][1])
                for l=2,self.LEVEL_HEIGHT do
                    f:write(", "..w.tileGrid[1][l])
                end
                f:write("}")

                --write other columns
                for k=2,self.LEVEL_WIDTH do
                    f:write(",\n{"..w.tileGrid[k][1])
                    for l=2,self.LEVEL_HEIGHT do
                        f:write(", "..w.tileGrid[k][l])
                    end
                    f:write("}")
                end

                f:write("\n})\n\n")
            end
        end

        f:write("_playerSpawn("..self.playerSpawn.levelX..", "..self.playerSpawn.levelY
                ..", "..self.playerSpawn.tileX..", "..self.playerSpawn.tileY..")\n")

        f:close()
    end
    
    return w
end
