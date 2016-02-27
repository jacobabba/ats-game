function love.load()
    levelX = 1
    levelY = 1
    tileType = 1
    expandView = false --if true, show 9 levels on the screen
    showGrid = true
    mouse = {
        x = 0,
        y = 0,
        tileX = 0,
        tileY = 0,
        levelX = 1,
        levelY = 1,
        dragTileX = 1,
        dragTileY = 1,
        dragLevelX = 1,
        dragLevelY = 1,
        dragLevelSnapX = nil,
        dragLevelSnapY = nil,
        dragPrevLevelX = 1,
        dragPrevLevelY = 1,
        dragTileShiftX = nil,
        dragTileShiftY = nil,
        dragLevelShiftX = nil,
        dragLevelShiftY = nil
    }
    editState = "none"
    rectMode = false

    DATAFILE = "DATA.lua"
    timeSinceSwp = 0

    world = require("world")
    world:loadWorld(DATAFILE)

    WINDOW_WIDTH = world.TILE_SIZE*world.LEVEL_WIDTH*1.5
    WINDOW_HEIGHT = world.TILE_SIZE*world.LEVEL_HEIGHT*1.5

    love.window.setMode(WINDOW_WIDTH, WINDOW_HEIGHT)

    rect = {update, draw = require("rect_mode")}
end

function love.update(dt)
    timeSinceSwp = timeSinceSwp + dt
    mouse.x = love.mouse.getX()
    mouse.y = love.mouse.getY()

    --compute mouseTile and mouseLevel
    if not expandView then
        --compensate for shifted level
        mouse.x = mouse.x - WINDOW_WIDTH/6
        mouse.y = mouse.y - WINDOW_HEIGHT/6

        mouse.tileX = (mouse.x - mouse.x % world.TILE_SIZE)/world.TILE_SIZE + 1
        mouse.tileY = (mouse.y - mouse.y % world.TILE_SIZE)/world.TILE_SIZE + 1

        if mouse.tileX < 1 then mouse.tileX = 1
        elseif mouse.tileX > world.LEVEL_WIDTH then mouse.tileX = world.LEVEL_WIDTH end

        if mouse.tileY < 1 then mouse.tileY = 1
        elseif mouse.tileY > world.LEVEL_HEIGHT then mouse.tileY = world.LEVEL_HEIGHT end

        mouse.levelX = levelX
        mouse.levelY = levelY
    else
        mouse.tileX = (mouse.x - mouse.x % (world.TILE_SIZE*.5))/(world.TILE_SIZE*.5)
        mouse.tileX = mouse.tileX % world.LEVEL_WIDTH + 1

        mouse.tileY = (mouse.y - mouse.y % (world.TILE_SIZE*.5))/(world.TILE_SIZE*.5)
        mouse.tileY = mouse.tileY % world.LEVEL_HEIGHT + 1

        mouse.levelX = (mouse.x - mouse.x % (WINDOW_WIDTH/3))/(WINDOW_WIDTH/3) - 1
        mouse.levelX = mouse.levelX + levelX

        mouse.levelY = (mouse.y - mouse.y % (WINDOW_HEIGHT/3))/(WINDOW_HEIGHT/3) - 1
        mouse.levelY = mouse.levelY + levelY
    end

    --make swap file
    if timeSinceSwp > 10 then 
        world:saveWorld(DATAFILE..".eswp") 
        timeSinceSwp = 0
    end

    --editing fsm
    ----------------------------------------------
    if editState == "none" then
        if love.mouse.isDown(1)
                and not world:levelExists(mouse.levelX, mouse.levelY) then
            world:newLevel(mouse.levelX, mouse.levelY)
            editState = "newlevel"
        elseif love.mouse.isDown(1) and rectMode then
            editState = "drawrect"
            mouse.dragTileX = mouse.tileX
            mouse.dragTileY = mouse.tileY
            mouse.dragLevelX = mouse.levelX
            mouse.dragLevelY = mouse.levelY
            mouse.dragPrevLevelX = mouse.levelX
            mouse.dragPrevLevelY = mouse.levelY
            mouse.dragLevelSnapX = nil
            mouse.dragLevelSnapY = nil
            mouse.dragLevelShiftX = nil
            mouse.dragLevelShiftY = nil
            mouse.dragTileShiftX = nil
            mouse.dragTileShiftY = nil
        elseif love.mouse.isDown(1) then
            editState = "drawfree"
        end
    ----------------------------------------------
    elseif editState == "newlevel" then
        if not love.mouse.isDown(1) then
            editState = "none"
        end
    ----------------------------------------------
    elseif editState == "drawrect" then
        rect.update()
    ----------------------------------------------
    elseif editState == "drawfree" then
        if love.mouse.isDown(1) and mouse.tileX > 0 and mouse.tileY > 0 
                and mouse.tileX <= world.LEVEL_WIDTH and mouse.tileY <= world.LEVEL_HEIGHT
                and world:levelExists(mouse.levelX, mouse.levelY) then
            world:setTile(mouse.levelX, mouse.levelY, mouse.tileX, mouse.tileY, tileType)
        elseif not love.mouse.isDown(1) then
            editState = "none"
        end
    ----------------------------------------------
    end
end

function love.draw()
    --draw level(s)
    if expandView then
        world:drawLevel(levelX-1, levelY-1, showGrid, 0,                0,                 .5)
        world:drawLevel(levelX,   levelY-1, showGrid, WINDOW_WIDTH/3,   0,                 .5)
        world:drawLevel(levelX+1, levelY-1, showGrid, WINDOW_WIDTH/1.5, 0,                 .5)
        world:drawLevel(levelX-1, levelY,   showGrid, 0,                WINDOW_HEIGHT/3,   .5)
        world:drawLevel(levelX,   levelY,   showGrid, WINDOW_WIDTH/3,   WINDOW_HEIGHT/3,   .5)
        world:drawLevel(levelX+1, levelY,   showGrid, WINDOW_WIDTH/1.5, WINDOW_HEIGHT/3,   .5)
        world:drawLevel(levelX-1, levelY+1, showGrid, 0,                WINDOW_HEIGHT/1.5, .5)
        world:drawLevel(levelX,   levelY+1, showGrid, WINDOW_WIDTH/3,   WINDOW_HEIGHT/1.5, .5)
        world:drawLevel(levelX+1, levelY+1, showGrid, WINDOW_WIDTH/1.5, WINDOW_HEIGHT/1.5, .5)
    else
        world:drawLevel(levelX, levelY, showGrid, WINDOW_WIDTH/6, WINDOW_HEIGHT/6, 1)
    end

    --draw rect preview if we're in drawrect state
    if editState == "drawrect" then
        rect.draw()
    end

    --show info about the tile/level the mouse is on
    love.graphics.setColor(255, 255, 255)
    love.graphics.print(mouse.levelX.." "..mouse.levelY.." "..mouse.tileX.." "..mouse.tileY, 10, 10)
end

function love.keypressed(key)
    if key == "up" then levelY = levelY - 1
    elseif key == "down" then levelY = levelY + 1
    elseif key == "left" then levelX = levelX - 1
    elseif key == "right" then levelX = levelX + 1
    elseif key == "g" then showGrid = not showGrid
    elseif key == "s" then world:saveWorld(DATAFILE)
    elseif key == "e" and editState ~= "drawrect" then expandView = not expandView
    elseif key == "r" then rectMode = not rectMode
    elseif key == "1" then tileType = 1
    elseif key == "d" then tileType = 0
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
