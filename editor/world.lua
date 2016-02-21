local w = {}
w.LEVEL_HEIGHT = 30
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
function w:newLevel(x, y)
    self.levelGrid[x] = self.levelGrid[x] or {}
    if self.levelGrid[x][y] then error("attempt to add a level that already exists") end

    local l = {}

    g = {}
    for i=1,self.LEVEL_WIDTH do
        g[i] = {}
        for j=1,self.LEVEL_HEIGHT do
            g[i][j] = 0
        end
    end
    l.tileGrid = g

    self.levelGrid[x][y] = l
end

--if expandview is on, then draw this levels, and all levels bordering it
--TODO: implement expandView
function w:drawLevel(levelX, levelY, showGrid, expandView)
    if self.levelGrid[levelX] == nil or self.levelGrid[levelX][levelY] == nil then
        love.graphics.print("Level doesn't exist. Click to create.", 100, 100)
        return nil
    end

    --draw tiles
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
    love.graphics.setColor(255, 255, 255)
end

return w
