--[[-------------------------------------

Author: Pyro-Fire
https://mods.factorio.com/mod/warptorio2


Script: control_planets_templates.lua
Purpose: A bunch of built-in planets (mostly for warptorio, but you can use it too)

Written using Microsoft Notepad.
IDE's are for children.

How to notepad like a pro:
ctrl+f = find
ctrl+h = find & replace
ctrl+g = show/jump to line (turn off wordwrap n00b)

Status bar wastes screen space, don't use it.

Use https://tools.stefankueng.com/grepWin.html to mass search, find and replace many files in bulk.

]] ---------------------------------------

local PCR = planets.control

local function PlanetRNG(key) return settings.startup["planet_" .. key].value or 1 end

--[[ Planet Tables ]] --

planets.RegisterDefaultTemplate({
	key = "normal",
	name = { "planet-name.normal" },
	desc = { "planet-description.normal" },
	zone = 0,
	rng = PlanetRNG("normal"),
	modifiers = { { "nauvis", mod_resource = false } },
	gen = nil,            -- The base planet map_gen_settings table
	nauvis_multiply = nil, -- Set to false to disable inheriting initial map settings resource settings.

	flags = {},           -- Planets that have any flags that the next planet has will not be rolled in simple rolls. {"rest","nowater","biter"} currently.
	biome = false,        -- Flag whether this planet is a biome or not. Biomes are intended to be merged together. Set to false for simple planet.
	biomes = {},          -- Templates that this planet will copy modifiers from

	tick_speed = nil,     -- =(60*60*minutes) -- runs the tick calls every X ticks
	tick_offset = 0,      -- = tick%60==offset -- so things dont tick perfectly aligned
	required_controls = nil, -- {"iron-ore"} -- Mod compatability: This planet REQUIRES a certain autoplace_control.
	required_tiles = nil, -- {"grass-1"} -- Mod compatability: This planet REQUIRES a certain autoplace_setting.tile
	required_ents = nil,  -- {"enemy-base"} -- Mod compatability: This planet REQUIRES a certain autoplace_setting.entity
	required_decor = nil, -- {"shrub-x"} -- Mod compatability: This planet REQUIRES a certain autoplace_setting.decorative

	-- Built-in event calls:
	on_built_entity = nil,
	on_robot_built_entity = nil,
	script_raised_built = nil,
	script_raised_revive = nil,
	on_chunk_generated = nil,
	on_chunk_deleted = nil,
	on_entity_died = nil,
	on_tick = nil,

	-- Call tables are used for remote interfaces: { {"remote_interface","remote_name"} }
	fgen_call = nil,     -- Final function calls on map_gen_settings, behaving similar to a modifier function but planet specific.
	spawn_call = nil,    -- Function calls after surface is created.

	warpout_call = nil,  -- Function called upon warpout of this planet event{oldsurface=surface,oldplanet=planet_table,newsurface=surface,newplanet=planet_table}
	postwarpout_call = nil, -- Function called upon warpout of this planet event{oldsurface=surface,oldplanet=planet_table,newsurface=surface,newplanet=planet_table}

	-- Built in call table
	fgen = nil,     -- function(map_gen_settings) end, -- planet modify function (warptorio internal)
	spawn = nil,    -- function(surface_object, table_of_modifier_return_values) -- planet spawn function (warptorio internal)

	tick = nil,     -- function(surface_object, event_variable) -- planet tick function (warptorio internal)
	warpout = nil,  -- function(oldsurface,oldplanet,newsurface,newplanet) -- planet on warpout (warptorio internal)
	postwarpout = nil, -- function(oldsurface,oldplanet,newsurface,newplanet) -- planet on warpout (warptorio internal)
})

planets.RegisterDefaultTemplate({
	key = "uncharted",
	name = { "planet-name.uncharted" },
	desc = { "planet-description.uncharted" },
	zone = 1,
	rng = PlanetRNG("uncharted"),
	flags = { "nauvis" }, -- default nauvis generation (modded)
	nauvis_multiply = false,
	modifiers = {
		{ "copy_nauvis" },
	},
})

planets.RegisterDefaultTemplate({
	key = "average",
	name = { "planet-name.average" },
	desc = { "planet-description.average" },
	zone = 3,
	rng = PlanetRNG("average"),
	flags = {},
	modifiers = { { "nauvis" }, { "resource", { op = "set", all = true, random = { 1, 2 }, value = 0 } } },
})

