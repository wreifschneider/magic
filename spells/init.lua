local playereffects_path = minetest.get_modpath("playereffects")
local enable_attack = minetest.setting_getbool("enable_attack_spells")
if (enable_attack == nil) then
	enable_attack = true
end

stunned = {}
-- local lock = {
-- 	-- is_visible = false,

-- }


-- function lock.on_activate( self, staticdata, dtime_s )

-- end

-- function lock. (self)
-- 	local yaw = self.driver:get_look_yaw()
-- 	self.object:setyaw(yaw)
-- end

-- minetest.register_entity("spells:lock", {
-- 	initial_properties = {
-- 	is_visible = false,

-- 	-- textures = {"nether_transparent.png"},
-- 	-- collisionbox = {-0.5,0,-0.5, 0.5,2,0.5},
-- 	-- driver = nil,
-- 	},
-- 	on_activate = function(self, staticdata, dtime_s)
-- 		minetest.after(16.5, function(self)
-- 			self.object:remove()
-- 		end, self)
-- 	end,
-- 	-- on_step = function(self)
-- 	-- 	local yaw = self.driver:get_look_yaw()
-- 	-- 	self.object:setyaw(yaw)
-- 	-- end,
-- })

-- activate the spells
minetest.register_on_joinplayer(function(player)
	local playername = player:get_player_name()
	wands.unlock_spell(playername, "spells:light")
	wands.unlock_spell(playername, "spells:bluefire")
	wands.unlock_spell(playername, "spells:freeze_water")
	wands.unlock_spell(playername, "spells:obsidian")
	wands.unlock_spell(playername, "spells:stone")
	wands.unlock_spell(playername, "spells:pickaxe")
	wands.unlock_spell(playername, "spells:place")
	wands.unlock_spell(playername, "spells:heal")
	wands.unlock_spell(playername, "spells:make_heal")
	wands.unlock_spell(playername, "spells:teleport")
	-- wands.unlock_spell(playername, "spells:retrieve_item")
	if (enable_attack) then
		wands.unlock_spell(playername, "spells:damage")
		if (core.check_player_privs(playername, {server=true})) then
			wands.unlock_spell(playername, "spells:ulti damage")
		end
	end
	if (playereffects_path) then
		wands.unlock_spell(playername, "spells:fly")
		wands.unlock_spell(playername, "spells:make_fly")
		wands.unlock_spell(playername, "spells:water_breath")
		wands.unlock_spell(playername, "spells:make_water_breath")
		if (enable_attack) then
			wands.unlock_spell(playername, "spells:blind")
			wands.unlock_spell(playername, "spells:fall")
			-- wands.unlock_spell(playername, "spells:drown")
			wands.unlock_spell(playername, "spells:stun")
		end
	end
end)

minetest.register_node("spells:lightball", {
	drawtype = "plantlike",
	tiles = {"spells_lightball.png"},
	paramtype = "light",
	light_source = 14,
	walkable = false,
	drop = "",
	groups = { dig_immediate = 3 },
	post_effect_color = {a = 128, r= 255, g= 255, b= 0},
	sunlight_propagates = true,
	use_texture_alpha = true,
})


minetest.register_tool("spells:pick", {
	description = "Pickaxe",
	inventory_image = "spells_pick.png",
	range = 12,
	tool_capabilities = {
		full_punch_interval = 0.5,
		max_drop_level=3,
		groupcaps={
			fleshy = {times={[1]=0.4, [2]=0.3, [3]=0.2}, uses=1, maxlevel=3},
			choppy = {times={[1]=0.4, [2]=0.3, [3]=0.2}, uses=1, maxlevel=3},
			bendy = {times={[1]=0.4, [2]=0.3, [3]=0.2}, uses=1, maxlevel=3},
			cracky = {times={[1]=0.4, [2]=0.3, [3]=0.2}, uses=1, maxlevel=3},
			crumbly = {times={[1]=0.4, [2]=0.3, [3]=0.2}, uses=1, maxlevel=3},
			snappy = {times={[1]=0.4, [2]=0.3, [3]=0.2}, uses=1, maxlevel=3},
		},
	},
})


wands.register_spell("spells:light", {
	title = "Light Orb",
	description = "Places a ball of light",
	type = "node",
	cost = 10,
	func = function(player, pointed_thing)
		local playername = player:get_player_name()
		local pos = pointed_thing.above
		local node = minetest.get_node(pos)
		if (minetest.is_protected(pos, playername)) then
			return false
		end
		if (node.name == "air") then
			minetest.set_node(pos, {name = "spells:lightball"})
			return true
		end
		return false
	end
})

