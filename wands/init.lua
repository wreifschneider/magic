local file = io.open(minetest.get_worldpath() .. "/wands", "r")
if (file) then
	print "reading wands..."
	wands = minetest.deserialize(file:read("*all"))
	file:close()
end
wands = wands or { }
wands.spells = { }
wands.unlocked_spells = wands.unlocked_spells or { }
wands.selected_spells = wands.selected_spells or { }
wands.formspec_lists = {}


-- registeres a spell with the name name
-- name should follow the naming conventions modname:spellname
--
-- spellspec is a table of the format:
-- { title       = "the visible name of the spell",
--   description = "a small description of the spell",
--   type        = "nothing" for yourself, "node" for the environment or "object" for objects, see pointed_thing,
--   cost        = amount of mana to get consumend
--   func        = function(player, pointed_thing) function to get called.
-- }
function wands.register_spell(name, spellspec)
	if (wands.spells[name] ~= nil) then
		print "There is already a spell with this name."
		return false
	end
	wands.spells[name] = {  title = spellspec.title or "missing title",
				description = spellspec.description or "missing description",
				type = spellspec.type,
				cost = spellspec.cost or 0,
				func = spellspec.func or nil }
end

-- unlocks the spell spell for the player playername
function wands.unlock_spell(playername, spell)
	wands.unlocked_spells[playername] = wands.unlocked_spells[playername] or { }
	wands.unlocked_spells[playername][spell] = true
end

minetest.register_on_shutdown(function()
	print "writing wands..."
	local file = io.open(minetest.get_worldpath() .. "/wands", "w")
	if (file) then
		file:write(minetest.serialize({ selected_spells = wands.selected_spells,
						unlocked_spells = wands.unlocked_spells}))
		file:close()
	end
end)



local use = function(itemstack, user, pointed_thing)
	local playername = user:get_player_name()
	if (not playername) then
		return itemstack
	end
	if (not(wands.selected_spells[playername]) or not(wands.selected_spells[playername].list)) then
		return itemstack
	end
	local selected = tonumber(itemstack:get_metadata()) or 1
	if (not wands.selected_spells[playername].list[selected]
	or wands.spells[wands.selected_spells[playername].list[selected]] == nil) then
		return itemstack
	end
	if (pointed_thing.type == wands.spells[wands.selected_spells[playername].list[selected]].type
	or wands.spells[wands.selected_spells[playername].list[selected]].type == "anything") then
		if (wands.spells[wands.selected_spells[playername].list[selected]].func ~= nil) then
			if (mana.subtract(playername, wands.spells[wands.selected_spells[playername].list[selected]].cost)) then
				if (not wands.spells[wands.selected_spells[playername].list[selected]].func(user, pointed_thing)) then
					mana.add_up_to(playername, wands.spells[wands.selected_spells[playername].list[selected]].cost)
				end
			end
		end
	end
	return itemstack
