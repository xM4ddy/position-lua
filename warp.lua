util.keep_running()
util.require_natives(1663599433)

local pos = players.get_position(players.user())
local rand_pos = pos;
local radius = 5
local interval = 5000
local debug = false;
local path = menu.ref_by_path("Online>Spoofing>Position Spoofing")

math.randomseed(util.current_time_millis())

menu.slider_float(path, "Radius", {"radius"}, "sets the radius the random position can be in", 0, 10000, 1000, 100, function (value)
    radius = value / 100;
end)

menu.slider(path, "Interval (ms)", {"interval (ms)"}, "sets interval between warps", 0, 15000, 2000, 50, function (value)
    interval = value
end)

menu.action(menu.my_root(), "To Options", {}, "go to the relevant menu", function()
    menu.focus(menu.ref_by_path("Online>Spoofing>Position Spoofing>Position Spoofing"))
end)

-- stolen from wiri scirpt sorry your code is in this mess
function get_ground_z(pos)
	local pGroundZ = memory.alloc(4)
	MISC.GET_GROUND_Z_FOR_3D_COORD(pos.x, pos.y, pos.z, pGroundZ, false, true)
	local groundz = memory.read_float(pGroundZ)
	return groundz
end

function random_pos()
    rand_pos.x = pos.x + math.random(-radius, radius)
    rand_pos.y = pos.y + math.random(-radius, radius)
    rand_pos.z += 50;
    rand_pos.z = get_ground_z(rand_pos)
end

menu.toggle_loop(path, "Randomize Position", {"randwarp"}, "spoofs your position to a random place within a radius around your current position at the given interval", function ()
    pos = players.get_position(players.user())

    if pos then
        random_pos();
        menu.trigger_commands("spoofedposition " .. tostring(rand_pos.x) .. ", " .. tostring(rand_pos.y) .. ", " .. tostring(rand_pos.z))
        util.yield(interval)
    else
        util.toast("Failed Lmao")
    end
end)