wands.register_spell("spells:bluefire", {
	title = "Blue Fire",
	description = "Places a ball of light",
	type = "node",
	cost = 10,
	func = function(player, pointed_thing)
		local playername = player:get_player_name()
		local pos = pointed_thing.above
		local node = minetest.get_node(pos)
		if (minetest.is_protected(pos, playername)) then
			return false
		end
		if (node.name == "air") then
			minetest.set_node(pos, {name = "fake_fire:blue_fire_no_w"})
			return true
		end
		return false
	end
})

wands.register_spell("spells:freeze_water", {
	title = "Freeze Water",
	description = "Freezes water",
	type = "node",
	cost = 100,
	func = function(player, pointed_thing)
		local playername = player:get_player_name()
		local pos = pointed_thing.under
		local node = minetest.get_node(pos)
		if (minetest.is_protected(pos, playername)) then
			return false
		end
		if (node.name == "default:water_source") then
			minetest.set_node(pos, {name = "default:ice"})
			return true
		end
		return false
	end
})

wands.register_spell("spells:obsidian", {
	title = "Cool Lava Source",
	description = "Cool lava source",
	type = "node",
	cost = 100,
	func = function(player, pointed_thing)
		local playername = player:get_player_name()
		local pos = pointed_thing.under
		local node = minetest.get_node(pos)
		if (minetest.is_protected(pos, playername)) then
			return false
		end
		if (node.name == "default:lava_source") then
			minetest.set_node(pos, {name = "default:obsidian"})
			return true
		end
		return false
	end
})

wands.register_spell("spells:stone", {
	title = "Cool Flowing Lava",
	description = "Cool flowing lava",
	type = "node",
	cost = 100,
	func = function(player, pointed_thing)
		local playername = player:get_player_name()
		local pos = pointed_thing.under
		local node = minetest.get_node(pos)
		if (minetest.is_protected(pos, playername)) then
			return false
		end
		if (node.name == "default:lava_flowing") then
			minetest.set_node(pos, {name = "default:stone"})
			return true
		end
		return false
	end
})

wands.register_spell("spells:pickaxe", {
	title = "Get Pickaxe",
	description = "Digs the block you're pointing at",
	type = "anything",
	cost = 200,
	func = function(player, pointed_thing)

		local inv = player:get_inventory()
		inv:add_item("main", "spells:pick")

		return true
	end
})

wands.register_spell("spells:place", {
	title = "Place Block",
	description = "Places a block where you point to",
	type = "node",
	cost = 20,
	func = function(player, pointed_thing)
		local playername = player:get_player_name()
		local pos = pointed_thing.above
		if (minetest.is_protected(pos, playername)) then
			return false
		end
		local idx = player:get_wield_index() + 1
		local stack = player:get_inventory():get_stack(player:get_wield_list(), idx)
		local success = false
		stack, success = minetest.item_place(stack, player, pointed_thing)
		player:get_inventory():set_stack(player:get_wield_list(),idx, stack)
		return success
	end
})

wands.register_spell("spells:heal", {
	title = "Heal Yourself",
	description = "Heals yourself by 10 HP.",
	type = "anything",
	cost = 100,
	func = function(player, pointed_thing)
		if (player:get_hp() < 20) then
			player:set_hp(player:get_hp() + 10)
			return true
		end
		return false
	end
})


wands.register_spell("spells:make_heal", {
	title = "Heal Someone",
	description = "Heals yourself by 10 HP.",
	type = "object",
	cost = 100,
	func = function(player, pointed_thing)
		if (not pointed_thing.ref:is_player()) then
			return false
		end
		if (pointed_thing.ref:get_hp() < 20) then
			pointed_thing.ref:set_hp(pointed_thing.ref:get_hp() + 10)
			return true
		end
		return false
	end
})

