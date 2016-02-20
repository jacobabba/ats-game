local w = {}
w.LEVEL_HEIGHT = 30
w.LEVEL_WIDTH = 40
w.TILE_SIZE = 20

w.levelGrid = {}
w.levelX = 0
w.levelY = 0
w.shiftX = 0
w.shiftY = 0

--sets the tile in the specified level
function w:setTile(levelX, levelY, x, y, tileType)
    self.levelGrid[levelX][levelY].tileGrid[x][y] = tileType
end

function w:levelExists()
    if self.levelGrid[self.levelX] == nil or self.levelGrid[self.levelX][self.levelY] == nil then
        return false
    else
        return true
    end
end

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

function w:drawLevel()
    if self.levelGrid[self.levelX] == nil or self.levelGrid[self.levelX][self.levelY] == nil then
        return nil
    end

    local l = self.levelGrid[self.levelX][self.levelY]
    local s = self.TILE_SIZE
    for i=1,self.LEVEL_WIDTH do
        for j=1,self.LEVEL_HEIGHT do
            if l.tileGrid[i][j] == 1 then
                love.graphics.rectangle("fill", (i-1)*s+, (j-1)*s+, s, s)
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

return w
