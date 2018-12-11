local graphic = love.graphics.newImage("assets/boss/dj.png")
local dj = anim.newAnimHead(graphic,12,20)
	:addAnim("idle",{1,1,1})
	:addAnim("hurt",{1,2,1},{11,3,1},{21,"loop"})

local laser = love.graphics.newQuad(37,0,9,50,276,250)
local dir

local lastVul = 0

local boss = {
	anim = anim.newAnimHead(graphic,46,50)
		:addAnim("hurt",{1,2,1},{6,3,1},{11,"loop"})
		:addAnim("idle",{1,1,2},{6,2,2},{11,3,2},{16,4,2},{21,5,2},{31,"loop"})
		:addAnim("att1",{1,1,3},{6,2,3},{11,3,3},{16,4,3},{21,5,3},{26,6,3},{31,"end"})
		:addAnim("att2",{1,1,4},{6,2,4},{11,3,4},{16,4,4},{21,5,4},{26,6,4})
		:addAnim("att3",{1,1,5},{6,2,5},{11,3,5},{16,4,5},{21,5,5},{26,6,5},{31,"end"}),
	x = 225,
	y = 225,
	hp = 12,
	var = 0,
	hurttime = 0,
	status = "idle",
	d = {
		x = 225,
		y = 225,
		hp = 12,
		var = 0,
		hurttime = 0,
		status = "idle"
	},
	reset = function()
		dj:update("idle")
	end,
	update = function()
		dj:update()

		-- Player attack
		if colide(player.attackBox.x-player.attackBox.w/2,player.attackBox.y-player.attackBox.h/2,player.attackBox.w,player.attackBox.h,boss.x-23,boss.y-25,46,50) and player.attack > 0 and boss.hurttime <= 0 then
			boss.hurttime = 60
			boss.hp = boss.hp - 1
			if player.x > boss.x then player.xv = 14 else player.xv = -14 end

			partSystem:spawnParticles("smoke",50,boss.x,boss.y,23,25)
			if boss.hp <= 0 then
				boss.var = 0
				boss.yv = -4
				boss.xv = math.random(-2,2)

				boss.status = "dead"
				sound.explode:play(boss.x,boss.y)
				partSystem:spawnParticles("smokeLarge",100,boss.x,boss.y,23,25)

				-- "No(-Save) RIPs for you" Trophy
				if noSave and savedata.ripCount == 0 then
					trophy.give("no_death")
				end

				dj:update("hurt")
			else
				partSystem:spawnParticles("smoke",150,boss.x,boss.y,23,25)
				sound.smallexplode:play(boss.x,boss.y)
			end
		end

		if boss.hurttime > 0 then
			boss.hurttime = boss.hurttime - 1
		end

		if boss.status == "idle" then
			-- Idle
			boss.var = boss.var + 1

			boss.x = boss.x + 0.05 * (player.x - boss.x)
			boss.y = boss.y + 0.1 * (225 - boss.y)

			boss.anim:update("idle")

			if boss.var > 60 then
				local r = math.random(1,3)
				if r == 1 then
					boss.status = "att1"
					lastVul = 0
				elseif r == 2 then
					if lastVul > 2 then
						boss.status = "att1"
						lastVul = 0
					else
						boss.status = "att2"
						lastVul = lastVul + 1
					end
				elseif r == 3 then
					boss.status = "att3"
					lastVul = 0
				end

				boss.var = 0
			end
		elseif boss.status == "att1" then
			-- Stomping attack
			local animend = boss.anim:update("att1")

			if colide(player.x+player.hitBox.xo,player.y+player.hitBox.yo,player.hitBox.w,player.hitBox.h,boss.x-23,boss.y-25,46,50) then
				if boss.var == 1 then player.actuallyDie = true end
				player.yv = -9
				if player.x > boss.x then player.xv = 30 else player.xv = -30 end
			end

			if boss.var == 1 then
				boss.y = boss.y + 7
				partSystem:spawnParticles("dust",5,boss.x,boss.y+25,23,2)

				if boss.y >= 363 then
					boss.y = 363
					boss.var = 2

					partSystem:spawnParticles("dust",30,boss.x,boss.y+25,23,2)
					sound.smash:play(boss.x+23,boss.y+50)
					screen.rumble = 30
					dj:update("hurt")
				end
			elseif boss.var > 1 and boss.var < 60 then
				boss.var = boss.var + 1
			elseif boss.var == 60 then
				boss.y = boss.y - 4
				if boss.y <= 225 then
					boss.y = 225
					boss.var = 0
					boss.status = "idle"

					dj:update("idle")
				end
			elseif animend then
				boss.var = 1
			else
				boss.x = boss.x + 0.2 * (player.x - boss.x)
			end
		elseif boss.status == "att2" then
			-- Laser attack
			local animend = boss.anim:update("att2")

			if boss.var == 0 then
				if boss.x > 225 then
					dir = 4
				else
					dir = -4
				end

				boss.var = 1
			elseif boss.var == 1 then
				boss.x = boss.x + dir*1.5
				if boss.x <= 36 or boss.x >= 414 then
					if boss.x <= 36 then boss.x = 36 else boss.x = 414 end

					if boss.anim.frame > 30 then
						boss.var = 2

						dj:update("hurt")
					end
				end
			elseif boss.var == 2 then
				boss.x = boss.x - dir

				if colide(player.x+player.hitBox.xo,player.y+player.hitBox.yo,player.hitBox.w,player.hitBox.h,boss.x-9,boss.y+25,18,128) then
					player.xv = player.x - boss.x
					player.actuallyDie = true
				end

				partSystem:spawnParticles("dust",5,boss.x,boss.y+153,9,2)
				if boss.x%10 < 2 then
					sound.smallexplode:play(boss.x,boss.y+153)
				end

				if boss.x <= 36 or boss.x >= 414 then
					if boss.x <= 36 then boss.x = 36 else boss.x = 414 end
					boss.var = 0
					boss.status = "idle"

					dj:update("idle")
				end
			end
		elseif boss.status == "att3" then
			-- Something?
			local animend = boss.anim:update("att3")

			boss.x = boss.x + 0.05 * (player.x - boss.x)
			boss.y = boss.y + 0.05 * (player.y - boss.y)

			if animend then
				sound.smallexplode:play()
				partSystem:spawnParticles("smoke",150,225,378,225,9)

				if colide(player.x+player.hitBox.xo,player.y+player.hitBox.yo,player.hitBox.w,player.hitBox.h,0,374,450,18) then
					player.yv = -9
					player.actuallyDie = true
				end

				boss.var = 0
				boss.status = "idle"
			end
		elseif boss.status == "dead" then
			-- DED
			boss.x = boss.x + boss.xv
			boss.y = boss.y + boss.yv

			partSystem:spawnParticles("smoke",1,boss.x,boss.y-10,6,10)

			boss.yv = boss.yv + 0.1

			if boss.y > 600 then
				boss = love.filesystem.load("boss/dynamic_collect.lua")()
				boss.init(41,42,225,255)

				finish.x = 44
				finish.y = 42
				return
			end
		end
	end,
	drawBG = function()
		if boss.status == "att2" and boss.var == 2 then
			love.graphics.draw(graphic,laser,boss.x-9,boss.y+25,0,2,2.56)
		end
	end,
	draw = function()
		dj:draw(boss.x,boss.y-10,0,player.x > boss.x and 1 or -1,1,6,10)
		if boss.status ~= "dead" then
			boss.anim:draw(boss.x,boss.y,0,1,1,23,25)
		end

		if boss.status == "att3" then
			love.graphics.setColor(0,94,255,80)
			love.graphics.rectangle("fill",0,374,450,18)
			love.graphics.setColor(255,255,255,255)
		end
	end
}

boss.anim:update()

return boss