wands.register_spell("spells:teleport", {
	title = "Port Someone",
	description = "Teleport someone to you.",
	type = "object",
	cost = 200,
	func = function(player, pointed_thing)
		local name = pointed_thing.ref:get_player_name()
		local port_name = player:get_player_name()
		if (not pointed_thing.ref:is_player())
		or (core.check_player_privs(name, {server=true})) then
			return false
		end
		local function find_free_position_near(pos)
			local tries = {
				{x=1,y=0,z=0},
				{x=-1,y=0,z=0},
				{x=0,y=0,z=1},
				{x=0,y=0,z=-1},
			}
			for _, d in ipairs(tries) do
				local p = {x = pos.x+d.x, y = pos.y+d.y, z = pos.z+d.z}
				local n = core.get_node_or_nil(p)
				if n and n.name then
					local def = core.registered_nodes[n.name]
					if def and not def.walkable then
						return p, true
					end
				end
			end
			return pos, false
		end

		local porter = nil

		if name then
			porter = core.get_player_by_name(name)
		end
		if name then
			local target = core.get_player_by_name(port_name)
			if target then
				p = target:getpos()
			end
		end
		if porter and p then
			p = find_free_position_near(p)
			porter:setpos(p)
			return true, "Teleporting " .. name
					.. " to " .. port_name
					.. " at " .. core.pos_to_string(p)
		end
		return false
	end
})


-- wands.register_spell("spells:retrieve_item", {
-- 	title = "Retrieve Item",
-- 	description = "Retrieves item",
-- 	type = "object",
-- 	cost = 10,
-- 	func = function(player, pointed_thing)
-- 		local object = pointed_thing.ref
-- 		if (not object:is_player() and object:get_luaentity() and object:get_luaentity().name == "__builtin:item") then
-- 			local inv = player:get_inventory()
-- 			if (inv and inv:room_for_item("main", ItemStack(object:get_luaentity().itemstring))) then
-- 				inv:add_item("main", ItemStack(object:get_luaentity().itemstring))
-- 				object:get_luaentity().itemstring = ""
-- 				object:remove()
-- 				return true
-- 			end
-- 		end
-- 		print "test"
-- 		return false
-- 	end
-- })

if (enable_attack) then
	wands.register_spell("spells:damage", {
		title = "Damage",
		description = "Damages a monster or a player",
		type = "object",
		cost = 200,
		func = function(player, pointed_thing)
			local luaentity = pointed_thing.ref:get_luaentity()
			if (luaentity and luaentity.name == "__builtin:item") then
				return false
			end
			pointed_thing.ref:punch(player, nil, {damage_groups = {fleshy = 20}}, nil)
			return true
		end
	})
	wands.register_spell("spells:ulti damage", {
		title = "Ulti Damage",
		description = "Damages a monster or a player",
		type = "object",
		cost = 200,
		func = function(player, pointed_thing)
			local luaentity = pointed_thing.ref:get_luaentity()
			if (luaentity and luaentity.name == "__builtin:item") then
				return false
			end
			pointed_thing.ref:punch(player, nil, {damage_groups = {fleshy = 99999999999999}}, nil)
			return true
		end
	})
end

