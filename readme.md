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
    function minetest.is_protected(pos, digger, digging)
    	if not protector.can_dig(protector.radius, pos, digger, false, 1) then
    		if digging then protection_lagporter.check(pos, digger) end
    		return true
    	end
    	return protector.old_is_protected(pos, digger, digging)
    end
#### ShadowNinja's Areas
    function minetest.is_protected(pos, name, digging)
     if not areas:canInteract(pos, name) then
      if digging then protection_lagporter.check(pos, name) end
      return true
     end
    return old_is_protected(pos, name, digging)
    end
    
#### Node Definitions
In node definitions you should use the digger argument, `minetest.is_protected(pos, name, digging)`, if you test for protection in `on_dig`. This is only needed if the node is walkable.
