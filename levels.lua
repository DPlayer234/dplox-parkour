levels = {
	width = 1,
	height = 1,
	latestHub = "hub",
	isEndless = false,
	currentCollect = 0,
	totalCollect = 0,
	collectLvl = {},
	weatherSpeed = 0,
	toWeatherSpeed = 0,
	darkBg = false
}
local levels = levels

local doorQuads = {
	ground = love.graphics.newQuad(0,0,9,18,18,18),
	float = love.graphics.newQuad(9,0,9,18,18,18)
}

-- Preset BGs
levels.bgs = {
	forest = {
		[0] = "skybox.png",
		[0.3] = "cloud1.png",
		[0.4] = "cloud2.png",
		[0.5] = "hills.png",
		[0.6] = "cloud3.png",
	},
	cave = {
		[0.2] = "caveback.png",
		[0.5] = "cavefront.png",
		properties = {dark=true}
	},
	desert = {
		[0] = "skybox.png",
		[0.25] = "pyramid.png",
		[0.5] = "deserthills.png",
	},
	finale = {
		[0] = "pillarfiller.png",
		[0.1] = "pillars.png",
		[0.2] = "pillars2.png",
		[0.3] = "pillars3.png",
	},
	ice = {
		[0] = "sea.png",
		[0.5] = "icehills.png"
	},
	endless = {
		[0] = "endless.png",
		properties = {dark=true}
	}
}

