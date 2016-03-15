require("run")

DATA_FILE = "editor/DATA.lua"

function love.load()
    local world = require("world")

    world:loadWorld(DATA_FILE)

    local player = require("player")

    player:setPosition(world.playerSpawn.tileX, world.playerSpawn.tileY, world)
    
    --list containing which keys are currently pressed
    --and how many frames they've been held (1 on first frame; 0 if not held)
    local keyList = {
        left = {pressed=false, frame=0, key="left"},
        right = {pressed=false, frame=0, key="right"},
        jump = {pressed=false, frame=0, key="z"}
    }

    font = love.graphics.newFont(12)
    love.graphics.setBackgroundColor(0, 0, 0)

    return world, player, keyList
end

function love.update(dt, world, player, keyList)
    --check inputs
    for k, v in pairs(keyList) do
        if love.keyboard.isDown(v.key) then
            v.pressed = true
            v.frame = v.frame + 1
        else
            v.pressed = false
            v.frame = 0
        end
    end
    
    player:update(keyList, world)

    --check if we're going to the next level
    if player.x < -player.WIDTH/2 then
        player:changeLevel(-1, 0, world)
        world:changeLevel(-1, 0)
        world.shiftX = world.shiftX - world.LEVEL_WIDTH * world.TILE_SIZE
    elseif player.x > world.LEVEL_WIDTH * world.TILE_SIZE - player.WIDTH/2 then
        player:changeLevel(1, 0, world)
        world:changeLevel(1, 0)
        world.shiftX = world.shiftX + world.LEVEL_WIDTH * world.TILE_SIZE
    end

    if player.y < -player.HEIGHT/2 then
        player:changeLevel(0, -1, world)
        world:changeLevel(0, -1)
        world.shiftY = world.shiftY - world.LEVEL_HEIGHT * world.TILE_SIZE
    elseif player.y > world.LEVEL_HEIGHT * world.TILE_SIZE - player.HEIGHT/2 then
        player:changeLevel(0, 1, world)
        world:changeLevel(0, 1)
        world.shiftY = world.shiftY + world.LEVEL_HEIGHT * world.TILE_SIZE
    end

    world.shiftX = world.shiftX*0.90
    world.shiftY = world.shiftY*0.90

    if world.shiftX < 1 and world.shiftX > -1 then world.shiftX = 0 end
    if world.shiftY < 1 and world.shiftY > -1 then world.shiftY = 0 end
end

function love.draw(interpolate, world, player)
    world:drawLevel()

    player:draw(interpolate, world.shiftX, world.shiftY)

    --debug
    love.graphics.setColor(255, 117, 117)
    love.graphics.setFont(font)
    love.graphics.print(player.x, 200, 0)
    love.graphics.print(player.y, 400, 0)
    love.graphics.print(love.timer.getFPS(), 0, 10)
    love.graphics.print(world.shiftX, 200, 10)
    love.graphics.print(world.shiftY, 400, 10)
end