planets.RegisterDefaultTemplate({
	key = "barren",
	name = { "planet-name.barren" },
	desc = { "planet-description.barren" },
	zone = 12,
	rng = PlanetRNG("barren"),
	warptime = 0.5,
	flags = { "nowater", "rest" },
	modifiers = {
		{ "nauvis", { tiles = { "dirt", "sand" }, ents = { "rock" }, decor = { "rock" }, autoplace = false, resource = false } },
		{ "water",  { value = 0 } },
		{ "rocks",  { op = "set", value = PCR(2, 2, 1) } },
		{ "entity", { op = "set", all = { "rock" }, value = PCR(2, 2, 1) } },
	},
})

planets.RegisterDefaultTemplate({
	key = "ocean",
	name = { "planet-name.ocean" },
	desc = { "planet-description.ocean" },
	zone = 3,
	rng = PlanetRNG("ocean"),
	warptime = 0.5,
	flags = { "rest" },
	modifiers = {
		{ "nauvis",        { tiles = { "grass", "water" }, ents = { "fish", "tree", "trunk" }, autoplace = { "tree" }, resource = false } },
		{ "rocks",         { value = 0 } },
		{ "trees",         { op = "set", value = PCR(3.25, 0.1, 0.3) } },
		{ "entity",        { op = "set", all = { "tree" }, value = PCR(3.25, 0.1, 0.3) } },
		{ "water",         { value = 100000 } },
		{ "starting_area", { value = 0 } },
		{ "entity",        { op = "set", all = { "fish" }, value = 8 } }
	},
})

planets.RegisterDefaultTemplate({
	key = "jungle",
	name = { "planet-name.jungle" },
	desc = { "planet-description.jungle" },
	zone = 27,
	rng = PlanetRNG("jungle"),
	warptime = 1,
	flags = { "rest" },
	modifiers = {
		{ "nauvis" },
		{ "resource",      { op = "set", all = true, value = 0.4 } },
		{ "trees",         { op = "set", value = PCR(8, 0.5, 0.4) } },
		{ "biters",        { value = PCR(1.5) } },
		{ "entity",        { op = "set", all = "tree", value = PCR(8, 0.55, 0.4) } },
		{ "starting_area", { op = "set", value = 0.7 } },
		{ "moisture",      0.7 },
		{ "temperature",   9 },
		{ "aux",           0.1 },
		{ "daytime",       { random = { 0, 1 } } },
	},
})

planets.RegisterDefaultTemplate({
	key = "dwarf",
	name = { "planet-name.dwarf" },
	desc = { "planet-description.dwarf" },
	zone = 12,
	rng = PlanetRNG("dwarf"),
	warptime = 1,
	flags = { "dwarf" },
	modifiers = { { "nauvis" }, { "resource", { op = "set", all = true, value = 0.35 } }, { "biters", { value = PCR(0.5, 0.5, 1) } } },
})

planets.RegisterDefaultTemplate({
	key = "rich",
	name = { "planet-name.rich" },
	desc = { "planet-description.rich" },
	zone = 60,
	rng = PlanetRNG("rich"),
	warptime = 1,
	flags = { "rich" },
	modifiers = { { "nauvis" }, { "resource", { op = "set", all = true, value = PCR(4, 2, 1) } }, { "biters", { value = PCR(1.25) } } },
})

planets.RegisterDefaultTemplate({
	key = "iron",
	name = { "planet-name.iron" },
	desc = { "planet-description.iron" },
	zone = 5,
	rng = PlanetRNG("res"),
	warptime = 1,
	flags = { "resource-specific" },
	modifiers = { { "nauvis" }, { "resource", { op = "set", all = true, value = 0.4 } }, { "resource_named", { op = "set", res = { ["iron-ore"] = PCR(4, 2, 1) } } } },
	required_controls = { "iron-ore" },
})

planets.RegisterDefaultTemplate({
	key = "copper",
	name = { "planet-name.copper" },
	desc = { "planet-description.copper" },
	zone = 8,
	rng = PlanetRNG("res"),
	warptime = 1,
	flags = { "resource-specific" },
	modifiers = { { "nauvis" }, { "resource", { op = "set", all = true, value = 0.3 } }, { "resource_named", { op = "set", res = { ["copper-ore"] = PCR(4, 2, 1) } } } },
	required_controls = { "copper-ore" },
})

planets.RegisterDefaultTemplate({
	key = "coal",
	name = { "planet-name.coal" },
	desc = { "planet-description.coal" },
	zone = 7,
	rng = PlanetRNG("res"),
	warptime = 1,
	flags = { "resource-specific" },
	modifiers = { { "nauvis" }, { "resource", { op = "set", all = true, value = 0.3 } }, { "resource_named", { op = "set", res = { ["coal"] = PCR(7, 2, 1) } } } },
	required_controls = { "coal" },
})

