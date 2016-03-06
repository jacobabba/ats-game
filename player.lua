local p = {}
p.MAX_HSPEED = 3
p.HACCEL = .3
p.MAX_VSPEED = 8
p.VACCEL_GRAVITY = .5
p.VACCEL_JUMP = 11
p.WIDTH = 10
p.HEIGHT = 10

p.x = 0
p.y = 0
p.vy = 0
p.vx = 0

p.jump = false

function p:update(kl, w)
    --apply vertical acceleration
    if kl.z and self.jump then
        --jump
        self.vy = -self.VACCEL_JUMP
    else
        --apply gravity
        self.vy = math.min(self.MAX_VSPEED, self.vy + self.VACCEL_GRAVITY)
    end

    -- apply horizontal acceleration
    if kl.left and not kl.right then
        self.vx = math.max(-self.MAX_HSPEED, self.vx - self.HACCEL)
    elseif kl.right and not kl.left then
        self.vx = math.min(self.MAX_HSPEED, self.vx + self.HACCEL)
    elseif self.vx > 0 then
        self.vx = math.max(0, self.vx - self.HACCEL)
    elseif self.vx < 0 then
        self.vx = math.min(0, self.vx + self.HACCEL)
    end

    local ctx, cty = w:findLevelCollisions(self.x, self.y, self.vx, self.vy, self.WIDTH, self.HEIGHT)

    self.x = self.x + self.vx*ctx
    self.y = self.y + self.vy*cty

    if ctx < 1 then
        self.vx = 0
    end

    if cty < 1 then
        if self.vy > 0 then self.jump = true end
        self.vy = 0
    else
        self.jump = false
    end
end

function p:draw(interpolate, shiftX, shiftY)
    local x = self.x + interpolate*self.vx + shiftX
    local y = self.y + interpolate*self.vy + shiftY
    love.graphics.rectangle("fill", x, y, self.WIDTH, self.HEIGHT)
end

function p:changeLevel(x, y, w)
    if x == -1 then
        self.x = self.x + w.LEVEL_WIDTH * w.TILE_SIZE
    elseif x == 1 then
        self.x = self.x - w.LEVEL_WIDTH * w.TILE_SIZE
    end

    if y == -1 then
        self.y = self.y + w.LEVEL_HEIGHT * w.TILE_SIZE
    elseif y == 1 then
        self.y = self.y - w.LEVEL_HEIGHT * w.TILE_SIZE
    end
end

function p:setPosition(tileX, tileY, world)
    self.x = (tileX-1)*world.TILE_SIZE + world.TILE_SIZE/2 - self.WIDTH/2
    self.y = (tileY-1)*world.TILE_SIZE + world.TILE_SIZE - self.HEIGHT
end

return p
