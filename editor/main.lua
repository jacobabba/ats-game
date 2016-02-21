function love.load()
    levelX = 1
    levelY = 1
    tileType = 1
    expandView = false --if true, show 9 levels on the screen
    showGrid = true
    mouseHold = false
    DATAFILE = "DATA.lua"
    timeSinceSwp = 0

    world = require("world")
    world:loadWorld(DATAFILE)
end

function love.update(dt)
    timeSinceSwp = timeSinceSwp + dt
    local x = (love.mouse.getX() - love.mouse.getX() % world.TILE_SIZE)/world.TILE_SIZE + 1
    local y = (love.mouse.getY() - love.mouse.getY() % world.TILE_SIZE)/world.TILE_SIZE + 1

    if timeSinceSwp > 10 then world:saveWorld(DATAFILE..".eswp") end --swap file

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
end

function love.keypressed(key)
    if key == "up" then levelY = levelY - 1
    elseif key == "down" then levelY = levelY + 1
    elseif key == "left" then levelX = levelX - 1
    elseif key == "right" then levelX = levelX + 1
    elseif key == "g" then showGrid = not showGrid
    elseif key == "s" then world:saveWorld(DATAFILE)
    end
end

function love.quit()
    --make sure the user remembers to save
    local messageChoice = 
        love.window.showMessageBox(
            " ",
            "Would you like to save before closing?",
            {"Yes", "No", "Cancel", enterbutton=1, escapebutton=3}
        )

    if messageChoice == 1 then
        world:saveWorld(DATAFILE)
        os.remove(DATAFILE..".eswp")
        return false
    elseif messageChoice == 2 then
        os.remove(DATAFILE..".eswp")
        return false
    elseif messageChoice == 3 then
        return true --don't exit
    end
end
