--[[-------------------------------------

Author: Pyro-Fire
https://mods.factorio.com/mod/warptorio2

Script: control_planets_modifiers.lua
Purpose: Functions that change map_gen_settings based on a templates modifier table.

Written using Microsoft Notepad.
IDE's are for children.

How to notepad like a pro:
ctrl+f = find
ctrl+h = find & replace
ctrl+g = show/jump to line (turn off wordwrap n00b)

Status bar wastes screen space, don't use it.

Use https://tools.stefankueng.com/grepWin.html to mass search, find and replace many files in bulk.

]]

planets=planets or {}



--[[ Nauvis Whitelist ]]--

local nauvis={} planets.nauvis=nauvis
nauvis.autoplace={"trees","enemy-base"} -- game.autoplace_control_prototypes
nauvis.resource={"iron-ore","copper-ore","stone","coal","uranium-ore","crude-oil"} -- game.autoplace_control_prototypes (resources edition)

nauvis.tile={ -- game.tile_prototypes (with autoplace)
"concrete","stone-path","tutorial-grid","refined-concrete","refined-hazard-concrete-left","refined-hazard-concrete-right","hazard-concrete-left","hazard-concrete-right",
"grass-1","grass-2","grass-3","grass-4","dirt-1","dirt-2","dirt-3","dirt-4","dirt-5","dirt-6","dirt-7","dry-dirt","sand-1","sand-2","sand-3",
"red-desert-0","red-desert-1","red-desert-2","red-desert-3","lab-dark-1","lab-dark-2","lab-white","landfill","out-of-map","water","deepwater",
}

