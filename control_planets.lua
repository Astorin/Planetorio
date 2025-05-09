--[[-------------------------------------

Author: Pyro-Fire
https://mods.factorio.com/mod/warptorio2


	This is not the code you are looking for, but it has most of the remotes at the bottom


Script: control_planets.lua
Purpose: standalone planets thing.

Written using Microsoft Notepad.
IDE's are for children.

How to notepad like a pro:
ctrl+f = find
ctrl+h = find & replace
ctrl+g = show/jump to line (turn off wordwrap n00b)

Status bar wastes screen space, don't use it.

Use https://tools.stefankueng.com/grepWin.html to mass search, find and replace many files in bulk.

]]---------------------------------------




--[[ Planets ]]--

planets=planets or {}
planets.remote=planets.remote or {}
function planets.remote.GetEvents() return events.vdefs end

events.register("on_started")
events.register("on_new_template")
events.register("on_template_updated")
events.register("on_template_removed")

function planets.init_globals()
	global.worlds=global.worlds or {}
	planets.BuildCache()
	planets.ValidateTemplates()
end

function planets.load_tick(tick) -- I wish this didn't need to be on_tick
	if(tick>0)then if(global.migrated)then planets.post_dependencies_loaded() global.migrated=false end events.un_tick(1,0,"load_tick") end
end
--events.on_tick(1,0,"load_tick",planets.load_tick)


function planets.on_init()
	global.templates={}
	for k,v in pairs(planets.templates)do planets.RegisterTemplate(v) end

	planets.init_globals()

	global.migrated=true
	events.on_tick(1,0,"load_tick",planets.load_tick)
end
function planets.on_load()
end
function planets.on_migrate(ev)
	planets.init_globals()
	global.migrated=true
	events.on_tick(1,0,"load_tick",planets.load_tick)
end
function planets.post_dependencies_loaded()
	events.vraise("on_started",{templates=global.templates})
end


events.on_init(planets.on_init)
events.on_load(planets.on_load)
events.on_migrate(planets.on_migrate)

function planets.call(world,evname,ev) if(world[evname])then if(remote.interfaces[world[evname][1]])then return remote.call(world[evname][1],world[evname][2],ev,world) end end end
function planets.callremote(rm,...) return remote.call(rm[1],rm[2],...) end
function planets.GetBySurface(f) return global.worlds[isnumber(f) and f or (istable(f) and f.index or game.surfaces[f].index)] or nil end

function planets.DestroyWorld(world,ev)
	planets.call(world,"on_pre_surface_destroyed",ev)
	global.worlds[world.surface.index]=nil
end
function planets.OnPreSurfaceDestroyed(ev) local world=planets.GetBySurface(ev.surface_index) if(world)then planets.DestroyWorld(world,ev) end end
events.hook(defines.events.on_pre_surface_deleted,planets.OnPreSurfaceDestroyed)

function planets.OnSurfaceCreated(ev) local world=planets.GetBySurface(events.surface(ev)) if(world)then planets.call(world,"on_surface_created") end end
events.hook("on_surface_created",planets.OnSurfaceCreated)

function planets.OnPreSurfaceCleared(ev) local world=planets.GetBySurface(events.surface(ev)) if(world)then planets.call(world,"on_pre_surface_cleared") end end
events.hook("on_pre_surface_cleared",planets.OnSurfaceCreated)

function planets.OnChunkGenerated(ev) local world=planets.GetBySurface(events.surface(ev)) if(world)then
	planets.call(world,"on_chunk_generated",ev)
	local fc=world.force
	if(fc)then for k,v in pairs(fc.surface.find_entities_filtered{force=game.forces.enemy,area=ev.area})do v.force=fc end end
end end
events.hook(defines.events.on_chunk_generated,planets.OnChunkGenerated)

function planets.OnBiterBase(ev) local e=ev.entity if(isvalid(e))then local world=planets.GetBySurface(e.surface) if(world)then
	planets.call(world,"on_biter_base_built",ev)
	if(world.force)then e.force=world.force end
end end end
events.hook(defines.events.on_biter_base_built,planets.OnBiterBase)

planets.TileDefaults={} -- Used to stop certain tiles from spawning on unmodified planets
function planets.TileDefault(n,b) planets.TileDefaults[n]=b end


--[[ Templates ]]--


planets.templates={}
function planets.RegisterDefaultTemplate(tbl) -- internal constructor called during script include
	tbl.mod="planetorio" planets.templates[tbl.key]=tbl
end

