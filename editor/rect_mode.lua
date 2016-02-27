--functions supporting drawrect mode

--TODO: didn't expect this functionality to be so cumbersome...
--threw it in here to separate it from the main file short-term, but I
--probably need to restructure this into a class to make it more managable

do
    local _r = {}

    function _r.update(mouse)
        if love.mouse.isDown(1) then
            --check if we need to snap to something or unsnap (x)
            if mouse.dragPrevLevelX ~= mouse.levelX then
                --mod signifies whether we are going to a bigger level than before or a smaller one
                local mod = (mouse.dragPrevLevelX<mouse.levelX and 1 or -1)

                --check if there are any nonexistant levels inhibiting our movement
                for i = mouse.dragPrevLevelX+mod, mouse.levelX, mod do
                    if not mouse.dragLevelSnapX 
                    and not world:levelsExist(i, mouse.dragLevelY, i, mouse.dragLevelSnapY or mouse.levelY) then
                        mouse.dragLevelSnapX = i - mod
                        break
                    end
                end

                if mouse.dragLevelSnapX == mouse.levelX then
                    mouse.dragLevelSnapX = nil
                end

                --recompute y to see if we can update the snap
                mod = (mouse.dragLevelY<mouse.levelY and 1 or -1)

                local noSnap = true
                for i = mouse.dragLevelY+mod, mouse.levelY, mod do
                    if not world:levelsExist(mouse.dragLevelX, i, mouse.dragLevelSnapX or mouse.levelX, i) then
                        mouse.dragLevelSnapY = i - mod
                        noSnap = false
                        break
                    end
                end

                if noSnap then
                    mouse.dragLevelSnapY = nil
                end
            end

            --check if we need to snap to something or unsnap (y)
            if mouse.dragPrevLevelY ~= mouse.levelY then
                --mod signifies whether we are going to a bigger level than before or a smaller one
                local mod = (mouse.dragPrevLevelY<mouse.levelY and 1 or -1)

                --check if there are any nonexistant levels inhibiting our movement
                for i = mouse.dragPrevLevelY+mod, mouse.levelY, mod do
                    if not mouse.dragLevelSnapY 
                    and not world:levelsExist(mouse.dragLevelX, i, mouse.dragLevelSnapX or mouse.levelX, i) then
                        mouse.dragLevelSnapY = i - mod
                        break
                    end
                end

                if mouse.dragLevelSnapY == mouse.levelY then
                    mouse.dragLevelSnapY = nil
                end

                --recompute x to see if we can update the snap
                mod = (mouse.dragLevelX<mouse.levelX and 1 or -1)

                local noSnap = true
                for i = mouse.dragLevelX+mod, mouse.levelX, mod do
                    if not world:levelsExist(i, mouse.dragLevelY, i, mouse.dragLevelSnapY or mouse.levelY) then
                        mouse.dragLevelSnapX = i - mod
                        noSnap = false
                        break
                    end
                end

                if noSnap then
                    mouse.dragLevelSnapX = nil
                end
            end

            mouse.dragPrevLevelX = mouse.levelX
            mouse.dragPrevLevelY = mouse.levelY

            --mouse.dragTileShiftX and Y signify how many tiles the rect is shifting from dragTileX and Y
            mouse.dragLevelShiftX = mouse.levelX - mouse.dragLevelX
            mouse.dragLevelShiftY = mouse.levelY - mouse.dragLevelY
            mouse.dragTileShiftX = mouse.tileX + world.LEVEL_WIDTH*mouse.dragLevelShiftX - mouse.dragTileX
            mouse.dragTileShiftY = mouse.tileY + world.LEVEL_HEIGHT*mouse.dragLevelShiftY - mouse.dragTileY

            --if we're snapped to a level, modify tileShift vars to reflect that
            if mouse.dragLevelSnapX then
                local snapShiftX = mouse.dragLevelSnapX - mouse.levelX

                if snapShiftX > 0 then
                    mouse.dragTileShiftX = mouse.dragTileShiftX + (world.LEVEL_WIDTH - mouse.tileX + 1)
                    mouse.dragTileShiftX = mouse.dragTileShiftX + (world.LEVEL_WIDTH*(snapShiftX-1))
                else
                    mouse.dragTileShiftX = mouse.dragTileShiftX - (mouse.tileX)
                    mouse.dragTileShiftX = mouse.dragTileShiftX + (world.LEVEL_WIDTH*(snapShiftX+1))
                end
            end

            if mouse.dragLevelSnapY then
                local snapShiftY = mouse.dragLevelSnapY - mouse.levelY
                if snapShiftY > 0 then
                    mouse.dragTileShiftY = mouse.dragTileShiftY + (world.LEVEL_HEIGHT - mouse.tileY + 1)
                    mouse.dragTileShiftY = mouse.dragTileShiftY + (world.LEVEL_HEIGHT*(snapShiftY-1))
                else
                    mouse.dragTileShiftY = mouse.dragTileShiftY - (mouse.tileY)
                    mouse.dragTileShiftY = mouse.dragTileShiftY + (world.LEVEL_HEIGHT*(snapShiftY+1))
                end
            end

        elseif love.keyboard.isDown("escape") then
            editState = "none"
        else
            editState = "none"
            --TODO: write tiles to world
            if mouse.dragLevelShiftX and mouse.dragLevelShiftY 
            and mouse.dragTileShiftX and mouse.dragTileShiftY then
                local modX = (mouse.dragTileShiftX>0 and 1 or -1)
                local modY = (mouse.dragTileShiftY>0 and 1 or -1)
                
                --write the tiles to the world
                for i=0, mouse.dragTileShiftX, modX do
                    --calculate the level we're writing to, since we can span multiple levels
                    --integer division in a floating point world
                    local currentLevelX = ((mouse.dragTileX+i-1) - (mouse.dragTileX+i-1)%world.LEVEL_WIDTH)
                                          /world.LEVEL_WIDTH + mouse.dragLevelX

                    --calculate the tile to write to
                    local currentTileX = (mouse.dragTileX+i-1)%world.LEVEL_WIDTH + 1

                    for j=0, mouse.dragTileShiftY, modY do
                        --calculate level
                        local currentLevelY = ((mouse.dragTileY+j-1) - (mouse.dragTileY+j-1)%world.LEVEL_HEIGHT)
                                              /world.LEVEL_HEIGHT + mouse.dragLevelY

                        --calculate tile
                        local currentTileY = (mouse.dragTileY+j-1)%world.LEVEL_HEIGHT + 1

                        world:setTile(currentLevelX, currentLevelY, currentTileX, currentTileY, tileType)
                    end
                end
            end
        end
    end

    -------------------------------------------------------------------------
    function _r.draw(mouse)
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
        if mouse.dragTileShiftX and mouse.dragTileShiftY and mouse.dragLevelShiftX and mouse.dragLevelShiftY then
            for i=0,mouse.dragTileShiftX,(mouse.dragTileShiftX<0 and -1 or 1) do
                for j=0,mouse.dragTileShiftY,(mouse.dragTileShiftY<0 and -1 or 1) do
                    love.graphics.setColor(255, 255, 255)
                    love.graphics.rectangle("fill", i*world.TILE_SIZE*scale + startX, j*world.TILE_SIZE*scale + startY, 
                                            world.TILE_SIZE*scale, world.TILE_SIZE*scale)
    
                    if showGrid then
                        love.graphics.setColor(127, 127, 127)
                        love.graphics.rectangle("line", i*world.TILE_SIZE*scale + startX, j*world.TILE_SIZE*scale + startY, 
                                                world.TILE_SIZE*scale, world.TILE_SIZE*scale)
                    end
                end
            end
        end
    end

    return _r
end
