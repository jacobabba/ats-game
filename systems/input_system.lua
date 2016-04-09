--the input system checks what action type of action is required for each
--input type on each component, and if that input type is active(pressed), then
--it performs the action type

--although this system only requires the input component as its signature, certain
--input actions may require other components to operate

--input "actions" are defined as functions called with the entity as an argument

do
    local actions = {}

    actions.player_jump = function (entity)

    local inputSystem = function (self, entityManagers, keyList)
        local entities, indexToManagerId =
            self.getEntities(entityManager, {"input"})

        if keyList.left.pressed then
            --do all left actions for components
            for k, v in ipairs(entities) do
                actions[k.
            end
        end

        if keyList.right.pressed then
            --do all right actions for components
            for k, v in ipairs(entities) do

            end
        end

        if keyList.jump.pressed then
            --do all jump actions for components
            for k, v in ipairs(entities) do

            end
        end
    end

    return inputSystem
end
