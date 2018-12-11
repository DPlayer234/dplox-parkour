-- Title Screen
local function titlescreen()
	local obgc = { love.graphics.getBackgroundColor() }

	local titleimg = love.graphics.newImage("assets/title.png")
	local titleanim = anim.newAnimHead(titleimg,244,138)
	titleanim:defineQuad(love.graphics.newQuad(0,168,65,30,244,276),2,1)
	titleanim:defineQuad(love.graphics.newQuad(65,168,65,30,244,276),2,2)
	titleanim:defineQuad(love.graphics.newQuad(130,168,65,30,244,276),2,3)
	titleanim:addAnim("hit",{1,2,1},{5,2,3},{9,2,1},{13,2,2},{17,"loop"})

	local bgquad = love.graphics.newQuad(0,0,244,138,244,276)
	local ttitle = love.graphics.newQuad(0,138,244,30,244,276)
	local pos = 0
	local minPos = -3
	local maxPos = 3
	local toPos = maxPos

	setMusic(music.title)

	if not _args.singlethread then
		sounds.enableThreadedLoading()
	end

	local hasConf = love.filesystem.isFile("cnf.bin")

	local input,t = love.waitForInput(nil,function() --TITLESCREEN FUNCTION
			pos = pos + 0.07*(toPos-pos)
			if roundm(pos,4) <= minPos*0.88 then
				toPos = maxPos
			elseif roundm(pos,4) >= maxPos*0.88 then
				toPos = minPos
			end

			love.graphics.clear(38,123,2,255)
			love.graphics.origin()

			love.graphics.scale(winW/titleimg:getWidth())

			local vWinW,vWinH = winW/(winW/titleimg:getWidth()),winH/(winW/titleimg:getWidth())
			love.graphics.draw(titleimg,bgquad)
			love.graphics.draw(titleimg,ttitle,0,math.floor((vWinH/2-25+pos)*winH)/winH)

			titleanim:update("hit")
			titleanim:draw(math.floor(vWinW/2),math.floor((vWinH/2+25+pos*0.5)*winH)/winH,0,1,1,32,15)

			if hasConf then
				love.graphics.origin()
				love.graphics.print("Hit \"Esc.\" to reset the configuration.",5,5,0,screen.scale)
			end

			love.graphics.present()
		end --TITLESCREEN FUNCTION END
	)

	if input then
		if input == "escape" then
			cnf = cloneTable(_cnf)
			print("Reset configuration.")
		elseif input == "quit" then
			love.event.quit()
		end
	end
end

