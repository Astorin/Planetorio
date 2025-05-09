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

]]---------------------------------------

local PCR=planets.control

local function PlanetRNG(key) return settings.startup["planet_"..key].value or 1 end

--[[ Planet Tables ]]--

planets.RegisterDefaultTemplate({
	key="normal", name="A Normal Planet", zone=0, rng=PlanetRNG("normal"),
	desc="This world reminds you of home.",
	modifiers={{"nauvis",mod_resource=false}},
	gen=nil, -- The base planet map_gen_settings table
	nauvis_multiply=nil, -- Set to false to disable inheriting initial map settings resource settings.

	flags={}, -- Planets that have any flags that the next planet has will not be rolled in simple rolls. {"rest","nowater","biter"} currently.
	biome=false, -- Flag whether this planet is a biome or not. Biomes are intended to be merged together. Set to false for simple planet.
	biomes={}, -- Templates that this planet will copy modifiers from

	tick_speed=nil, -- =(60*60*minutes) -- runs the tick calls every X ticks
	tick_offset=0, -- = tick%60==offset -- so things dont tick perfectly aligned
	required_controls=nil, -- {"iron-ore"} -- Mod compatability: This planet REQUIRES a certain autoplace_control.
	required_tiles=nil, -- {"grass-1"} -- Mod compatability: This planet REQUIRES a certain autoplace_setting.tile
	required_ents=nil, -- {"enemy-base"} -- Mod compatability: This planet REQUIRES a certain autoplace_setting.entity
	required_decor=nil, -- {"shrub-x"} -- Mod compatability: This planet REQUIRES a certain autoplace_setting.decorative

	-- Built-in event calls:
	on_built_entity=nil,
	on_robot_built_entity=nil,
	script_raised_built=nil,
	script_raised_revive=nil,
	on_chunk_generated=nil,
	on_chunk_deleted=nil,
	on_entity_died=nil,
	on_tick=nil,

	-- Call tables are used for remote interfaces: { {"remote_interface","remote_name"} }
	fgen_call=nil, -- Final function calls on map_gen_settings, behaving similar to a modifier function but planet specific.
	spawn_call=nil, -- Function calls after surface is created.

	warpout_call=nil, -- Function called upon warpout of this planet event{oldsurface=surface,oldplanet=planet_table,newsurface=surface,newplanet=planet_table}
	postwarpout_call=nil, -- Function called upon warpout of this planet event{oldsurface=surface,oldplanet=planet_table,newsurface=surface,newplanet=planet_table}

	-- Built in call table
	fgen=nil, -- function(map_gen_settings) end, -- planet modify function (warptorio internal)
	spawn=nil, -- function(surface_object, table_of_modifier_return_values) -- planet spawn function (warptorio internal)

	tick=nil, -- function(surface_object, event_variable) -- planet tick function (warptorio internal)
	warpout=nil, -- function(oldsurface,oldplanet,newsurface,newplanet) -- planet on warpout (warptorio internal)
	postwarpout=nil, -- function(oldsurface,oldplanet,newsurface,newplanet) -- planet on warpout (warptorio internal)
})

planets.RegisterDefaultTemplate({ key="uncharted", name="An Uncharted Planet", zone=1, rng=PlanetRNG("uncharted"), flags={"nauvis"}, -- default nauvis generation (modded)
	desc="You prospect your surroundings and gaze at the stars, and you wonder if this world has ever had a name.",
	nauvis_multiply=false,
	modifiers={
		{"copy_nauvis"},
	},
})


planets.RegisterDefaultTemplate({ key="average", name="An Average Planet", zone=3,rng=PlanetRNG("average"), flags={},
	desc="The usual critters and riches surrounds you, but you feel like something is missing.",
	modifiers={{"nauvis"},{"resource",{op="set",all=true,random={1,2},value=0}}},
})

planets.RegisterDefaultTemplate({
	key="barren", name="A Barren Planet", zone=12, rng=PlanetRNG("barren"), warptime=0.5, flags={"nowater","rest"},
	desc="This world looks deserted and we appear to be safe. .. For now.",
	modifiers={
		{"nauvis",{tiles={"dirt","sand"},ents={"rock"},decor={"rock"},autoplace=false,resource=false}},
		{"water",{value=0}},
		{"rocks",{op="set",value=PCR(2,2,1)}},
		{"entity",{op="set",all={"rock"},value=PCR(2,2,1)}},
	},
})

