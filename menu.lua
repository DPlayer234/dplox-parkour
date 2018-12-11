menus = {}
local menus = menus

local lastInput
local menuStatus
local pmenu

-- Load/Unload
local preStatus
function menus.load(which,mstatus)
	print("Loading menu ["..which.."]")
	if mstatus then
		menuStatus = mstatus
	end

	if which then
		menus.selection = 1
		menus.drawSelection = 1
		lastInput = {}
		menus.id = which

		if which == "main" and menus.insertLoadGame then
			menus.insertLoadGame()
		end

		if menus.data[which] then
			menu = menus.data[which]
			menus.sizes = {}
			for i=1,#menu.t do
				table.insert(menus.sizes,1)
			end
		else
			print("\tOops-- Loading Invalid.")
			menu = menus.data.invalid
			menus.sizes = {1,1}
			menus.selection = 1
		end

		if type(menu.back) == "number" then
			if menu.back < 1 then
				menu.back = #menu.f-menu.back
			end
		end
		menus.drawSelectionWidth = 0
	end

	if gameStatus ~= 1 then
		love.keyboard.setKeyRepeat(true)
		preStatus = gameStatus
	end
	gameStatus = 1
end

function menus.unload()
	print("'Unloading' menu.")
	if gameStatus == 1 then
		love.keyboard.setKeyRepeat(false)
	end
	gameStatus = preStatus
end

