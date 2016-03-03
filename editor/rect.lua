-----------------------------------------------------------------
-- editor/rect.lua
-- Contains a table with data/functions to support drawrect mode.
-- Author: Jacob Abba
-----------------------------------------------------------------

do
    local r = {}

    --always call when the user starts drawing a new rect
    function r:reset(startTileX, startTileY, startLevelX, startLevelY)
        self.startTileX = startTileX
        self.startTileY = startTileY
        self.startLevelX = startLevelX
        self.startLevelY = startLevelY
        self.levelSnapX = nil
        self.levelSnapY = nil
        self.prevLevelX = startLevelX
        self.prevLevelY = startLevelY
        self.tileShiftX = 0
        self.tileShiftY = 0
        self.levelShiftX = 0
        self.levelShiftY = 0
    end

    --update the state of the rect while the user is still drawing
    function r:update(mouse, world)
        --check if we need to snap to something or unsnap (x)
        if self.prevLevelX ~= mouse.levelX then
            --mod signifies whether we are going to a bigger level than before or a smaller one
            local mod = (self.prevLevelX<mouse.levelX and 1 or -1)

            --check if there are any nonexistant levels inhibiting our movement
            for i = self.prevLevelX+mod, mouse.levelX, mod do
                if not self.levelSnapX 
                and not world:levelsExist(i, self.startLevelY, i, self.levelSnapY or mouse.levelY) then
                    self.levelSnapX = i - mod
                    break
                end
            end

            if self.levelSnapX == mouse.levelX then
                self.levelSnapX = nil
            end

            --recompute y to see if we can update the snap
            mod = (self.startLevelY<mouse.levelY and 1 or -1)

            local noSnap = true
            for i = self.startLevelY+mod, mouse.levelY, mod do
                if not world:levelsExist(self.startLevelX, i, self.levelSnapX or mouse.levelX, i) then
                    self.levelSnapY = i - mod
                    noSnap = false
                    break
                end
            end

            if noSnap then
                self.levelSnapY = nil
            end
        end

        --check if we need to snap to something or unsnap (y)
        if self.prevLevelY ~= mouse.levelY then
            --mod signifies whether we are going to a bigger level than before or a smaller one
            local mod = (self.prevLevelY<mouse.levelY and 1 or -1)

            --check if there are any nonexistant levels inhibiting our movement
            for i = self.prevLevelY+mod, mouse.levelY, mod do
                if not self.levelSnapY 
                    and not world:levelsExist(self.startLevelX, i, self.levelSnapX or mouse.levelX, i) then
                    self.levelSnapY = i - mod
                    break
                end
            end

            if self.levelSnapY == mouse.levelY then
                self.levelSnapY = nil
            end

            --recompute x to see if we can update the snap
            mod = (self.startLevelX<mouse.levelX and 1 or -1)

            local noSnap = true
            for i = self.startLevelX+mod, mouse.levelX, mod do
                if not world:levelsExist(i, self.startLevelY, i, self.levelSnapY or mouse.levelY) then
                    self.levelSnapX = i - mod
                    noSnap = false
                    break
                end
            end

            if noSnap then
                self.levelSnapX = nil
            end
        end

        self.prevLevelX = mouse.levelX
        self.prevLevelY = mouse.levelY

        --self.tileShiftX and Y signify how many tiles the rect is shifting from dragTileX and Y
        self.levelShiftX = mouse.levelX - self.startLevelX
        self.levelShiftY = mouse.levelY - self.startLevelY
        self.tileShiftX = mouse.tileX + world.LEVEL_WIDTH*self.levelShiftX - self.startTileX
        self.tileShiftY = mouse.tileY + world.LEVEL_HEIGHT*self.levelShiftY - self.startTileY

        --if we're snapped to a level, modify tileShift vars to reflect that
        if self.levelSnapX then
            local snapShiftX = self.levelSnapX - mouse.levelX

            if snapShiftX > 0 then
                self.tileShiftX = self.tileShiftX + (world.LEVEL_WIDTH - mouse.tileX + 1)
                self.tileShiftX = self.tileShiftX + (world.LEVEL_WIDTH*(snapShiftX-1))
            else
                self.tileShiftX = self.tileShiftX - (mouse.tileX)
                self.tileShiftX = self.tileShiftX + (world.LEVEL_WIDTH*(snapShiftX+1))
            end
        end

        if self.levelSnapY then
            local snapShiftY = self.levelSnapY - mouse.levelY
            if snapShiftY > 0 then
                self.tileShiftY = self.tileShiftY + (world.LEVEL_HEIGHT - mouse.tileY + 1)
                self.tileShiftY = self.tileShiftY + (world.LEVEL_HEIGHT*(snapShiftY-1))
            else
                self.tileShiftY = self.tileShiftY - (mouse.tileY)
                self.tileShiftY = self.tileShiftY + (world.LEVEL_HEIGHT*(snapShiftY+1))
            end
        end
    end

    --write the rect to the world once the user is done drawing
    function r:write(world)
        local modX = (self.tileShiftX>0 and 1 or -1)
        local modY = (self.tileShiftY>0 and 1 or -1)

        --write the tiles to the world
        for i=0, self.tileShiftX, modX do
            --calculate the level we're writing to, since we can span multiple levels
            --integer division in a floating point world
            local currentLevelX = ((self.startTileX+i-1) - (self.startTileX+i-1)%world.LEVEL_WIDTH)
            /world.LEVEL_WIDTH + self.startLevelX

            --calculate the tile to write to
            local currentTileX = (self.startTileX+i-1)%world.LEVEL_WIDTH + 1

            for j=0, self.tileShiftY, modY do
                --calculate level
                local currentLevelY = ((self.startTileY+j-1) - (self.startTileY+j-1)%world.LEVEL_HEIGHT)
                /world.LEVEL_HEIGHT + self.startLevelY

                --calculate tile
                local currentTileY = (self.startTileY+j-1)%world.LEVEL_HEIGHT + 1

                world:setTile(currentLevelX, currentLevelY, currentTileX, currentTileY, tileType)
            end
        end
    end

    --show the preview rect while the user is drawing
    function r:draw(mouse, world)
        local startX, startY, scale

        --find start point of drawing and the scale of tiles
        if expandView then
            startX = WINDOW_WIDTH/3 + (self.startTileX - 1)*world.TILE_SIZE*.5
            startX = startX + (self.startLevelX - levelX)*world.LEVEL_WIDTH*world.TILE_SIZE*.5

            startY = WINDOW_HEIGHT/3 + (self.startTileY - 1)*world.TILE_SIZE*.5
            startY = startY + (self.startLevelY - levelY)*world.LEVEL_HEIGHT*world.TILE_SIZE*.5

            scale = .5
        else
            startX = WINDOW_WIDTH/6 + (self.startTileX - 1)*world.TILE_SIZE
            startY = WINDOW_HEIGHT/6 + (self.startTileY - 1)*world.TILE_SIZE

            scale = 1
        end

        --draw tiles for the rect preview
        if self.tileShiftX and self.tileShiftY and self.levelShiftX and self.levelShiftY then
            for i=0,self.tileShiftX,(self.tileShiftX<0 and -1 or 1) do
                for j=0,self.tileShiftY,(self.tileShiftY<0 and -1 or 1) do
                    if tileType == 1 then
                        love.graphics.setColor(255, 255, 255)
                    elseif tileType == 0 then
                        love.graphics.setColor(0, 0, 0)
                    end
                    love.graphics.rectangle("fill", i*world.TILE_SIZE*scale + startX, 
                            j*world.TILE_SIZE*scale + startY, world.TILE_SIZE*scale, world.TILE_SIZE*scale)
    
                    if showGrid then
                        love.graphics.setColor(127, 127, 127)
                        love.graphics.rectangle("line", i*world.TILE_SIZE*scale + startX, 
                                j*world.TILE_SIZE*scale + startY, world.TILE_SIZE*scale, world.TILE_SIZE*scale)
                    end
                end
            end
        end
    end

    return r
end