planets.RegisterDefaultTemplate({
	key="ocean", name="An Ocean Planet", zone=3, rng=PlanetRNG("ocean"), warptime=0.5, flags={"rest"},
	desc="There is water all around and seems to go on forever. The nearby fish that greet you fills you with determination.",
	modifiers={
		{"nauvis",{tiles={"grass","water"},ents={"fish","tree","trunk"},autoplace={"tree"},resource=false}},
		{"rocks",{value=0}},
		{"trees",{op="set",value=PCR(3.25,0.1,0.3)}},
		{"entity",{op="set",all={"tree"},value=PCR(3.25,0.1,0.3)}},
		{"water",{value=100000}},
		{"starting_area",{value=0}},
		{"entity",{op="set",all={"fish"},value=8}}
	},
})

planets.RegisterDefaultTemplate({
	key="jungle", name="A Jungle Planet", zone=27, rng=PlanetRNG("jungle"), warptime=1, flags={"rest"},
	desc="These trees might be enough to conceal your location from the natives. .. At least for a while.",
	modifiers={
		{"nauvis"},
		{"resource",{op="set",all=true,value=0.4}},
		{"trees",{op="set",value=PCR(8,0.5,0.4)}},
		{"biters",{value=PCR(1.5)}},
		{"entity",{op="set",all="tree",value=PCR(8,0.55,0.4)}},
		{"starting_area",{op="set",value=0.7}},
		{"moisture",0.7},
		{"temperature",9},
		{"aux",0.1},
		{"daytime",{random={0,1}}},
	},
})

planets.RegisterDefaultTemplate({
	key="dwarf", name="A Dwarf Planet", zone=12, rng=PlanetRNG("dwarf"), warptime=1,flags={"dwarf"},
	desc="You are like a giant to the creatures of this planet. .. And to its natural resources.",
	modifiers={{"nauvis"},{"resource",{op="set",all=true,value=0.35}},{"biters",{value=PCR(0.5,0.5,1)}}},
})

planets.RegisterDefaultTemplate({
	key="rich", name="A Rich Planet", zone=60, rng=PlanetRNG("rich"), warptime=1,flags={"rich"},
	desc="Nucleosynthesis in a nearby neutron star merger has seeded this planet with abundant resources",
	modifiers={{"nauvis"},{"resource",{op="set",all=true,value=PCR(4,2,1)}},{"biters",{value=PCR(1.25)}}},
})

planets.RegisterDefaultTemplate({
	key="iron", name="An Iron Planet", zone=5, rng=PlanetRNG("res"), warptime=1, flags={"resource-specific"},
	desc="You land with a loud metal clang. The sparkle in the ground fills you with determination.",
	modifiers={ {"nauvis"},{"resource",{op="set",all=true,value=0.4}},{"resource_named",{op="set",res={["iron-ore"]=PCR(4,2,1)}}} },
	required_controls={"iron-ore"},
})

planets.RegisterDefaultTemplate({
	key="copper", name="A Copper Planet", zone=8, rng=PlanetRNG("res"), warptime=1, flags={"resource-specific"},
	desc="The warp reactor surges with power and you feel static in the air. You are charged with determination.",
	modifiers={ {"nauvis"},{"resource",{op="set",all=true,value=0.3}},{"resource_named",{op="set",res={["copper-ore"]=PCR(4,2,1)}}} },
	required_controls={"copper-ore"},
})

planets.RegisterDefaultTemplate({
	key="coal", name="A Coal Planet", zone=7, rng=PlanetRNG("res"), warptime=1, flags={"resource-specific"},
	desc="The piles of raw fuel strewn about this world makes you wonder about the grand forest that once thrived here, a very long time ago.",
	modifiers={ {"nauvis"},{"resource",{op="set",all=true,value=0.3}},{"resource_named",{op="set",res={["coal"]=PCR(7,2,1)}}} },
	required_controls={"coal"},
})