function menus.update()
	lastInput = {
		moveLeft = input.moveLeft,
		moveRight = input.moveRight,
		moveUp = input.moveUp,
		moveDown = input.moveDown
	}
	if ctrl and inputType == 1 then
		local stickx = ctrl:getGamepadAxis("leftx")
		local sticky = ctrl:getGamepadAxis("lefty")
		input.moveLeft = stickx < -cnf.ctrlStick or ctrl:isGamepadDown("dpleft")
		input.moveRight = stickx > cnf.ctrlStick or ctrl:isGamepadDown("dpright")
		input.moveUp = sticky < -cnf.ctrlStick or ctrl:isGamepadDown("dpup")
		input.moveDown = sticky > cnf.ctrlStick or ctrl:isGamepadDown("dpdown")
		input.jump = prButtons[cnf.jumpjs]
		input.action = prButtons[cnf.actionjs]
		input.pause = prButtons[cnf.startjs]
		input.select = prButtons[cnf.selectjs]
	else
		input.moveLeft = prKeys[cnf.moveLeft]
		input.moveRight = prKeys[cnf.moveRight]
		input.moveUp = prKeys[cnf.moveUp]
		input.moveDown = prKeys[cnf.moveDown]
		input.jump = prKeys[cnf.jump]
		input.action = prKeys[cnf.action]
		input.pause = prKeys[cnf.start]
		input.select = prKeys[cnf.select]
	end

	if input.moveDown and input.moveUp then input.moveDown,input.moveUp = false,false end

	if input.moveDown and not lastInput.moveDown then
		if menus.selection < #menu.t then
			menus.selection = menus.selection + 1
		else
			menus.selection = 1
		end
		sound.select:play()
		local t = type(menu.f[menus.selection])
		if not ( t == "function" or t == "table" or t == "string" ) then
			repeat
				if menus.selection < #menu.t then
					menus.selection = menus.selection + 1
				else
					menus.selection = 1
				end
				t = type(menu.f[menus.selection])
			until t == "function" or t == "table" or t == "string"
		end
	elseif input.moveUp and not lastInput.moveUp then
		if menus.selection > 1 then
			menus.selection = menus.selection - 1
		else
			menus.selection = #menu.t
		end
		sound.select:play()
		local t = type(menu.f[menus.selection])
		if not ( t == "function" or t == "table" or t == "string" ) then
			repeat
				if menus.selection > 1 then
					menus.selection = menus.selection - 1
				else
					menus.selection = #menu.t
				end
				t = type(menu.f[menus.selection])
			until t == "function" or t == "table" or t == "string"
		end
	end

	local scont = menu.f[menus.selection]
	local stype = type(scont)

	if input.jump then
		sound.select:play()
		if stype == "table" then
			if type(scont[2]) == "function" then
				scont[2]()
			else
				scont[3]()
			end
		elseif stype == "string" then
			if scont == "!" then
				menus.load(pmenu)
			else
				if string.byte(scont,1,1) == 33 then
					scont = scont:sub(2,#scont)
					pmenu = menus.id
				end
				menus.load(scont)
			end
		else
			scont()
		end
	elseif input.action and menu.back then
		sound.select:play()
		if type(menu.back) == "function" then
			menu.back()
		elseif type(menu.back) == "number" then
			menus.selection = menu.back
			local s = menu.f[menus.selection]
			local t = type(s)
			if t == "table" then
				if type(s[2]) == "function" then
					s[2]()
				else
					s[3]()
				end
			elseif t == "string" then
				if s == "!" then
					menus.load(pmenu)
				else
					if string.byte(s,1,1) == 33 then
						s = s:sub(2,#s)
						pmenu = menus.id
					end
					menus.load(s)
				end
			else
				s()
			end
		end
	elseif input.moveRight and stype == "table" and not lastInput.moveRight then
		sound.select:play()
		scont[3]()
	elseif input.moveLeft and stype == "table" and not lastInput.moveLeft then
		sound.select:play()
		scont[1]()
	end

	for i=1,#menus.sizes do
		if i == menus.selection then
			if menus.sizes[i] < 1.25 then
				menus.sizes[i] = menus.sizes[i] + 0.1
			end
		else
			if menus.sizes[i] > 1 then
				menus.sizes[i] = menus.sizes[i] - 0.1
			end
		end
	end

	if menu.bgCalc then menu.bgCalc() end

	menus.draw(menu,true)
end

-- Drawing a menu
local sideway = {{255,255,255,255},"---",{120,120,120,255},"<",{255,255,180,255},"[-]",{120,120,120,255},">"}
local sidewayAll = {{120,120,120,255},"<",{255,255,255,255},"---",{120,120,120,255},">"}
function menus.draw(menu,buttons)
	if menuStatus == "pause" then
		love.draw()
	end

	local strings = {}
	for i=1,#menu.t do
		if type(menu.t[i]) == "function" then
			table.insert(strings,tostring(menu.t[i]()))
		else
			table.insert(strings,tostring(menu.t[i]))
		end
	end

	local selectionWidth = fonts.normal:getWidth(strings[menus.selection] or "---")*menus.sizes[menus.selection] + 10
	menus.drawSelection = menus.drawSelection + 0.3*(menus.selection-menus.drawSelection)
	menus.drawSelectionWidth = menus.drawSelectionWidth + 0.3*(selectionWidth-menus.drawSelectionWidth)

	love.graphics.push()

	local s = math.floor(screen.scale/screen.scaleMult*1.5)
	love.graphics.scale(s)

	local vWinW,vWinH = winW/s,winH/s
	local centerX,centerY = math.floor(vWinW/2),math.floor(vWinH/2)

	love.graphics.draw(menus.bgImg,menus.bgQuads.main,centerX,centerY,0,1,1,122,102)

	local barY = roundm(centerY-5-#strings*5+menus.drawSelection*10,s)
	love.graphics.draw(menus.bgImg,menus.bgQuads.select.m,centerX,barY,0,menus.drawSelectionWidth/224,1,112,5)
		love.graphics.draw(menus.bgImg,menus.bgQuads.select.l,centerX-menus.drawSelectionWidth/2,barY,0,1,1,5,5)
		love.graphics.draw(menus.bgImg,menus.bgQuads.select.r,centerX+menus.drawSelectionWidth/2,barY,0,1,1,0,5)

	love.graphics.printf(_app_version,centerX-118,centerY-98,236,"right")

	love.graphics.setFont( fonts.bold )
	love.graphics.print(menu.n,centerX-118,centerY-98)

	love.graphics.setFont( fonts.normal )
	if buttons then
		if ctrl and inputType == 1 then
			local pstr = "\n"..ctrlKeyName(cnf.jumpjs).." > Select"
			if menu.back then
				pstr = ctrlKeyName(cnf.actionjs).." > "..(menu.backname or strings[menu.back])..pstr
			end
			love.graphics.print(pstr,centerX-118,centerY+79)
		else
			local pstr = "\n"..goodKey(cnf.jump).." > Select"
			if menu.back then
				pstr = goodKey(cnf.action).." > "..(menu.backname or strings[menu.back])..pstr
			end
			love.graphics.print(pstr,centerX-118,centerY+79)
		end
	end

	if trophy.user then
		love.graphics.printf(trophy.user.print,centerX-118,centerY+79,218,"right")
		love.graphics.draw(gj_icon,centerX+100,centerY+81)
	end

	for i=1,#strings do
		if i ~= menus.selection then
			local dSize = menus.sizes[i]
			love.graphics.setColor(255,255,255/(dSize*dSize))
			love.graphics.printf(strings[i],0,centerY-5-#strings*5+i*10,vWinW/dSize,"center",0,dSize,dSize,0,5)
		end
	end

	do
		local i = menus.selection
		local dSize = menus.sizes[i]
		love.graphics.setColor(255,255,255/(dSize*dSize))
		if type(menu.f[menus.selection]) == "table" then
			local s = strings[i]
			local b,e = string.find(s,"%[.-%]$")
			if b and e then
				sideway[2] = string.sub(s,1,b-1)
				sideway[6] = string.sub(s,b,e)
				love.graphics.printf(sideway,0,centerY-5-#strings*5+i*10,vWinW/dSize,"center",0,dSize,dSize,0,5)
			else
				sidewayAll[4] = s
				love.graphics.printf(sidewayAll,0,centerY-5-#strings*5+i*10,vWinW/dSize,"center",0,dSize,dSize,0,5)
			end
		else
			love.graphics.printf(strings[i],0,centerY-5-#strings*5+i*10,vWinW/dSize,"center",0,dSize,dSize,0,5)
		end
	end

	love.graphics.setColor(255,255,255)
	love.graphics.pop()
end

-- Defining Menu Data
local currentPage
local tlight,tlightLenght
local password,passchar = "",0
local windowFormat = 0
local maxPage
local link

-- Other things
local function creditify(l)
	pmenu = menus.id
	link = l
	menus.load("openurl")
	local n,w = fonts.bold:getWrap(link,236)
	local s = "" for i,v in ipairs(w) do s = s.."\n"..v end
	menu.n = "Open URL?\n"..s:sub(2,#s)
end

-- updating the player selection menu
local lastModTime,lastSize,lastUnlocks
local optionsP,cancel
function menus.updatePlayerList(directQuit)
	print("Updating Character Selection...")

	local tstart = love.timer.getTime()

	local plist = love.filesystem.getDirectoryItems("player")
	for k,v in pairs(plist) do if not love.filesystem.isFile("player/"..v) then table.remove(plist,k) end end

	local modTime = 0
	local size = 0
	local unlockN = 0
	for k,v in pairs(plist) do
		modTime = modTime + (love.filesystem.getLastModified("player/"..v) or 0)
		size = size + (love.filesystem.getSize("player/"..v) or 0)
	end
	for k,v in pairs(unlocks) do
		if v then unlockN = unlockN + 1 end
	end

	if directQuit then
		optionsP = function() sendSave("Config","cnf.bin",cnf) menus.unload() end
		cancel = menus.unload
	else
		optionsP = function() menus.load("options") end
		cancel = optionsP
	end

	if modTime ~= lastModTime or size ~= lastSize or lastUnlocks ~= unlockN then
		print("\tUpdating...")

		lastModTime = modTime
		lastSize = size
		lastUnlocks = unlockN

		do
			local savedir = love.filesystem.getSaveDirectory()
			local realdir = love.filesystem.getRealDirectory
			table.sort(plist,function(a,b)
				local reala = realdir("player/"..a)
				local realb = realdir("player/"..b)
				if reala == realb or (reala ~= savedir and realb ~= savedir) then
					return a:gsub("^z%-","") < b:gsub("^z%-","")
				elseif reala == savedir then
					return false
				else
					return true
				end
			end)
		end

		local offset = 0
		local page = 0
		local pages = {}
		local previousP = function() currentPage = currentPage - 1 menus.load("playerselect-"..currentPage) menus.selection = #menu.t-1 menus.drawSelection = menus.selection end
		local nextP = function() currentPage = currentPage + 1 menus.load("playerselect-"..currentPage) if #menu.t == 16 then menus.selection = 14 menus.drawSelection = 14 else menus.selection = #menu.t-1 menus.drawSelection = menus.selection end end

		local opCall = function() optionsP() end
		local cnCall = function() cancel() end

		for i,v in ipairs(plist) do
			local pname = v:gsub("%.char$","")

			if not pname:find("^#") and (not pname:find("^z%-") or unlocks[pname]) then
				if (i-offset-1)%12 == 0 then
					if page > 0 then
						table.insert(pages[page].t,"") table.insert(pages[page].t,"> Next >") table.insert(pages[page].t,"Cancel")
						table.insert(pages[page].f,0) table.insert(pages[page].f,nextP) table.insert(pages[page].f,cnCall)
					end
					page = page + 1
					pages[page] = {n = "Choose Character",f = {},t = {}}
				end
				local pl = fileLoad("player/"..plist[i])
				if pl.costumes then
					local clist = fileLoad(pl.costumes)
					local cnamelist
					if clist.defaultname then
						cnamelist = { clist.defaultname }
					else
						cnamelist = { "Normal" }
					end
					for k,v in pairs(clist) do if k ~= "defaultname" then table.insert(cnamelist,k) end end

					local costume = 1
					local loc = #pages[page].t+1
					local playername = pl.name or pname

					local function plisttext()
						if menus.selection == loc then
							return playername.." ["..cnamelist[costume].."]"
						else
							if costume ~= 1 then costume = 1 end
							return playername
						end
					end

					local plistfunc = {
						function() costume = costume - 1 if costume <= 0 then costume = #cnamelist end end,
						function() player:setPlayer(pname,cnamelist[costume]) cnf.player = pname cnf.playercostume = cnamelist[costume] optionsP() end,
						function() costume = costume + 1 if costume > #cnamelist then costume = 1 end end,
					}

					table.insert(pages[page].t,plisttext)
					table.insert(pages[page].f,plistfunc)
				else
					table.insert(pages[page].t,pl.name or pname)
					table.insert(pages[page].f,function() player:setPlayer(pname) cnf.player = pname cnf.playercostume = "" optionsP() end)
				end
			else
				offset = offset + 1
			end
		end

		table.insert(pages[page].t,"") table.insert(pages[page].t,"Cancel")
		table.insert(pages[page].f,0) table.insert(pages[page].f,opCall)

		if #pages > 1 then
			for i=2,#pages do
				table.insert(pages[i].t,#pages[i].t,"< Previous <")
				table.insert(pages[i].f,#pages[i].f,previousP)
			end
		end

		for i=1,#pages do
			pages[i].back = #pages[i].t
			menus.data["playerselect-"..i] = pages[i]
		end

		maxPage = page
	else
		print("\tSkipped updating, probably the same...")
	end

	currentPage = 1
	print(string.format(">> Took %fs",love.timer.getTime()-tstart))
end

-- GJ
local gj_username = ""
local gj_token = ""
if love.filesystem.isFile("gj_login") then
	local l = love.filesystem.lines("gj_login")
	gj_username = l()
	gj_token = l()
end

local gj_state = 0
local orig_cnf

-- Actual menus
menus.data = {
	main = {
		n = "Main Menu",
		f = {
			function() noSave = false savedata = _savedata() menus.unload() levels.latestHub = _vars.hub levels.set(_vars.level) levels.hubPos = nil end, --NEW GAME
			function() noSave = true  savedata = _savedata() menus.unload() levels.latestHub = _vars.hub levels.set(_vars.level) levels.hubPos = nil gameTimer = 0 end, --NO-SAVE-GAME
			0,
			"!options",
			0,
			function() if not gj_logged_in then pmenu = "main" menus.load("gj") end end,
			"password",
			"credits",
			0,
			function() love.event.quit() end,
		},
		t = {
			"New Game",
			"No-Save-Game",
			"",
			"Settings",
			"",
			function() return gj_logged_in and "Logged in!" or "Game Jolt-Login" end,
			"Password",
			"Credits",
			"",
			"Quit",
		}
	},
	gj = { --Game Jolt log-in etc.
		n = "Game Jolt-Login",
		f = {
			function()
				local gj = love.thread.newThread("threads/gamejolt.lua")

				gj:start(gj_username,gj_token)

				local response = gj_comm.ret:demand()

				print(response)
				if response == "login_success" then
					gj_logged_in = true
					threads.gamejolt = gj
					menus.load(pmenu)
				end

				love.filesystem.write("gj_login",gj_username.."\n"..gj_token)
			end,
			0,
			function()
				if gj_state == 0 then
					orig_cnf = cloneTable(cnf)
					for k,v in pairs{"moveLeft","moveRight","moveUp","moveDown","jump","action","start","select"} do cnf[v] = "no_key" cnf[v.."js"] = "no_button" end
					cnf.jump = "return"
					cnf.moveLeft = "backspace"

					love.keyboard.setTextInput(true)
					if lastText then lastText = nil end

					gj_state = 1
				else
					cnf = orig_cnf
					orig_cnf = nil
					love.keyboard.setTextInput(false)

					gj_state = 0
				end
			end,
			0,
			function()
				if gj_state == 0 then
					orig_cnf = cloneTable(cnf)
					for k,v in pairs{"moveLeft","moveRight","moveUp","moveDown","jump","action","start","select"} do cnf[k] = "return" cnf[k.."js"] = "a" end
					cnf.jump = "return"
					cnf.moveLeft = "backspace"

					love.keyboard.setTextInput(true)
					if lastText then lastText = nil end

					gj_state = 2
				else
					cnf = orig_cnf
					orig_cnf = nil
					love.keyboard.setTextInput(false)

					gj_state = 0
				end
			end,
			0,
			0,
			"!"
		},
		t = {
			"Login",
			"",
			"Username:",
			gj_username,
			"Token:",
			gj_token,
			"",
			"Back"
		},
		bgCalc = function()
			if inputType == 0 then
				if gj_state == 1 then
					if lastText then gj_username = gj_username .. lastText lastText = nil menu.t[4] = gj_username
					elseif input.moveLeft then gj_username = gj_username:sub(1,#gj_username-1) menu.t[4] = gj_username end
				elseif gj_state == 2 then
					if lastText then gj_token = gj_token .. lastText lastText = nil menu.t[6] = gj_token
					elseif input.moveLeft then gj_token = gj_token:sub(1,#gj_token-1) menu.t[6] = gj_token end
				end
			elseif gj_state ~= 0 then
				gj_state = 0

				cnf = orig_cnf
				orig_cnf = nil
				love.keyboard.setTextInput(false)
			end
		end
	},
	pause = {
		n = "Paused...",
		f = {
			function() menus.unload() end,
			"!options",
			0,
			function()
				if currentMusic then
					if currentMusic.link then
						pmenu = menus.id
						link = currentMusic.link
						menus.load("openurl")
						local n,w = fonts.bold:getWrap(currentMusic.link,236)
						local s = "" for i,v in ipairs(w) do s = s.."\n"..v end
						menu.n = (currentMusic.title or "A Song").."\nby "..(currentMusic.creator or "Unknown").."\n\nOpen URL?\n"..s:sub(2,#s)
						return
					end
				end
				sound.destroy:play() sound.select:stop()
			end,
			function() if not gj_logged_in then pmenu = menus.id menus.load("gj") end end,
			0,
			function() menus.load("main","main") gameTimer = nil end,
			function() love.event.quit() end,
		},
		t = {
			"Continue",
			"Settings",
			"",
			function() if currentMusic then if currentMusic.link then return "Get ["..currentMusic.title.."]" else return "•"..currentMusic.title.."◘" end else return "•No Music◘" end end,
			function() return gj_logged_in and "Logged in!" or "Game Jolt-Login" end,
			"",
			"Quit to Main Menu",
			"Quit Game"
		},
		back = 1
	},
	openurl = {
		n = "Open Link?",
		f = {
			function() love.system.openURL(link) menus.load(pmenu) end,
			"!",
		},
		t = {
			"Open URL!!!",
			"No..."
		},
		back = 2
	},
	options = {
		n = "Settings",
		f = {
			function() toggleFullscreen() cnf.fullscreen = love.window.getFullscreen() end,
			{function() windowFormat = 1-windowFormat end,function() local isFs = love.window.getFullscreen() if not isFs then local wdata = {love.window.getMode()} wdata[1] = (windowFormat == 0 and 640 or 480)*screen.scale wdata[2] = 360*screen.scale love.window.setMode(unpack(wdata)) love.resize(love.graphics.getDimensions()) else toggleFullscreen() cnf.fullscreen = love.window.getFullscreen() end end,function() windowFormat = 1-windowFormat end},
			{function() cnf.maxPart = cnf.maxPart - 1 if cnf.maxPart < 3 then cnf.maxPart = 25 end partSystem:setMaximum(cnf.maxPart*100) end,0,function() cnf.maxPart = cnf.maxPart + 1 if cnf.maxPart > 25 then cnf.maxPart = 3 end partSystem:setMaximum(cnf.maxPart*100) end},
			function() tlight = cnf.light*10 tlightLenght = cnf.lightLenght*2 menus.load("optionsshader") end,
			0,
			{function() cnf.sfx = cnf.sfx - 0.05 if cnf.sfx < -0.01 then cnf.sfx = 1 elseif cnf.sfx < 0.04 then cnf.sfx = 0 end sounds.setSFXVolume(cnf.sfx) end,0,function() cnf.sfx = cnf.sfx + 0.05 if cnf.sfx > 1.01 then cnf.sfx = 0 end sounds.setSFXVolume(cnf.sfx) end},
			{function() if cnf.msfx == 0 and currentMusic then currentMusic:play() end cnf.msfx = cnf.msfx - 0.05 if cnf.msfx < -0.01 then cnf.msfx = 1 elseif cnf.msfx < 0.04 then cnf.msfx = 0 sounds.stopMusic() end sounds.setMusicVolume(cnf.msfx) end,0,function() if cnf.msfx == 0 and currentMusic then currentMusic:play() end cnf.msfx = cnf.msfx + 0.05 if cnf.msfx > 1.01 then cnf.msfx = 0 sounds.stopMusic() end sounds.setMusicVolume(cnf.msfx) end},
			0,
			function() -- Set up Keyboard
				local origms = menus.selection
				local origmsz = cloneTable(menus.sizes)
				local origmds = menus.drawSelection
				menus.selection = 0
				menus.drawSelection = 0
				menus.sizes = { 1,1,1,1,1,1,1,1 }
				local keys = { "moveLeft","moveRight","moveUp","moveDown","jump","action","start","select" }
				local dKeys = { "Moving Left","Moving Right","Moving Up","Moving Down","Jumping/Accept","Action/Abort","Start/Pause","Character Selection" }
				local assigned = { escape = true,f1 = true,f2 = true,f3 = true,f10 = true,f12 = true }
				for k,v in pairs(keys) do
					menus.sizes[menus.selection] = 1
					menus.selection = menus.selection + 1
					menus.drawSelection = menus.selection
					menus.sizes[menus.selection] = 1.25
					love.graphics.clear() love.graphics.origin() menus.draw({n="Hit Key for ...",t = dKeys,f = {}}) love.graphics.present()
					while true do
						local nK,t = love.waitForInput("keyboard")
						if nK and t == "keyboard" and not assigned[nK] then
							cnf[v] = nK
							dKeys[menus.selection] = dKeys[menus.selection]..": "..goodKey(nK)
							assigned[nK] = true
							break
						elseif nK == "quit" and t == "event" then
							love.event.quit()
							return
						end
					end
				end
				menus.selection = origms
				menus.drawSelection = origmds
				menus.sizes = origmsz
			end,
			"optionsctrl",
			0,
			function() if levels.changedPlayer then sound.destroy:play() sound.select:stop() else menus.updatePlayerList(false) menus.load("playerselect-1") menus.selection = #menu.t menus.drawSelection = #menu.t end end,
			0,
			function() love.system.openURL("file://"..love.filesystem.getSaveDirectory().."/screenshots") end,
			function() love.system.openURL("file://"..love.filesystem.getSaveDirectory().."/player") end,
			0,
			function() menus.load(pmenu) sendSave("Config","cnf.bin",cnf) end
		},
		t = {
			function() local isFs = love.window.getFullscreen() local isFsS = "" if isFs then isFsS = "On" else isFsS = "Off" end return "Full Screen? ["..isFsS.."]" end,
			function() if windowFormat == 0 then return string.format("Fit Window > [%d/%d]",screen.scale*640,screen.scale*360) else return string.format("Fit Window > [%d/%d]",screen.scale*480,screen.scale*360) end end,
			function() return "Max. Particles ["..(cnf.maxPart <= 0 and "None" or tostring(cnf.maxPart*100)).."]" end,
			"Shader Effects",
			"",
			function() return string.format("SFX Vol. [%d%%]",cnf.sfx*100) end,
			function() return string.format("Music Vol. [%d%%]",cnf.msfx*100) end,
			"",
			"Set up Keyboard",
			"Set up Controller",
			"",
			function() if levels.changedPlayer then return "Locked •"..player.name.."◘" else return "Choose Character ["..player.name.."]" end end,
			"",
			"Open Screenshot directory",
			"Open Player directory",
			"",
			"Back"
		},
		back = 0
	},
	optionsshader = {
		n = "Shader Effects",
		f = {
			{ function() if tlight > 0 then tlight = tlight - 1 else tlight = 10 end end,
				0, function() if tlight < 10 and tlight >= 0 then tlight = tlight + 1 else tlight = 0 end end },
			{ function() tlightLenght = tlightLenght-1 if tlightLenght < 1 then tlightLenght = 20 end end,
				0, function() tlightLenght = tlightLenght+1 if tlightLenght > 20 then tlightLenght = 1 end end },
			0,
			function()
				tlight = tlight/10
				tlightLenght = tlightLenght/2
				if tlight > 0 then
					light = love.graphics.newCanvas(love.graphics.getWidth(),love.graphics.getHeight())
					shaders.light:send("LENGTH",(tlightLenght*9)/winH*screen.scale)
					shaders.light:send("X_STEP",2/(winW*tlight*3))
					shaders.light:send("Y_STEP",1/(winH*tlight))
				end
				cnf.light = tlight cnf.lightLenght = tlightLenght menus.load("options") end
		},
		t = {
			function() return "Shadow Level [".. (tlight > 0 and tlight*10 .."%]" or "Off]") end,
			function() return "Shadow Length [".. tostring(tlightLenght/2).." Tiles]" end,
			"",
			"Back",
		},
		back = 0
	},
	optionsctrl = {
		n = "Controller Set-up",
		f = {
			function() -- Set up Controller
				if ctrl then
					local origms = menus.selection
					local origmsz = cloneTable(menus.sizes)
					local origmds = menus.drawSelection
					menus.selection = 0
					menus.drawSelection = 0
					menus.sizes = { 1,1,1,1,1,1 }
					local keys = { "jump","action","up","down","start","select" }
					local dKeys = { "Jumping/Accept","Action/Abort","Alternate Up","Alternate Down","Start/Pause","Character Selection" }
					local assigned = { dpup = true, dpdown = true, dpleft = true, dpright = true }
					for k,v in pairs(keys) do
						menus.sizes[menus.selection] = 1
						menus.selection = menus.selection + 1
						menus.drawSelection = menus.selection
						menus.sizes[menus.selection] = 1.25
						love.graphics.clear() love.graphics.origin() menus.draw({n="Hit Key for ...",t = dKeys,f = {}}) love.graphics.present()
						while true do
							local nB,t = love.waitForInput("controller")
							if nB and t == "controller" and not assigned[nB] then
								cnf[v.."js"] = nB
								dKeys[menus.selection] = dKeys[menus.selection]..": "..ctrlKeyName(nB)
								assigned[nB] = true
								break
							elseif nB == "quit" and t == "event" then
								love.event.quit()
								return
							end
						end
					end
					menus.selection = origms
					menus.drawSelection = origmds
					menus.sizes = origmsz
				else
					sound.destroy:play()
					sound.select:stop()
				end
			end,
			{function() if cnf.ctrlStick <= 0.11 then cnf.ctrlStick = 0.9 else cnf.ctrlStick = cnf.ctrlStick - 0.05 end end,0,function() if cnf.ctrlStick > 0.89 then cnf.ctrlStick = 0.1 else cnf.ctrlStick = cnf.ctrlStick + 0.05 end end},
			{function() if cnf.ctrlType > 0 then cnf.ctrlType = cnf.ctrlType - 1 else cnf.ctrlType = 2 end end,0,function() if cnf.ctrlType < 2 then cnf.ctrlType = cnf.ctrlType + 1 else cnf.ctrlType = 0 end end},
			0,
			"options"
		},
		t = {
			"Button Config",
			function() return string.format("Stick Threshold [%d%%]",cnf.ctrlStick*100) end,
			function() return "Controller Type ["..(cnf.ctrlType==0 and "XBox 360" or cnf.ctrlType==1 and "Dual-Shock 4" or "Others").."]" end,
			"",
			"Back"
		},
		back = 0
	},
	password = {
		n = "Enter Password",
		f = {
			function() local valid = fileLoad("assets/password.txt") menu.n = "Enter Password" if valid[password] then xpcall(loadstring(valid[password],password),function() print(debug.traceback()) end) else menus.load("404") end password = "" end,
			{function() passchar = passchar - 1 if passchar < 0 then passchar = 15 end end,function() if #password < 10 then password = password..string.format("%X",passchar) end end,function() passchar = passchar + 1 if passchar > 15 then passchar = 0 end end},
			{function() passchar = passchar - 1 if passchar < 0 then passchar = 15 end end,function() if #password < 10 then password = password..string.format("%X",(passchar+8)%16) end end,function() passchar = passchar + 1 if passchar > 15 then passchar = 0 end end},
			function() if #password > 0 then password = password:sub(1,#password-1) end end,
			0,
			function() menu.n = "Enter Password" menus.load("main") end
		},
		t = {
			function() if menus.selection == 1 then return ">>> "..password.." <<<" else return password..string.rep("_",10-#password) end end,
			function() return string.format("…%X %X [%X] %X %X…",(passchar-2)%16,(passchar-1)%16,passchar,(passchar+1)%16,(passchar+2)%16) end,
			function() return string.format("…%X %X [%X] %X %X…",(passchar+6)%16,(passchar+7)%16,(passchar+8)%16,(passchar+9)%16,(passchar+10)%16) end,
			"[<– ]",
			"",
			"Back"
		},
		back = function() if #password > 0 then password = password:sub(1,#password-1) else menu.n = "Enter Password" menus.load("main") end end,
		backname = "[<– ]"
	},
	credits = {
		n = "Credits",
		t = {
			"Select to visit their site!",
			"",
			"Code/Scripting, Art and SFX",
			"by DPlay aka DPlayer234",
			"",
			"Current Character:",
			function() local c = cnf.player return c == "z-glassth" and "RE-sublimity-kun" or c == "z-purplesis" and "Idea Factory/Compile Heart" or c == "z-pewdog" and "PewDiePie" or c == "z-lily" and "Lost Pause" or "---" end,
			"",
			"Music by several artists",
			"",
			"And I'm thanking",
			"the others of FineGames",
			"and my friends.",
			"",
			"Back"
		},
		f = {
			function() menu.t[1] = "Not me!" end,
			0,
			0,
			function() creditify("https://www.youtube.com/channel/UCTUYgcZlcrPkX0nq8V8IPCQ") end,
			0,
			0,
			function() local c = cnf.player creditify(c == "z-glassth" and "http://re-sublimity-kun.deviantart.com/" or c == "z-purplesis" and "http://ideafintl.com" or c == "z-pewdog" and "https://www.youtube.com/user/PewDiePie" or c == "z-lily" and "https://www.youtube.com/user/LostPause" or "http://www.lmgtfy.com/?q=Am+I+stupid%3F") end,
			0,
			"musiccredits",
			0,
			0,
			function() creditify("https://www.youtube.com/user/FineMindable") end,
			0,
			0,
			"main"
		},
		back = 0
	},
	musiccredits = {
		n = "Credits - Music",
		t = { "","Back" },
		f = { 0,"credits" },
		back = 0
	},
	["404"] = {
		n = "404: Password not found",
		t = {"'k then."},
		f = {"password"}
	},
	invalid = {
		n = "Invalid",
		f = { menus.unload,menus.unload },
		t = { "-ERROR-","Attempt to load invalid menu!" },
		back = menus.unload,
		backname = "Close"
	}
}

menus.data.pauseH = cloneTable(menus.data.pause)
table.insert(menus.data.pause.f,3,function() menus.unload() levels.set(levels.latestHub,true) end)
table.insert(menus.data.pause.t,3,"Return to Hub")

local mc = menus.data.musiccredits
for k,v in pairs(music) do
	table.insert(mc.t,#mc.t-1,(v.title or "A Song").." : "..(v.creator or "Unknown"))
	table.insert(mc.f,#mc.f-1,function() creditify(v.link) end)
end
if #mc.t <= 2 then
	table.insert(mc.t,1,"---")
	table.insert(mc.f,1,function()end)
end

function menus.insertLoadGame()
	if love.filesystem.isFile("sav.bin") then
		table.insert(menus.data.main.f,1,function()
			local start = love.timer.getTime()
			noSave = false
			local lsave = save.read("sav.bin")
			if lsave then
				local sd = _savedata()

				local nsave = {}
				nsave.levels = type(lsave.levels) == "table" and lsave.levels or cloneTable(sd.levels)
				nsave.collectLvl = type(lsave.collectLvl) == "table" and lsave.collectLvl or cloneTable(sd.collectLvl)
				nsave.ripCount = type(lsave.ripCount) == "number" and lsave.ripCount or 0
				nsave.hub = type(lsave.hub) == "string" and lsave.hub or _vars.hub
				nsave.collect = 0
				for i,v in ipairs(nsave.collectLvl) do if type(v) == "number" then nsave.collect = nsave.collect + v else nsave.collectLvl[i] = 0 end end
				nsave.endlessScore = type(lsave.endlessScore) == "number" and lsave.endlessScore or 0

				savedata = nsave
				menus.unload()
				levels.set(savedata.hub or levels.latestHub)

				levels.hubPos = nil

				print("Loaded Save Data.",string.format("Took %fs",love.timer.getTime()-start))
			end
		end)
		table.insert(menus.data.main.t,1,"Load Game")

		menus.insertLoadGame = nil
	end
end

menus.bgImg = love.graphics.newImage("assets/menuBg.png")
menus.bgQuads = {
	main = love.graphics.newQuad(0,0,244,204,menus.bgImg:getDimensions()),
	select = {
		l = love.graphics.newQuad(5,204,5,10,menus.bgImg:getDimensions()),
		m = love.graphics.newQuad(10,204,224,10,menus.bgImg:getDimensions()),
		r = love.graphics.newQuad(234,204,5,10,menus.bgImg:getDimensions()),
	}
}
