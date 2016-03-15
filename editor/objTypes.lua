--each object type should be in its own file named *type*Obj.lua

--TODO:each type should contain a method (tbd) to initiate an object of
--that type. And each object should contain methods (tbd) which will 
--update state, draw, etc.

do
    local ot = {}

    ot.types = {}

    function ot:getType(t)
        --only load a type if we need it
        if not self.types[t] then
            self.types[t] = require(t.."Obj")
        end

        return self.types[t]
    end

end