local noboss = {
	update = function()end,
	d = {}
} noboss.__index = noboss
-- Setting a level
local lastBg
function levels.set(levelname,allowLast,deleteBoss)
	local tstart = love.timer.getTime()
	-- Resetting certain values
	screen.rumble = 0

	player.attack = 0
	player.attackAnim = false
	player.freeze = -1
	player.freezeDeath = false
	player.xv = 0
	player.yv = 0
	player.yOff = 0
	player.airJumps = 0

	sounds.stopSFX()

	partSystem:clear()

	print("Loading level ["..tostring(levelname).."]:")

	if (deleteBoss == nil or deleteBoss) and boss then
		print("\tDeleting Boss...")
		boss = nil
	end

	local loadlevel
	if type(levelname) == "table" then
		loadlevel = levelname
		levelname = tostring(levelname)
	elseif love.filesystem.isFile("levels/"..levelname..".lua") then
		local l = love.filesystem.load("levels/"..levelname..".lua")
		loadlevel = l()
	elseif love.filesystem.isFile("levels/"..levelname) then
		local l = love.filesystem.load("levels/"..levelname)
		loadlevel = l()
	else
		error("Level '"..levelname.."' does not exist!")
	end
	level = loadlevel.level
	set2d(level)

	local isEndless = levelname:find("endless")
	if isEndless then
		levels.isEndless = true
	else
		if levels.isEndless then
			levels.isEndless = false
			endlessSelection = nil
		end
		levels.currentCollect = 0
	end
	levels.totalCollect = levels.collectLvl[levelname] or 0

	local cmusic = music[loadlevel.music]
	if cmusic ~= currentMusic then
		setMusic(cmusic)
	end

	if boss then
		print("\tSetting Boss-data...")
		local boss = boss
		if getmetatable(boss) == nil then setmetatable(boss,noboss) end

		boss._healthbar = love.graphics.newImage("assets/boss_bar.png")

		boss._healthbase = love.graphics.newQuad(0,0,200,14,200,28)
		boss._healthcont = love.graphics.newQuad(0,14,196,14,200,28)
	end

	levels.width = 0
	levels.height = #level

	for i,v in ipairs(level) do
		if #v > levels.width then levels.width = #v end
	end

	levels.outside = loadlevel.outside or nil

	print("\tLoading BG data...")
	if lastBg ~= loadlevel.bg then
		if loadlevel.bg then
			bgBatch = {}
			bgWidth = {}
			bgHeight = {}
			for k,v in pairs(loadlevel.bg) do
				k = tonumber(k)
				if k then
					local img = love.graphics.newImage("assets/bg/"..v)
					bgBatch[k] = love.graphics.newSpriteBatch(img,20,"dynamic")
					bgWidth[k] = img:getWidth()
					bgHeight[k] = img:getHeight()
				end
			end

			if loadlevel.bg.properties then
				local properties = loadlevel.bg.properties
				if properties.dark and not levels.darkBg then
					doorBatch:setTexture(doorImgBright)
					levels.darkBg = true
				end
			elseif levels.darkBg then
				doorBatch:setTexture(doorImgDark)
				levels.darkBg = false
			end
		else
			bgBatch = nil
			bgWidth = nil
			bgHeight = nil
			if levels.darkBg then
				doorBatch:setTexture(doorImgDark)
				levels.darkBg = false
			end
		end

		lastBg = loadlevel.bg
	end

	if loadlevel.warps then
		print("\tLoading warps...")
		warps = {}
		for i,v in ipairs(loadlevel.warps) do
			if type(v) == "table" then
				local x = v[1]
				local y = v[2]
				local q

				local tid = level(x,y+1)
				if tid ~= nil and tid ~= 0 then
					q = doorQuads.ground
				else
					q = doorQuads.float
				end

				table.insert(warps,{
					to = v[3],
					name = (v[4] or ""):gsub("\n","\n  "),
					x = x,
					y = y,
					quad = q,
					overX = v[5],
					overY = v[6],
				})
			end
		end
	else
		warps = nil
	end

	if loadlevel.npc then
		print("\tLoading NPCs...")
		npc = {}
		for i,v in ipairs(loadlevel.npc) do
			if type(v) == "table" then
				table.insert(npc,
				{
					name = v[1],
					x = (v[2] or 1)*9-math.floor(v[6]/2),
					y = (v[3] or 1)*9+1-math.ceil(v[7]/2),
					xo = math.floor(v[6]/2),
					yo = math.floor(v[7]/2),
					quad = love.graphics.newQuad(v[4],v[5],v[6],v[7],npcImg:getDimensions()),
					text = v[8] or "I used to be an adven...\nNah, this joke is getting old.",
					dir = 1
				}
				)
			end
		end
	else
		npc = nil
	end

	print("\tLoading miscellaneous data...")
	if loadlevel.finish then
		finish = {
			x = loadlevel.finish[1],
			y = loadlevel.finish[2],
			id = loadlevel.finishId,
			finished = false,
			to = loadlevel.exit
		}
	else
		finish = nil
	end

	if loadlevel.finishId then
		if not savedata.levels[loadlevel.finishId] and loadlevel.enterCutscene then
			cutscene.start(loadlevel.enterCutscene,true)
		end
		exitCutscene = loadlevel.exitCutscene
	end

	if loadlevel.unlockableChar then
		levels.unlockableChar = loadlevel.unlockableChar
	else
		levels.unlockableChar = nil
	end

	if loadlevel.clearTrophy then
		levels.clearTrophy = loadlevel.clearTrophy
	else
		levels.clearTrophy = nil
	end

	if loadlevel.td ~= levels.tileset or loadlevel.tileImage ~= levels.tileImage then
		print("\tLoading new Tile-Data...")
		levels.tileset = loadlevel.td

		local tiles = tileSets[loadlevel.td]
		if loadlevel.tileImage then
			tileImg = love.graphics.newImage("assets/tiles/"..loadlevel.tileImage)
		else
			tileImg = love.graphics.newImage("assets/tiles/"..tiles.image)
		end
		levels.tileImage = loadlevel.tileImage
		tileImg:setWrap("mirroredrepeat","mirroredrepeat")

		tileData = {}
		tileAnim = nil
		for i,v in ipairs(tiles.data) do
			-- Quad for the tile
			tileData[i-1] = { q = love.graphics.newQuad(v[1]*9-9,v[2]*9-9,9,9,tileImg:getDimensions()), d = {} }
			if #v >= 3 then
				for j=3,#v do
					-- Evaluating arguments for the tile
					if type(v[j]) == "string" then
						if j < #v then
							if type(v[j+1]) ~= "string" then
								if v[j] == "anim" then
									-- Eventual animation
									if not tileAnim then tileAnim = anim.newMultiAnim(tileImg,9,9) end
									tileAnim:addAnim(i-1,unpack(v[j+1]))
								elseif v[j] == "bgtile" then
									-- BG-Tile quad
									tileData[i-1].d.bgtile = love.graphics.newQuad(v[j+1][1]*9-9,v[j+1][2]*9-9,9,9,tileImg:getDimensions())
								else
									tileData[i-1].d[v[j]] = v[j+1]
								end
							else
								-- Solid tile
								if v[j] == "solid" then
									tileData[i-1].d.solid = true
									tileData[i-1].d.hori = true
									tileData[i-1].d.vert = true
									tileData[i-1].d.vertneg = true
								else
									tileData[i-1].d[v[j]] = true
								end
							end
						else
							-- Also Solid tile
							if v[j] == "solid" then
								tileData[i-1].d.solid = true
								tileData[i-1].d.hori = true
								tileData[i-1].d.vert = true
								tileData[i-1].d.vertneg = true
							else
								tileData[i-1].d[v[j]] = true
							end
						end
					end
				end
			end
		end
		levelBatch:setTexture(tileImg)

		levels.script = tiles.script or nil
	end

	print("\tFinalizing...")
	local lastLevel = levels.current
	local wasHub = levels.current == levels.latestHub

	love.resize(love.graphics.getDimensions())
	levels.current = levelname
	levels.currentName = loadlevel.name or levelname
	local isHub = levelname:find("hub")
	if isHub then
		levels.latestHub = levelname
	end

	if wasHub and not isHub then levels.hubPos = {player.x,player.y,lastLevel} end
	-- Player spawn-point
	if loadlevel.spawn then
		player.x = loadlevel.spawn[1]*9
		player.y = loadlevel.spawn[2]*9
		if levels.hubPos and isHub and not wasHub and allowLast then
			if levels.hubPos[3] == levels.current then
				player.x = levels.hubPos[1]
				player.y = levels.hubPos[2]
			end
		end
		screen.x,screen.y = player.x,player.y
		player.xv,player.yv = 0,0
		player.respawn = {loadlevel.spawn[1]*9,loadlevel.spawn[2]*9}
	end

	levels.textbox = loadlevel.textbox or ""
	levels.textboxAlign = loadlevel.textboxAlign or "left"

	print(string.format(">> Took %fs",love.timer.getTime()-tstart))

	if loadlevel.player then
		print("\tSetting this level's player...")
		if loadlevel.player ~= levels.changedPlayer then
			player:setPlayer(loadlevel.player,loadlevel.playercostume,true)
		end
		levels.changedPlayer = loadlevel.player
	elseif levels.changedPlayer then
		print("\tResetting player...")
		if levels.changedPlayer ~= cnf.player then
			player:setPlayer(cnf.player,cnf.playercostume)
		end
		levels.changedPlayer = nil
	end

	return isHub,wasHub
