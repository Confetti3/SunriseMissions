-- Run from the repository root with a stock Lua 5.4:
--   lua strike_nokris/tests/server_health_phase_test.lua <nokris-health-timeline.csv>
-- The timeline is run 11's replicated boss health (t_ms,health_q10,...).
package.path = "./?.lua;" .. package.path
local observe = require("strike_nokris.server_health_phase")({{registry_key=0xC55749AB,slot_type=1,slot_index=0}})
local path = assert(arg and arg[1] or os.getenv("NOKRIS_HEALTH_CSV"), "timeline csv path required")

local crossings = {}
for line in io.lines(path) do
    local t, q = line:match("^(%d+),(%d+),")
    if t then
        local event = {registry_key=0xC55749AB, slot_type=1, slot_index=0, health=tonumber(q)/1023}
        local phase = observe(event)
        if phase then crossings[#crossings+1] = {phase=phase, q=tonumber(q), t=tonumber(t)} end
    end
end
-- An unobserved level (-1) never counts, even for the boss.
assert(require("strike_nokris.server_health_phase")({{registry_key=0xC55749AB,slot_type=1,slot_index=0}})(
    {registry_key=0xC55749AB, slot_type=1, slot_index=0, health=-1}) == nil)
-- Another squad's damage never counts.
assert(observe({registry_key=1, slot_type=1, slot_index=0, health=0.1}) == nil)

local expected = {879, 614, 338}
assert(#crossings == 3, "expected three crossings, got " .. #crossings)
for index, crossing in ipairs(crossings) do
    assert(crossing.phase == index and crossing.q == expected[index],
        string.format("phase %d crossed at %d (t=%d)", crossing.phase, crossing.q, crossing.t))
    print(string.format("phase %d at q10=%d t=%.3fs", crossing.phase, crossing.q, crossing.t/1000))
end
print("ok")
