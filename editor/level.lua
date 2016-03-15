do
    local l = {}

    l.mt = {}

    l.mt.__index = {
        newObj = function (self, obj)
            if not obj.update or not obj.draw then
                error("Attempt to create object without an update or draw method")
            end
            self.objCount = self.objCount + 1
            self.objList[self.objCount] = obj
        end
    }

    function l:newLevel(g)
        local level = {}
        setmetatable(level, self.mt)
        level.tileGrid = g
        level.objCount = 0

        return level
    end

    return l
end
