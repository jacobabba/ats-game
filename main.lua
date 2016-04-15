require("run")

DATA_FILE = "editor/DATA.lua"

LEVEL_HEIGHT = 30
LEVEL_WIDTH = 40
TILE_SIZE = 20

ENTITY_MANAGER_CLASS = require("entity_manager")
SYSTEMS_MANAGER = dofile("systems/systems_manager.lua")

function love.load()
    local world = require("world")

    world:loadWorld(DATA_FILE)

    local player = require("player")

    player:setPosition(world.playerSpawn.tileX, world.playerSpawn.tileY)
    
    --list containing which keys are currently pressed
    --and how many frames they've been held (1 on first frame; 0 if not held)
    local keyList = {
        left = {pressed=false, frame=0, key="left"},
        right = {pressed=false, frame=0, key="right"},
        jump = {pressed=false, frame=0, key="z"}
    }

    font = love.graphics.newFont(12)
    love.graphics.setBackgroundColor(0, 0, 0)

    local globalEntities = ENTITY_MANAGER_CLASS:newManager()

    globalEntities:addEntity(
        {
            player = {},
            transform = {
                xPosition = (world.playerSpawn.tileX-1)*TILE_SIZE + TILE_SIZE/2 - 5,
                yPosition = (world.playerSpawn.tileY-1)*TILE_SIZE + TILE_SIZE - 10,
                width = 10,
                height = 10
            },
            motion = {},
            rigid = {},
            drawable = {}
        },
        "player"
    )



    return world, player, keyList, globalEntities
end

function love.update(dt, world, player, keyList, globalEntities)
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

    local managers = {globalEntities}

    SYSTEMS_MANAGER:playerSystem(managers, keyList)
    SYSTEMS_MANAGER:levelCollisionSystem(managers, world)
    SYSTEMS_MANAGER:movementSystem(managers)
    SYSTEMS_MANAGER:levelNavSystem(managers, world)
    
    --[[player:update(keyList, world)

    --check if we're going to the next level
    if player.x < -player.WIDTH/2 then
        player:changeLevel(-1, 0)
        world:changeLevel(-1, 0)
    elseif player.x > LEVEL_WIDTH * TILE_SIZE - player.WIDTH/2 then
        player:changeLevel(1, 0)
        world:changeLevel(1, 0)
    end

    if player.y < -player.HEIGHT/2 then
        player:changeLevel(0, -1)
        world:changeLevel(0, -1)
    elseif player.y > LEVEL_HEIGHT * TILE_SIZE - player.HEIGHT/2 then
        player:changeLevel(0, 1)
        world:changeLevel(0, 1)
    end]]

    world:update()
end

function love.draw(interpolate, world, player, globalEntities)
    world:drawLevel()

    local managers = {globalEntities}

    SYSTEMS_MANAGER:drawSystem(managers, world, interpolate)

    --player:draw(interpolate, world.shiftX, world.shiftY)

    --debug
    love.graphics.setColor(255, 117, 117)
    love.graphics.setFont(font)
    love.graphics.print(love.timer.getFPS(), 0, 10)
    love.graphics.print(world.shiftX, 200, 10)
    love.graphics.print(world.shiftY, 400, 10)
end
