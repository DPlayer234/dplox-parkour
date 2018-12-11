local math = math

local function attackBreak(rep)
	local pCax = {math.ceil((player.attackBox.x+4)/9),math.ceil(player.attackBox.x/9),math.ceil((player.attackBox.x-4)/9)}
	local pCay = {math.ceil((player.attackBox.y-7)/9),math.ceil(player.attackBox.y/9),math.ceil((player.attackBox.y+7)/9)}

	for i=1,3 do local y = pCay[i] if level[y] then for j=1,3 do local x = pCax[j] local id = level(x,y) if id then
		local tile = tileData[id]
		if tile.d.hit then
			if type(tile.d.hit) == "function" then
				tile.d.hit(x,y,tile.d.hitarg,rep)
			else
				level[y][x] = #tileData
				partSystem:spawnParticles("gold",10,x*9-4.5,y*9-9,3,0)
				levels.collectSth()
			end
		elseif tile.d.collect then
			level[y][x] = 0
			levels.collectSth()
		end
	end end end end
end

function love.update()
	local player = player
	local levels = levels
	local level = level
	local input = input

	-- Player Input Processing
	if player.freeze < 0 then
		if ctrl and inputType == 1 then
			local stickx = ctrl:getGamepadAxis("leftx")
			local sticky = ctrl:getGamepadAxis("lefty")
			input.moveLeft = stickx < -cnf.ctrlStick and -stickx or ctrl:isGamepadDown("dpleft") and 1
			input.moveRight = stickx > cnf.ctrlStick and stickx or ctrl:isGamepadDown("dpright") and 1
			input.moveUp = sticky < -cnf.ctrlStick or ctrl:isGamepadDown(cnf.upjs) or ctrl:isGamepadDown("dpup")
			input.moveDown = sticky > cnf.ctrlStick or ctrl:isGamepadDown(cnf.downjs) or ctrl:isGamepadDown("dpdown")
			input.jump = prButtons[cnf.jumpjs]
			input.holdJump = ctrl:isGamepadDown(cnf.jumpjs)
			input.action = prButtons[cnf.actionjs]
			input.holdAction = ctrl:isGamepadDown(cnf.actionjs)
			input.pause = prButtons[cnf.startjs]
			input.select = prButtons[cnf.selectjs]
		else
			input.moveLeft = love.keyboard.isScancodeDown(cnf.moveLeft) and 1
			input.moveRight = love.keyboard.isScancodeDown(cnf.moveRight) and 1
			input.moveUp = love.keyboard.isScancodeDown(cnf.moveUp)
			input.moveDown = love.keyboard.isScancodeDown(cnf.moveDown)
			input.jump = prKeys[cnf.jump]
			input.holdJump = love.keyboard.isScancodeDown(cnf.jump)
			input.action = prKeys[cnf.action]
			input.holdAction = love.keyboard.isScancodeDown(cnf.action)
			input.pause = prKeys[cnf.start]
			input.select = prKeys[cnf.select]
		end
	elseif player.freeze == 0 then
		player.freeze = -1
		if player.freezeDeath then
			player.x,player.y = unpack(player.respawn)
			screen.x,screen.y = player.x,player.y
			player.xv,player.yv = 0,0
			player.pdata.xv,player.pdata.yv = 0,0
			player.freezeDeath = false
			player.yOff = 0

			-- Endless Mode Scoring
			if levels.isEndless then
				if levels.current ~= "endless_hub" then
					local newHighscore = false
					if savedata.endlessScore < levels.currentCollect then
						savedata.endlessScore = levels.currentCollect
						newHighscore = true

						sendSave("Save Data","sav.bin",savedata)
					end

					trophy.sendScore(levels.currentCollect)

					if savedata.endlessScore >= 1000 then
						trophy.give("its_over_1k")
						unlockChar("z-zendless")
					end

					cutscene.start({{"text",nil,string.format("-- GAME OVER --\nScore: %d\n\n%s",levels.currentCollect,newHighscore and "NEW HIGHSCORE!" or "Try again!"),"center"}},true)
					levels.set("endless_hub")
				end
			end

			if boss then
				for k,v in pairs(boss.d) do
					if type(v) == "table" then
						boss[k] = cloneTable(v)
					else
						boss[k] = v
					end
				end
				if boss.reset then
					boss.reset()
				end
			end
		end
	else
		player.freeze = player.freeze - 1

		input.moveLeft = false input.moveRight = false input.moveUp = false input.moveDown = false input.jump = false input.holdJump = false input.action = false input.holdAction = false input.pause = prKeys[cnf.start] or prButtons[cnf.startjs] input.select = false
	end

	player.data.duck = player.data.g and input.moveDown or player:headInBlock()

	if player.data.g then -- X-Velocity Mods
		if player.data.duck and (player.xv > 0.6 or player.xv < -0.6) then
			player.xv = player.xv * 0.985
		else
			player.xv = player.xv * 0.77
			player.acceleration = 1
		end
	else
		player.xv = player.xv * 0.9
		player.acceleration = 0.45
	end
	if player.xv > -0.1 and player.xv < 0.1 then
		player.xv = 0
	end

	if player.data.w then -- Gravity and Wall / Y-Velocity Mods
		if input.moveUp and player.yv < 0 then
			player.gravity.multiplier = 0.985
			player.gravity.acceleration = 0.012
		elseif input.moveDown then
			player.gravity.multiplier = 0.97
			player.gravity.acceleration = 0.135
		elseif player.yv < 0 then
			player.gravity.multiplier = 0.97
			player.gravity.acceleration = 0.13
		else
			player.gravity.multiplier = 0.8
			player.gravity.acceleration = 0.13
		end
		if not player.data.g then
			player.xv = player.xv + player.dir*0.01
		end
	else
		player.gravity.multiplier = 1
		player.gravity.acceleration = 0.13
	end
	player.yv = (player.yv + player.gravity.acceleration) * 0.985 * player.gravity.multiplier

	-- Player Input
	if ( input.moveLeft or input.moveRight ) and not ( input.moveLeft and input.moveRight ) and not ( player.data.duck ) then
		player.data.m = input.moveLeft or input.moveRight
		if input.moveLeft then
			player.xv = player.xv - 0.45*player.acceleration*input.moveLeft
			if player.data.g then
				player.dir = -1
			end
		elseif input.moveRight then
			player.xv = player.xv + 0.45*player.acceleration*input.moveRight
			if player.data.g then
				player.dir = 1
			end
		end
	else
		player.data.m = false
	end

	if input.jump then -- Jumping
		if input.moveDown then
			if player.data.w and not player.data.g then -- Jump from Wall while holding down
				player.yv = player.wJumpV
				player.xv = player.dir * -3
				player.dir = player.dir * -1
				player.airJumps = 0
				if not player.data.updateAnim then player.data.updateAnim = true end
				player.jumped = true
				sound.jump:play(player.x,player.y)
			end
		elseif not player.data.duck then
			if player.data.g then -- Jump from Ground
				player.yv = player.jumpV
				player.jumped = true
				sound.jump:play(player.x,player.y)
			elseif player.data.w then -- From Wall
				player.yv = player.wJumpV
				player.xv = player.dir * -3
				player.dir = player.dir * -1
				player.airJumps = 0
				if not player.data.updateAnim then player.data.updateAnim = true end
				player.jumped = true
				sound.jump:play(player.x,player.y)
			elseif player.airJumps < player.pAirJumps then -- From Air
				if input.moveLeft then
					player.dir = -1
				elseif input.moveRight then
					player.dir = 1
				end
				if player.hasDoubleJump then
					player.status = "djump"
					player.anim.frame = 0
					player.data.updateAnim = false
					player.data.stopStatus = 0
				end
				player.airJumps = player.airJumps + 1
				player.jumped = true
				sound.jump:play(player.x,player.y)
				partSystem:spawnParticles("dust",math.ceil(math.abs(player.dJumpV-player.yv)),player.x,player.y+2,4,2)
				player.yv = player.dJumpV
			end
		end
	end

	if player.yOff > 0 then
		if player.data.g then
			player.yOff = player.yOff - 1.5
		else
			player.yOff = 0
		end
	end

	if input.action and player.attack < -5 then -- Attacking
		player.attack = 3
		player.attackBox.x = player.x+player.xv+player.dir*10
		player.attackBox.y = player.y+player.yv
		player.attackDir = player.dir
		sound.attack:play(player.attackBox.x,player.attackBox.y,0,5)

		if player.hasAttack then
			player.status = "attack"
			player.anim.frame = 0
			player.data.updateAnim = false
			player.data.stopStatus = player:getStatusId()
		end

		attackBreak(false)

		player.attackAnim = true
		attackAnim.frame = 0
		attackAnim:update(0)
	elseif player.attack > 0 then
		attackBreak(true)

		player.attack = player.attack - 1
	elseif player.attack >= -5 then
		player.attack = player.attack - 1
	end

	if sound.jump.source:isPlaying() then sound.jump:setPosition(player.x,player.y) end

	if player.attackAnim then
		player.attackAnim = not attackAnim:update(0)
		player.attackBox.x = player.x+player.xv+player.dir*10
		player.attackBox.y = player.y+player.yv
		player.attackDir = player.dir
	end

	-- Collision and movement
	-- x movement
	local closest
	local cdie
	local foundstair
	local collect
	local pC
	if player.data.duck then
		player.hitBox.h = 9
		player.hitBox.yo = 1
		pC = { math.floor((player.y+17)/9) }
	else
		player.hitBox.h = 17
		player.hitBox.yo = -7
		pC = { math.ceil((player.y-6)/9),math.ceil(player.y/9),math.floor((player.y+17)/9) }
	end
	for k=1,#pC do
		local yt = level[pC[k]]
		if yt then
			local xt = -1
			if yt[round((player.x+player.xv+8.5)/9)] and player.xv > 0 then
				xt = round((player.x+player.xv+8.5)/9)
			elseif yt[round((player.x+player.xv)/9)] and player.xv < 0 then
				xt = round((player.x+player.xv)/9)
			end
			if xt >= 0 then
				if tileData[yt[xt] ] then
					local tile = tileData[yt[xt] ]
					if player.data.g and k == 3 and tile.d.stair then -- Stairs
						foundstair = xt
						break
					elseif tile.d.hori then -- Solid
						closest = xt
						break
					elseif tile.d.death then
						cdie = true
					elseif tile.d.collect then
						collect = {pC[k],xt}
					end
				end
			end
		end
	end
	if closest then -- Position Calculation
		player.data.w = true
		player.airJumps = 0
		local pyvwallrun = player.yv*0.25-math.abs(player.xv)
		if not player.pdata.w and input.moveUp and pyvwallrun <= player.gravity.acceleration then player.yv = pyvwallrun end
		if player.xv > 0 then
			player.x = closest*9-13
			player.dir = 1
		else
			player.x = closest*9+4
			player.dir = -1
		end
		player.xv = 0
		if player.data.m then
			player.data.m = false
		end
	else
		if foundstair then
			player.yOff = 9
			player.y = player.y - 9
			if player.xv > 0 then
				player.x = math.ceil(player.x + player.xv) + 1
				if player.xv >= 1.5 then player.xv = player.xv - .5 end
			else
				player.x = math.floor(player.x + player.xv) - 1
				if player.xv <= -1.5 then player.xv = player.xv + .5 end
			end
		else
			player.x = player.x + player.xv
		end
		player.data.w = false

		if cdie then
			player.actuallyDie = true
			player.xv = -player.xv
		elseif collect then
			level[collect[1]][collect[2]] = 0
			levels.collectSth()
		elseif player.data.duck then
			if player:headInBlock() and player.xv > -0.5 and player.xv < 0.5 then
				local dir = player.xv == 0 and player.dir or player.xv > 0 and 1 or player.xv < 0 and -1
				player.xv = dir * 0.5
			end
		end
	end

	-- y movement
	local closest
	local cdie
	local collect
	local pC2 = { math.floor((player.x+5.1)/9),math.ceil((player.x+3.9)/9) }
	for k=1,2 do
		local j = pC2[k]
		if player.yv > 0 then -- y positive (down)
			local yt = round((player.y+player.yv+14)/9)
			local ytt = level[yt]
			if ytt then
				if ytt[j] then
					local tile = tileData[ytt[j]]
					if tile then
						if tile.d.vert or ( tile.d.nonsolid and player.y+17 < yt*9 and not ( input.jump and input.moveDown ) ) then -- Solid Collision +y and Dropping
							if player:moves() then
								if tile.d.part then
									if math.random(1,2) == 1 then
										partSystem:spawnParticles(particleId[tile.d.part],1,player.x-1,player.y+8,4,1)
									else
										partSystem:spawnParticles("dustMove",1,player.x-1,player.y+8,4,1)
									end
								else
									partSystem:spawnParticles("dustMove",1,player.x-1,player.y+8,4,1)
								end
							end
							player.data.g = true
							player.airJumps = 0
							closest = yt
							break
						elseif tile.d.nonsolid and player.y+17 < yt*9 and input.jump and input.moveDown then
							player.y = player.y + 1
						elseif tile.d.death then
							cdie = true
						elseif tile.d.collect then
							collect = {yt,j}
						end
					end
				end
			end
		elseif player.yv < 0 then -- y negative (up)
			local yt = round((player.y+player.yv-4)/9)
			local ytt = level[yt]
			if ytt then
				if ytt[j] then
					local tile = tileData[ytt[j]]
					if tile then
						if tile.d.vertneg then -- Solid Collision -y
							closest = yt
							if tile.d.hit then
								if type(tile.d.hit) == "function" then
									tile.d.hit(j,yt,tile.d.hitarg)
								else
									ytt[j] = #tileData
									partSystem:spawnParticles("gold",10,j*9-4.5,yt*9-9,3,0)
									levels.collectSth()
								end
							end
						elseif tile.d.death then
							cdie = true
						elseif tile.d.collect then
							collect = {yt,j}
						end
					end
				end
			end
		else
			break
		end
	end
	if closest then -- Position Calculation
		if player.yv > 0 then
			player.y = closest*9-18
		else
			player.y = closest*9+8
		end
		player.yv = 0
	else
		if player.data.g then
			player.data.g = false
		end
		player.y = player.y + player.yv
		if cdie then
			player.actuallyDie = true
			player.yv = -player.yv
		elseif collect then
			level[collect[1]][collect[2]] = 0
			levels.collectSth()
		end
	end

	if ( player.data.g or player.data.w or player.yv > -1 or not input.holdJump ) and player.jumped then
		player.jumped = false
		if not input.holdJump then
			player.yv = player.yv * 0.65
		end
	end

	if player.y > levels.height*9 + 240 then
		player.actuallyDie = true
	end

	-- Bosses
	if boss then
		boss.update()
	end

	if player.actuallyDie then
		-- Death
		if not player.freezeDeath then
			player.freezeDeath = true
			player.freeze = 65
			player.data.updateAnim = true
			if not levels.isEndless then
				savedata.ripCount = savedata.ripCount + 1
			end
			sound.jump:stop()
			sound.death:play(player.x,player.y)
			partSystem:spawnParticles("blood",math.random(15,25),player.x,player.y,0,0)

			screen.toX = math.min(math.max(player.x,0),levels.width*9)
			screen.toY = math.min(math.max(player.y,0),levels.height*9)
		else
			partSystem:spawnParticles("blood",math.random(2,4),player.x,player.y,0,0)
		end
		player.actuallyDie = false
	elseif finish then
		-- Finish Flag
		finishAnim:update()

		if finish.xv and finish.yv then -- Moving flag-pole
			if finish.yv == 0 then
				finish.xv = finish.xv * 0.87
			else
				finish.xv = finish.xv * 0.97
			end
			local xt = math.floor(finish.x+finish.xv+3/18)
			local yt = math.floor(finish.y+finish.yv)
			if level[yt] then
				local t = tileData[level[yt][xt]]
				if t then
					if t.d.hori then
						finish.xv = 0
					end
				end
				finish.x = finish.x + finish.xv
				local t2 = tileData[level(xt,yt+1)]
				if t2 then
					if t2.d.vertneg or t2.d.nonsolid then
						finish.yv = 0
					else
						finish.yv = (finish.yv + .014) * 0.985
					end
				else finish.yv = (finish.yv + .014) * 0.985 end
				finish.y = finish.y + finish.yv

				if t then
					if t.d.death then
						partSystem:spawnParticles("smoke",20,finish.x*9-9,finish.y*9-14,3,14)
						finish.x,finish.y = finish.ox,finish.oy
						finish.ox,finish.oy,finish.xv,finish.yv = nil
						partSystem:spawnParticles("smoke",20,finish.x*9-9,finish.y*9-14,3,14)
					end
				end
			else
				partSystem:spawnParticles("smoke",20,finish.x*9-9,finish.y*9-14,3,14)
				finish.x,finish.y = finish.ox,finish.oy
				finish.ox,finish.oy,finish.xv,finish.yv = nil
				partSystem:spawnParticles("smoke",20,finish.x*9-9,finish.y*9-14,3,14)
			end
		end

		if player.x-4 < finish.x*9 and player.x+4 > finish.x*9-9 and player.y-5 < finish.y*9 and player.y+5 > finish.y*9-27 and player.freeze < 0 then
			if not savedata.levels[finish.id] and finish.id then
				savedata.levels[finish.id] = true
				if exitCutscene then
					cutscene.start(exitCutscene,true)
				end
			end

			if levels.unlockableChar then
				unlockChar(levels.unlockableChar)
			end
			if levels.clearTrophy then
				trophy.give(levels.clearTrophy)
			end

			finish.finished = true
		elseif colide(player.attackBox.x-player.attackBox.w/2,player.attackBox.y-player.attackBox.h/2,player.attackBox.w,player.attackBox.h,finish.x*9-9,finish.y*9-27,9,27) and player.attack > 0 then -- Hitting the flag-pole
			finish.xv = player.dir * .2
			if not finish.ox then
				finish.yv = 0

				finish.ox = finish.x
				finish.oy = finish.y
			end
		end
	end

	-- Warps
	local warpto
	if warps and input.action then
		for i=1,#warps do
			if colide(player.x+player.hitBox.xo,player.y+player.hitBox.yo,player.hitBox.w,player.hitBox.h,warps[i].x*9-9,warps[i].y*9-9,9,18) then
				warpto = { to = warps[i].to, x = warps[i].overX, y = warps[i].overY }
				break
			end
		end
	end
	-- NPCs
	if npc then
		local closest = 32
		local closestTalk = 0
		for k,v in pairs(npc) do
			v.dir = player.x >= v.x and 1 or -1
			local distance = math.abs(player.x-v.x)
			if distance < closest and input.action and player.data.g and math.abs(player.y-v.y) < 10 then
				closest = distance
				closestTalk = k
			end
		end
		if closestTalk > 0 then
			local cnpc = npc[closestTalk]
			local text = type(cnpc.text) == "function" and cnpc.text() or tostring(cnpc.text)
			if cutscene.isActor(cnpc.name) then
				cutscene.start({{"move",cnpc.name,0.9,-1},{"text",cnpc.name,text}},true)
			else
				cutscene.start({{"text",cnpc.name,text}},true)
			end
			player.dir = -cnpc.dir
			player.attack = 0
			player.attackAnim = false
			sound.attack:stop()
		end
	end

	-- Animation and Data Updates
	if player:getStatusId() ~= player.data.stopStatus then player.data.updateAnim = true end
	if player.data.updateAnim then
		if player.freezeDeath then
			if player.hasGroundDie and player.data.g then
				player.status = "gdie"
			else
				player.status = "die"
			end
		elseif player.data.g then
			if player.data.m then
				if player.data.m > 0.6 then
					player.status = "walk"
				else
					player.status = "slowwalk"
				end
			elseif player.data.duck then
				if player.canSlide and ( player.xv > 0.6 or player.xv < -0.6 ) then
					player.status = "slide"
				elseif player.canDuck then
					player.status = "duck"
				else
					player.status = "idle"
				end
			else
				player.status = "idle"
			end
		elseif player.data.w then
			if input.moveUp and player.yv <= -0.5 then
				player.status = "wallrun"
			else
				player.status = "wall"
			end
		else
			if player.hasUpJump and player.yv < -0.1 then
				player.status = "jumpu"
			elseif player.xv > -0.75 and player.xv < 0.75 then
				player.status = "jump"
			elseif player.hasFrontJump and ( ( player.xv > 0 and player.dir > 0 ) or ( player.xv < 0 and player.dir < 0 ) ) then
				player.status = "jumpf"
			elseif player.hasBackJump and ( ( player.xv < 0 and player.dir > 0 ) or ( player.xv > 0 and player.dir < 0 ) ) then
				player.status = "jumpb"
			else
				player.status = "jump"
			end
		end
	end

	-- Scripts attached to the player
	if player.scripts.always then player.scripts.always(player) end
	if player.scripts[player.status] then player.scripts[player.status](player) end

	if player.anim:update(player.status) then
		player.data.updateAnim = true
	end

	if levels.script then
		if roundm(levels.weatherSpeed,10) == levels.toWeatherSpeed then
			levels.toWeatherSpeed = math.random(-7,7) / 10
		else
			levels.weatherSpeed = levels.weatherSpeed + 0.01*(levels.toWeatherSpeed - levels.weatherSpeed)
		end

		levels.script()
	end

	if tileAnim then
		tileAnim:update()
		for k,v in pairs(tileAnim.quads) do
			tileData[k].q = v
		end
	end

	-- Main Particle Simulation
	if player.data.g and not player.pdata.g then
		partSystem:spawnParticles("dust",player.pdata.yv*2.5,player.x-1,player.y+7,4,1)
		sound.hitground:play(player.x,player.y+7)
		sound.hitground:setVolume((player.pdata.yv/4)^2)
	elseif player.data.w then
		if not player.pdata.w then
			if player.pdata.xv > 0 then
				partSystem:spawnParticles("dustWR",player.pdata.xv*2.5,player.x+5,player.y,0,7)
			elseif player.pdata.xv < 0 then
				partSystem:spawnParticles("dustWL",-player.pdata.xv*2.5,player.x-7,player.y,0,7)
			end
			sound.hitground:play(player.x,player.y)
			sound.hitground:setVolume((player.pdata.xv/4)^2)
		elseif player.yv <= -1 or player.yv >= 1 then
			if player.dir > 0 then
				partSystem:spawnParticles("dustWR",math.abs(player.yv),player.x+5,player.y,0,7)
			elseif player.dir < 0 then
				partSystem:spawnParticles("dustWL",math.abs(player.yv),player.x-7,player.y,0,7)
			end
		end
	end

	partSystem:update()

	-- Scrolling
	if not player.freezeDeath then
		screen.toX = math.min(math.max(player.x + player.xv*60/screen.scale,0),levels.width*9)
		screen.toY = math.min(math.max(player.y + player.yOff + player.yv*30/screen.scale,0),levels.height*9)
	end
	screen.x = roundm(screen.x + (screen.toX - screen.x)*0.025*screen.scale,5)
	screen.y = roundm(screen.y + (screen.toY - screen.y)*0.025*screen.scale,5)
	if screen.x < 0 then
		screen.x = 0
	elseif screen.x > levels.width*9 then
		screen.x = levels.width*9
	end
	if screen.y < 0 then
		screen.y = 0
	elseif screen.y > levels.height*9 then
		screen.y = levels.height*9
	end

	-- Other
	player.pdata.g = player.data.g
	player.pdata.m = player.data.m
	player.pdata.w = player.data.w
	player.pdata.xv = player.xv
	player.pdata.yv = player.yv
	player.pdata.duck = player.data.duck

	-- Level Finished
	if finish then
		if finish.finished then
			if finish.id then
				local cfinishid = finish.id
				local ccollect = levels.currentCollect
				if savedata.collectLvl[cfinishid] < ccollect then
					savedata.collect = savedata.collect + ccollect - savedata.collectLvl[cfinishid]
					savedata.collectLvl[cfinishid] = ccollect
				end
				if savedata.collect >= 708 then
					trophy.give("master_collector")
				end
			end
			-- Saving data
			if not noSave and finish.to ~= levels.current then
				savedata.hub = levels.latestHub

				sendSave("Save Data","sav.bin",savedata)
			end
			-- Saving data end
			levels.set(finish.to or levels.latestHub,true)
			partSystem:spawnParticles("finish",1,player.x,player.y,0,0)
			partSystem:spawnParticles("confetti",80,player.x,player.y,9,9)
		end
	end
	-- Warp Doors
	if warpto then
		sound.attack:stop()
		if warpto.to ~= "none" then
			local isHub,wasHub = levels.set(warpto.to)
			if isHub and wasHub and not noSave then
				savedata.hub = levels.latestHub

				sendSave("Save Data","sav.bin",savedata)
			end
		end
		if warpto.x and warpto.y then
			player.x = warpto.x*9
			player.y = warpto.y*9
			screen.x = player.x
			screen.y = player.y
		end
	end

	-- Screen Rumble
	if screen.rumble > 0 then
		screen.x = screen.x + math.random(-screen.rumble/10,screen.rumble/10)
		screen.y = screen.y + math.random(-screen.rumble/10,screen.rumble/10)
		screen.rumble = screen.rumble - 1
	end

	if gameTimer then gameTimer = gameTimer + 1 end

	if input.pause then
		-- Trigger Pause Menu
		if player.freezeDeath then
			player.freeze = 1
		else
			if levels.current == levels.latestHub then
				menus.load("pauseH","pause")
			else
				menus.load("pause","pause")
			end
			sound.select:play()
		end
	elseif input.select then
		if levels.changedPlayer then
			sound.destroy:play()
		else
			-- Open Player Selection
			menus.updatePlayerList(true)
			menus.load("playerselect-1","pause") menus.selection = #menu.t menus.drawSelection = #menu.t
			sound.select:play()
		end
	elseif prKeys.escape then
		-- Trigger Help Menu
		help.load()
		sound.select:play()
	end
end
