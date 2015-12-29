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


## Protection Mods
In protection mods simply add `digging` to the definition of `minetest.is_protected`: `minetest.isprotected(..., digging)` and add this line just before before returning `true`: `if digging then protection_lagporter.check(pos, name) end` (replace pos and name with the proper variables).
    
## Fast Movement Mods
These mods must be changed to detect `protection_lagporter.glitching` and set the speed to 0.1 if it is `true` for `protection_lagporter.glitching[playerName]`

    
#### Node Definitions
In node definitions you should use the digger argument, `minetest.is_protected(pos, name, true)`, if you test for protection in `on_dig`. This is only needed if the node is walkable.
