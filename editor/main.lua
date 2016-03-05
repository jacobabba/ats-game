-----------------------------------------------------------------
-- editor/main.lua
-- Contains main love2d callbacks for the level editor.
-- Author: Jacob Abba
-----------------------------------------------------------------

function love.load()
    levelX = 1
    levelY = 1

    TILE_TYPES = require("tile_types")
    tileType = 1
    tileSelect = ""

    expandView = false --if true, show 9 levels on the screen
    showGrid = true

    mouse = {
        x = 0,
        y = 0,
        tileX = 0,
        tileY = 0,
        levelX = 1,
        levelY = 1,
        holdTime = 0,
        holdLevelX = nil,
        holdLevelY = nil
    }

    --current state of editing, i.e. what the user is doing now
    editState = "none" --the current editing state we're in:
                       --"none" - not currently editing
                       --"newlevel" - creating a new level
                       --"drawrect" - drawing a rectangle of tiles
                       --"drawfree" - freely drawing tiles
                       --"deletelevel" - deleting a level

    --mode the user is in, determines where editState will go depending on input
    editMode = "free" --free: create tiles individually:
                      --rect: draw rectangles of tiles
                      --deletelevel: delete levels

    DATAFILE = "DATA.lua"
    timeSinceSwp = 0

    world = require("world")
    world:loadWorld(DATAFILE)

    WINDOW_WIDTH = world.TILE_SIZE*world.LEVEL_WIDTH*1.5
    WINDOW_HEIGHT = world.TILE_SIZE*world.LEVEL_HEIGHT*1.5

    love.window.setMode(WINDOW_WIDTH, WINDOW_HEIGHT)

    rect = require("rect")
end

function love.update(dt)
    timeSinceSwp = timeSinceSwp + dt
    mouse.x = love.mouse.getX()
    mouse.y = love.mouse.getY()

    --find which tile and level the mouse is on
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

    --make swap file, handy if the program crashes
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
        elseif love.mouse.isDown(1) and editMode == "rect" then
            editState = "drawrect"
            rect:reset(mouse.tileX, mouse.tileY, mouse.levelX, mouse.levelY)
        elseif love.mouse.isDown(1) and editMode == "deletelevel" then
            editState = "deletelevel"
            mouse.holdTime = 0
            mouse.holdLevelX = mouse.levelX
            mouse.holdLevelY = mouse.levelY
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
        if love.mouse.isDown(1) then
            rect:update(mouse, world)
        elseif love.keyboard.isDown("escape") then
            editState = "none"
        else
            rect:write(world)
            editState = "none"
        end
    ----------------------------------------------
    elseif editState == "drawfree" then
        if love.mouse.isDown(1)
        and world:levelExists(mouse.levelX, mouse.levelY) then
            world:setTile(mouse.levelX, mouse.levelY, mouse.tileX, mouse.tileY, tileType)
        elseif not love.mouse.isDown(1) then
            editState = "none"
        end
    ----------------------------------------------
    elseif editState == "deletelevel" then
        --if the user holds the mouse on a level for 1.5 seconds, delete it
        if love.mouse.isDown(1) and mouse.levelX == mouse.holdLevelX 
        and mouse.levelY == mouse.holdLevelY then
            mouse.holdTime = mouse.holdTime + dt
        else
            mouse.holdTime = 0
            editState = "none"
        end

        if mouse.holdTime > 1.5 then
            world:deleteLevel(mouse.holdLevelX, mouse.holdLevelY)
        end
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
        rect:draw(mouse, world)
    end

    --show tile selection progress
    if tileSelect ~= "" then
        love.graphics.setColor(0, 0, 0)
        love.graphics.rectangle("fill", 0, 0, 50, 20)
        love.graphics.setColor(255, 117, 117)
        love.graphics.print(tileSelect, 0, 0)
    end

    --show info box
    --move out of the way if the mouse is near the box
    local infoXPos
    if expandView and mouse.x < 200 and mouse.y > WINDOW_HEIGHT-30 then
        infoXPos = WINDOW_WIDTH-200
    else
        infoXPos = 10
    end
        
    love.graphics.setColor(0, 0, 0)
    love.graphics.rectangle("fill", infoXPos-10, WINDOW_HEIGHT-25, 200, 20)
    love.graphics.setColor(255, 255, 255)
    love.graphics.print("("..mouse.levelX..", "..mouse.levelY
                        ..") - ("..mouse.tileX..", "..mouse.tileY..") - "
                        ..(editMode=="free" and "f" or editMode=="rect" and "r" or "x")
                        .." - "..tileType, infoXPos, WINDOW_HEIGHT-20)

    --show controls info/overlay
    if not expandView then
        love.graphics.setColor(255, 255, 255)
        love.graphics.print("Controls:\n".."Arrow keys - move levels\n"
                            .."g - toggle grid\n".."s - save changes\n"
                            .."e - toggle expanded view\n\n".."Editing modes:\n"
                            .."r - rect mode "..(editMode=="rect" and "(on)" or "(off)")
                            .."\nf - free mode "..(editMode=="free" and "(on)" or "(off)")
                            .."\nx - delete level "
                            ..(editMode=="deletelevel" and "(on)" or "(off)"), 10, 50)

        --show tile types available
        for k, v in pairs(TILE_TYPES) do
            love.graphics.printf("Available tiles: ", 
                                 WINDOW_WIDTH-WINDOW_WIDTH/6, 50, WINDOW_WIDTH/6, "right")

            love.graphics.printf((tileType==k and "*" or "")..v.name.." - "..k, 
                                 WINDOW_WIDTH-WINDOW_WIDTH/6, 65+k*15, WINDOW_WIDTH/6, "right")
        end
    end
end

function love.keypressed(key)
    if key == "up" and editState ~= "drawrect" then levelY = levelY - 1
    elseif key == "down" and editState ~= "drawrect" then levelY = levelY + 1
    elseif key == "left" and editState ~= "drawrect" then levelX = levelX - 1
    elseif key == "right" and editState ~= "drawrect" then levelX = levelX + 1
    elseif key == "g" then showGrid = not showGrid
    elseif key == "s" then world:saveWorld(DATAFILE)
    elseif key == "e" and editState ~= "drawrect" then expandView = not expandView
    elseif key == "r" then editMode = "rect"
    elseif key == "f" then editMode = "free"
    elseif key == "x" then editMode = "deletelevel"
    elseif key == "q" then world:setSpawn(mouse.levelX, mouse.levelY, mouse.tileX, mouse.tileY)
    elseif (key == "0" or key == "1" or key == "2" or key == "3" or key == "4" 
    or key == "5" or key == "6" or key == "7" or key == "8" or key == "9")
    and string.len(tileSelect) < 3 then
        tileSelect = tileSelect .. key
    elseif key == "t" and tileSelect ~= "" then
        local n = tonumber(tileSelect)

        if TILE_TYPES[n] then
            tileType = n
            tileSelect = ""
        else
            tileSelect = ""
        end
    elseif key == "escape" then
        tileSelect = ""
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
