--defines behavior unique to the player, including response to inputs

do
    local playerSystem = function (self, entityManagers, keyList)
        local entities, indexToManagerId = 
            self.getEntities(entityManagers, {"player", "motion", "rigid"})

        for k,v in ipairs(entities) do
            --apply vertical acceleration
            if keyList.jump.pressed and keyList.jump.frame == 1 and v.rigid.isOnGround then
                --jump
                v.motion.yVelocity = -v.player.VACCEL_JUMP
            else
                --apply gravity
                v.motion.yVelocity = math.min(v.player.MAX_VSPEED, 
                                              v.motion.yVelocity + v.player.VACCEL_GRAVITY)
            end

            -- apply horizontal acceleration
            if keyList.left.pressed and not keyList.right.pressed then
                v.motion.xVelocity = math.max(-v.player.MAX_HSPEED, 
                                              v.motion.xVelocity - v.player.HACCEL)
            elseif keyList.right.pressed and not keyList.left.pressed then
                v.motion.xVelocity = math.min(v.player.MAX_HSPEED, 
                                              v.motion.xVelocity + v.player.HACCEL)
            elseif v.motion.xVelocity > 0 then
                v.motion.xVelocity = math.max(0, v.motion.xVelocity - v.player.HACCEL)
            elseif v.motion.xVelocity < 0 then
                v.motion.xVelocity = math.min(0, v.motion.xVelocity + v.player.HACCEL)
            end
        end
    end

    return playerSystem
end
