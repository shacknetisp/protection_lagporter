### Protection Lagporter
This mod will teleport players back to where they started digging if they try to dig through protection.

### Known Problems

* It cannot handle very long lag.
* Occasionally players who try very hard to break through protection while in the air will jump up and down rapidly. This won't last very long though.

### minetest.is_protected

This mod overrides `minetest.node_dig` and calls a third argument in `minetest.is_protected`: `digging`
This argument can be safely ignored, so existing mods aren't broken by this.

### Usage in other mods

In a protection mod change the definition of minetest.is_protected and call `protection_lagporter.check(pos, name)` to support the digging option.

A table of players being teleported is available with `protection_lagporter.glitching`, player names will either be `nil` if not teleporting or `true` if they are.
#### TenPlus1's Protection Redo
    function minetest.is_protected(pos, digger)

	if not protector.can_dig(protector.radius, pos, digger, false, 1) then
		if digging then protection_lagporter.check(pos, name) end

		local player = minetest.get_player_by_name(digger)

		if protector.hurt > 0
		and player then
			player:set_hp(player:get_hp() - protector.hurt)
		end

		if protector.drop == true
		and player then
			-- drop tool/item if protection violated
			local tool = player:get_wielded_item()
			--local wear = tool:get_wear()
			local num = player:get_wield_index()
			local player_inv = player:get_inventory()
			local inv = player_inv:get_stack("main", num)
			local sta = inv:take_item(inv:get_count())
			local obj = minetest.add_item(player:getpos(), sta)

			if obj then
				obj:setvelocity({x = 0, y = 5, z = 0})
				player:set_wielded_item(nil)
				minetest.after(0.2, function()
					player_inv:set_stack("main", num, nil)
				end)
			end
		end

		return true
	end

	return protector.old_is_protected(pos, digger)

	end
#### ShadowNinja's Areas
    function minetest.is_protected(pos, name, digging)
     if not areas:canInteract(pos, name) then
      if digging then protection_lagporter.check(pos, name) end
      return true
     end
    return old_is_protected(pos, name, digging)
    end
    
## Fast Movement Mods
These mods must be changed to detect `protection_lagporter.glitching`

### Sprint
```
sprint.speed = {}
function setSprinting(playerName, sprinting) --Sets the state of a player (0=stopped/moving, 1=sprinting)
	local player = minetest.get_player_by_name(playerName)
	if players[playerName] then
        if protection_lagporter.glitching[playerName] then
            sprint.speed[playerName] = 0.1
        end
		players[playerName]["sprinting"] = sprinting
		if sprinting == true then
			player:set_physics_override({speed=SPRINT_SPEED * (sprint.speed[playerName] or 1),jump=SPRINT_JUMP})
		elseif sprinting == false then
			player:set_physics_override({speed=1.0 * (sprint.speed[playerName] or 1), jump=1.0})
		end
		return true
	end
	return false
end
```

    
#### Node Definitions
In node definitions you should use the digger argument, `minetest.is_protected(pos, name, true)`, if you test for protection in `on_dig`. This is only needed if the node is walkable.
