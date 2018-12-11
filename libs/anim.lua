--[[
DPlays Animation and Particle System Library.
animHead = anim.newAnimHead(image,tx,ty)
	animHead:addAnim(animname,{f,id_X,id_Y},...)
	animHead:update(animname)
	animHead:draw(x,y,r,sx,sy,ox,oy,kx,kz)
	animHead:defineQuad(quad,id_X,id_Y)

multiAnim = anim.newMultiAnim(image,tx,ty)
	Inherits all functions from animHead, changes:
		multiAnim:update()
		multiAnim:draw(animname,x,y,r,sx,sy,ox,oy,kx,kz)

particleSystem = anim.newParticleSystem(image,maximum)
	particleSystem:newParticleType(id,xv_min,xv_max,yv_min,yv_max,quad,logic_function,initializer_function)
	particleSystem:spawnParticles(id,amount,x,y,max_x_offset,max_y_offset)
	particleSystem:update()
	particleSystem:setMaximum(max)
	particleSystem:clear()
... Just check the code, dammit.

Originally created by DPlayer234:
YOU MAY NOT SHARE THIS CODE UNDER YOUR NAME OR REMOVE ANY OF THIS NOTICE.
YOU MAY HOWEVER USE IT IN YOUR OWN PROJECTS, IF YOU CREDIT THE ORIGINAL CREATOR.
IF YOU DON'T, GO F--- YOURSELF, 'CAUSE I AIN'T HAVE THE POWER OR MONEY TO SUE YOU!
]]--
local type = type
local tostring = tostring
local tonumber = tonumber
local unpack = table.unpack or unpack
local insert = table.insert
local remove = table.remove
local setmetatable = setmetatable
local random = math.random
local floor = math.floor
local ceil = math.ceil
local format = string.format
local pairs = pairs
local ipairs = ipairs

local graphics = require "love.graphics"

local newSpriteBatch = graphics.newSpriteBatch
local newQuad = graphics.newQuad
local draw = graphics.draw

local anim = {}

-- New Anim Header
local animHead = {}

function animHead:addAnim(animname,...)
	local frames = {...}
	self.anims[animname] = {}
	for i=1,#frames do
		local f = frames[i][1]
		local a = frames[i][2]
		local b = frames[i][3]
		self.anims[animname][f] = { a,b }
		if type(a) == "number" and type(b) == "number" then
			if not self.sheet[a] then
				self:defineQuad(newQuad(a*self.tx-self.tx,b*self.ty-self.ty,self.tx,self.ty,self.img:getDimensions()),a,b)
			elseif not self.sheet[a][b] then
				self:defineQuad(newQuad(a*self.tx-self.tx,b*self.ty-self.ty,self.tx,self.ty,self.img:getDimensions()),a,b)
			end
		end
	end
	if not self.anim then self.anim = animname end

	return self
end

function animHead:update(animname)
	local animname = animname or self.anim
	local frame = self.frame
	if self.anim ~= animname then
		frame = 0
		self.anim = animname
	end
	local anims = self.anims[animname]
	frame = frame + 1
	if anims[frame] then
		local a = anims[frame][1]
		local b = anims[frame][2]
		local ta = type(a)
		local tb = type(b)
		if a == "loop" then
			frame = 1
		elseif a == "end" then
			return true
		elseif ta == "number" and tb ~= "number" then
			frame = a
		end
		if anims[frame] then
			a = anims[frame][1]
			b = anims[frame][2]
			if self.sheet[a] then if self.sheet[a][b] then
				self.quad = self.sheet[a][b]
			end end
		end
	end
	self.frame = frame
end

function animHead:draw(x,y,r,sx,sy,ox,oy,kx,ky)
	draw(self.img,self.quad,x,y,r,sx,sy,ox,oy,kx,ky)
end

function animHead:defineQuad(quad,id1,id2)
	if type(quad) == "userdata" and type(id1) == "number" and type(id2) == "number" then if quad:typeOf("Quad") then
		if not self.sheet[id1] then
			self.sheet[id1] = {}
		end
		self.sheet[id1][id2] = quad
		return quad
	end end
end

animHead.__tostring = function(t) return format("AnimHead: 0x%08x",t.__address or 0) end
animHead.__index = animHead

-- Actual function
function anim.newAnimHead(img,tx,ty,...)
	local newHead = {
		img = img,
		sheet = {},
		frame = 0,
		anims = {},
		tx = tx, ty = ty
	}
	local s = tostring(newHead):gsub("table: ","")
	newHead.__address = tonumber(s)

	setmetatable(newHead,animHead)

	newHead.quad = newHead:defineQuad(newQuad(0,0,tx,ty,img:getDimensions()),1,1)

	for i,v in ipairs{...} do
		newHead:addAnim(unpack(v))
	end

	return newHead
end
-- New Anim Header End

-- New Multi Anim
local multiAnim = {}

function multiAnim:addAnim(animname,...)
	local frames = {...}
	self.anims[animname] = { frame = 0 }
	self.quads[animname] = { 1,1 }
	for i=1,#frames do
		local f = frames[i][1]
		local a = frames[i][2]
		local b = frames[i][3]
		self.anims[animname][f] = { a,b }
		if type(a) == "number" and type(b) == "number" then
			if not self.sheet[a] then
				self:defineQuad(newQuad(a*self.tx-self.tx,b*self.ty-self.ty,self.tx,self.ty,self.img:getDimensions()),a,b)
			elseif not self.sheet[a][b] then
				self:defineQuad(newQuad(a*self.tx-self.tx,b*self.ty-self.ty,self.tx,self.ty,self.img:getDimensions()),a,b)
			end
		end
	end

	return self
