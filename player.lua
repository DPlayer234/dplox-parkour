player = {
	status = "idle",
	x = 50,
	y = 50,
	yOff = 0,
	xv = 0,
	yv = 0,
	dir = 1,
	acceleration = 0,
	airJumps = 0,
	data = { g = false, m = false, w = false, updateAnim = true, stopStatus = -1 }, -- air:0, ground:1, wall:2
	pdata = { g = false, m = false, w = false, duck = false, xv = 0, yv = 0 },
	attack = -5,
	attackBox = { w=12, h=18, x=0, y=0 },
	attackDir = 0,
	attackAnim = false,
	duck = false,
	jumped = false,
	freeze = 0,
	freezeDeath = false,
	status = "idle",
	hitBox = { w=8, h=17, xo=-3, yo=-7 },
	color = { 255, 255, 255 },
	gender = "male",
	name = "DenNiz",
	fullname = "Denniz P.",
	hasBackJump = true,
	hasFrontJump = true,
	hasUpJump = true,
	hasDoubleJump = true,
	canDuck = true,
	hasGroundDie = true,
	hasAttack = true,
	scale = 1,
	scripts = {},
	gravity = {
		multiplier = 1,
		acceleration = 0.13
	},
	default = { pAirJumps = 1, jumpV = -3.5, dJumpV = -3, wJumpV = -3, scripts = {}, helpInfo = "", helpInfoTable = {} }
}

player.pronouns = {
	male = { sub = "he", obj = "him", pos = "his" },
	female = { sub = "she", obj = "her", pos = "her" },
	neutral = { sub = "they", obj = "them", pos = "their"},
	none = { sub = "it", obj = "it", pos = "its" },
}

function player:moves()
	return self.xv > 0.6 or self.xv < -0.6
end

function player:getStatusId()
	return self.data.g and 1 or self.data.w and 2 or 0
end

function player:headInBlock()
	if self.data.g then
		--local xt = round((self.x+4)/9)
		local xt1 = math.floor((player.x+5.1)/9)
		local xt2 = math.ceil((player.x+3.9)/9)
		local yt = math.ceil(self.y/9)

		local id1 = level(xt1,yt) or 0
		local id2 = level(xt2,yt) or 0
		return tileData[id1].d.hori or tileData[id2].d.hori
	end
	return false
end

local dDefaultPlayers = fileLoadArray("player/#defaults.txt")
local defaultPlayer = {}
for k,v in pairs(dDefaultPlayers) do
	defaultPlayer[v] = true
end

_players = defaultPlayer

