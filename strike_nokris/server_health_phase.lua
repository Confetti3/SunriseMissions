-- Health gates seen in the boss squad's replicated damage state. Shadows the native reaction:
-- it records crossings and drives nothing until the client hook is retired.
-- The client clamp holds the boss at the first ten-bit level at or above each floor (880, 614, 338
-- of 1023 for 86/60/33%), so a gate is "level <= ceil(floor*1023)", not "fraction <= floor".
local floors={880,614,338}

return function()
    local phase=0
    -- Returns the newest phase this sample crossed into, or nil.
    return function(event)
        if event.registry_key~=0xC55749AB or event.slot_type~=1 or event.slot_index~=0
            or type(event.health)~="number" then return nil end
        -- A fresh boss reports above the first floor again.
        local level=math.floor(event.health*1023+0.5)
        if level>floors[1] then phase=0 end
        local crossed
        while phase<3 and level<=floors[phase+1] do phase=phase+1; crossed=phase end
        return crossed
    end
end