end

function multiAnim:update()
	local sheet = self.sheet
	for k,v in pairs(self.anims) do
		local frame = v.frame
		frame = frame + 1
		if v[frame] then
			local a = v[frame][1]
			local b = v[frame][2]
			local ta = type(a)
			local tb = type(b)
			if a == "loop" then
				frame = 1
			elseif ta == "number" and tb ~= "number" then
				frame = a
			end
			if v[frame] then
				a = v[frame][1]
				b = v[frame][2]
				if sheet[a] then if sheet[a][b] then
					self.quads[k] = sheet[a][b]
				end end
			end
		end
		v.frame = frame
	end
end

function multiAnim:draw(anim,x,y,r,sx,sy,ox,oy,kx,ky)
	draw(self.img,self.quads[anim],x,y,r,sx,sy,ox,oy,kx,ky)
end

function multiAnim:defineQuad(quad,id1,id2)
	if type(quad) == "userdata" and type(id1) == "number" and type(id2) == "number" then if quad:typeOf("Quad") then
		if not self.sheet[id1] then
			self.sheet[id1] = {}
		end
		self.sheet[id1][id2] = quad
		return quad
	end end
end

multiAnim.__tostring = function(t) return format("MultiAnim: 0x%08x",t.__address or 0) end
multiAnim.__index = multiAnim

-- Actual function
function anim.newMultiAnim(img,tx,ty,...)
	local newMulti = {
		anims = {},
		sheet = {},
		quads = {},
		img = img,
		tx = tx, ty = ty
	}
	local s = tostring(newMulti):gsub("table: ","")
	newMulti.__address = tonumber(s)

	setmetatable(newMulti,multiAnim)

	for i,v in ipairs{...} do
		newMulti:addAnim(unpack(v))
	end

	return newMulti
end
-- New Multi Anim End

-- Particle System
local particleBase = {}
function particleBase:newParticleType(tname,xmin,xmax,ymin,ymax,quad,logic,init)
	if ( type(tname) == "string" or type(tname) == "number" ) and type(quad) == "userdata" and type(logic) == "function" then if quad:typeOf("Quad") then
		self.types[tname] = {
			q = quad,
			l = logic,
			i = type(init) == "function" and init or nil,
			xmin = xmin*20,xmax = xmax*20,ymin = ymin*20,ymax = ymax*20
		}
		return self
	end end
	error("newParticleType: type string/number, XV-min number, XV-max number, YV-min number, YV-max number, graphicQuad Quad, logicFunction function, <Initializer function>")
end

function particleBase:spawnParticles(t,n,x,y,xo,yo)
	xo = xo or 0
	yo = yo or 0
	local pdata = self.types[t]
	for i=1,n do
		local nParticle = {
			x = x+random(floor(xo*-9),ceil(xo*9))*(1/9),
			y = y+random(floor(yo*-9),ceil(yo*9))*(1/9),
			t = t,
			xv = random(pdata.xmin,pdata.xmax)*.05,
			yv = random(pdata.ymin,pdata.ymax)*.05,
			age = 0,
			s = 1,
		}
		if pdata.i then pdata.i(nParticle) end
		insert(self.particles,nParticle)
	end

	if self.maximum < #self.particles then
		for i=1,#self.particles-self.maximum do
			remove(self.particles,1)
		end
	end
end

function particleBase:update()
	for i,v in ipairs(self.particles) do
		self.types[v.t].l(v)
		if v.kill then
			remove(self.particles,i)
		else
			v.x = v.x + v.xv
			v.y = v.y + v.yv
			v.age = v.age + 1
		end
	end
end

function particleBase:draw(xo,yo,sx,sy)
	self.drawBatch:clear()
	for i,v in ipairs(self.particles) do
		self.drawBatch:add(self.types[v.t].q,roundm(v.x,screen.scale),roundm(v.y,screen.scale),0,v.s)
	end
	draw(self.drawBatch,-xo,-yo,0,sx,sy)
end

function particleBase:clear()
	self.particles = {}
end

function particleBase:setMaximum(newMax)
	self.maximum = newMax
	if self.maximum < #self.particles then
		for i=#self.particles,self.maximum,-1 do
			remove(self.particles,i)
		end
	end
	if newMax > 0 then
		self.drawBatch:setBufferSize(newMax)
	end
end

particleBase.__tostring = function(t) return format("ParticleSystem: 0x%08x",t.__address or 0) end
particleBase.__index = particleBase

function anim.newParticleSystem(ptex,maxP,...)
	local newPartSys = {
		particles = {},
		types = {},
		maximum = maxP,
		texture = ptex,
		drawBatch = newSpriteBatch(ptex,maxP,"stream")
	}
	local s = tostring(newPartSys):gsub("table: ","")
	newPartSys.__address = tonumber(s)

	setmetatable(newPartSys,particleBase)

	for i,v in ipairs{...} do
		newPartSys:newParticleType(unpack(v))
	end

	return newPartSys
end
-- Particle System End

return anim