end
local place = function(itemstack, placer, pointed_thing)
	local playername = placer:get_player_name()
	local item = placer:get_wielded_item()
	if (not playername) then
		return itemstack
	end
	if (not wands.selected_spells[playername] or not wands.selected_spells[playername].list) then
		return itemstack
	end
	local selected = tonumber(itemstack:get_metadata()) or 1
	local node = item:get_name()
	selected = selected + 1
	if (minetest.get_item_group(node, "wand_s") ~= 0) then
		if (selected > 3 or selected > #wands.selected_spells[playername].list) then
			selected = 1
		end
		itemstack:set_name("wands:wand_simple_"..selected)
		itemstack:set_metadata(selected)
		return itemstack
	elseif (minetest.get_item_group(node, "wand_p") ~= 0) then
		if (selected > 7 or selected > #wands.selected_spells[playername].list) then
			selected = 1
		end
		itemstack:set_name("wands:wand_powerfull_"..selected)
		itemstack:set_metadata(selected)
		return itemstack
	elseif (minetest.get_item_group(node, "wand_a") ~= 0) then
		if (selected > 15 or selected > #wands.selected_spells[playername].list) then
			selected = 1
		end
		itemstack:set_name("wands:wand_admin_"..selected)
		itemstack:set_metadata(selected)
		return itemstack
	end
end


-- register the wand
for i = 2,7 do
	minetest.register_tool("wands:wand_powerfull_"..i, {
		description = "A Powerfull Wand (" .. i ..")",
		inventory_image = "wands_wand_p.png",
		wield_image = "wands_wand_p.png",
		stack_max = 1,
		range = 20,
		groups =  {not_in_creative_inventory=1, wand_p = 1},
		on_use = use,
		on_place = place
 	})
end
minetest.register_tool("wands:wand_powerfull_1", {
	description = "A Powerfull Wand (Liquids Pointable)",
	inventory_image = "wands_wand_p.png",
	wield_image = "wands_wand_p.png",
	stack_max = 1,
	range = 20,
	groups =  {wand_p = 1},
	on_use = use,
	liquids_pointable = true,
	on_place = place
})

for i = 2,3 do
	minetest.register_tool("wands:wand_simple_"..i, {
		description = "A Simple Wand (" .. i ..")",
		inventory_image = "wands_wand_s.png",
		wield_image = "wands_wand_s.png",
		stack_max = 1,
		range = 12,
		groups =  {not_in_creative_inventory=1, wand_s = 1},
		on_use = use,
		on_place = place
 	})
end
minetest.register_tool("wands:wand_simple_1", {
	description = "A Simple Wand (Liquids Pointable)",
	inventory_image = "wands_wand_s.png",
	wield_image = "wands_wand_s.png",
	stack_max = 1,
	range = 12,
	groups =  {wand_s = 1},
	on_use = use,
	liquids_pointable = true,
	on_place = place
})

for i = 2,15 do
	minetest.register_tool("wands:wand_admin_"..i, {
		description = "Admin Wand (" .. i .. ")",
		inventory_image = "wands_wand_admin.png",
		wield_image = "wands_wand_admin.png",
		stack_max = 1,
		range = 30,
		groups =  {not_in_creative_inventory=1, wand_a = 1},
		on_use = use,
		on_place = place,
 	})
end
minetest.register_tool("wands:wand_admin_1", {
	description = "Admin Wand (Liquids Pointable)",
	inventory_image = "wands_wand_admin.png",
	wield_image = "wands_wand_admin.png",
	stack_max = 1,
	range = 30,
	groups =  {wand_a = 1},
	liquids_pointable = true,
	on_use = use,
	on_place = place,
})

minetest.register_craftitem("wands:stick", {
	description = "Wand Stick",
	inventory_image = "wands_stick.png",
	groups = {stick = 1},
})

local function spelllist(playername, uidx, sidx)
	local formspec = "size[9.7,7.5]" ..
			 "label[.25,0;known spells:]" ..
			 "textlist[.25,.4;4,7;known_spells;"
	if (wands.unlocked_spells[playername] == nil) then
		wands.unlocked_spells[playername] = {}
	end
	local unlocked_list = {}
	for spell,_ in pairs(wands.unlocked_spells[playername]) do
		if (wands.spells[spell] ~= nil) then
			formspec = formspec .. wands.spells[spell].title .. ","
			table.insert(unlocked_list, spell)
		end
	end
	formspec = string.sub(formspec, 1, -2)
	formspec = formspec .. ";" .. (uidx or 1) .. "]" ..
			 "label[5.25,0;selected spells:]" ..
			"textlist[5.25,.4;4,7;selected_spells;"
	if (wands.selected_spells[playername] == nil) then
		wands.selected_spells[playername] = { list = { } }
	end
	local selected_list = {}
	local i = 0
	for _,spell in ipairs(wands.selected_spells[playername].list) do
		i = i + 1
		formspec = formspec .. i .. ". " .. (wands.spells[spell] or {title = "unknown"}).title .. ","
		table.insert(selected_list, spell)
	end
	formspec = formspec .. ";" .. (sidx or 1) .. "]"

	formspec = formspec .. "button[4.37,2.4;1,.6;add_spell;+]" ..
			       "button[4.37,4.4;1,.6;remove_spell;-]" ..
			       "button[4.37,3.4;1,.6;position_one;p1]"
	wands.formspec_lists[playername] = { unlocked_spells = unlocked_list,
					     unlocked_idx    = uidx or 1,
					     selected_spells = selected_list,
					     selected_idx    = sidx or 1 }

	return formspec
end


-- register the spellbook
minetest.register_tool("wands:spellbook_p", {
	description = "A book filled with spells",
	inventory_image = "wands_spellbook_p.png",
	stack_max = 1,
	on_use = function(itemstack, user, pointed_thing)
		local playername = user:get_player_name()
		if (not playername) then
			return itemstack
		end
		minetest.show_formspec(playername, "wands:spelllist_p", spelllist(playername))
	end
})
minetest.register_tool("wands:spellbook_s", {
	description = "A book filled with spells",
	inventory_image = "wands_spellbook_s.png",
	stack_max = 1,
	on_use = function(itemstack, user, pointed_thing)
		local playername = user:get_player_name()
		if (not playername) then
			return itemstack
		end
		minetest.show_formspec(playername, "wands:spelllist_s", spelllist(playername))
	end
})

minetest.register_tool("wands:spellbook_admin", {
	description = "Admin Spellbook",
	inventory_image = "wands_spellbook_admin.png",
	stack_max = 1,
	on_use = function(itemstack, user, pointed_thing)
		local playername = user:get_player_name()
		if (not playername) then
			return itemstack
		end
		minetest.show_formspec(playername, "wands:spelllist_admin", spelllist(playername))
	end
})

minetest.register_on_player_receive_fields(function(player, formname, fields)
	local playername = player:get_player_name()
	if (formname == "wands:spelllist_p") then
		if (fields["add_spell"]) then
			wands.selected_spells[playername] = wands.selected_spells[playername] or { list = { } }
			if (#wands.selected_spells[playername].list < 7) then
				table.insert(wands.selected_spells[playername].list,
					wands.formspec_lists[playername].unlocked_spells[wands.formspec_lists[playername].unlocked_idx])
			end
			minetest.show_formspec(playername, "wands:spelllist_p",
				spelllist(playername, wands.formspec_lists[playername].unlocked_idx,
					wands.formspec_lists[playername].selected_idx))
			return
		end
		if (fields["position_one"]) then
			wands.selected_spells[playername] = wands.selected_spells[playername] or { list = { } }
			if (#wands.selected_spells[playername].list < 7) then
				table.insert(wands.selected_spells[playername].list, 1,
					wands.formspec_lists[playername].unlocked_spells[wands.formspec_lists[playername].unlocked_idx])
			end
			minetest.show_formspec(playername, "wands:spelllist_p",
				spelllist(playername, wands.formspec_lists[playername].unlocked_idx))
			return
		end
		if (fields["remove_spell"]) then
			wands.selected_spells[playername] = wands.selected_spells[playername] or { list = { } }
			table.remove(wands.selected_spells[playername].list,wands.formspec_lists[playername].selected_idx)
			minetest.show_formspec(playername, "wands:spelllist_p", spelllist(playername,
				wands.formspec_lists[playername].unlocked_idx))
			return
		end
		if (fields["known_spells"]) then
			local event = minetest.explode_textlist_event(fields.known_spells)
			wands.formspec_lists[playername].unlocked_idx = tonumber(event.index)
			return
		end
		if (fields["selected_spells"]) then
			local event = minetest.explode_textlist_event(fields.selected_spells)
			wands.formspec_lists[playername].selected_idx = tonumber(event.index)
			return
		end
	elseif (formname == "wands:spelllist_s") then
		if (fields["add_spell"]) then
			wands.selected_spells[playername] = wands.selected_spells[playername] or { list = { } }
			if (#wands.selected_spells[playername].list < 3) then
				table.insert(wands.selected_spells[playername].list,
					wands.formspec_lists[playername].unlocked_spells[wands.formspec_lists[playername].unlocked_idx])
			end
			minetest.show_formspec(playername, "wands:spelllist_s", spelllist(playername,
				wands.formspec_lists[playername].unlocked_idx, wands.formspec_lists[playername].selected_idx))
			return
		end
		if (fields["position_one"]) then
			wands.selected_spells[playername] = wands.selected_spells[playername] or { list = { } }
			if (#wands.selected_spells[playername].list < 3) then
				table.insert(wands.selected_spells[playername].list, 1,
					wands.formspec_lists[playername].unlocked_spells[wands.formspec_lists[playername].unlocked_idx])
			end
			minetest.show_formspec(playername, "wands:spelllist_s",
				spelllist(playername, wands.formspec_lists[playername].unlocked_idx))
			return
		end
		if (fields["remove_spell"]) then
			wands.selected_spells[playername] = wands.selected_spells[playername] or { list = { } }
			table.remove(wands.selected_spells[playername].list,wands.formspec_lists[playername].selected_idx)
			minetest.show_formspec(playername, "wands:spelllist_s",
				spelllist(playername, wands.formspec_lists[playername].unlocked_idx))
			return
		end
		if (fields["known_spells"]) then
			local event = minetest.explode_textlist_event(fields.known_spells)
			wands.formspec_lists[playername].unlocked_idx = tonumber(event.index)
			return
		end
		if (fields["selected_spells"]) then
			local event = minetest.explode_textlist_event(fields.selected_spells)
			wands.formspec_lists[playername].selected_idx = tonumber(event.index)
			return
		end
	elseif (formname == "wands:spelllist_admin") then
		if (fields["add_spell"]) then
			wands.selected_spells[playername] = wands.selected_spells[playername] or { list = { } }
			if (#wands.selected_spells[playername].list < 15) then
				table.insert(wands.selected_spells[playername].list,
					wands.formspec_lists[playername].unlocked_spells[wands.formspec_lists[playername].unlocked_idx])
			end
			minetest.show_formspec(playername, "wands:spelllist_admin",
				spelllist(playername, wands.formspec_lists[playername].unlocked_idx,
					wands.formspec_lists[playername].selected_idx))
			return
		end
		if (fields["position_one"]) then
			wands.selected_spells[playername] = wands.selected_spells[playername] or { list = { } }
			if (#wands.selected_spells[playername].list < 15) then
				table.insert(wands.selected_spells[playername].list, 1,
					wands.formspec_lists[playername].unlocked_spells[wands.formspec_lists[playername].unlocked_idx])
			end
			minetest.show_formspec(playername, "wands:spelllist_admin",
				spelllist(playername, wands.formspec_lists[playername].unlocked_idx))
			return
		end
		if (fields["remove_spell"]) then
			wands.selected_spells[playername] = wands.selected_spells[playername] or { list = { } }
			table.remove(wands.selected_spells[playername].list,wands.formspec_lists[playername].selected_idx)
			minetest.show_formspec(playername, "wands:spelllist_admin", spelllist(playername,
				wands.formspec_lists[playername].unlocked_idx))
			return
		end
		if (fields["known_spells"]) then
			local event = minetest.explode_textlist_event(fields.known_spells)
			wands.formspec_lists[playername].unlocked_idx = tonumber(event.index)
			return
		end
		if (fields["selected_spells"]) then
			local event = minetest.explode_textlist_event(fields.selected_spells)
			wands.formspec_lists[playername].selected_idx = tonumber(event.index)
			return
		end
	end
end)

minetest.register_node("wands:rubysuperblock", {
	description = "Ruby Super Block",
	tiles = {"wands_ruby_super_block.png"},
	drop = "wands:ruby_crystal",
	is_ground_content = false,
	groups = {cracky=1,level=3},
	sounds = default.node_sound_stone_defaults(),
})
minetest.register_node("wands:amethystsuperblock", {
	description = "Amethyst Super Block",
	tiles = {"wands_amethyst_super_block.png"},
	drop = "wands:amethyst_crystal",
	is_ground_content = false,
	groups = {cracky=1,level=3},
	sounds = default.node_sound_stone_defaults(),
})
minetest.register_node("wands:emeraldsuperblock", {
	description = "Emerald Super Block",
	tiles = {"wands_emerald_super_block.png"},
	drop = "wands:emerald_crystal",
	is_ground_content = false,
	groups = {cracky=1,level=3},
	sounds = default.node_sound_stone_defaults(),
})
minetest.register_node("wands:sapphiresuperblock", {
	description = "Sapphire Super Block",
	tiles = {"wands_sapphire_super_block.png"},
	drop = "wands:sapphire_crystal",
	is_ground_content = false,
	groups = {cracky=1,level=3},
	sounds = default.node_sound_stone_defaults(),
})
minetest.register_node("wands:topazsuperblock", {
	description = "Topaz Super Block",
	tiles = {"wands_topaz_super_block.png"},
	drop = "wands:topaz_crystal",
	is_ground_content = false,
	groups = {cracky=1,level=3},
	sounds = default.node_sound_stone_defaults(),
})

minetest.register_node("wands:magicblock", {
	description = "Magic Block",
	tiles = {"wands_magic_block.png"},
	drop = "shields:magic_jewel",
	is_ground_content = false,
	groups = {cracky=2,level=3},
	sounds = default.node_sound_stone_defaults(),
})

minetest.register_craftitem("wands:ruby_crystal", {
	description = "Ruby Crystal",
	inventory_image = "wands_ruby_crystal.png",
})
minetest.register_craftitem("wands:amethyst_crystal", {
	description = "Amethyst Crystal",
	inventory_image = "wands_amethyst_crystal.png",
})
minetest.register_craftitem("wands:emerald_crystal", {
	description = "Emerald Crystal",
	inventory_image = "wands_emerald_crystal.png",
})
minetest.register_craftitem("wands:sapphire_crystal", {
	description = "Sapphire Crystal",
	inventory_image = "wands_sapphire_crystal.png",
})
minetest.register_craftitem("wands:topaz_crystal", {
	description = "Topaz Crystal",
	inventory_image = "wands_topaz_crystal.png",
})

minetest.register_craft({
	output = "wands:rubysuperblock",
	recipe = {
		{"glooptest:rubyblock", "glooptest:rubyblock", "glooptest:rubyblock"},
		{"glooptest:rubyblock", "glooptest:rubyblock", "glooptest:rubyblock"},
		{"glooptest:rubyblock", "glooptest:rubyblock", "glooptest:rubyblock"}
	}
})
minetest.register_craft({
	output = "wands:amethystsuperblock",
	recipe = {
		{"glooptest:amethystblock", "glooptest:amethystblock", "glooptest:amethystblock"},
		{"glooptest:amethystblock", "glooptest:amethystblock", "glooptest:amethystblock"},
		{"glooptest:amethystblock", "glooptest:amethystblock", "glooptest:amethystblock"}
	}
})
minetest.register_craft({
	output = "wands:emeraldsuperblock",
	recipe = {
		{"glooptest:emeraldblock", "glooptest:emeraldblock", "glooptest:emeraldblock"},
		{"glooptest:emeraldblock", "glooptest:emeraldblock", "glooptest:emeraldblock"},
		{"glooptest:emeraldblock", "glooptest:emeraldblock", "glooptest:emeraldblock"}
	}
})
minetest.register_craft({
	output = "wands:sapphiresuperblock",
	recipe = {
		{"glooptest:sapphireblock", "glooptest:sapphireblock", "glooptest:sapphireblock"},
		{"glooptest:sapphireblock", "glooptest:sapphireblock", "glooptest:sapphireblock"},
		{"glooptest:sapphireblock", "glooptest:sapphireblock", "glooptest:sapphireblock"}
	}
})
minetest.register_craft({
	output = "wands:topazsuperblock",
	recipe = {
		{"glooptest:topazblock", "glooptest:topazblock", "glooptest:topazblock"},
		{"glooptest:topazblock", "glooptest:topazblock", "glooptest:topazblock"},
		{"glooptest:topazblock", "glooptest:topazblock", "glooptest:topazblock"}
	}
})

minetest.register_craft({
	output = "wands:magicblock",
	recipe = {
		{"", "glooptest:rubyblock", ""},
		{"glooptest:emeraldblock", "glooptest:sapphireblock", "glooptest:topazblock"},
		{"", "glooptest:amethystblock", ""}
	}
})

for i = 1,3 do

	minetest.register_craft({
		output = "wands:wand_powerfull_1",
		recipe = {
			{"", "wands:sapphire_crystal", "wands:ruby_crystal"},
			{"", "wands:emerald_crystal", "wands:amethyst_crystal"},
			{"wands:wand_simple_" .. i , "", ""}
		}
	})
end

minetest.register_craft({
	output = "wands:wand_simple_1",
	recipe = {
		{"", "wands:magicblock", "wands:topaz_crystal"},
		{"", "wands:topaz_crystal", "wands:magicblock"},
		{"wands:stick", "", ""}
	}
})

minetest.register_craft({
	output = "wands:stick",
	recipe = {
		{"nyancat:nyancat_rainbow", 	"", "nyancat:nyancat_rainbow"},
		{		"", 	"group:stick", 		""},
		{"nyancat:nyancat_rainbow", 	"", "nyancat:nyancat_rainbow"}
	}
})

minetest.register_craft({
	output = "wands:spellbook_p",
	recipe = {
		{"nyancat:nyancat_rainbow", "nyancat:nyancat", "nyancat:nyancat_rainbow"},
		{"nyancat:nyancat", "wands:spellbook_s", "nyancat:nyancat"},
		{"nyancat:nyancat_rainbow", "nyancat:nyancat", "nyancat:nyancat_rainbow"}
	}
})

minetest.register_craft({
	output = "wands:spellbook_s",
	recipe = {
		{"nyancat:nyancat_rainbow", "nyancat:nyancat", "nyancat:nyancat_rainbow"},
		{"", "default:book", ""},
		{"nyancat:nyancat_rainbow", "nyancat:nyancat", "nyancat:nyancat_rainbow"}
	}
})
