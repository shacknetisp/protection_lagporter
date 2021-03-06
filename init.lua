--Protection Lag Teleporter

local check_speed = 0.05 --Teleport this quickly.
local check_time = 8 --Test this many times before finishing.
local message = true --Send a message when done teleporting. This is useful with high check_time values.

protection_lagporter = {}
protection_lagporter.glitching = {} --Check if a player is being teleported with: if protection_lagporter.glitching[playername] then ... end

local togo = {} --Target locations.
local times = {} --Test times.

local function check_togo(name)
    local player = minetest.get_player_by_name(name)
    if player then
        if togo[name] then
            local p1 = player:getpos()
            local p2 = togo[name]
            --Calculate offset from y-axis velocity.
            local ytest = math.max(math.min(math.abs(player:get_player_velocity().y), 1), 0.1)
            --Is the player where he should be?
            if math.abs(p1.x - p2.x) <= 0.1 and math.abs(p1.y - p2.y) <= ytest and math.abs(p1.z - p2.z) <= 0.1 then
                times[name] = times[name] - 1
            end
            --Yes, he is.
            if times[name] <= 0 then
                togo[name] = nil
                times[name] = nil
                protection_lagporter.glitching[name] = nil
                player:set_physics_override({speed=1.0})
                if message then
                    minetest.chat_send_player(name, "You may now move.")
                end
                return
            end
            --Teleport and retry.
            player:setpos(togo[name])
            minetest.after(check_speed, check_togo, name)
        end
    end
end

function protection_lagporter.check(pos, digger)
    local player = minetest.get_player_by_name(digger)
    if player then
        if not togo[digger] then
            --Target where the player was before.
            togo[digger] = player:getpos()
            protection_lagporter.glitching[digger] = true
        end
        if not times[digger] then
            --Begin checks.
            minetest.after(check_speed, check_togo, digger)
            player:set_physics_override({speed=0.1})
        end
        times[digger] = check_time
    end
end

minetest.register_on_leaveplayer(function(player)
        --Ensure the player isn't still teleporting when he returns.
	togo[player:get_player_name()] = nil
        times[player:get_player_name()] = nil
        protection_lagporter.glitching[player:get_player_name()] = nil
end)

--Override node_dig to use

local old_node_dig = minetest.node_dig

function minetest.node_dig(pos, node, digger)
	local def = ItemStack({name=node.name}):get_definition()
        --Check if diggable, then check if is protected.
	if not def.diggable or (def.can_dig and not def.can_dig(pos,digger)) then
		--Cannot dig, but old_node_dig will handle this.
	elseif minetest.is_protected(pos, digger:get_player_name(), def.walkable) then
		minetest.log("action", digger:get_player_name()
				.. " tried to dig " .. node.name
				.. " at protected position "
				.. minetest.pos_to_string(pos))
		minetest.record_protection_violation(pos, digger:get_player_name())
                return
	end
        
        --Leave the rest to the proper function.
        return old_node_dig(pos, node, digger)
end

print("[MOD] protection_lagporter loaded")