planets.RegisterDefaultTemplate({
	key="stone", name="A Stone Planet", zone=15, rng=PlanetRNG("res"), warptime=1, flags={"resource-specific"},
	desc="This planet is like your jouney through warpspacetime. Stuck somewhere between a rock and a hard place.",
	modifiers={ {"nauvis"},{"resource",{op="set",all=true,value=0.3}},{"resource_named",{op="set",res={["stone"]=PCR(7,2,1)}}} },
	required_controls={"stone"},
})

planets.RegisterDefaultTemplate({
	key="oil", name="An Oil Planet", zone=15, rng=PlanetRNG("res"), warptime=1, flags={"resource-specific"},
	desc="This place has been a wellspring of life for millenia, but now they are just more fuel for your flamethrowers.",
	modifiers={ {"nauvis"},{"resource",{op="set",all=true,value=0.3}},{"resource_named",{op="set",res={["crude-oil"]=PCR(7,2,1)}}},{"biters",{value=PCR(1.15,1.15,1)}} },
	required_controls={"crude-oil"},
})

planets.RegisterDefaultTemplate({
	key="uranium", name="A Uranium Planet", zone=30, rng=PlanetRNG("res"), warptime=1, flags={"resource-specific"},
	desc="The warmth of this worlds green glow fills you with determination, but you probably shouldn't stay too long",
	modifiers={ {"nauvis"},{"resource",{op="set",all=true,value=0.3}},{"resource_named",{op="set",res={["uranium-ore"]=PCR(8,2,1)}}},{"biters",{value=PCR(1.35,1.35,1)}} },
	required_controls={"uranium-ore"},
})

planets.RegisterDefaultTemplate({
	key="midnight", name="A Planet Called Midnight", zone=20, rng=PlanetRNG("midnight"), warptime=1.5, flags={"biter","night"},
	desc="Your hands disappear before your eyes as you are shrouded in darkness. This place seems dangerous.",
	modifiers={ {"nauvis"},{"biters",{value=PCR(2)}},{"daytime",{time=0.5,freeze=true}} },
})

planets.RegisterDefaultTemplate({
	key="polluted", name="A Polluted Planet", zone=40, rng=PlanetRNG("polluted"), warptime=1.5, flags={"biter"},
	desc="A heavy aroma of grease and machinery suddenly wafts over the platform and you wonder if you have been here before.",
	modifiers={
		{"nauvis"},
		{"resource",{op="set",all=true,value=0.75}},
		{"biters",{value=PCR(1.75)}},
		{"pollute",{value=200,area={{-5,-5},{5,5}}} },
	},

})

planets.RegisterDefaultTemplate({
	key="biter", name="A Biter Planet", zone=100, rng=PlanetRNG("biter"), warptime=1.2, flags={"biter"},
	desc="Within moments of warping in, your factory is immediately under siege. We must survive until the next warp!",
	modifiers={ {"nauvis"},{"biters",{value=PCR(8)}},{"starting_area",{value=0.3}} },
})

planets.RegisterDefaultTemplate({
	key="rogue", name="A Rogue Planet", zone=60, rng=PlanetRNG("rogue"), warptime=1.25, flags={"biter","nowater"},
	desc="Ah, just your usual barren wasteland, nothing to worry about. But something seems a little off.",
	modifiers={
		{"nauvis",{tiles={"dirt","sand"},decor={"rock"}}},
		{"resource",{op="set",all=true,value=0}},
		{"decor",{value=PCR(0.1,0.1,0.1)}},
		{"water",{value=0}},
		{"starting_area",{value=2.4}},
		{"biters",{value=PCR(3)}},
		{"rocks",{op="set",value=PCR(2,2,1)}},
		{"entity",{op="set",all={"rock"},value=PCR(2,2,1)}},

		{"trees",{op="set",value=PCR(1.25,0.075,0.3)}},
		{"entity",{op="set",all="tree",value=PCR(1.25,0.075,0.3)}},
		{"daytime",{time=0.35,freeze=true}},
	},
})


--[[planets.RegisterDefaultTemplate({
	key="void", name="Warpspace Void", zone=50, rng=PlanetRNG("void"), warptime=1.75, flags={"nowater","rest"},
	desc="What on earth was that, where are we!? Something went wrong with the warp reactor and we are stranded in a vast nothingness.",
	modifiers={{"nauvis",{tiles={"dirt","sand"}}},{"water",0},{"starting_area",2.5},{"biters",3}},
})]]
