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
        dragPrevLevelY = 1
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
            --check if we need to snap to something or unsnap
            if mouse.dragPrevLevelX ~= mouse.levelX then
                --mod signifies whether we are going to a bigger level than before or a smaller one
                local mod = (mouse.dragPrevLevelX<mouse.levelX and 1 or -1)

                --check if there are any nonexistant levels inhibiting our movement
                for i = mouse.dragPrevLevelX+mod, mouse.levelX, mod do
                    if not mouse.dragLevelSnapX and not world:levelsExist(i, mouse.dragLevelY, i, mouse.dragLevelSnapY or mouse.levelY) then
                        mouse.dragLevelSnapX = i - mod
                        break
                    end
                end

                if mouse.dragLevelSnapX == mouse.levelX then
                    mouse.dragLevelSnapX = nil
                end
            end

            if mouse.dragPrevLevelY ~= mouse.levelY then
                --mod signifies whether we are going to a bigger level than before or a smaller one
                local mod = (mouse.dragPrevLevelY<mouse.levelY and 1 or -1)

                --check if there are any nonexistant levels inhibiting our movement
                for i = mouse.dragPrevLevelY+mod, mouse.levelY, mod do
                    if not mouse.dragLevelSnapY and not world:levelsExist(mouse.dragLevelX, i, mouse.dragLevelSnapX or mouse.levelX, i) then
                        mouse.dragLevelSnapY = i - mod
                        break
                    end
                end

                if mouse.dragLevelSnapY == mouse.levelY then
                    mouse.dragLevelSnapY = nil
                end
            end

            mouse.dragPrevLevelX = mouse.levelX
            mouse.dragPrevLevelY = mouse.levelY
        elseif love.keyboard.isDown("escape") then
            editState = "none"
        else
            editState = "none"
            --TODO: write tiles to world
        end
    ----------------------------------------------
    elseif editState == "drawfree" then
        if love.mouse.isDown(1) and mouse.tileX > 0 and mouse.tileY > 0 
                and mouse.tileX <= world.LEVEL_WIDTH and mouse.tileY <= world.LEVEL_HEIGHT
                and world:levelExists(mouse.levelX, mouse.levelY) then
            world:setTile(mouse.levelX, mouse.levelY, mouse.tileX, mouse.tileY, tileType)
        elseif not love.mouse.isDown(1) then
            editState = "none"
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
        --tileShiftX and Y signify how many tiles we're shifting from dragTileX and Y
        local levelShiftX = mouse.levelX - mouse.dragLevelX
        local levelShiftY = mouse.levelY - mouse.dragLevelY
        local tileShiftX = mouse.tileX + world.LEVEL_WIDTH*levelShiftX - mouse.dragTileX
        local tileShiftY = mouse.tileY + world.LEVEL_HEIGHT*levelShiftY - mouse.dragTileY

        --if we're snapped to a level, modify tileShift vars to reflect taht
        if mouse.dragLevelSnapX then
            local snapShiftX = mouse.dragLevelSnapX - mouse.levelX

            if snapShiftX > 0 then
                tileShiftX = tileShiftX + (world.LEVEL_WIDTH - mouse.tileX + 1)
                tileShiftX = tileShiftX + (world.LEVEL_WIDTH*(snapShiftX-1))
            else
                tileShiftX = tileShiftX - (mouse.tileX)
                tileShiftX = tileShiftX + (world.LEVEL_WIDTH*(snapShiftX+1))
            end
        end

        if mouse.dragLevelSnapY then
            local snapShiftY = mouse.dragLevelSnapY - mouse.levelY
            if snapShiftY > 0 then
                tileShiftY = tileShiftY + (world.LEVEL_HEIGHT - mouse.tileY + 1)
                tileShiftY = tileShiftY + (world.LEVEL_HEIGHT*(snapShiftY-1))
            else
                tileShiftY = tileShiftY - (mouse.tileY)
                tileShiftY = tileShiftY + (world.LEVEL_HEIGHT*(snapShiftY+1))
            end
        end

        local startX, startY, scale

        --find start point of drawing and the scale of tiles
        if expandView then
            startX = WINDOW_WIDTH/3 + (mouse.dragTileX - 1)*world.TILE_SIZE*.5
            startX = startX + (mouse.dragLevelX - levelX)*world.LEVEL_WIDTH*world.TILE_SIZE*.5

            startY = WINDOW_HEIGHT/3 + (mouse.dragTileY - 1)*world.TILE_SIZE*.5
            startY = startY + (mouse.dragLevelY - levelY)*world.LEVEL_HEIGHT*world.TILE_SIZE*.5

            scale = .5
        else
            startX = WINDOW_WIDTH/6 + (mouse.dragTileX - 1)*world.TILE_SIZE
            startY = WINDOW_HEIGHT/6 + (mouse.dragTileY - 1)*world.TILE_SIZE

            scale = 1
        end

        --draw tiles for the rect preview
        for i=0,tileShiftX,(tileShiftX<0 and -1 or 1) do
            for j=0,tileShiftY,(tileShiftY<0 and -1 or 1) do
                love.graphics.setColor(255, 255, 255)
                love.graphics.rectangle("fill", i*world.TILE_SIZE*scale + startX, j*world.TILE_SIZE*scale + startY, 
                                        world.TILE_SIZE*scale, world.TILE_SIZE*scale)

                love.graphics.setColor(127, 127, 127)
                love.graphics.rectangle("line", i*world.TILE_SIZE*scale + startX, j*world.TILE_SIZE*scale + startY, 
                                        world.TILE_SIZE*scale, world.TILE_SIZE*scale)
            end
        end
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
    elseif key == "e" then expandView = not expandView
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
