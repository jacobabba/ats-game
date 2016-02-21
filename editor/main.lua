function love.load()
    levelX = 1
    levelY = 1
    tileType = 1
    expandView = false --if true, show 9 levels on the screen
    showGrid = true
    disableMouse = false

    world = require("world")
end

function love.update(dt)
    local x = (love.mouse.getX() - love.mouse.getX() % 20)/20 + 1
    local y = (love.mouse.getY() - love.mouse.getY() % 20)/20 + 1

    if not love.mouse.isDown(1, 2) then disableMouse = false end

    if love.mouse.isDown(1, 2) and not world:levelExists(levelX, levelY) then
        world:newLevel(levelX, levelY)
        disableMouse = true
    elseif love.mouse.isDown(1) and not disableMouse then
        world:setTile(levelX, levelY, x, y, tileType)
    elseif love.mouse.isDown(2) and not disableMouse then
        world:setTile(levelX, levelY, x, y, 0)
    end
end

function love.draw()
    world:drawLevel(levelX, levelY, showGrid, expandView)
    love.graphics.setColor(127, 127, 127)
    love.graphics.print("("..levelX..", "..levelY..")", 10, 10)
    love.graphics.setColor(255, 255, 255)
end

function love.keypressed(key)
    if key == "up" then levelY = levelY - 1
    elseif key == "down" then levelY = levelY + 1
    elseif key == "left" then levelX = levelX - 1
    elseif key == "right" then levelX = levelX + 1
    elseif key == "g" then showGrid = not showGrid
    end
end
