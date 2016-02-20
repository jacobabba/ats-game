require("run")

function love.load()
    local levelGrid = {}
    for i=1,40 do
        levelGrid[i] = {}
        for j=1,30 do
            levelGrid[i][j] = 0
        end
    end

    for i=1,40 do
        levelGrid[i][29] = 1
    end

    for i=20,40 do
        levelGrid[i][10] = 1
    end
    levelGrid[40][9] = 1

    local world = require("world")

    world:newLevel(0, 0, levelGrid)
    world:newLevel(1, 0, levelGrid)

    local player = require("player")
    
    keyList = {}
    keyList.left = false
    keyList.right = false
    keyList.z = false

    shiftX = 0
    shiftY = 0

    font = love.graphics.newFont(12)
    love.graphics.setBackgroundColor(0, 0, 0)

    return world, player
end

function love.update(dt, world, player)
    player:update(keyList, world)

    --check if we're going to the next level
    if player.x < -player.WIDTH/2 then
        player:changeLevel(-1, 0, world)
        world:changeLevel(-1, 0)
        shiftX = shiftX - world.LEVEL_WIDTH * world.TILE_SIZE
    elseif player.x > world.LEVEL_WIDTH * world.TILE_SIZE - player.WIDTH/2 then
        player:changeLevel(1, 0, world)
        world:changeLevel(1, 0)
        shiftX = shiftX + world.LEVEL_WIDTH * world.TILE_SIZE
    end

    if player.y < -player.HEIGHT/2 then
        player:changeLevel(0, -1, world)
        world:changeLevel(0, -1)
        shiftY = shiftY - world.LEVEL_HEIGHT * world.TILE_SIZE
    elseif player.y > world.LEVEL_HEIGHT * world.TILE_SIZE - player.HEIGHT/2 then
        player:changeLevel(0, 1, world)
        world:changeLevel(0, 1)
        shiftY = shiftY + world.LEVEL_HEIGHT * world.TILE_SIZE
    end

    shiftX = shiftX*0.90
    shiftY = shiftY*0.90

    if shiftX < 1 and shiftX > -1 then shiftX = 0 end
    if shiftY < 1 and shiftY > -1 then shiftY = 0 end
end

function love.draw(interpolate, world, player)
    world:drawLevel(shiftX, shiftY)

    player:draw(interpolate, shiftX, shiftY)

    --debug
    love.graphics.setFont(font)
    love.graphics.print(player.x, 200, 0)
    love.graphics.print(player.y, 400, 0)
    love.graphics.print(love.timer.getFPS(), 0, 10)
    love.graphics.print(shiftX, 200, 10)
    love.graphics.print(shiftY, 400, 10)
end

function love.keypressed(key, isrepeat)
    if key == "left" then
        keyList.left = true
    elseif key == "right" then
        keyList.right = true
    elseif key == "z" then
        keyList.z = true
    end
end

function love.keyreleased(key)
    if key == "left" then
        keyList.left = false
    elseif key == "right" then
        keyList.right = false
    elseif key == "z" then
        keyList.z = false
    end
end
