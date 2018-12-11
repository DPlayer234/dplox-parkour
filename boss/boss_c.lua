local bossimg = love.graphics.newImage("assets/boss/ancient.png")
bossimg:setWrap("mirroredrepeat","mirroredrepeat")

local boss = {
	baseanim = anim.newAnimHead(bossimg,90,90),
	leftanim = anim.newAnimHead(bossimg,45,45),
	rightanim = anim.newAnimHead(bossimg,45,45),
	headanim = anim.newAnimHead(bossimg,54,54),
	base = { x=90,y=288,status="idle" },
	left = { x=18,y=282,status="vert" },
	right = { x=216,y=282,status="vert" },
	head = { x=118,y=252,status="idle" },
	hp = 10,
	hurttime = 0,
	status = "idle",
	var = 0,
	d = {
		base = { x=90,y=288,status="idle" },
		left = { x=18,y=282,status="vert" },
		right = { x=216,y=282,status="vert" },
		head = { x=118,y=252,status="idle" },
		hp = 10,
		hurttime = 0,
		status = "idle",
		var = 0,
	},

	update = function()
		local hurt = false
		if boss.hp > 0 then
			if boss.hurttime > 0 then
				hurt = true
				boss.hurttime = boss.hurttime-1
			elseif colide(player.attackBox.x-player.attackBox.w/2,player.attackBox.y-player.attackBox.h/2,player.attackBox.w,player.attackBox.h,boss.head.x,boss.head.y,54,54) and player.attack > 0 then
				boss.hurttime = 30
				partSystem:spawnParticles("snow",70,boss.base.x+45,boss.base.y+18,45,72)
				boss.hp = boss.hp - 1
				sound.smallexplode:play(boss.head.x+27,boss.head.y+34)
				if boss.hp <= 0 then
					partSystem:spawnParticles("snow",200,boss.base.x+45,boss.base.y+18,45,72)
					boss.status = "dead"
					boss.head.yv = -2
					boss.head.xv = 0
					boss.left.yv = -2
					boss.right.yv = -2
					boss.base.x = 2000
				end
			end
		elseif colide(player.attackBox.x-player.attackBox.w/2,player.attackBox.y-player.attackBox.h/2,player.attackBox.w,player.attackBox.h,boss.head.x,boss.head.y,54,54) and player.attack > 0 then
			boss.head.yv = -2
			boss.head.xv = player.dir-player.xv
		end

		if boss.status == "dead" then
			boss.head.x = boss.head.x + boss.head.xv
			boss.head.y = boss.head.y + boss.head.yv
			boss.left.y = boss.left.y + boss.left.yv
			boss.right.y = boss.right.y + boss.right.yv

			boss.head.yv = boss.head.yv + 0.15
			boss.left.yv = boss.left.yv + 0.1
			boss.right.yv = boss.right.yv + 0.1

			if boss.head.y > 900 then
				boss = love.filesystem.load("boss/dynamic_collect.lua")()
				boss.init(55,10,135,185)

				finish.x = 27
				finish.y = 43
				return
			end
		else
			-- Base
			boss.baseanim:update(boss.base.status..(hurt and "hurt" or ""))
			if boss.status == "idle" then
				local n = math.random(1,30)
				boss.var = 0
				if n == 1 then
					if boss.left.y-9 < boss.d.left.y and boss.right.y-9 < boss.d.right.y then
						boss.status = "squish"
					else
						boss.status = "qsquish"
					end
				elseif n == 2 and boss.left.y-9 < boss.d.left.y then
					boss.status = "crushleft"
				elseif n == 3 and boss.right.y-9 < boss.d.right.y then
					boss.status = "crushright"
				end
			elseif boss.status == "qsquish" then
				if boss.left.y-9 < boss.d.left.y and boss.right.y-9 < boss.d.right.y then
					boss.status = "squish"
				end
			end
			-- Head
			boss.headanim:update(boss.head.status..(hurt and "hurt" or ""))

			-- Squish stuff
			if boss.status == "squish" then
				boss.leftanim:update("hori"..(hurt and "hurt" or ""))
				boss.rightanim:update("hori"..(hurt and "hurt" or ""))
				if boss.var < 60 then
					boss.var = boss.var + 1
					boss.left.x = boss.left.x + 0.1*(player.x-112 - boss.left.x)
					boss.right.x = boss.right.x + 0.1*(player.x+68 - boss.right.x)
				elseif boss.var == 60 then
					if boss.left.y < 334 then
						boss.left.y = boss.left.y + 3 + 10/boss.hp
						if colide(player.x+player.hitBox.xo,player.y+player.hitBox.yo,player.hitBox.w,player.hitBox.h,boss.left.x,boss.left.y,45,45) then
							player.yv = 9
							player.actuallyDie = true
						end
						if boss.left.y >= 334 then
							boss.left.y = 334
							partSystem:spawnParticles("dust",30,boss.left.x+23,boss.left.y+45,23,2)
							sound.smash:play(boss.left.x+45,boss.left.y+27)
							screen.rumble = screen.rumble + 30
						end
					end
					if boss.right.y < 334 then
						boss.right.y = boss.right.y + 3 + 10/boss.hp
						if colide(player.x+player.hitBox.xo,player.y+player.hitBox.yo,player.hitBox.w,player.hitBox.h,boss.right.x,boss.right.y,45,45) then
							player.yv = 9
							player.actuallyDie = true
						end
						if boss.right.y >= 334 then
							boss.right.y = 334
							partSystem:spawnParticles("dust",30,boss.right.x+23,boss.right.y+45,23,2)
							sound.smash:play(boss.right.x,boss.right.y+27)
							screen.rumble = screen.rumble + 30
						end
					end
					if boss.left.y >= 334 and boss.right.y >= 334 then
						boss.var = 61
					end
				elseif boss.var == 61 then
					boss.left.x = boss.left.x + 2 + 5/boss.hp
					boss.right.x = boss.right.x - 2 - 5/boss.hp
					if colide(player.x+player.hitBox.xo,player.y+player.hitBox.yo,player.hitBox.w,player.hitBox.h,boss.left.x,boss.left.y,45,45) then
						player.xv = 3
						player.actuallyDie = true
					elseif colide(player.x+player.hitBox.xo,player.y+player.hitBox.yo,player.hitBox.w,player.hitBox.h,boss.right.x,boss.right.y,45,45) then
						player.xv = -3
						player.actuallyDie = true
					end
					if boss.left.x + 22 >= boss.right.x - 22 then
						partSystem:spawnParticles("dust",30,boss.right.x,boss.right.y+22,2,23)
						sound.smash:play(boss.right.x,boss.right.y+22)
						boss.var = 62
					end
				else
					boss.status = "idle"
				end
			end

			-- Left Hand
			if boss.status == "crushleft" then
				boss.leftanim:update("vert"..(hurt and "hurt" or ""))
				if boss.var < 60 then
					boss.var = boss.var + 1
					boss.left.x = boss.left.x + 0.3*(player.x-15 - boss.left.x)/boss.hp
				elseif boss.var == 60 then
					boss.var = 61
					boss.left.yv = -4
				elseif boss.var < 62 then
					boss.left.yv = boss.left.yv + 0.4 + 1/boss.hp
					boss.left.y = boss.left.y + boss.left.yv
					if colide(player.x+player.hitBox.xo,player.y+player.hitBox.yo,player.hitBox.w,player.hitBox.h,boss.left.x,boss.left.y,32,45) then
						player.yv = 9
						player.actuallyDie = true
					end
					if boss.left.y >= 334 then
						boss.left.y = 334
						boss.var = 62
						partSystem:spawnParticles("dust",30,boss.left.x+23,boss.left.y+45,23,2)
						sound.smash:play(boss.left.x+23,boss.left.y+45)
						screen.rumble = screen.rumble + 30
					end
				else
					boss.status = "idle"
				end
			elseif boss.status ~= "squish" then
				boss.left.x = boss.left.x + 0.02*(boss.base.x-65 - boss.left.x)
				boss.left.y = boss.left.y + 0.07*(boss.d.left.y - boss.left.y)
				boss.leftanim:update("vert"..(hurt and "hurt" or ""))
			end

			-- Right Hand
			if boss.status == "crushright" then
				boss.rightanim:update("vert"..(hurt and "hurt" or ""))
				if boss.var < 60 then
					boss.var = boss.var + 1
					boss.right.x = boss.right.x + 0.3*(player.x-30 - boss.right.x)/boss.hp
				elseif boss.var == 60 then
					boss.var = 61
					boss.right.yv = -4
				elseif boss.var < 62 then
					boss.right.yv = boss.right.yv + 0.4 + 1/boss.hp
					boss.right.y = boss.right.y + boss.right.yv
					if colide(player.x+player.hitBox.xo,player.y+player.hitBox.yo,player.hitBox.w,player.hitBox.h,boss.right.x+13,boss.right.y,32,45) then
						player.yv = 9
						player.actuallyDie = true
					end
					if boss.right.y >= 334 then
						boss.right.y = 334
						boss.var = 62
						partSystem:spawnParticles("dust",30,boss.right.x+23,boss.right.y+45,23,2)
						sound.smash:play(boss.right.x+23,boss.right.y+45)
						screen.rumble = screen.rumble + 30
					end
				else
					boss.status = "idle"
				end
			elseif boss.status ~= "squish" then
				boss.right.x = boss.right.x + 0.02*(boss.base.x+110 - boss.right.x)
				boss.right.y = boss.right.y + 0.07*(boss.d.right.y - boss.right.y)
				boss.rightanim:update("vert"..(hurt and "hurt" or ""))
			end

			-- Base Movement
			boss.base.x = boss.base.x + 0.1*((boss.left.x+boss.right.x)/2 - boss.base.x-22.5)
			if boss.base.x < 0 then
				boss.base.x = 0
			elseif boss.base.x > 180 then
				boss.base.x = 180
			end
			boss.head.x,boss.head.y = boss.base.x+18,boss.base.y-36

		end
	end,

	draw = function()
		boss.headanim:draw(roundm(boss.head.x,screen.scale),roundm(boss.head.y,screen.scale))
		boss.leftanim:draw(roundm(boss.left.x,screen.scale),roundm(boss.left.y,screen.scale))
		boss.rightanim:draw(roundm(boss.right.x,screen.scale),roundm(boss.right.y,screen.scale))
	end,
	drawBG = function()
		boss.baseanim:draw(roundm(boss.base.x,screen.scale),roundm(boss.base.y,screen.scale))
	end
}
boss.baseanim:addAnim("idle",{1,2,1})
boss.baseanim:addAnim("idlehurt",{1,3,1},{6,2,1},{11,"loop"})
boss.headanim:addAnim("idle",{1,1,3})
boss.headanim:addAnim("idlehurt",{1,2,3},{6,1,3},{11,"loop"})
	boss.leftanim:addAnim("vert",{1,0,1})
	boss.leftanim:addAnim("verthurt",{1,0,2},{6,0,1},{11,"loop"})
	boss.leftanim:addAnim("hori",{1,-1,1})
	boss.leftanim:addAnim("horihurt",{1,-1,2},{6,-1,1},{11,"loop"})
boss.rightanim:addAnim("vert",{1,1,1})
boss.rightanim:addAnim("verthurt",{1,1,2},{6,1,1},{11,"loop"})
boss.rightanim:addAnim("hori",{1,2,1})
boss.rightanim:addAnim("horihurt",{1,2,2},{6,2,1},{11,"loop"})
	boss.baseanim:update("idle")
	boss.headanim:update("idle")
	boss.leftanim:update("vert")
	boss.rightanim:update("vert")

return boss