local replacer = function(t)
	local _1 = t:sub(2,2)
	local _2 = t:sub(#t,#t)
	--Pattern: "['\"%(%{].-['\"%)%}]"
	if (_1 == '"' and _2 == '"') or (_1 == "'" and _2 == "'") or (_1 == "(" and _2 == ")") or (_1 == "{" and _2 == "}") then
		return t:sub(1,1)
	else
		return t
	end
end
function player:setPlayer(file,costume,allowCustom)
	if self.scripts.deinit then self.scripts.deinit(self) end

	local tstart = love.timer.getTime()

	print("Setting player ["..tostring(file).."]"..(costume and "; costume ["..tostring(costume).."]" or ""))
	local pfile
	file = file:gsub("%.char$","")

	if love.filesystem.isFile("player/"..file..".char") then
		pfile = fileLoad("player/"..file..".char")
	elseif love.filesystem.isFile("player/"..file) then
		pfile = fileLoad("player/"..file)
	else
		pfile = fileLoad("player/1default.char")
		file = "1default"
		print("\tCannot find player file, using default...")
	end

	-- Checking values and setting defaults if necessary
	pfile.texture = pfile.texture or "assets/player/denniz.png"
	pfile.tilewidth = tonumber(pfile.tilewidth) or 10
	pfile.tileheight = tonumber(pfile.tileheight) or 18

	-- Loading the player's graphics
	local function getImage(str)
		if love.filesystem.isFile(str) then
			print("\t\tSupplied file path to image, loading...")
			return love.graphics.newImage(str)
		else
			print("\t\tSupplied b64 data, converting to image...")
			local filedata = love.filesystem.newFileData(str,".png","base64")
			return love.graphics.newImage(love.image.newImageData(filedata))
		end
	end

	local function getSFX(str)
		if love.filesystem.isFile(str) then
			print("\t\tSupplied file path to sound, loading...")
			return str
		else
			print("\t\tSupplied b64 data, converting to sound...")
			return love.filesystem.newFileData(str,".ogg","base64")
		end
	end

	print("\tLoading graphic...")
	local psheet
	if costume and pfile.costumes then
		local pcostumes = fileLoad(pfile.costumes,true)
		if type(pcostumes[costume]) == "string" then
			psheet = getImage(pcostumes[costume])
		elseif type(pcostumes[costume]) == "table" then
			pfile.color = string.format("%d,%d,%d",tonumber(pcostumes[costume][2]) or 255,tonumber(pcostumes[costume][3]) or 255,tonumber(pcostumes[costume][4]) or 255)
			psheet = getImage(pcostumes[costume][1])
		else
			psheet = getImage(pfile.texture)
		end
	else
		psheet = getImage(pfile.texture)
	end
	psheet:setWrap("mirroredrepeat","mirroredrepeat")

	self.anim = anim.newAnimHead(psheet,pfile.tilewidth,pfile.tileheight)
	self.tx = math.floor(pfile.tilewidth/2)
	self.ty = math.floor(pfile.tileheight/2)
	self.scale = tonumber(pfile.scale) or 1

	local gender = tostring(pfile.gender)
	self.gender = self.pronouns[gender] and gender or "none"

	if pfile.jumpsound then
		print("\tFound jump sfx, loading...")
		local s,e = pcall(sounds.newSFX,getSFX(pfile.jumpsound),tonumber(pfile.jumpsoundvolume) or sound.genericjump.volume,"jump")
		sound.jump = s and e or sound.genericjump
	else
		print("\tUsing default jump sfx...")
		sound.jump = sound.genericjump
	end

	if pfile.attacksound and love.filesystem.isFile(pfile.attacksound) then
		print("\tFound attack sfx, loading...")
		local s,e = pcall(sounds.newSFX,getSFX(pfile.attacksound),tonumber(pfile.attacksoundvolume) or sound.swing.volume,"attack")
		sound.attack = s and e or sound.swing
	else
		print("\tUsing default attack sfx...")
		sound.attack = sound.swing
	end

	if type(pfile.customtiles) == "string" then
		print("\tLoading custom animation frames...")
		local s,customtiles = pcall(loadstring("return {"..tostring(pfile.customtiles):gsub("[a-zA-Z0-9_]['\"%(%{].-['\"%)%}]",replacer).."}"))
		if s then
			for k,v in pairs(customtiles) do
				if type(v) == "table" then
					self.anim:defineQuad(select(2,pcall(love.graphics.newQuad,v[3],v[4],v[5],v[6],psheet:getDimensions())),v[1],v[2])
				end
			end
		end
	end

	print("\tGetting name...")
	self.fullname = pfile.name or file
	self.name = pfile.shortname or self.fullname

	print("\tSetting attack color...")
	if pfile.color then
		self.color = valuelize(pfile.color,true)
		if type(self.color) == "table" then
			for i,v in ipairs(self.color) do
				self.color[i] = math.max(0,math.min(tonumber(v) or 255,255))
			end
			if #self.color < 3 then
				table.insert(self.color,self.color[1] or 255)
			elseif #self.color > 3 then
				while #self.color > 3 do table.remove(self.color,4) end
			end
		elseif type(self.color) == "number" then
			local color = math.max(0,math.min(self.color or 255,255))
			self.color = {color,color,color}
		else
			self.color = {255,255,255}
		end
	else
		self.color = {255,255,255}
	end

	-- Values
	if pfile.values and (defaultPlayer[file] or allowCustom) then
		print("\tCustom values. Setting...")
		pfile.values = select(2,pcall(loadstring("return "..pfile.values)))
		print("\t\t"..tostring(pfile.values))
		for k,v in pairs(self.default) do
			if pfile.values[k] and type(pfile.values[k]) == type(v) then
				self[k] = pfile.values[k]
				print("\t\tSetting value "..tostring(k)..".")
			else
				self[k] = v
			end
		end
		if self.scripts.init then self.scripts.init(self) end
	elseif defaultPlayer[pfile.values] and (unlocks[pfile.values] or not tostring(pfile.values):find("^z%-")) then
		print("\tLoading alien values...")
		local s,e = pcall(function()
			local from = loadstring("return "..fileLoad("player/"..pfile.values..".char").values)()
			for k,v in pairs(self.default) do
				if from[k] and type(from[k]) == type(v) then
					self[k] = from[k]
				else
					self[k] = v
				end
			end
			if self.scripts.init then self.scripts.init(self) end
		end)
		if not s then
			print("\t\tAn error occured, resetting...",e)
			for k,v in pairs(self.default) do
				self[k] = v
			end
		end
	else
		print("\tNo values or custom. Resetting...")
		for k,v in pairs(self.default) do
			self[k] = v
		end
	end
	self.airJumps = self.pAirJumps

	-- Clearing no longer necessary variables
	print("\tClearing variables...")
	pfile.shortname = nil
	pfile.name = nil
	pfile.texture = nil
	pfile.tilewidth = nil
	pfile.tileheight = nil
	pfile.jumpsound = nil
	pfile.attacksound = nil
	pfile.jumpsoundvolume = nil
	pfile.attacksoundvolume = nil
	pfile.customtiles = nil
	pfile.color = nil
	pfile.scale = nil
	pfile.values = nil
	pfile.costumes = nil
	pfile.gender = nil

	print("\tLoading animations...")
	-- Rough Syntax Check
	print("\t\tSyntax-checking...")
	for k,v in pairs(pfile) do
		local s = v

		s = s:gsub("[\"']loop[\"']","loop"):gsub("[\"']end[\"']","end")

		s = s:gsub("[%[%(]","{")
		s = s:gsub("[%]%)]","}")
		s = s:gsub("[;:|/\\]",",")
		s = s:gsub("[a-zA-Z0-9_]['\"%(%{].-['\"%)%}]",replacer)

		s = s:gsub("loop","'loop'"):gsub("end","'end'")

		pfile[k] = s
	end

	-- Loading animation tables
	for k,v in pairs(pfile) do
		local l = select(2,pcall(loadstring("return {"..v.."}")))
		if type(l) == "table" then
			pfile[k] = l
		else
			pfile[k] = nil
		end
	end

	-- Loading default if import animations are missing
	print("\t\tDefining constants...")
	if not pfile.jumpf	then	self.hasFrontJump = false 	else self.hasFrontJump = true end
	if not pfile.jumpb	then	self.hasBackJump = false		else self.hasBackJump = true end
	if not pfile.jumpu	then	self.hasUpJump = false			else self.hasUpJump = true end
	if not pfile.djump	then	self.hasDoubleJump = false	else self.hasDoubleJump = true end
	if not pfile.duck 	then	self.canDuck = false				else self.canDuck = true end
	if not pfile.slide	then	self.canSlide = false 			else self.canSlide = true end
	if not pfile.gdie 	then	self.hasGroundDie = false		else self.hasGroundDie = true end
	if not pfile.attack then	self.hasAttack = false			else self.hasAttack = true end

	-- Defining animations
	local w
	print("\t\tWriting animations...")
	for k,t in pairs(pfile) do
		for k,v in pairs(t) do
			if type(v) == "table" then
				for l,v in pairs(v) do
					local tv = type(v)
					if not (tv == "string" or tv == "number") then
						table.remove(t,k)
						break
					end
				end
			end
		end
		local s,e = pcall(self.anim.addAnim,self.anim,k,unpack(t))
		if not s then print("\t\t\tAnim error:",e)
		elseif k == "walk" and not self.anim.anims.slowwalk then
			pcall(function()
				for k,v in pairs(t) do v[1] = v[1]*2-1 end
				self.anim:addAnim("slowwalk",unpack(t))
			end)
		end
	end

	local loaded = self.anim.anims
	if not (loaded.idle and loaded.walk and loaded.jump and loaded.wall and loaded.wallrun and loaded.die and loaded.slowwalk) then
		print("Important animations are missing, canceling...")
		if file == "1default" then
			error("The default character data is corrupted. Re-download the game and if that still doesn't work, report it to the developer.")
		else
			print(string.format(">> Error after %fs",love.timer.getTime()-tstart))
			love.window.showMessageBox("Character Error!","Necessary animation data is missing.\nDenNiz will be loaded instead.",{"Crash game","Okay...","I SUCK"},"error",true)
			return self:setPlayer("1default")
		end
	end

	self.data.updateAnim = true
	if not loaded[self.status] then self.status = "idle" end

	print(string.format(">> Took %fs",love.timer.getTime()-tstart))
end