if playereffects_path then
	-- Fly
	playereffects.register_effect_type("spells:fly_effect", "Fly (using k)", nil, {"fly"},
		function(player)
			local playername = player:get_player_name()
			local privs = minetest.get_player_privs(playername)
			if (privs.fly) then
				return false
			end
			privs.fly = true
			minetest.set_player_privs(playername, privs)
			return true
		end,
		function(effect, player)
			local playername = player:get_player_name()
			local privs = minetest.get_player_privs(playername)
			privs.fly = nil
			minetest.set_player_privs(playername, privs)
		end)
	wands.register_spell("spells:fly", {
		title = "Fly",
		description = "Allows you to fly (using k key)",
		type = "anything",
		cost = 200,
		func = function(player, pointed_thing)
			if (playereffects.apply_effect_type("spells:fly_effect", 60, player)) then
				return true
			end
			return false
		end
	})
	wands.register_spell("spells:make_fly", {
		title = "Give Someone Fly",
		description = "Allows you to fly (using k key)",
		type = "object",
		cost = 200,
		func = function(player, pointed_thing)
			if (not pointed_thing.ref:is_player()) then
				return false
			end
			if (playereffects.apply_effect_type("spells:fly_effect", 60, pointed_thing.ref)) then
				return true
			end
			return false
		end
	})

	-- Breath under water
	playereffects.register_effect_type("spells:water_breath_effect", "Breath even under water", nil, {"breath"},
		function(player)
			player:set_breath(11)
			return true
		end,
		function(effect, player)
		end,
		false, true, 3)
	wands.register_spell("spells:water_breath", {
		title = "Water breath",
		description = "Let's you breath even when you're not in air",
		type = "anything",
		cost = 200,
		func = function(player, pointed_thing)
			if (playereffects.apply_effect_type("spells:water_breath_effect", 20, player)) then
				return true
			end
			return false
		end
	})
	wands.register_spell("spells:make_water_breath", {
		title = "Give Someone Breath",
		description = "Let's you breath even when you're not in air",
		type = "object",
		cost = 200,
		func = function(player, pointed_thing)
		if (not pointed_thing.ref:is_player())  then
			return false
		end
			if (playereffects.apply_effect_type("spells:water_breath_effect", 20, pointed_thing.ref)) then
				return true
			end
			return false
		end
	})

	if (enable_attack) then
		playereffects.register_effect_type("spells:blind_effect", "blind", nil, {"blind"},
			function(player)
				local id = player:hud_add({
					hud_elem_type = "image",
					position = {x = .5, y = .5},
					scale = {x = -100, y = -100},
					text = "spells_blind.png"
					})
				return { id = id }
			end,
			function(effect, player)
				player:hud_remove(effect.metadata.id)
			end)
		wands.register_spell("spells:blind", {
			title = "Blind player",
			description = "Blinds the player you're pointing at for five seconds",
			type = "object",
			cost = 200,
			func = function(player, pointed_thing)
				local name = pointed_thing.ref:get_player_name()
				if (not pointed_thing.ref:is_player())
				or (core.check_player_privs(name, {server=true})) then
					return false
				end
				if (playereffects.apply_effect_type("spells:blind_effect", 5, pointed_thing.ref)) then
					return true
				end
				return false
			end
		})

		playereffects.register_effect_type("spells:fall_effect", "no fly", nil, { "fly" },
			function(player)
				local playername = player:get_player_name()
				local privs = minetest.get_player_privs(playername)
				local fly = privs.fly
				privs.fly = nil
				minetest.set_player_privs(playername, privs)
				return { fly = fly }
			end,
			function(effect, player)
				local playername = player:get_player_name()
				local privs = minetest.get_player_privs(playername)
				privs.fly = effect.metadata.fly
				minetest.set_player_privs(playername, privs)
			end)

		wands.register_spell("spells:fall", {
			title = "Take down player",
			description = "Stops a player from flying",
			type = "object",
			cost = 100,
			func = function(player, pointed_thing)
				if (not pointed_thing.ref:is_player()) then
					return false
				end
				if (playereffects.apply_effect_type("spells:fall_effect", 15, pointed_thing.ref)) then
					return true
				end
				return false
			end
		})

		-- wands.register_spell("spells:drown", {
		-- 	title = "Drown player",
		-- 	description = "Takes all breath of a player",
		-- 	type = "object",
		-- 	cost = 50,
		-- 	func = function(player, pointed_thing)
		-- 		if (not pointed_thing.ref:is_player()) then
		-- 			return false
		-- 		end
		-- 		playereffects.cancel_effect_group("breath", pointed_thing.ref:get_player_name())
		-- 		pointed_thing.ref:set_breath(0)
		-- 		return true
		-- 	end
		-- })

		playereffects.register_effect_type("spells:stun_effect", "stunned", nil, {"speed", "jump", "sneak"},
			function(player)
				local name = player:get_player_name()
				local pos = player:getpos()
				-- local obj = minetest.add_entity(pos, "spells:lock")
				stunned[name] = true
				player:set_physics_override({speed = 0, jump = 0, sneak = false})
				player:setpos(pos)
				-- player:set_attach(obj, "", {x=0, y=11, z=0}, {x=0, y=0, z=0})
				-- local prop = obj:get_properties()
				-- prop.driver = player
				-- obj:set_properties({driver = player})
				-- default.player_set_animation(player, "stand" , 30)
				-- minetest.after(15, function(player, obj)
				-- 	player:set_detach()
				-- 	obj:remove()
				-- end, player, obj)

			end,
			function(effect, player)
				local name = player:get_player_name()
				stunned[name] = false
				player:set_physics_override({speed = 1, jump = 1, sneak = true})
			end
		)
		wands.register_spell("spells:stun", {
			title = "Stun player",
			description = "Disables all movement of a player",
			type = "object",
			cost = 200,
			func = function(player, pointed_thing)
				local name = pointed_thing.ref:get_player_name()
				if (not pointed_thing.ref:is_player())
				or (core.check_player_privs(name, {server=true})) then
					return false
				end


				if (playereffects.apply_effect_type("spells:stun_effect", 15, pointed_thing.ref)) then
					return true
				end
				return false
			end
		})
	end
end
