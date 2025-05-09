--[[-------------------------------------

Author: Pyro-Fire
https://mods.factorio.com/mod/warptorio2


	This is not the code you are looking for


Script: control.lua
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

planets=planets or {}

require("lib")
require("control_planets_modifiers")
require("control_planets")
require("control_planets_templates")
require("lib_planets")


remote.add_interface("planet",planets.remote)
remote.add_interface("planets",planets.remote)
remote.add_interface("planetorio",planets.remote)


lib_dot_lua()


--[[
/c local tmp=remote.call("planets","GetTemplates") local x={} for k,v in pairs(tmp)do x[v.key]=true end game.print(serpent.block(x))
]]

