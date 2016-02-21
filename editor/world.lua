local w = {}
w.LEVEL_HEIGHT = 30 --height/width should be bigger than 1 or bad stuff happens
w.LEVEL_WIDTH = 40
w.TILE_SIZE = 20

w.levelGrid = {}

--sets the tile in the specified level
function w:setTile(levelX, levelY, x, y, tileType)
    self.levelGrid[levelX][levelY].tileGrid[x][y] = tileType
end

function w:levelExists(levelX, levelY)
    if self.levelGrid[levelX] == nil or self.levelGrid[levelX][levelY] == nil then
        return false
    else
        return true
    end
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

--if expandview is on, then draw this levels, and all levels bordering it
--TODO: implement expandView
function w:drawLevel(levelX, levelY, showGrid, expandView)
    if self.levelGrid[levelX] == nil or self.levelGrid[levelX][levelY] == nil then
        love.graphics.print("Level doesn't exist. Click to create.", 100, 100)
        return nil
    end

    --draw tiles
    love.graphics.setColor(255, 255, 255)
    local l = self.levelGrid[levelX][levelY]
    local s = self.TILE_SIZE
    for i=1,self.LEVEL_WIDTH do
        for j=1,self.LEVEL_HEIGHT do
            if l.tileGrid[i][j] == 1 then
                love.graphics.rectangle("fill", (i-1)*s, (j-1)*s, s, s)
            end
        end
    end

    --draw grid
    love.graphics.setColor(127, 127, 127)
    if showGrid then
        for i=1,self.LEVEL_HEIGHT do
            love.graphics.line(0, i*self.TILE_SIZE, self.LEVEL_WIDTH*self.TILE_SIZE, i*self.TILE_SIZE)
        end

        for i=1,self.LEVEL_WIDTH do
            love.graphics.line(i*self.TILE_SIZE, 0, i*self.TILE_SIZE, self.LEVEL_HEIGHT*self.TILE_SIZE)
        end
    end
end

function w:loadWorld(s)
    function _levelEntry(levelX, levelY, g)
        self:newLevel(levelX, levelY, g)
    end

    dofile(s)
end

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

    f:close()
end

return w
