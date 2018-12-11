local ptex = love.graphics.newImage("assets/particles.png")
local w,h = ptex:getDimensions()

local empty = function() end
local dustQuad = love.graphics.newQuad(0,0,2,2,w,h)
local smokeQuad = love.graphics.newQuad(6,0,2,2,w,h)

local function dustUpdate(p)
	p.xv = p.xv * 0.9
	p.yv = p.yv - 0.01
	if p.age >= 30 then
		p.kill = true
	elseif p.age >= 15 then
		p.s = p.s * 0.9
	end
end
local function dustInit(p) p.age = 5 p.t = "dust" end
local function dustMoveInit(p)
	if player.xv < 0 then
		p.xv = math.random(math.ceil(player.xv/-10),math.floor(-1*player.xv))/1.5
	else
		p.xv = math.random(math.floor(-1*player.xv),math.ceil(player.xv/-10))/1.5
	end
	p.age = 8
	p.t = "dust"
end

local function grassUpdate(p)
	p.yv = p.yv + 0.015
	if p.age >= 20 then
		p.kill = true
	elseif p.age >= 10 then
		p.s = p.s * 0.9
	end
end
local function grassInit(p)
	if player.xv < 0 then
		p.xv = math.random(math.ceil(player.xv/-10),math.floor(-1*player.xv))/3
	else
		p.xv = math.random(math.floor(-1*player.xv),math.ceil(player.xv/-10))/3
	end
end

local function sandUpdate(p)
	p.xv = p.xv * 0.9
	p.yv = p.yv - 0.01
	if p.age >= 30 then
		p.kill = true
	elseif p.age >= 15 then
		p.s = p.s * 0.9
	end
end
local function sandInit(p)
	if player.xv < 0 then
		p.xv = math.random(math.ceil(player.xv/-10),math.floor(-1*player.xv))/1.5
	else
		p.xv = math.random(math.floor(-1*player.xv),math.ceil(player.xv/-10))/1.5
	end
end

local function finishUpdate(p)
	p.yv = p.yv + 0.1
	if p.age > 180 then
		p.kill = true
	end
end

local function bloodUpdate(p)
	if p.stuck then
		p.s = p.s -0.003
		if p.s < 0.1 then
			p.kill = true
		end
	else
		if p.age > 600 then
			p.kill = true
		else
			p.yv = p.yv + 0.07
			local tx = math.ceil(p.x/9)
			local ty = math.ceil(p.y/9)
			if level[ty] then if level[ty][tx] then if tileData[level[ty][tx]] then if tileData[level[ty][tx]].d.solid then
				p.stuck = true
				p.xv = 0
				p.yv = 0
			end end end end
		end
	end
end
local function bloodInitPlayer(p)
	p.xv = math.random(-40,40)/30+player.xv/2
	p.yv = math.random(-40,40)/30+player.yv/2
	p.s = 1.5
end
local function bloodInit(p) p.s = 1.5 end

local function smokeUpdate(p)
	p.xv = p.xv * 0.9
	p.yv = p.yv - 0.01
	if p.age >= 30 then
		p.kill = true
	elseif p.age >= 15 then
		p.s = p.s * 0.9
	end
end
local function smokeLargeUpdate(p)
	p.xv = p.xv * 0.9
	p.yv = p.yv * 0.9
	if p.age >= 45 then
		p.kill = true
	elseif p.age >= 30 then
		p.s = p.s * 0.9
	end
end
local function smokeInit(p) p.s = 2 end

local function brickUpdate(p)
	if p.age > 60 then
		p.kill = true
	else
		p.yv = p.yv + 0.03
		p.s = p.s * 0.98
	end
end

local function snowUpdate(p)
	p.xv = p.xv * 0.9
	p.yv = p.yv + 0.03
	if p.age >= 50 then
		p.kill = true
	elseif p.age >= 15 then
		p.s = p.s * 0.9
	end
end

local function goldUpdate(p)
	p.xv = p.xv * 0.9
	p.yv = p.yv * 0.9
	p.s = p.s * 0.95
	if p.age > 25 then
		p.kill = true
	end
end

local function confettiUpdate(p)
	p.xv = p.xv * 0.98
	p.yv = p.yv * 0.99 + 0.005
	p.s = p.s * 0.99
	if p.age > 300 then
		p.kill = true
	end
end
local function confettiInit(p)
	local t = math.random(0,2)
	if t == 0 then
		p.t = "confettiRed"
	elseif t == 1 then
		p.t = "confettiGreen"
	else
		p.t = "confettiBlue"
	end
end

local function snowFallUpdate(p)
	if p.age < 10 then
		p.s = p.s + p._
	elseif p.age > 220 then
		p.s = p.s - p._
		if p.s < 0.1 then
			p.kill = true
		end
	end
	p.xv = levels.weatherSpeed*p.yv*2
end
local function snowFallInit(p) p.s = 0 p._ = p.yv/2.5 end

partSystem = anim.newParticleSystem(ptex,200)
	:newParticleType("dust",-1,1,0,.25,dustQuad,dustUpdate)
	:newParticleType("dustWR",-1,0,-.25,.25,dustQuad,empty,dustInit)
	:newParticleType("dustWL",0,1,-.25,.25,dustQuad,empty,dustInit)
	:newParticleType("dustMove",0,0,0,.25,dustQuad,empty,dustMoveInit)

	:newParticleType("grass",0,0,-.4,.1,love.graphics.newQuad(2,0,2,1,w,h),grassUpdate,grassInit)

	:newParticleType("finish",-1,1,-3.5,-3.0,love.graphics.newQuad(0,2,9,9,w,h),finishUpdate)

	:newParticleType("blood",0,0,0,0,love.graphics.newQuad(4,0,1,1,w,h),bloodUpdate,bloodInitPlayer)
	:newParticleType("bloodN",-1.35,1.35,-1.35,1.35,love.graphics.newQuad(4,0,1,1,w,h),bloodUpdate,bloodInit)

	:newParticleType("smoke",-1,1,0,.25,smokeQuad,smokeUpdate,smokeInit)
	:newParticleType("smokeLarge",-8,8,-8,8,smokeQuad,smokeLargeUpdate,smokeInit)

	:newParticleType("sand",0,0,0,.25,love.graphics.newQuad(8,0,2,2,w,h),sandUpdate,sandInit)

	:newParticleType("brick",-.5,.5,-1,.25,love.graphics.newQuad(9,2,3,2,w,h),brickUpdate)

	:newParticleType("snow",-.5,.5,-1,.25,love.graphics.newQuad(10,0,2,2,w,h),snowUpdate)

	:newParticleType("gold",-.75,.75,-1.25,0,love.graphics.newQuad(10,4,2,2,w,h),goldUpdate)

	:newParticleType("confetti",-.75,.75,-1.5,0,dustQuad,empty,confettiInit)
	:newParticleType("confettiRed",0,0,0,0,love.graphics.newQuad(10,8,2,2,w,h),confettiUpdate)
	:newParticleType("confettiGreen",0,0,0,0,love.graphics.newQuad(2,0,2,2,w,h),confettiUpdate)
	:newParticleType("confettiBlue",0,0,0,0,love.graphics.newQuad(10,6,2,2,w,h),confettiUpdate)

	:newParticleType("snowfall",0,0,.25,.5,love.graphics.newQuad(10,0,2,2,w,h),snowFallUpdate,snowFallInit)
