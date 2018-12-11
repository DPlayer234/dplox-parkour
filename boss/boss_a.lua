local bossrise = function(_a)
	if boss.var < 60 then
		boss.var = boss.var + 1
		boss.anim:update("weak")
		partSystem:spawnParticles("dust",1,boss.x+23,boss.y+28,23,18)
	elseif boss.y > 209 then
		boss.y = boss.y - 2
		boss.anim:update(_a)
	else
		boss.status = "idle"
		boss.var = 0
	end
end

local bar = { {255,0,0},"",{0,0,0},"" }

local boss = {
	anim = anim.newAnimHead(love.graphics.newImage("assets/boss/press.png"),46,50),
	x = 135,
	y = 209,
	var = 0,
	hp = 5,
	d = {x=135,y=209,var=0,hp=5,status="idle"},
	status = "idle",
	update = function()
		if boss.status == "idle" then
			if player.x > boss.x+26 then
				boss.x = boss.x + (6-boss.hp)/2
				if not (player.x > boss.x+26) then
					boss.x = player.x-26
				end
			elseif player.x < boss.x+20 then
				boss.x = boss.x - (6-boss.hp)/2
				if not (player.x < boss.x+20) then
					boss.x = player.x-20
				end
			elseif boss.var < 120 then
				boss.var = boss.var + 1
			else
				boss.status = "attack"
				boss.var = 0
			end
			boss.anim:update("n")
		elseif boss.status == "attack" then
			if boss.var < boss.hp*4+5 then
				boss.var = boss.var + 1
			elseif boss.y < 329 then
				boss.y = boss.y + 5
				partSystem:spawnParticles("dust",5,boss.x+23,boss.y+50,23,2)
			else
				partSystem:spawnParticles("dust",30,boss.x+23,boss.y+50,23,2)
				boss.status = "rise"
				sound.smash:play(boss.x+23,boss.y+50)
				screen.rumble = 30
				boss.var = 0
			end
			if colide(player.x+player.hitBox.xo,player.y+player.hitBox.yo,player.hitBox.w,player.hitBox.h,boss.x,boss.y,46,50) then
				player.actuallyDie = true
			end
			boss.anim:update("atta")
		elseif boss.status == "rise" then
			bossrise("n")
			if colide(player.attackBox.x-player.attackBox.w/2,player.attackBox.y-player.attackBox.h/2,player.attackBox.w,player.attackBox.h,boss.x,boss.y,46,50) and player.attack > 0 and not player.freezeDeath then
				if player.x > boss.x + 23 then player.xv = 14 else player.xv = -14 end
				boss.hp = boss.hp - 1
				boss.var = 60
				partSystem:spawnParticles("smoke",50,boss.x+23,boss.y+25,23,25)
				if boss.hp <= 0 then
					boss.status = "dead"
					sound.explode:play(boss.x+23,boss.y+25)
				else
					boss.status = "rise2"
					sound.smallexplode:play(boss.x+23,boss.y+25)
				end
			end
		elseif boss.status == "rise2" then
			bossrise("hurt")
		elseif boss.status == "dead" then
			boss.anim:update("dead")
			boss.y = boss.y - 1
			boss.x = boss.x + math.random(-2,2)
			boss.var = boss.var + 1
			partSystem:spawnParticles("smoke",5,boss.x+23,boss.y+25,23,25)
			if boss.var >= 200 then
				local x,y = boss.x,boss.y
				partSystem:spawnParticles("smokeLarge",100,x+23,y+25,23,25)

				boss = love.filesystem.load("boss/dynamic_collect.lua")()
				boss.init(50,5,x+23,y+25)

				if gameTimer then if gameTimer <= 7200 then trophy.give("area1_ace") end end

				finish.x = 27
				finish.y = 43
				return
			end
		end
		if colide(player.x+player.hitBox.xo,player.y+player.hitBox.yo,player.hitBox.w,player.hitBox.h,boss.x,boss.y,46,50) then
			player.yv = -9
			if player.x > boss.x + 23 then player.xv = 30 else player.xv = -30 end
		end
	end,
	draw = function()
		boss.anim:draw(roundm(boss.x,screen.scale),roundm(boss.y,screen.scale))
		if boss.status == "idle" then
			local n = math.ceil(boss.var/15)
			bar[2] = " "..string.rep("! ",n)
			bar[4] = string.rep("! ",8-n)
			love.graphics.printf(bar,boss.x,boss.y+26,46,"center")
		end
	end
}
boss.anim:addAnim("n",{1,1,1})
boss.anim:addAnim("hurt",{1,2,1},{6,1,1},{11,"loop"})
boss.anim:addAnim("atta",{1,3,1},{6,1,1},{11,"loop"})
boss.anim:addAnim("dead",{1,4,1})
boss.anim:addAnim("weak",{1,5,1})

return boss
