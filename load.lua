function love.load(args)
	local love = love

	-- Game jolt integration stuff
	gj_logged_in = false

	gj_comm = {
		set = love.thread.getChannel("gj_set"),
		ret = love.thread.getChannel("gj_ret"),
	}

	require "trophies"

	-- Other shenanigans
	if love.filesystem.isFile(".version") then
		if love.filesystem.read(".version") ~= _app_version then
			_first_startup = true
			love.filesystem.write(".version",_app_version)
		else
			_first_startup = false
		end
	else
		_first_startup = true
		love.filesystem.write(".version",_app_version)
	end

	love.keyboard.setTextInput(false)

	love.mouse.setVisible(false)
	love.graphics.setDefaultFilter("nearest","nearest")

	if _first_startup then
		local function convert(old,new)
			if love.filesystem.isFile(old) and not love.filesystem.isFile(new) then
				require "libs.binsave"
				local s,c = pcall(love.filesystem.readBin,old)
				if s and c then
					local s = save.write(new,c)
					if s then
						print("Converted ["..old.."] into ["..new.."]!")
						love.filesystem.remove(old)
					else
						print("Error converting ["..old.."]")
					end
				end
			end
		end
		convert("save","sav.bin")
		convert("configuration","cnf.bin")
		convert("unlocks","unl.bin")

		if love.filesystem.isFile("player/#readme.txt") then
			love.filesystem.remove("player/#readme.txt")
		end
	end

	-- Loading both fonts
	local glyphs = "  abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789.:,;+-–_#()[]{}/\\\"'*~=!?%$><&^•◘○ @├…♥♦♣♠▲▼◄►✓✖"
	fonts = {
		normal = love.graphics.newImageFont("assets/font/normal.png",glyphs),
		bold = love.graphics.newImageFont("assets/font/bold.png",glyphs),
		--keyboard = love.graphics.newImageFont("assets/font/keyboard.png"," ABCDEFGHIJKLMNOPQRSTUVWXYZ1234567890!\"#$&'()*+,-./:;<>=?@[]^_`•◘◄►")
	}
	for k,v in pairs(fonts) do v:setLineHeight(10/v:getHeight()) end --Correcting Line-Height

	love.graphics.setFont(fonts.normal)

	require "player"
	local attackimg = love.graphics.newImage("assets/attack.png")
	attackAnim = anim.newAnimHead(attackimg,13,19)
		:addAnim(0,{1,1,1},{3,2,1},{5,3,1},{7,4,1},{10,"end"})

	-- Create a new Particle System
	require "particle"

	-- Set vars
	input = {}
	screen = { scale = 2, scaleMult = 1, x = 0, y = 0, toX = 0, toY = 0, rumble = 0 }
	prKeys = {}
	prButtons = {}
	particleId = { "dust","grass","sand","brick","snow" }
	noSave = false

	-- Default code settings
	_vars = {
		level = "tutorial",
		hub = "hub"
	}

	--SOUNDS
	sounds = require "libs.sounds"
	sounds.fileParser = fileLoad

	sound = {
		genericjump 	= sounds.newSFX("assets/sound/jump.ogg",0.6),
		hover 				= sounds.newSFX("assets/sound/hover.ogg",1),
		death 				= sounds.newSFX("assets/sound/death.ogg"),
		select				= sounds.newSFX("assets/sound/select.ogg"),
		choice				= sounds.newSFX("assets/sound/choice.ogg"),
		collect 			= sounds.newSFX("assets/sound/collect.ogg",0.5),
		smash 				= sounds.newSFX("assets/sound/smash.ogg"),
		hitground 		= sounds.newSFX("assets/sound/hitground.ogg"),
		explode 			= sounds.newSFX("assets/sound/explode.ogg"),
		smallexplode	= sounds.newSFX("assets/sound/smallexplode.ogg"),
		warp					= sounds.newSFX("assets/sound/warp.ogg"),
		destroy 			= sounds.newSFX("assets/sound/break.ogg"),
		swing 				= sounds.newSFX("assets/sound/swing.ogg",0.4),
	}

	if love.filesystem.isDirectory("assets/music") and not _args.nomusic then
		music = {
			title 	= sounds.newMusic("assets/music/title.txt", 	"assets/music/title.mp3",0.35),
			forest	= sounds.newMusic("assets/music/forest.txt",	"assets/music/forest.mp3",0.25),
			cave		= sounds.newMusic("assets/music/cave.txt",		"assets/music/cave.mp3",0.3),
			desert	= sounds.newMusic("assets/music/desert.txt",	"assets/music/desert.mp3",0.25),
			ice 		= sounds.newMusic("assets/music/ice.txt", 		"assets/music/ice.mp3",0.25),
			final 	= sounds.newMusic("assets/music/final.txt", 	"assets/music/final.mp3",0.2),
			boss_a	= sounds.newMusic("assets/music/boss_a.txt",	"assets/music/boss_a.mp3",0.3),
			boss_b	= sounds.newMusic("assets/music/boss_b.txt",	"assets/music/boss_b.mp3",0.25),
			boss_c	= sounds.newMusic("assets/music/boss_c.txt",	"assets/music/boss_c.mp3",0.25),
			relax 	= sounds.newMusic("assets/music/relax.txt", 	"assets/music/relax.mp3",0.3),

			hdn 		= sounds.newMusic("assets/music/hdn.txt", 		"assets/music/hdn.mp3",0.25),
			boss_hdn= sounds.newMusic("assets/music/boss_hdn.txt","assets/music/boss_hdn.mp3",0.20),
		}
	else
		music = {}
	end

	-- General images
	doorImgBright = love.graphics.newImage("assets/door_bright.png")
	doorImgDark = love.graphics.newImage("assets/door_dark.png")
	doorBatch = love.graphics.newSpriteBatch(doorImgDark,25,"stream")
	local finishImg = love.graphics.newImage("assets/finishFlag.png")
	finishAnim = anim.newAnimHead(finishImg,9,31)
		:addAnim(0,{1,1,1},{8,2,1},{15,3,1},{22,4,1},{29,5,1},{36,6,1},{41,"loop"})
	npcImg = love.graphics.newImage("assets/npcs.png")
	npcBatch = love.graphics.newSpriteBatch(npcImg,25,"stream")

	-- Hud
	local hudimg = { image = love.graphics.newImage("assets/hud.png") }
	local hudw,hudh = hudimg.image:getDimensions()
	hudimg.quad = {
		collect = love.graphics.newQuad(0,0,24,14,hudw,hudh),
		rip = love.graphics.newQuad(0,14,24,14,hudw,hudh)
	}

	hud = { show = true }

	hud.batch = love.graphics.newSpriteBatch(hudimg.image,2,"static")
		hud.batch:add(hudimg.quad.collect,0,0)
		hud.batch:add(hudimg.quad.rip,0,16)

	hud.write = anim.newAnimHead(hudimg.image,12,12)
		:addAnim("write",{1,3,1},{4,4,1},{7,3,2},{10,4,2},{13,"loop"})
		:addAnim("fail",{1,3,3})
		:addAnim("success",{1,4,3})

	-- Loading Config
	function _cnf() return {
		moveLeft = "left",
		moveRight = "right",
		moveUp = "up",
		moveDown = "down",
		jump = "z",
		action = "x",
		start = "return",
		select = "backspace",

		jumpjs = "a",
		actionjs = "x",
		startjs = "start",
		downjs = "leftshoulder",
		upjs = "rightshoulder",
		selectjs = "back",

		ctrlType = 0,
		ctrlStick = 0.3,

		player = "1default",
		playercostume = "",
		fullscreen = false,
		sfx = 1,
		msfx = 0.5,

		maxPart = 5,
		light = 0.5,
		lightLenght = 1.5
	} end

	cnf = _cnf()
	if love.filesystem.isFile("cnf.bin") then
		local cnfDisk,error = save.read("cnf.bin")
		if cnfDisk then
			for k,v in pairs(cnfDisk) do
				if type(v) == type(cnf[k]) then cnf[k] = v end
			end
		else
			print("Error loading config:",error)
		end
	end

	if not love.filesystem.isFile("player/#readme.txt") then
		if love.filesystem.isDirectory("player/#readme.txt") then
			love.filesystem.remove("player/#readme.txt")
		end

		love.filesystem.createDirectory("player")
		love.filesystem.write("player/#readme.txt",love.filesystem.read("assets/pl_readme.txt"))
	end

	-- Applying volumes
	sounds.setSFXVolume(cnf.sfx)
	sounds.setMusicVolume(cnf.msfx)

	partSystem:setMaximum(cnf.maxPart*100)

	-- Loading Unlocks
	if love.filesystem.isFile("unl.bin") then
		local _unlocks = save.read("unl.bin")
		if _unlocks then
			unlocks = _unlocks
		else
			unlocks = {}
		end
	else
		unlocks = {}
	end

	-- Screenshot Directory
	if not love.filesystem.isDirectory("screenshots") then
		love.filesystem.createDirectory("screenshots")
	end

	-- Default save data
	function _savedata()
		local sd = {
			levels = {},
			collectLvl = {},
			ripCount = 0,
			collect = 0,
			endlessScore = 0
		}
		for i=1,100 do table.insert(sd.levels,false) end
		for i=1,100 do table.insert(sd.collectLvl,0) end
		return sd
	end
	savedata = _savedata()

	-- Splash
	local splashes = fileLoadArray("assets/splashes.txt")
	local splash = splashes[math.random(1,#splashes)]
	gameSplash = splash
	love.window.setTitle(gameTitle.."  –  "..splash)

	if gameSplash == "Drag here" then
		local count=0 local message={"I didn't think anyone would do that. ... So how was your day?","You are really curious about this, aren't you?","Uh... Having fun so far?","Geez, just stop that.","You're not gonna stop, are you?","I've got a simple question...","Do you know that I can write that file you drop here?","For all you know, I might have overwritten it already.","You just checked, didn't you?","Just kidding.","But seriously, I won't talk to you anymore.","Bye.","I SAID BYE!!"}function love.filedropped(file)count=count+1 if message[count]then notice.add(message[count],240)else notice.add("...\n...\n...",120)end end
	end

	-- TILES AND LEVEL --
	bufferImage = love.graphics.newImage(love.image.newImageData(1,1))
	levelBatch = love.graphics.newSpriteBatch(bufferImage,5000,"stream")
	require "tiles"
	require "levels"

	enableDebug = false

	-- Run Argument Processing
	if args then
		if args.scale then
			if type(args.scale) == "number" then
				screen.scaleMult = args.scale
			end
		end

		if args.title then
			if args.title == "#disable" then
				love.window.setTitle(gameTitle)
			elseif type(args.title) == "string" then
				love.window.setTitle(gameTitle.."  –  "..args.title)
			end
		end

		if args.editor then
			require "editor.main"
		end

		if args.debug then
			debugger = require "debugger"
			debugger.registerHandlers()

			_app_debug = require "threads.app_debug"

			enableDebug = true
			debugger.doTempPrint = false

			print("WARNING: Enabled debug mode.")
		end

		if args.maximize then
			love.window.maximize()
		end
	end

	gameStatus = 0
	-- Load Menu Data
	require "menu"

	-- Loading Cutscene Data.
	require "cutscene"

	-- Loading Help-Screen Data.
	require "help"

	-- Shader for shadows
	shaders = {
		light = love.graphics.newShader("shader/light.glsl"),
		fade = love.graphics.newShader("shader/fade-out.glsl")
	}

	-- Toggle Fullscreen if set in configuration
	local w,h,m = love.window.getMode()
	if m.refreshrate ~= 60 then
		m.vsync = false
		love.window.setMode(w,h,m)
	end
	if cnf.fullscreen then
		toggleFullscreen()
	else
		love.resize(love.graphics.getDimensions())
	end

	require "notice"

	-- Activating Threads
	threads = {}
	if not _args.singlethread then
		local saveThread = love.thread.newThread("threads/saving.lua")
		saveThread:start(enableDebug)

		threads.save = saveThread
	end

	channels = {}
	channels.saveOut = love.thread.getChannel("save")
	channels.saveIn = love.thread.getChannel("saver")
	if enableDebug then
		channels.print = love.thread.getChannel("print")
	end

	-- 2d Table
	local _2d = { __call = function(t,x,y,v) if t[y] then if v then t[y][x] = v else return t[y][x] end end end }
	function set2d(t)
		if type(t) == "table" then
			setmetatable(t,_2d)
		else
			error("DAFUQ, 2D -TABLES-! PLS!")
		end
	end

	-- Setting music
	function setMusic(cmusic)
		if cmusic ~= nil then
			if cnf.msfx > 0 then
				cmusic:play()
			end
			currentMusic = cmusic
			levels.musicPrint = {{127,146,255},"Now Playing...  \n",{255,255,255},{127,146,255},"\nby ",{255,255,255}}
			table.insert(levels.musicPrint,4,cmusic.title or "A song")
			table.insert(levels.musicPrint,8,cmusic.creator or "Unknown")
		elseif currentMusic ~= nil then
			currentMusic:stop()
			currentMusic = nil
			levels.musicPrint = nil
		end
	end

	collectgarbage()
end
