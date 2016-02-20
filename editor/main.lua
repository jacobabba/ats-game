function love.load()
    levelX = 0
    levelY = 0
    tileType = 1
    expandView = false --if true, show 9 levels on the screen
    showGrid = true

    world = require("world")
end

function love.update(dt)
    local x = (love.mouse.getX - love.mouse.getX % 20)/20
    local y = (love.mouse.getY - love.mouse.getY % 20)/20

    if love.mouse.isDown(1, 2) and not world:levelExists() then
        world:newLevel(levelX, levelY)
    if love.mouse.isDown(1) then
        world:setTile(x, y, tileType)
    elseif love.mouse.isDown(2) then
        world:setTile(x, y, 0)
    end
end

function love.draw()
    world:drawLevel()
end

function love.keypressed(key)
end