function planets.ValidateTemplates() -- check templates in global table against installed mods
	local tbr={} for k,v in pairs(global.templates)do if(v.mod and not game.active_mods[v.mod])then tbr[k]=true end end
	for k in pairs(tbr)do planets.RemoveTemplate(k) end
end

function planets.RegisterTemplate(tbl) -- register template to global table.
	global.templates[tbl.key]=table.deepcopy(tbl) events.vraise("on_new_template",{template=tbl})
end

function planets.RemoveTemplate(key) -- Remove a template. Particularly needed for migrating planet mods that have removed templates from themselves
	local tmp=global.templates[key] if(not tmp)then return false end
	events.vraise("on_template_removed",{template=tmp})
	global.templates[key]=nil
end

function planets.UpdateTemplate(tbl) -- update a template in the global table
	if(not global.templates[tbl.key])then error("Tried to update a template that doesnt exist! : " .. tostring(tbl.key)) end
	table.deepmerge(planets.templates[tbl.key],tbl) events.vraise("on_template_updated",{template=tbl})
end

function planets.GetTemplate(key) return global.templates[key] end
function planets.GetTemplates() return global.templates end


--[[ map_gen_settings World Generator ]]--

function planets.EmptyTable(name)
	local t={name=name,seed=math.random(4294967295),autoplace_controls={},autoplace_settings={tile={settings={}},entity={settings={}},decorative={settings={}} },property_expression_names={}}
	for k,v in pairs(planets.TileDefaults)do if(v==false)then t.property_expression_names["tile:"..k..":probability"]=-1000000 end end
	return t
end

function planets.EmptyMapGenSettings()
	local gen=planets.EmptyTable()
	return gen
end

function planets.Merge(g,pg) return table.deepmerge(g,table.deepcopy(pg)) end
function planets.Modify(g,mdt,...)
	local datas={}
	local mdf=planets.Modifiers[mdt[1]] if(not mdf)then return end
	if(mdf.gen)then planets.Merge(g,mdf.gen) end
	if(mdf.fgen)then mdf.fgen(g,mdt[2],...) end
	if(mdf.fgen_call)then local gx,dx=planets.call(mdf.fgen_call,g,mdt[2],...) or {} if(gx)then planets.Merge(g,gx) end if(dx)then planets.Merge(datas,dx) end end
	return datas
end
function planets.Generate(planet,gen,...)
	local datas={}
	if(planet.gen)then planets.Merge(gen,planet.gen) end
	if(planet.modifiers)then
		for id,mdt in ipairs(planet.modifiers)do local x=planets.Modify(gen,mdt,...) if(x)then planets.Merge(datas,x) end end
	end
	if(planet.biomes)then
		for id,tmp in ipairs(planet.biomes)do local temp=global.templates[tmp] if(temp)then local mdr=temp.modifiers if(mdr)then for i,mdt in ipairs(mdr)do
			if(mdt[1]~="nauvis")then local x=planets.Modify(gen,mdt,...) if(x)then planets.Merge(datas,x) end end
		end end end end
	end
	if(planet.fgen)then local gx,dx=planet.fgen(gen,planet,...) if(gx)then planets.Merge(g,gx) end if(dx)then planets.Merge(datas,dx) end end
	if(planet.fgen_call)then local gx,dx=planets.call(planet.fgen,gen,planet,...) if(gx)then planets.Merge(g,gx) end if(dx)then planets.Merge(datas,dx) end end
	return gen,datas
end

function planets.MakeSurface(name,planet,gen,...)
	local f=game.surfaces[name] if(f)then f.map_gen_settings=gen else f=game.create_surface(name,gen) end
	planet.surface=f
	global.worlds[f.index]=planet global.worlds[f.index].surface=f

	if(planet.mod_table)then remote.call(planet.mod,"INSERT_MOD_TABLE",f) end

	if(planet.modifiers)then for i,mdt in ipairs(planet.modifiers)do local mdf=planets.Modifiers[mdt.name or mdt[1]]
		if(mdf and mdf.spawn)then mdf.spawn(f,planet,mdt[2],...) end
		if(mdf and mdf.spawn_call)then planets.callremote(mdf.spawn_call,f,planet,mdt[2],...) end
	end end
	if(planet.biomes)then
		for id,tmp in ipairs(planet.biomes)do local temp=global.templates[tmp] if(temp)then local mdr=temp.modifiers if(mdr)then for i,mdt in ipairs(mdr)do
			local mdf=planets.Modifiers[mdt[1]]
			if(mdf and mdf.spawn)then mdf.spawn(f,planet,mdt[2],...) end
			if(mdf and mdf.spawn_call)then planets.callremote(mdf.spawn_call,f,planet,mdt[2],...) end
		end end end end
	end
	if(planet.spawn)then planet.spawn(f,planet,...) end
	if(planet.spawn_call)then planets.callremote(planet.spawn_call,f,planet,...) end

	if(not planet.no_first_chunks)then f.request_to_generate_chunks({0,0},5) f.force_generate_chunk_requests() end
	return f