end

-- Simplifies some stuff; returns "warp" if the level "id" was completed
function levels.rIfSave(id,warp)
	if savedata.levels[id] then
		return warp
	else
		return nil
	end
end

-- Returns the collectables counter of a level "<COLLECTED>/<TOTAL> (I)"
local function gMax(id)
	return tostring(savedata.collectLvl[id]).."/"..tostring(levels.collectLvl[id]).." ├"
end

-- Returns the correct icon whether or not a level has been completed
local function completed(id)
	return savedata.levels[id] and "✓" or "✖"
end
levels.completed = completed

-- Return the entire title
function levels.title(id,name)
	return name.." "..completed(id)..(savedata.levels[id] and "\n"..gMax(id) or "")
end

function levels.collectSth()
	sound.collect:play(player.x,player.y)
	levels.currentCollect = levels.currentCollect + 1
end

do
	local l = fileLoadArray("levels/#levels.txt")--love.filesystem.getDirectoryItems("levels")
	local tcol = {}
	for k,v in pairs(tileSets) do
		local tiles = v
		local tileData = {}
		for i=1,#tiles.data do
			tileData[i-1] = { d = {} }
			if #tiles.data[i] >= 3 then
				for j=3,#tiles.data[i] do
					if type(tiles.data[i][j]) == "string" then
						if j < #tiles.data[i] then
							if type(tiles.data[i][j+1]) == "string" then
								tileData[i-1].d[tiles.data[i][j]] = true
							end
						else
							tileData[i-1].d[tiles.data[i][j]] = true
						end
					end
				end
			end
		end
		tcol[k] = {}
		for i=1,#tileData do
			if tileData[i].d.collect then
				tcol[k][i] = true
			elseif tileData[i].d.hit == true then
				tcol[k][i] = true
			end
		end
	end

	-- Getting Collectable Count in each level and total Collectables in the game
	local function preloadLevel(k,v)
		local v2 = v
		v = v:gsub("%.lua$","")

		local found = false

		local llines = love.filesystem.lines("levels/"..v2)
		local loadcode = ""
		for line in llines do
			if line:find("^--LEVEL$") then
				loadcode = line
				found = true
				break
			end
		end

		if not found then error("Cannot find beginning of Level Data.") end
		for line in llines do
			loadcode = loadcode.."\n"..line
		end

		if #loadcode > 0 then
			local levelCollect = 0

			local s,loadlevel = pcall(loadstring(loadcode))
			if s and type(loadlevel) == "table" then
				local tset = tcol[loadlevel.td]
				if tset and loadlevel.level then
					for k,v in pairs(loadlevel.level) do
						for k,v in pairs(v) do
							if tset[v] then
								levelCollect = levelCollect + 1
							end
						end
					end
				end

				if loadlevel.additionalCollect then
					levelCollect = levelCollect + loadlevel.additionalCollect
				end

				levels.collectLvl[v] = levelCollect
				if loadlevel.finishId and loadlevel.finish then
					levels.collectLvl[loadlevel.finishId] = levelCollect
				end
			else
				if s then
					error("Level File does not return a table or attempts to return one defined prior to the 'return' statement.")
				else
					print("Error loading code","(Data before '--LEVEL' is not evaluated during pre-loading.)")
				end
			end

		end
	end

	for k,v in pairs(l) do
		local s,e = pcall(preloadLevel,k,v)
		if not s then print(v,e) end
	end

	local tCollect = 0
	for k,v in pairs(levels.collectLvl) do
		if tonumber(k) then
			tCollect = tCollect + v
		end
	end
	levels.collectLvl.total = tCollect
end