planets.RegisterDefaultTemplate({
	key = "stone",
	name = { "planet-name.stone" },
	desc = { "planet-description.stone" },
	zone = 15,
	rng = PlanetRNG("res"),
	warptime = 1,
	flags = { "resource-specific" },
	modifiers = { { "nauvis" }, { "resource", { op = "set", all = true, value = 0.3 } }, { "resource_named", { op = "set", res = { ["stone"] = PCR(7, 2, 1) } } } },
	required_controls = { "stone" },
})

planets.RegisterDefaultTemplate({
	key = "oil",
	name = { "planet-name.oil" },
	desc = { "planet-description.oil" },
	zone = 15,
	rng = PlanetRNG("res"),
	warptime = 1,
	flags = { "resource-specific" },
	modifiers = { { "nauvis" }, { "resource", { op = "set", all = true, value = 0.3 } }, { "resource_named", { op = "set", res = { ["crude-oil"] = PCR(7, 2, 1) } } }, { "biters", { value = PCR(1.15, 1.15, 1) } } },
	required_controls = { "crude-oil" },
})

planets.RegisterDefaultTemplate({
	key = "uranium",
	name = { "planet-name.uranium" },
	desc = { "planet-description.uranium" },
	zone = 30,
	rng = PlanetRNG("res"),
	warptime = 1,
	flags = { "resource-specific" },
	modifiers = { { "nauvis" }, { "resource", { op = "set", all = true, value = 0.3 } }, { "resource_named", { op = "set", res = { ["uranium-ore"] = PCR(8, 2, 1) } } }, { "biters", { value = PCR(1.35, 1.35, 1) } } },
	required_controls = { "uranium-ore" },
})

planets.RegisterDefaultTemplate({
	key = "midnight",
	name = { "planet-name.midnight" },
	desc = { "planet-description.midnight" },
	zone = 20,
	rng = PlanetRNG("midnight"),
	warptime = 1.5,
	flags = { "biter", "night" },
	modifiers = { { "nauvis" }, { "biters", { value = PCR(2) } }, { "daytime", { time = 0.5, freeze = true } } },
})

planets.RegisterDefaultTemplate({
	key = "polluted",
	name = { "planet-name.polluted" },
	desc = { "planet-description.polluted" },
	zone = 40,
	rng = PlanetRNG("polluted"),
	warptime = 1.5,
	flags = { "biter" },
	modifiers = {
		{ "nauvis" },
		{ "resource", { op = "set", all = true, value = 0.75 } },
		{ "biters",   { value = PCR(1.75) } },
		{ "pollute",  { value = 200, area = { { -5, -5 }, { 5, 5 } } } },
	},
})

planets.RegisterDefaultTemplate({
	key = "biter",
	name = { "planet-name.biter" },
	desc = { "planet-description.biter" },
	zone = 100,
	rng = PlanetRNG("biter"),
	warptime = 1.2,
	flags = { "biter" },
	modifiers = { { "nauvis" }, { "biters", { value = PCR(8) } }, { "starting_area", { value = 0.3 } } },
})

planets.RegisterDefaultTemplate({
	key = "rogue",
	name = { "planet-name.rogue" },
	desc = { "planet-description.rogue" },
	zone = 60,
	rng = PlanetRNG("rogue"),
	warptime = 1.25,
	flags = { "biter", "nowater" },
	modifiers = {
		{ "nauvis",        { tiles = { "dirt", "sand" }, decor = { "rock" } } },
		{ "resource",      { op = "set", all = true, value = 0 } },
		{ "decor",         { value = PCR(0.1, 0.1, 0.1) } },
		{ "water",         { value = 0 } },
		{ "starting_area", { value = 2.4 } },
		{ "biters",        { value = PCR(3) } },
		{ "rocks",         { op = "set", value = PCR(2, 2, 1) } },
		{ "entity",        { op = "set", all = { "rock" }, value = PCR(2, 2, 1) } },
		{ "trees",         { op = "set", value = PCR(1.25, 0.075, 0.3) } },
		{ "entity",        { op = "set", all = "tree", value = PCR(1.25, 0.075, 0.3) } },
		{ "daytime",       { time = 0.35, freeze = true } },
	},
})


--[[planets.RegisterDefaultTemplate({
	key="void", name="Warpspace Void", zone=50, rng=PlanetRNG("void"), warptime=1.75, flags={"nowater","rest"},
	desc="What on earth was that, where are we!? Something went wrong with the warp reactor and we are stranded in a vast nothingness.",
	modifiers={{"nauvis",{tiles={"dirt","sand"}}},{"water",0},{"starting_area",2.5},{"biters",3}},
})]]
