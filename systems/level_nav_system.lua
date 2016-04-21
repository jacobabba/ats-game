--this system handles the navigation of levels - ie when the player moves to the
--edge of the screen, they go to the next level.

do
    local levelNavSystem = function (self, entityManagers, world)
        local entities, _ = 
            self.getEntities(entityManagers, {"player", "transform"})
        
        --there should only be one player, so only the first member of entities is checked
        local player = entities[1]

        if player.transform.xPosition < -player.transform.width/2 then
            player.transform.xPosition = 
                player.transform.xPosition + LEVEL_WIDTH * TILE_SIZE
            world:changeLevel(-1, 0)
        elseif player.transform.xPosition > 
        LEVEL_WIDTH * TILE_SIZE - player.transform.width/2 then
            player.transform.xPosition =
                player.transform.xPosition - LEVEL_WIDTH * TILE_SIZE
            world:changeLevel(1, 0)
        end

        if player.transform.yPosition < -player.transform.height/2 then
            player.transform.yPosition =
                player.transform.yPosition + LEVEL_HEIGHT * TILE_SIZE
            world:changeLevel(0, -1)
        elseif player.transform.yPosition > 
        LEVEL_HEIGHT * TILE_SIZE - player.transform.height/2 then
            player.transform.yPosition =
                player.transform.yPosition - LEVEL_HEIGHT * TILE_SIZE
            world:changeLevel(0, 1)
        end
    end

    return levelNavSystem
end
