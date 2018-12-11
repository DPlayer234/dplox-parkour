return {
	finish_level = function()
		if finish then
			player.x,player.y = finish.x*9,finish.y*9
			print("!Tp-ed to finish")
		else
			print("Err!no finish")
		end
	end,
	set_flag = function(id,val)
		if savedata.levels[id] ~= nil and type(val) == "boolean" then
			savedata.levels[id] = val
			print("!set id '"..tostring(id).."' to '"..tostring(val).."'")
		else
			print("Err!id 0-100, val boolean")
		end
	end,
	deunlock_char = function(char)
		if unlocks[char] then
			unlocks[char] = false
			sendSave("Unlocks","unl.bin",unlocks)
			print("!de-unlocked "..tostring(char))
		else
			print("Err!"..tostring(char).." not unlocked")
		end
	end,
	respawn_player = function()
		player.freeze = 0
		player.freezeDeath = true
		print("!respawned")
	end,
	reload_level = function()
		levels.set(levels.current)
		print("!reloaded")
	end,
	become_THE_operator = function()
		player.pAirJumps = math.huge*player.pAirJumps
		print("!you are THE operator, enjoy infinite air jump")
	end,
	disable_debug = function()
		enableDebug = false
		if debugger.isActive() then debugger.setActive(false) end
		print("!disabled")
	end,
	force_quit = function() saveQueue = 0 love.event.quit() end,
	fck_up = function() menus = nil level = nil levels = nil error("!done") end,
	help = function() print("!what are you? a p*ssy? b*tch, please") end
}
