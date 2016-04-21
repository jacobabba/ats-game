require("run")
prof = require 'ProFi'
prof:start()

DATA_FILE = "editor/DATA.lua"

LEVEL_HEIGHT = 30
LEVEL_WIDTH = 40
TILE_SIZE = 20

COLOR_CODES = {
    white = {
        255, 255, 255
    },

    red = {
        247, 39, 39
    }
}


ENTITY_MANAGER_CLASS = require("entity_manager")
SYSTEMS_MANAGER = dofile("systems/systems_manager.lua")

function love.load()
    local world = require("world")

    world:loadWorld(DATA_FILE)

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

    --add the player
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
            drawable = {},
            colorState = {}
        },
        "player"
    )

    --[[line test
    globalEntities:addEntity(
        {
            line = {
                segments = {{
                    x = 3,
                    y = 1,
                    height = 29
                }}
            },
            colorState = {
                state = "red"
            },
            drawable = {
                drawType = "line"
            }
        }
    )]]

    return world, keyList, globalEntities
end

function love.update(world, keyList, globalEntities)
    --check inputs
    for _, v in pairs(keyList) do
        if love.keyboard.isDown(v.key) then
            v.pressed = true
            v.frame = v.frame + 1
        else
            v.pressed = false
            v.frame = 0
        end
    end

    local managers = {globalEntities, world:getCurrentLevel().entityManager}

    SYSTEMS_MANAGER:playerSystem(managers, keyList)
    SYSTEMS_MANAGER:levelCollisionSystem(managers, world)
    SYSTEMS_MANAGER:lineCollisionSystem(managers, world)
    SYSTEMS_MANAGER:movementSystem(managers)
    SYSTEMS_MANAGER:levelNavSystem(managers, world)
    
    world:update()
end

function love.draw(interpolate, world, globalEntities)
    world:drawLevel()

    local managers = {globalEntities, world:getCurrentLevel().entityManager}

    SYSTEMS_MANAGER:drawSystem(managers, world, interpolate)

    --debug
    love.graphics.setColor(255, 117, 117)
    love.graphics.setFont(font)
    love.graphics.print(love.timer.getFPS(), 0, 10)
    love.graphics.print(world.shiftX, 200, 10)
    love.graphics.print(world.shiftY, 400, 10)
end

function love.quit()
    prof:stop()
    prof:writeReport("profile.txt")
end
