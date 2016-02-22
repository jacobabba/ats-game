function love.load()
    levelX = 1
    levelY = 1
    tileType = 1
    expandView = false --if true, show 9 levels on the screen
    showGrid = true
    mouseHold = false --TODO: make click and drag filling
    DATAFILE = "DATA.lua"
    timeSinceSwp = 0

    world = require("world")
    world:loadWorld(DATAFILE)

    WINDOW_WIDTH = world.TILE_SIZE*world.LEVEL_WIDTH*1.5
    WINDOW_HEIGHT = world.TILE_SIZE*world.LEVEL_HEIGHT*1.5

    love.window.setMode(WINDOW_WIDTH, WINDOW_HEIGHT);
end

function love.update(dt)
    timeSinceSwp = timeSinceSwp + dt
    local mouseX = love.mouse.getX()
    local mouseY = love.mouse.getY()

    if not expandView then
        --compensate for shifted level
        mouseX = mouseX - WINDOW_WIDTH/6
        mouseY = mouseY - WINDOW_HEIGHT/6

        mouseTileX = (mouseX - mouseX % world.TILE_SIZE)/world.TILE_SIZE + 1
        mouseTileY = (mouseY - mouseY % world.TILE_SIZE)/world.TILE_SIZE + 1
        mouseLevelX = levelX
        mouseLevelY = levelY
    else
        mouseTileX = (mouseX - mouseX % (world.TILE_SIZE*.5))/(world.TILE_SIZE*.5)
        mouseTileX = mouseTileX % world.LEVEL_WIDTH + 1

        mouseTileY = (mouseY - mouseY % (world.TILE_SIZE*.5))/(world.TILE_SIZE*.5)
        mouseTileY = mouseTileY % world.LEVEL_HEIGHT + 1

        mouseLevelX = (mouseX - mouseX % (WINDOW_WIDTH/3))/(WINDOW_WIDTH/3) - 1
        mouseLevelX = mouseLevelX + levelX

        mouseLevelY = (mouseY - mouseY % (WINDOW_HEIGHT/3))/(WINDOW_HEIGHT/3) - 1
        mouseLevelY = mouseLevelY + levelY
    end

    --swap file
    if timeSinceSwp > 10 then 
        world:saveWorld(DATAFILE..".eswp") 
        timeSinceSwp = 0
    end

    if not love.mouse.isDown(1, 2) then disableMouse = false end

    if love.mouse.isDown(1, 2) and not world:levelExists(mouseLevelX, mouseLevelY) and not diableMouse then
        world:newLevel(mouseLevelX, mouseLevelY)
        disableMouse = true
    elseif love.mouse.isDown(1) and not disableMouse then
        world:setTile(mouseLevelX, mouseLevelY, mouseTileX, mouseTileY, tileType)
    elseif love.mouse.isDown(2) and not disableMouse then
        world:setTile(mouseLevelX, mouseLevelY, mouseTileX, mouseTileY, 0)
    end
end

function love.draw()
    if expandView then
        --draw levels
        world:drawLevel(levelX-1, levelY-1, showGrid, 0,                0,                 .5)
        world:drawLevel(levelX,   levelY-1, showGrid, WINDOW_WIDTH/3,   0,                 .5)
        world:drawLevel(levelX+1, levelY-1, showGrid, WINDOW_WIDTH/1.5, 0,                 .5)
        world:drawLevel(levelX-1, levelY,   showGrid, 0,                WINDOW_HEIGHT/3,   .5)
        world:drawLevel(levelX,   levelY,   showGrid, WINDOW_WIDTH/3,   WINDOW_HEIGHT/3,   .5)
        world:drawLevel(levelX+1, levelY,   showGrid, WINDOW_WIDTH/1.5, WINDOW_HEIGHT/3,   .5)
        world:drawLevel(levelX-1, levelY+1, showGrid, 0,                WINDOW_HEIGHT/1.5, .5)
        world:drawLevel(levelX,   levelY+1, showGrid, WINDOW_WIDTH/3,   WINDOW_HEIGHT/1.5, .5)
        world:drawLevel(levelX+1, levelY+1, showGrid, WINDOW_WIDTH/1.5, WINDOW_HEIGHT/1.5, .5)

        --draw grid between levels
        love.graphics.setColor(255, 117, 117)
        love.graphics.line(0, WINDOW_HEIGHT/3, WINDOW_WIDTH, WINDOW_HEIGHT/3)
        love.graphics.line(0, WINDOW_HEIGHT/1.5, WINDOW_WIDTH, WINDOW_HEIGHT/1.5)
        love.graphics.line(WINDOW_WIDTH/3, 0, WINDOW_WIDTH/3, WINDOW_HEIGHT)
        love.graphics.line(WINDOW_WIDTH/1.5, 0, WINDOW_WIDTH/1.5, WINDOW_HEIGHT)
    else
        --draw level
        world:drawLevel(levelX, levelY, showGrid, WINDOW_WIDTH/6, WINDOW_HEIGHT/6, 1)

        --draw outline

    end
    love.graphics.setColor(255, 255, 255)
    love.graphics.print(mouseLevelX.." "..mouseLevelY.." "..mouseTileX.." "..mouseTileY, 10, 10)
end

function love.keypressed(key)
    if key == "up" then levelY = levelY - 1
    elseif key == "down" then levelY = levelY + 1
    elseif key == "left" then levelX = levelX - 1
    elseif key == "right" then levelX = levelX + 1
    elseif key == "g" then showGrid = not showGrid
    elseif key == "s" then world:saveWorld(DATAFILE)
    elseif key == "e" then expandView = not expandView
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
