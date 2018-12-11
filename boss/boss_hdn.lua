local bullets = {}

local function firebullet(x,y)
	local tox = player.x + math.random(-10,10)/2
	local toy = player.y + math.random(-10,10)/2

	local dist = distance(x,y,tox,toy)

	sound.swing:play(x,y)

	table.insert(bullets,{
		x = x,
		y = y,
		xv = (tox-x)/dist * 5,
		yv = (toy-y)/dist * 5,
		dir = math.atan2(toy-y,tox-x),
		life = 180
	})
end

local lightning = {}
local function createlightning(x)
	table.insert(lightning,{
		x = x,
		sprite = math.random(1,5),
		timer = 60
	})
end

local graphic = love.graphics.newImage("assets/boss/arfoire.png")
local w,h = graphic:getDimensions()

local bulletquad = love.graphics.newQuad(119,0,9,9,w,h)
local lightningquad = {
	love.graphics.newQuad(83,9,9,119,w,h),
	love.graphics.newQuad(92,9,9,119,w,h),
	love.graphics.newQuad(101,9,9,119,w,h),
	love.graphics.newQuad(110,9,9,119,w,h),
	love.graphics.newQuad(119,9,9,119,w,h),
}

local purpleAttack = 0

local boss = {
	hp = 100,
	php = 6,
	x = 184,
	y = 90,
	xv = 0,
	yv = 0,
	var = 0,
	status = "idle",
	dir = 1,
	hurt = 0,
	purple = 180,
	d = { hp = 100, php = 6, x = 184, y = 90, xv = 0, yv = 0, var = 0, status = "idle", purple = 180, hurt = 0 },
	anim = anim.newAnimHead(graphic,25,25)
		:addAnim("idle",{1,1,1})
		:addAnim("for",{1,2,1})
		:addAnim("back",{1,3,1})
		:addAnim("attack1",{1,1,2})
		:addAnim("attack2",{1,2,2})
		:addAnim("hurt",{1,1,3},{6,2,3},{11,"loop"}),
	reset = function()
		bullets = {}
		lightning = {}
		purpleAttack = 0
	end,
	update = function()
		local distance = distance

		local dist = distance(boss.x,boss.y,player.x,player.y)
		if dist > 150 then
			boss.xv = boss.xv + (player.x - boss.x) * (0.15 / dist)
			boss.yv = boss.yv + (player.y - boss.y) * (0.15 / dist)
		elseif dist < 140 then
			boss.xv = boss.xv + (boss.x - player.x) * (.05 / dist)
			boss.yv = boss.yv + (boss.y - player.y) * (.05 / dist)
		end

		if boss.y > 385 then
			boss.yv = boss.yv - 0.1
			boss.xv = boss.xv + (player.x > boss.x and -.1 or .1)
		end

		boss.var = boss.var + 1
		if boss.status == "idle" then
			boss.xv = boss.xv * 0.985
			boss.yv = boss.yv * 0.985

			if (boss.xv > 0.7 and boss.dir > 0) or (boss.xv < -0.7 and boss.dir < 0) then
				boss.anim:update("for")
			elseif (boss.xv < -0.7 and boss.dir > 0) or (boss.xv > 0.7 and boss.dir < 0) then
				boss.anim:update("back")
			else
				boss.anim:update("idle")
			end

			if boss.var > 120 then
				boss.var = 0
				local r = math.random(1,2)
				if r == 1 then
					boss.status = "fire"
				elseif r == 2 then
					boss.status = "create"
				end
			end
		elseif boss.status == "fire" then
			boss.xv = boss.xv * 0.87
			boss.yv = boss.yv * 0.87

			boss.anim:update("attack1")

			if boss.var % 4 == 0 then
				firebullet(boss.x,boss.y+13)
			end

			if boss.var > 60 then
				boss.var = 0
				boss.status = "idle"
			end
		elseif boss.status == "create" then
			boss.xv = boss.xv * 0.87
			boss.yv = boss.yv * 0.87

			boss.anim:update("attack2")

			if boss.var % 8 == 0 then
				createlightning(player.x+math.random(-90,90))
			end

			if boss.var > 60 then
				boss.var = 0
				boss.status = "idle"
			end
		elseif boss.status == "hurt" then
			boss.xv = boss.xv * 0.995
			boss.yv = boss.yv * 0.995
			boss.anim:update("hurt")

			if boss.var > 60 then
				boss.status = "idle"
			end
		elseif boss.status == "death" then
			if boss.var % 10 == 0 then
				boss.anim:update("hurt")
				boss.xv = math.random(-20,20)/10
				boss.yv = math.random(-10,0)/10

				partSystem:spawnParticles("bloodN",2,boss.x,boss.y+12,4,6)

				sound.death:play(boss.x,boss.y)
			end

			if boss.var > 180 then
				local x,y = boss.x,boss.y
				sound.smallexplode:play(x,y)

				partSystem:spawnParticles("bloodN",20,x,y+12,4,6)
				partSystem:spawnParticles("dust",40,x,y+12,5,12)

				boss = love.filesystem.load("boss/dynamic_collect.lua")()
				boss.init(41,31,x,y)

				finish.x = 35 finish.y = 44+8/9
				return
			end
		end

		if colide(player.attackBox.x-player.attackBox.w/2,player.attackBox.y-player.attackBox.h/2,player.attackBox.w,player.attackBox.h,boss.x-9,boss.y,17,25) and player.attack > -2 then
			if boss.hurt <= 0 then
				sound.death:play(boss.x,boss.y)
			end
			boss.hurt = player.attack + 3

			boss.xv = boss.xv + player.dir

			boss.hp = boss.hp - 1

			partSystem:spawnParticles("bloodN",2,boss.x,boss.y+12,4,6)

			if boss.hp <= 0 and boss.status ~= "death" then
				boss.status = "death"
				boss.var = 0
			end
		elseif boss.hurt > 0 then
			boss.hurt = boss.hurt - 1
		end

		boss.x = boss.x + boss.xv
		boss.y = boss.y + boss.yv

		boss.dir = player.x >= boss.x and 1 or -1

		for i,v in pairs(bullets) do
			v.x = v.x + v.xv
			v.y = v.y + v.yv

			if colide(v.x-3,v.y-3,6,6,player.x+player.hitBox.xo,player.y+player.hitBox.yo,player.hitBox.w,player.hitBox.h) then
				v.life = 0

				player.xv = player.xv + v.xv
				player.yv = player.yv + v.yv

				sound.death:play(player.x,player.y)

				boss.php = boss.php - 1
				partSystem:spawnParticles("blood",5,player.x,player.y+12,4,6)
				if boss.php <= 0 then
					player.actuallyDie = true
				end
			end

			v.life = v.life - 1
			if v.life <= 0 then
				bullets[i] = nil
			end
		end

		for i,v in pairs(lightning) do
			if v.timer <= 0 then
				lightning[i] = nil
				sound.smash:play(v.x,player.y)

				if v.x - 8 < player.x+4 and player.x-4 < v.x + 8 then
					sound.death:play(player.x,player.y)

					player.yv = player.yv + 2
					player.xv = player.xv + (player.x - v.x)

					boss.php = boss.php - 2
					partSystem:spawnParticles("blood",10,player.x,player.y+12,4,6)
					if boss.php <= 0 then
						player.actuallyDie = true
					end
				end
			end

			v.timer = v.timer - 1
			if v.timer >= 30 then
				partSystem:spawnParticles("smoke",8,v.x,screen.y,0,winH)
			end
		end

		if boss.hp > 0 then
			boss.purple = boss.purple - 1
			if boss.purple <= 0 then
				if math.random(1,10) <= 4 then
					purpleAttack = 10
					sound.attack:play(boss.x,boss.y)
					sound.death:play(boss.x,boss.y)

					if math.random(1,2) == 1 then
						boss.xv = boss.xv + 4
					else
						boss.xv = boss.xv - 4
					end

					boss.hp = boss.hp - 5
					partSystem:spawnParticles("bloodN",10,boss.x,boss.y+12,4,6)

					boss.var = 0
					if boss.hp <= 0 then
						boss.status = "death"
						boss.var = 0
					else
						boss.status = "hurt"
					end
					boss.purple = 240
				else
					boss.purple = 180
				end
			elseif purpleAttack > 0 then
				purpleAttack = purpleAttack - 1
			end
		elseif purpleAttack > 0 then
			purpleAttack = purpleAttack - 1
		end
	end,
	drawBG = function()
		local roundm = roundm
		for i,v in pairs(bullets) do
			love.graphics.draw(graphic,bulletquad,roundm(v.x,screen.scale),roundm(v.y,screen.scale),v.dir,1,1,4,4)
		end
		local screentop = screen.y-math.ceil(vWinH/2)
		local lscale = vWinH/119
		for i,v in pairs(lightning) do
			if v.timer <= 0 then
				love.graphics.setColor(255,255,255,255)
				love.graphics.draw(graphic,lightningquad[v.sprite],v.x-13,screentop,0,3,lscale)
			else
				local c = (60-v.timer)*4.25
				love.graphics.setColor(c,c,c,c*.2)
				love.graphics.rectangle("fill",v.x-8,screen.y-math.ceil(vWinH/2),16,vWinH)
			end
		end
		love.graphics.setColor(255,255,255)
	end,
	draw = function()
		boss.anim:draw(roundm(boss.x,screen.scale),roundm(boss.y,screen.scale),0,boss.dir,1,13,0)

		if purpleAttack > 0 then
			love.graphics.setColor(118,29,165,25.5*purpleAttack)
			love.graphics.rectangle("fill",screen.x-math.ceil(vWinW/2),boss.y+2,vWinW+1,20)
			love.graphics.setColor(255,255,255)
		end
	end,
	drawHud = function(tx,ty)
		if boss.hp < 0 then
			boss.hp = 0
		end
		if boss.php < 0 then
			boss.php = 0
		end

		local bl = boss.hp*.5
		love.graphics.setColor(255,0,0,140)
		love.graphics.rectangle("fill",boss.x-25+tx,boss.y+27+ty,bl,5)
		love.graphics.setColor(64,10,10,140)
		love.graphics.rectangle("fill",boss.x-25+tx+bl,boss.y+27+ty,50-bl,5)

		local pl = boss.php*6
		love.graphics.setColor(0,255,0,140)
		love.graphics.rectangle("fill",player.x-18+tx,player.y+17+ty,pl,5)
		love.graphics.setColor(10,64,10,140)
		love.graphics.rectangle("fill",player.x-18+tx+pl,player.y+17+ty,36-pl,5)

		love.graphics.setColor(255,255,255)
	end
}

return boss
