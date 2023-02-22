util.keep_running()
util.require_natives(1663599433)

local pos = players.get_position(players.user())
local changed_pos = pos;
local aim_only, aim_only_fake_lag = false, false;
local x_off, y_off = 0, 0;
local fakelag_ms = 0;
local radius = 5
local interval = 5000
local debug = false;
local path = menu.ref_by_path("Online>Spoofing>Position Spoofing")
local beacon = false;

math.randomseed(util.current_time_millis())

menu.action(menu.my_root(), "To Options", {}, "go to the relevant menu", function()
    menu.focus(menu.ref_by_path("Online>Spoofing>Position Spoofing>Position Spoofing"))
end)

menu.toggle(path, "Always Show Beacon", {},"always shows the beacon for the current spoofed position", function()
    beacon = not beacon
end)


--------------------------------------------------------------------------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------------------------------------------------------------------

menu.divider(path, "Random Warping")

menu.slider_float(path, "Random Radius", {"radius"}, "sets the radius the random position can be in", 0, 10000, 1000, 100, function (value)
    radius = value / 100;
end)

menu.slider(path, "Randomm Interval (ms)", {"interval (ms)"}, "sets interval between warps", 0, 15000, 2000, 50, function (value)
    interval = value
end)

-- stolen from wiri scirpt sorry your code is in this mess
function get_ground_z(pos)
    local pGroundZ = memory.alloc(4)
    MISC.GET_GROUND_Z_FOR_3D_COORD(pos.x, pos.y, pos.z, pGroundZ, false, true)
    local groundz = memory.read_float(pGroundZ)
    return groundz
end

function random_pos()
    changed_pos.x = pos.x + math.random(-radius, radius)
    changed_pos.y = pos.y + math.random(-radius, radius)
    changed_pos.z += 50;
    changed_pos.z = get_ground_z(changed_pos)
end

menu.toggle_loop(path, "Randomize Position", {"randwarp"}, "spoofs your position to a random place within a radius around your current position at the given interval", function ()

    if pos then
        random_pos();
        menu.trigger_commands("spoofedposition " .. tostring(changed_pos.x) .. ", " .. tostring(changed_pos.y) .. ", " .. tostring(changed_pos.z))
        util.yield(interval)
    else
        util.toast("Failed Lmao")
    end
end)

--------------------------------------------------------------------------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------------------------------------------------------------------

menu.divider(path, "Slight Offset")

menu.toggle_loop(path, "Offset Position", {"offsetpos"}, "spoofs your position a slight offset from your actual ped when ADS'ing", function ()

    if PED.GET_PED_CONFIG_FLAG(players.user_ped(), 78, false) then
        changed_pos.x = pos.x + x_off
        changed_pos.y = pos.y + y_off
        changed_pos.z += 50;
        changed_pos.z = get_ground_z(changed_pos)
    elseif not aim_only then
        changed_pos.x = pos.x + x_off
        changed_pos.y = pos.y + y_off
        changed_pos.z += 50;
        changed_pos.z = get_ground_z(changed_pos)
    else
        changed_pos = pos
    end
    menu.trigger_commands("spoofedposition " .. tostring(changed_pos.x) .. ", " .. tostring(changed_pos.y) .. ", " .. tostring(changed_pos.z))

end, function() menu.trigger_commands("spoofpos off") end)

menu.toggle(path, "Only When Aiming", {},"only offset pos when aiming", function()
    aim_only = not aim_only
end)

menu.slider_float(path, "X Offset", {}, "sets the x offset for offset position", -100, 100, 0, 5, function (value)
    x_off = value / 100;
end)

menu.slider_float(path, "Y Offset", {}, "sets the y offset for offset position", -100, 100, 0, 5, function (value)
    y_off = value / 100;
end)

--------------------------------------------------------------------------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------------------------------------------------------------------

menu.divider(path, "Fake Lag")

menu.toggle_loop(path, "Fake Lag", {"fakelag"}, "makes your position update only after every certain number of ms", function ()

    if pos then
        if not aim_only_fake_lag then
            changed_pos = pos
            menu.trigger_commands("spoofedposition " .. tostring(changed_pos.x) .. ", " .. tostring(changed_pos.y) .. ", " .. tostring(changed_pos.z))
            util.yield(fakelag_ms)
        elseif  aim_only_fake_lag and PED.GET_PED_CONFIG_FLAG(players.user_ped(), 78, false) then
            changed_pos = pos
            menu.trigger_commands("spoofedposition " .. tostring(changed_pos.x) .. ", " .. tostring(changed_pos.y) .. ", " .. tostring(changed_pos.z))
            util.yield(fakelag_ms)
        else
            changed_pos = pos
            menu.trigger_commands("spoofedposition " .. tostring(changed_pos.x) .. ", " .. tostring(changed_pos.y) .. ", " .. tostring(changed_pos.z))
        end
    end

end, function() menu.trigger_commands("spoofpos off") end)

menu.toggle(path, "Only When Aiming", {},"only fakelag when aiming", function()
    aim_only_fake_lag  = not aim_only_fake_lag
end)

menu.slider(path, "Fakelag MS (ms)", {}, "sets interval between position updates", 0, 1000, 0, 5, function (value)
    fakelag_ms = value
end)

while true do
    pos = players.get_position(players.user())

    if beacon then
        util.draw_ar_beacon(changed_pos) 
    end

    util.yield()
end