nauvis.noise={ -- game.noise_layer_prototypes (isn't used nor needed for planets)
"aux","brown-fluff","coal","copper-ore","crude-oil","dirt-1","dirt-2","dirt-3","dirt-4","dirt-5","dirt-6","dirt-7","dry-dirt",
"elevation","elevation-persistence","enemy-base","fluff","garballo",
"grass-1","grass-2","grass-3","grass-4","grass1","grass2","green-fluff","iron-ore","moisture","pita","pita-mini",
"red-desert-0","red-desert-1","red-desert-2","red-desert-3","red-desert-decal","rocks",
"sand-1","sand-2","sand-3","sand-decal","sand-dune-decal","starting-area","stone","temperature",
"trees","trees-1","trees-10","trees-11","trees-12","trees-13","trees-14","trees-15","trees-2","trees-3","trees-4","trees-5","trees-6","trees-7","trees-8","trees-9",
"uranium-ore",}

nauvis.decor={ -- game.decorative_prototypes (with autoplace)
"brown-hairy-grass","green-hairy-grass","brown-carpet-grass",
"green-carpet-grass","green-small-grass","green-asterisk",
"brown-asterisk-mini","green-asterisk-mini","brown-asterisk",
"red-asterisk","dark-mud-decal","light-mud-decal","puberty-decal",
"red-desert-decal","sand-decal","sand-dune-decal","green-pita",
"red-pita","green-croton","red-croton","green-pita-mini","brown-fluff",
"brown-fluff-dry","green-desert-bush","red-desert-bush","white-desert-bush",
"garballo-mini-dry","garballo","green-bush-mini","lichen","rock-medium",
"rock-small","rock-tiny","big-ship-wreck-grass","sand-rock-medium","sand-rock-small","small-ship-wreck-grass"

}

nauvis.entities={ -- game.entity_prototypes (with autoplace)
"fish","tree-01","tree-02","tree-03","tree-04","tree-05","tree-09","tree-02-red","tree-07","tree-06","tree-06-brown",
"tree-09-brown","tree-09-red","tree-08","tree-08-brown","tree-08-red","dead-dry-hairy-tree","dead-grey-trunk",
"dead-tree-desert","dry-hairy-tree","dry-tree","rock-huge","rock-big","sand-rock-big","small-worm-turret",
"medium-worm-turret","big-worm-turret","behemoth-worm-turret","biter-spawner","spitter-spawner",
"crude-oil","coal","copper-ore","iron-ore","stone","uranium-ore",
}

nauvis.alienbiome={}
nauvis.alienbiome.entities={} -- not needed?
nauvis.alienbiome.decor={} -- not needed?
nauvis.alienbiome.tile={ -- tile-alias.lua
    ["grass-1"] = "vegetation-green-grass-1",
    ["grass-2"] = "vegetation-green-grass-2",
    ["grass-3"] = "vegetation-green-grass-3",
    ["grass-4"] = "vegetation-green-grass-4" ,
    ["dirt-1"] = "mineral-tan-dirt-1" ,
    ["dirt-2"] = "mineral-tan-dirt-2" ,
    ["dirt-3"] = "mineral-tan-dirt-1" ,
    ["dirt-4"] = "mineral-tan-dirt-2" ,
    ["dirt-5"] = "mineral-tan-dirt-3" ,
    ["dirt-6"] = "mineral-tan-dirt-5" ,
    ["dirt-7"] = "mineral-tan-dirt-4" ,
    ["dry-dirt"] = "mineral-tan-dirt-6" ,
    ["red-desert-0"] = "vegetation-olive-grass-2" ,
    ["red-desert-1"] = "mineral-brown-dirt-1" ,
    ["red-desert-2"] = "mineral-brown-dirt-5" ,
    ["red-desert-3"] = "mineral-brown-dirt-6" ,
    ["sand-1"] = "mineral-brown-sand-1" ,
    ["sand-2"] = "mineral-brown-sand-1" ,
    ["sand-3"] = "mineral-brown-sand-2" ,
    ["sand-4"] = "mineral-brown-sand-3" ,
	["water"]="water",
	["deepwater"]="deepwater",
	--["water-shallow"]="water-shallow",
}

-- on_load/on_init
function planets.NauvisAlienBiomes() for k,v in pairs(planets.nauvis.alienbiome.tile)do for x,y in pairs(planets.nauvis.tile)do if(y==k)then planets.nauvis.tile[x]=v break end end end end

--[[ Lookup Functions ]]--


function table.GetMatchTable(t,n,invert) local x={}
	if(istable(n))then for k,v in pairs(t)do
		if(not invert)then if(table.HasMatchValue(n,v))then table.insert(x,v) end
		elseif(invert)then if(not table.HasMatchValue(n,v))then table.insert(x,v) end
		end
	end else for i,v in pairs(t)do if(v:match(n))then table.insert(x,v) end end
	end
	return x
end
function table.HasValueMatch(t,u) for k,v in pairs(t)do if(v:match(u))then return v end end end
function table.HasMatchValue(t,u) for k,v in pairs(t)do if(u:match(v))then return v end end end


planets.cache={}
planets.cache.resource={all={},mod={},nauvis={}}
planets.cache.tile={all={},mod={},nauvis={}}
planets.cache.autoplace={all={},mod={},nauvis={}}
planets.cache.decor={all={},mod={},nauvis={}}
planets.cache.ents={all={},mod={},nauvis={}}

-- on_load/on_init
function planets.BuildCache() if(planets.cacheBuilt)then return end planets.cacheBuilt=true
	local pt=game.default_map_gen_settings.autoplace_controls local ct=planets.cache.autoplace
	for k,v in pairs(pt)do if(v.category~="resource")then table.insert(ct.all,v.name) if(not table.HasValue(planets.nauvis.autoplace,v.name))then table.insert(ct.mod,v.name) else table.insert(ct.nauvis,v.name) end end end

	local pt=game.default_map_gen_settings.autoplace_controls local ct=planets.cache.resource
	for k,v in pairs(pt)do if(v.category=="resource")then table.insert(ct.all,v.name) if(not table.HasValue(planets.nauvis.resource,v.name))then table.insert(ct.mod,v.name) else table.insert(ct.nauvis,v.name) end end end

	local pt=game.default_map_gen_settings.autoplace_settings local ct=planets.cache.decor
	for k,v in pairs(pt)do if(v.autoplace_specification)then table.insert(ct.all,v.name) if(not table.HasValue(planets.nauvis.decor,v.name))then table.insert(ct.mod,v.name) else table.insert(ct.nauvis,v.name) end end end

	local pt=game.default_map_gen_settings.autoplace_settings local ct=planets.cache.ents
	for k,v in pairs(pt)do if(v.autoplace_specification)then table.insert(ct.all,v.name) if(not table.HasValue(planets.nauvis.entities,v.name))then table.insert(ct.mod,v.name) else table.insert(ct.nauvis,v.name) end end end

	if script.active_mods["alien-biomes"] then planets.NauvisAlienBiomes() end
	local pt=game.default_map_gen_settings.autoplace_settings local ct=planets.cache.tile
	for k,v in pairs(pt)do table.insert(ct.all,v.name)
		if(not table.HasValue(planets.nauvis.tile,v.name))then table.insert(ct.mod,v.name) else table.insert(ct.nauvis,v.name) end
	end
	storage.controlcache=planets.cache
end

--[[ Gen functions etc ]]--

planets.Modifiers={} local pmods=planets.Modifiers


planets.control={} planets.control_Meta={__index=planets.control} local PCR=planets.control
function PCR.Freq(a) return istable(a) and (a.frequency or 0) or (a or 0) end
function PCR.Size(a) return istable(a) and (a.size or 0) or (a or 0) end
function PCR.Rich(a) return istable(a) and (a.richness or 0) or (a or 0) end

setmetatable(planets.control,{__call=function(t,f,z,r)
	if(istable(f))then f.frequency=f.frequency or 1 f.size=f.size or 1 f.richness=f.richness or 1 return setmetatable(f,planets.control_Meta) end
	return setmetatable({frequency=f or 1,size=z or ((not z and not r) and f or 1),richness=r or (not z and f or 1)},planets.control_Meta)
end })
function PCR.__add(a,b) return setmetatable({frequency=PCR.Freq(a)+PCR.Freq(b),size=PCR.Size(a)+PCR.Size(b),richness=PCR.Rich(a)+PCR.Rich(b)},planets.control_Meta) end
function PCR.__sub(a,b) return setmetatable({frequency=PCR.Freq(a)-PCR.Freq(b),size=PCR.Size(a)-PCR.Size(b),richness=PCR.Rich(a)-PCR.Rich(b)},planets.control_Meta) end
function PCR.__mul(a,b) return setmetatable({frequency=PCR.Freq(a)*PCR.Freq(b),size=PCR.Size(a)*PCR.Size(b),richness=PCR.Rich(a)*PCR.Rich(b)},planets.control_Meta) end
function PCR.__div(a,b) return setmetatable({frequency=PCR.Freq(a)/PCR.Freq(b),size=PCR.Size(a)/PCR.Size(b),richness=PCR.Rich(a)/PCR.Rich(b)},planets.control_Meta) end
function PCR.__pow(a,b) return setmetatable({frequency=PCR.Freq(a)^PCR.Freq(b),size=PCR.Size(a)^PCR.Size(b),richness=PCR.Rich(a)^PCR.Rich(b)},planets.control_Meta) end
function PCR.__mod(a,b) return setmetatable({frequency=PCR.Freq(a)%PCR.Freq(b),size=PCR.Size(a)%PCR.Size(b),richness=PCR.Rich(a)%PCR.Rich(b)},planets.control_Meta) end
PCR.add=PCR.__add
PCR.sub=PCR.__sub
PCR.mul=PCR.__mul
PCR.div=PCR.__div
PCR.pow=PCR.__pow
PCR.mod=PCR.__mod
PCR.set=function(a,b) return ((b~=nil and b~=false) and planets.control(b) or nil) end




--[[ Resource Modifiers ]]--
-- todo: similar searching to other modifiers
-- todo: fluid-type, solid-type, and solid-requiring-liquid-type distinctions required.

function planets.ControlValue(g,ev) local val=ev.value or ev[2] or (ev.value_random and math.random(ev.value_random[1],ev.value_random[2]))
	if(ev.value_call)then val=planets.call(ev.value_call,g) end
	return val
end

function planets.OperateValue(ev,a,b) return planets.control[ev.op or "mul"](a,b) end
function planets.NormalValue(ev,a,b) return a*b end

function planets.AutoplaceControlValue(g,ev,rsz) local val=planets.ControlValue(g,ev)
	for i,rc in pairs(rsz)do g.autoplace_controls[rc]=planets.control[ev.op or "mul"](planets.control(g.autoplace_controls[rc]),planets.control(val)) end
end

function planets.SettingsValue(g,ev,rsz,setval) local val=planets.ControlValue(g,ev)
	for i,rc in pairs(rsz)do
		local op=planets.control[ev.op or "mul"]

		local gset=g.autoplace_settings[setval].settings[rc] or PCR(1)
		g.autoplace_settings[setval].settings[rc]=op(gset,val)
	end
end

function planets.ExpressionValue(g,ev,rsz,pfx) local val=planets.ControlValue(g,ev) pfx=pfx or ev.prefix
	for i,rc in pairs(rsz)do g.property_expression_names[(pfx and pfx .. ":" or "") .. rc .. ":" .. ev.expression]=val end
end

function planets.ControlSelection(g,ev,ctype,rsz)
	rsz=rsz or {}
	if(ev.all)then rsz=planets.lookup(ctype or ev.class,"all",(ev.all~=true and ev.all or nil),ev.invert_all) end
	if(ev.mod)then table.deepmerge(rsz,planets.lookup(ctype or ev.class,"mod",(ev.mod~=true and ev.mod or nil),ev.invert_mod)) end
	if(ev.nauvis)then table.deepmerge(rsz,planets.lookup(ctype or ev.class,"nauvis",(ev.nauvis~=true and ev.nauvis or nil),ev.invert_nauvis)) end
	if(ev.named)then table.deepmerge(rsz,ev.named) end
	if(ev.random)then
		local nsz={}
		local nmax=ev.random.max or ev.random[2] or ev.random[1] local nmin=ev.random.min or (nmax and ev.random[1] or 1) local roll=math.random(nmin,nmax)
		local rmc=roll if(rmc>0)then for k,v in RandomPairs(rsz)do if(rmc>0)then table.insert(nsz,v) rmc=rmc-1 else break end end end
		rsz=nsz
	end
	return rsz
end


function planets.lookup(ctype,box,ptrn,invert)
	if(not ptrn)then return storage.controlcache[ctype][box] end
	return table.GetMatchTable(storage.controlcache[ctype][box],ptrn,invert)
end

--[[ Basic control modifiers ]]--



pmods.water={ fgen=function(g,ev) g.water=planets.NormalValue(ev,g.water or 1,planets.ControlValue(g,ev)) end } -- {"water",{op="set",value=9999}}
pmods.starting_area={ fgen=function(g,ev) g.starting_area=planets.NormalValue(ev,g.starting_area or 1,planets.ControlValue(g,ev)) end } -- {"starting_area",{op="set",value=9999}}
pmods.cliffs={ fgen=function(g,ev) g.cliff_settings=ev end } -- {"cliffs",{data}}

pmods.moisture={ fgen=function(g,ev) g.property_expression_names["moisture"]=(istable(ev) and ev.value or ev) end}
pmods.aux={ fgen=function(g,ev) g.property_expression_names["aux"]=(istable(ev) and ev.value or ev) end}
pmods.temperature={ fgen=function(g,ev) g.property_expression_names["temperature"]=(istable(ev) and ev.value or ev) end}
pmods.elevation={ fgen=function(g,ev) g.property_expression_names["elevation"]=(istable(ev) and ev.value or ev) end}
pmods.cliffiness={ fgen=function(g,ev) g.property_expression_names["cliffiness"]=(istable(ev) and ev.value or ev) end}
pmods.terrain_segmentation={ fgen=function(g,ev) g.terrain_segmentation=(istable(ev) and ev.value or ev) end}


pmods.resource_named={ fgen=function(g,ev) for k,v in pairs(ev.res)do
	local selection=planets.ControlSelection(g,{named={k}})
	planets.AutoplaceControlValue(g,{op=ev.op,named={k},value=v},selection)
	if(g.autoplace_settings and g.autoplace_settings.entity)then planets.SettingsValue(g,{op=ev.op,named={k},value=v},selection,"entity") end
end end }
pmods.resource={ fgen=function(g,ev)
	local selection=planets.ControlSelection(g,ev,"resource")
	planets.AutoplaceControlValue(g,ev,selection)
	if(g.autoplace_settings and g.autoplace_settings.entity)then planets.SettingsValue(g,ev,selection,"entity") end
end } -- {"resources",{op="add",value=planet.control(9,9,9)}}

pmods.biters={ fgen=function(g,ev) planets.AutoplaceControlValue(g,ev,planets.ControlSelection(g,ev,"autoplace",planets.lookup("autoplace","all","enemy%-base"))) end } -- {"biters",{op="add",value=planet.control(9,9,9)}}
pmods.trees={ fgen=function(g,ev) planets.AutoplaceControlValue(g,ev,planets.ControlSelection(g,ev,"autoplace",planets.lookup("autoplace","all","trees"))) end } -- {"trees",{op="add",value=planet.control(9,9,9)}}

pmods.autoplace={ fgen=function(g,ev) planets.AutoplaceControlValue(g,ev,planets.ControlSelection(g,ev)) end } -- {"autoplace",{class="resource",nauvis="iron-ore",op="add",value=planet.control(9,9,9)}}

pmods.rocks={ fgen=function(g,ev)
	planets.SettingsValue(g,ev,planets.ControlSelection(g,ev,"decor",planets.lookup("decor","all","rock")),"decorative")
	planets.SettingsValue(g,ev,planets.ControlSelection(g,ev,"ents",planets.lookup("ents","all","rock")),"entity")
end}
pmods.decor={ fgen=function(g,ev) planets.SettingsValue(g,ev,planets.ControlSelection(g,ev,"decor",planets.lookup("decor","all","rock",true)),"decorative") end}
pmods.decals={ fgen=function(g,ev) planets.SettingsValue(g,ev,planets.ControlSelection(g,ev,"decor"),"decorative") end}


pmods.entity={ fgen=function(g,ev) planets.SettingsValue(g,ev,planets.ControlSelection(g,ev,"ents"),"entity") end}

pmods.property={ fgen=function(g,ev) g[ev[1]]=ev[2] end}

pmods.disable_all_defaults={gen={ default_enable_all_autoplace_controls=false,
	autoplace_settings={ decorative={treat_missing_as_default=false},entity={treat_missing_as_default=false},tile={treat_missing_as_default=false} }
}}

pmods.setting={ fgen=function(g,ev) planets.SettingsValue(g,ev,planets.ControlSelection(g,ev),ev.category) end}
pmods.expression={ fgen=function(g,ev) planets.ExpressionValue(g,ev,planets.ControlSelection(g,ev)) end}


pmods.tile={ fgen=function(g,ev) planets.SettingsValue(g,ev,planets.ControlSelection(g,ev,"tile"),"tile") end}
pmods.tile_expression={ fgen=function(g,ev) planets.ExpressionValue(g,ev,planets.ControlSelection(g,ev,"tile"),"tile") end}

pmods.call={ fgen=function(g,ev) planets.Merge(g,planets.callremote(ev,g)) end }
pmods.call_spawn={ spawn=function(f,g,ev) planets.callremote(ev,f,g) end }

--[[ Basic Spawn Modifiers ]]--

pmods.daytime={ spawn=function(f,g,ev,r) ev=ev or {}
	if(ev.time)then f.daytime=ev.time end
	if(ev.random)then f.daytime=math.random(ev.random[1]*100,ev.random[2]*100)/100 end
	if(ev.freeze)then f.freeze_daytime=true end
end } -- {"daytime",{time=0,freeze=true}}


pmods.pollute={ spawn=function(f,g,ev,r)
	for x=ev.area[1][1],ev.area[2][1] do for y=ev.area[1][2],ev.area[2][2] do f.pollute({x*32,y*32},ev.value) end end
end, } -- {"pollute",{area={{-1,-1},{1,1}},value=200}}

--[[ Nauvis Modifier -- Remove all other tiles, decorations, entities and autoplacers except nauvis ones ]]

pmods.copy_nauvis={ fgen=function(g,ev) ev=ev or {} local gx=game.surfaces["nauvis"].map_gen_settings for k,v in pairs(gx)do if(k~="seed" and ev[k]~=false)then g[k]=v end end return g end }
pmods.nauvis={ -- remove mod tiles, decoratives and autoplacements incl. resources, generates a nauvis-like surface.
	fgen=function(g,ev) ev=ev or {}
		--[[if(ev.tiles~=false)then for k,v in pairs(warptorio.GetModTiles())do g.autoplace_settings.tile.settings[v]=g.autoplace_settings.tile.settings[v] or PCR(0) end end
		if(ev.decor~=false)then for k,v in pairs(warptorio.GetModDecoratives())do g.autoplace_settings.decorative.settings[v]=g.autoplace_settings.decorative[v] or PCR(0) end end
		if(ev.autop~=false)then for k,v in pairs(warptorio.GetModAutoplacers())do g.autoplace_controls[v]=g.autoplace_controls[v] or PCR(0) end end]]

		g.default_enable_all_autoplace_controls=false
		g.autoplace_settings.decorative.treat_missing_as_default=false
		g.autoplace_settings.entity.treat_missing_as_default=false
		g.autoplace_settings.tile.treat_missing_as_default=false

		if(ev.tiles~=false)then for k,v in pairs(planets.lookup("tile","nauvis",ev.tiles))do g.autoplace_settings.tile.settings[v]={} end end
		if(ev.decor~=false)then for k,v in pairs(planets.lookup("decor","nauvis",ev.decor))do g.autoplace_settings.decorative.settings[v]={} end end
		if(ev.ents~=false)then for k,v in pairs(planets.lookup("ents","nauvis",ev.ents))do g.autoplace_settings.entity.settings[v]={} end end
		if(ev.autoplace~=false)then for k,v in pairs(planets.lookup("autoplace","nauvis",ev.autoplace))do g.autoplace_controls[v]={} end end
		if(ev.resource~=false)then for k,v in pairs(planets.lookup("resource","nauvis",ev.resource))do g.autoplace_controls[v]={} g.autoplace_settings.entity.settings[v]={} end end

		-- so modded resources show up on all basic planets by default
		if(ev.mod_resource~=false and ev.resource~=false)then
			for k,v in pairs(planets.lookup("resource","mod",ev.mod_resource))do g.autoplace_controls[v]={} g.autoplace_settings.entity.settings[v]={}
		end end

		return g
	end
}
pmods.mauvis={ -- Like nauvis, but only modded generator controls.
	fgen=function(g,ev) ev=ev or {}
		--[[if(ev.tiles~=false)then for k,v in pairs(warptorio.GetModTiles())do g.autoplace_settings.tile.settings[v]=g.autoplace_settings.tile.settings[v] or PCR(0) end end
		if(ev.decor~=false)then for k,v in pairs(warptorio.GetModDecoratives())do g.autoplace_settings.decorative.settings[v]=g.autoplace_settings.decorative[v] or PCR(0) end end
		if(ev.autop~=false)then for k,v in pairs(warptorio.GetModAutoplacers())do g.autoplace_controls[v]=g.autoplace_controls[v] or PCR(0) end end]]

		g.default_enable_all_autoplace_controls=false
		g.autoplace_settings.decorative.treat_missing_as_default=false
		g.autoplace_settings.entity.treat_missing_as_default=false
		g.autoplace_settings.tile.treat_missing_as_default=false

		if(ev.tiles~=false)then for k,v in pairs(planets.lookup("tile","mod",ev.tiles))do g.autoplace_settings.tile.settings[v]={} end end
		if(ev.decor~=false)then for k,v in pairs(planets.lookup("decor","mod",ev.decor))do g.autoplace_settings.decorative.settings[v]={} end end
		if(ev.ents~=false)then for k,v in pairs(planets.lookup("ents","mod",ev.ents))do g.autoplace_settings.entity.settings[v]={} end end
		if(ev.autoplace~=false)then for k,v in pairs(planets.lookup("autoplace","mod",ev.autoplace))do g.autoplace_controls[v]={} end end
		if(ev.resource~=false)then for k,v in pairs(planets.lookup("resource","mod",ev.resource))do g.autoplace_controls[v]={} end end

		return g
	end
}