end

function planets.SimplePlanet(name,planet)
	local gen,data=planets.Generate(planet,planets.EmptyMapGenSettings())
	local f=planets.MakeSurface(name,planet,gen)
	planet.gen_data=data
	return {surface=f,planet=planet,force=nil}
end

function planets.FromTemplate(name,key)
	local tmp=table.deepcopy(global.templates[key])
	if(not tmp)then game.print("PLANET ERROR: FromTemplate() - planet does not exist: " .. tostring(key) .. ", defaulting to uncharted") tmp=table.deepcopy(global.templates["uncharted"]) end
	local gen,data=planets.Generate(tmp,planets.EmptyMapGenSettings())
	local f=planets.MakeSurface(name,tmp,gen)
	tmp.gen_data=data
	return {surface=f,planet=tmp,force=nil}
end

function planets.EvaluateRoll(planet,opts) local prev_planet,flags=opts.prevplanet,opts.flags
	if(planet.required_controls)then for k,v in pairs(planet.required_controls)do if(not game.autoplace_control_prototypes[v])then return false end end end
	if(prev_planet and prev_planet.flags and planet.flags)then for k,v in pairs(prev_planet.flags)do if(table.HasValue(planet.flags,v))then return false end end end
	if(planet.flags and flags)then for k,v in pairs(planet.flags)do if(table.HasValue(flags,v))then return false end end end
	return true
end

function planets.SimpleTemplateRoll(opts) opts=opts or {}
	local zone=opts.zone or 10000
	local prevplanet=opts.prevplanet
	local flags=opts.flags

	local temps={}
	local rnjesus=0
	for key,template in pairs(global.templates)do
		if(not template.biome and template.zone<zone and template.rng>0 and planets.EvaluateRoll(template,opts))then rnjesus=rnjesus+(template.rng or 1) temps[key]=template end
	end
	if(rnjesus==0)then return global.templates["normal"] end

	local rng=math.random(1,rnjesus)
	for key,template in pairs(temps)do rng=rng-(template.rng or 1) if(rng<=0)then return template end end
	return global.templates["normal"]
end




function planets.SimplePlanetRoll(name,opts) opts=opts or {}
	local temp=table.deepcopy(planets.SimpleTemplateRoll(opts))
	if(not temp.modifiers)then temp.modifiers={} end

	if(opts.force)then -- make a force for the biters on the planet
		local fopts=(opts.force~=true and opts.force or {})
		temp.force=game.create_force(name)
	end

	local mods=opts.modifiers or nil
	if(mods)then for k,v in ipairs(mods)do table.insert(temp.modifiers,v) end end
	local spf=planets.SimplePlanet(name,temp)
	--local surface,planet,force=



	return spf
end



planets.remote.SimpleTemplateRoll=planets.SimpleTemplateRoll
planets.remote.SimplePlanetRoll=planets.SimplePlanetRoll

planets.remote.register=planets.RegisterTemplate --alias
planets.remote.RegisterTemplate=planets.RegisterTemplate
planets.remote.UpdateTemplate=planets.UpdateTemplate

planets.remote.GetBySurface=planets.GetBySurface -- Returns World Table, which is a planet template table with .surface=f
planets.remote.SimplePlanet=planets.SimplePlanet -- Generate a planet by (name,template_table)
planets.remote.FromTemplate=planets.FromTemplate -- Generate a planet by (name,key
planets.remote.GetTemplate=planets.GetTemplate -- Template by (key)
planets.remote.GetTemplates=planets.GetTemplates -- Table of all templates

-- /c local f=remote.call("planet","FromTemplate","test1","ocean") game.player.teleport({0,0},f)


-- script.on_nth_tick(60,function() planets.FromTemplate("ocean") end)
-- /c __planetorio__ local f=planets.FromTemplate("ocean") game.player.teleport({0,0},f).surface

-- /c __planetorio__ local f=planets.FromTemplate("ocean") game.player.teleport({0,0},f).surface
-- /c __planetorio__ planets.MakeSurface("test",planets.templates["ocean"],planets.Generate(planets.templates["ocean"],planets.EmptyTable()))