-- MAIN LOOP
function love.run()
	math.randomseed(os.time() + love.timer.getTime())
	for i=1,3 do math.random() end

	love.graphics.print("Loading...\nPlease wait...",10,10)
	love.graphics.present()

	love.load(_args)
	print(string.format("Start-up took %f seconds!",love.timer.getTime()-_started),string.format("RAM: %.3fKB",collectgarbage("count")))

	titlescreen()

	if _args.gjapi_username and _args.gjapi_token then
		local gj_username = _args.gjapi_username
		local gj_token = _args.gjapi_token
		local gj = love.thread.newThread("threads/gamejolt.lua")

		gj:start(gj_username,gj_token)

		local response = gj_comm.ret:demand()

		print(response)
		if response == "login_success" then
			gj_logged_in = true
			threads.gamejolt = gj
		end
	end

	menus.load("main","main")
	player:setPlayer(cnf.player,cnf.playercostume)

	love.timer.step()
	local dt = 0

	local toaster = 0

	while true do -- Main Loop
		local _frame = love.timer.getTime()

		prKeys = {}
		prButtons = {}

		love.event.pump()
		for e,a,b,c,d in love.event.poll() do
			if e == "quit" then
				love.audio.stop()
				if saving then
					if saving >= 60 and saveQueue > 0 then
						repeat
							print("Waiting for "..saveQueue.." files to be saved...")
							savestatus = channels.saveIn:demand()
							saveQueue = saveQueue - 1
						until saveQueue <= 0
					end
				end

				if threads.gamejolt then
					gj_comm.set:push({"logout"})
					threads.gamejolt:wait()
				end

				return
			end
			love.handlers[e](a,b,c,d)
		end

		love.timer.step()
		dt = love.timer.getDelta()

		love.graphics.clear()
		love.graphics.origin()

		if enableDebug then debugger.update(dt) end

		if gameStatus == 0 then
			-- Making sure the game is not running on a toaster/at "toaster-speed"
			if dt > 0.02 then
				toaster = toaster + 1
				if toaster > 90 then
					if cnf.light > 0 then
						cnf.light = math.max(cnf.light - .1,0)
						if cnf.light > 0 then
							shaders.light:send("X_STEP",2/(winW*cnf.light*3))
							shaders.light:send("Y_STEP",1/(winH*cnf.light))
						end
					elseif cnf.maxPart > 5 then
						cnf.maxPart = cnf.maxPart - 1
						partSystem:setMaximum(cnf.maxPart*100)
					end
					toaster = 30
				end
			elseif toaster > 0 then
				toaster = toaster - 1
			end
			-- Actual Game
			love.update()
			love.draw()
		elseif gameStatus == 1 then
			-- Menu
			menus.update()
		elseif gameStatus == 2 then
			-- Cut-Scenes
			cutscene.update()
		elseif gameStatus == 3 then
			-- Help-Screen
			help.update()
		elseif gameStatus == 4 then
			-- Editor
			editor.update()
			editor.draw()
		end

		sounds.update(player.x,player.y)

		if prKeys.f12 then
			local screenshot = love.graphics.newScreenshot(false)
			local osdate = os.date("%y-%m-%d_%H.%M.%S")
			while love.filesystem.isFile("screenshots/"..osdate..".png") do
				osdate = osdate.."-"
			end
			screenshot:encode("png","screenshots/"..osdate..".png")
			print("Screenshot: "..osdate)
			notice.add("Screenshot saved!\n"..osdate..".png")
		end

		if saving then
			hud.write:update()

			if not savestring then
				savestring = {}
			end

			if saving >= 60 then
				local savestatus = channels.saveIn:pop()
				if savestatus then
					saveQueue = saveQueue - 1
					if savestatus:sub(#savestatus) == "-" then
						hud.write:update("fail")
						if #savestring > 0 then table.insert(savestring,{255,255,255}) table.insert(savestring,", ") end
						table.insert(savestring,{255,0,0}) table.insert(savestring,savestatus:sub(1,#savestatus-1))
					elseif hud.write.anim ~= "fail" then
						hud.write:update("success")
						if #savestring > 0 then table.insert(savestring,{255,255,255}) table.insert(savestring,", ") end
						table.insert(savestring,{0,255,23}) table.insert(savestring,savestatus)
					end
					if saveQueue <= 0 then
						saving = 59
					end
				end
			elseif saveQueue > 0 then
				saving = 60
			else
				saving = saving - 1
				if saving <= 0 then
					saving = nil
					savestring = nil
				end
			end

			if saving and hud.show then
				hud.write:draw(3*screen.scale,winH-15*screen.scale,0,screen.scale)
				love.graphics.print(savestring,22*screen.scale,winH-14*screen.scale,0,screen.scale)
			end
		end

		if notice.box then
			if hud.show then
				notice.draw()
			end
			notice.update()
		end

		if hud.show and levels.musicPrint and cnf.msfx > 0 then
			local yoffset = 0
			if notice.box then
				yoffset = notice.box.y + 35
			end
			love.graphics.printf(levels.musicPrint,0,3*screen.scale + yoffset*screen.scale,(winW-3)/screen.scale,"right",0,screen.scale)
		end

		if enableDebug then
			if enableDebug then debugger.draw() end

			if channels.print:getCount() > 0 then
				local p = channels.print:pop()
				require "debugger".print(unpack(p))
			end
		end

		love.graphics.present()

		local gj_ret = gj_comm.ret:pop()
		if gj_ret then
			if type(gj_ret) == "table" then
				local e,a,b,c = unpack(gj_ret)
				if e == "trophy_achieved" then
					trophy.achieved[a] = true
				elseif e == "user" then
					trophy.user = {
						name = a,
						type = b,
						print = {{255,255,255},a.."\n",{127,146,255},b}
					}

					print("User '"..a.."' is a '"..b.."'.")

					gj_icon = love.graphics.newImage("assets/gj_icon.png")
				end
			end
		end

		love.timer.sleep(1/60 - love.timer.getTime() + _frame)
	end
end

-- Function for Sub-Loops e.g. waiting for Inputs
function love.waitForInput(iType,fnc)
	local input = false
	local inputt = ""
	latestKey = nil
	latestButton = nil
	repeat
		local _frame = love.timer.getTime()

		love.event.pump()
		for e,a,b,c,d in love.event.poll() do
			if e == "quit" then
				return "quit","event"
			end
			love.handlers[e](a,b,c,d)
		end

		if type(fnc) == "function" then
			fnc()
		end

		if iType == "controller" then
			if latestButton then
				input = latestButton
				inputt = "controller"
			end
		elseif iType == "keyboard" then
			if latestKey then
				input = latestKey
				inputt = "keyboard"
			end
		elseif latestButton then
			input = latestButton
			inputt = "controller"
		elseif latestKey then
			input = latestKey
			inputt = "keyboard"
		end

		love.timer.step()
		love.timer.sleep(1/60 - love.timer.getTime() + _frame)
	until input
	prKeys = {}
	prButtons = {}
	return input,inputt
end
