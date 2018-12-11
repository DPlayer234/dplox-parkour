--[[
Library which wraps the usual audio library, simplifies it (somewhat) and allows for easier 2-dimensional sound management:
newSFX = sounds.newSFX(path, volume_mod, [id])
	newSFX:play(x_position, y_position) [Note: Absolute positions]
	+ some functions for normal sources
Also includes a simple, somewhat memory-effective wrapper for including music:
newMusic = sounds.newMusic(path, volume_mod, [id])
	newMusic:play()
	+ some functions for normal sources
	This library will only have the current music in memory and will make sure to only play one song at a time.
sounds.setListener(listener_x, listener_y)
	Sets the position of the listener (e.g. camera position).
sounds.enableThreadedLoading()
	Calling this function causes any future newMusic:play() to load the source in another thread.
	Subsequently, it may seem like the call is delayed (which it technically is) but no longer blocks the main thread until the source is loaded.
sounds.update(listener_x, listener_y)
	The same as sounds.setListener if sounds.enableThreadedLoading() hasn't been called yet.
	If it has been, this will also make sure that the music is activated upon loading.
sounds.positionScale = scale [default: 27]
	Divisor for any position given as an argument to a function.

Originally created by DPlayer234:
YOU MAY NOT SHARE THIS CODE UNDER YOUR NAME OR REMOVE ANY OF THIS NOTICE.
YOU MAY HOWEVER USE IT IN YOUR OWN PROJECTS, IF YOU CREDIT THE ORIGINAL CREATOR.
IF YOU DON'T, GO F--- YOURSELF, 'CAUSE I AIN'T HAVE THE POWER OR MONEY TO SUE YOU!
]]
local function log(...)
	print("[Sounds Main]",...)
end

local pcall = pcall
local setmetatable = setmetatable
local loveAudioSetPosition = love.audio.setPosition
local loveAudioNewSource = love.audio.newSource
local loveAudioStop = love.audio.stop
local isFile = love.filesystem.isFile

local sounds = {}

local weakmeta = { __mode = "kv" }

local posX = 0
local posY = 0

local sfx = {}				setmetatable(sfx,weakmeta)
local sfxVolume = 1
local sfxLastId = 0
local sources = {}		setmetatable(sources,weakmeta)

local music = {}			setmetatable(music,weakmeta)
local musicVolume = 1
local musicLastId = 0

local musicCurrent
local musicCurrentId

local sfxMeta = {
	play = function(s,x,y)
		if s.source:isPlaying() then
			sources[s.id] = s.source
			s.source = s.source:clone()
		end
		s.source:setPosition((x or posX)/sounds.positionScale,(y or posY)/sounds.positionScale,0)
		s.source:play()
	end,
	setVolume = function(s,vol)
		s.volume = vol
		s.source:setVolume(vol*sfxVolume)
	end,
	stop = function(s) s.source:stop() end,
	pause = function(s) s.source:pause() end,
	resume = function(s) s.source:resume() end,
	setPosition = function(s,x,y) s.source:setPosition(x/sounds.positionScale,y/sounds.positionScale) end,
	isPlaying = function(s) return s.source:isPlaying() end,
	isPaused = function(s) return s.source:isPaused() end,
	isStopped = function(s) return s.source:isStopped() end
}
sfxMeta.__index = sfxMeta

local musicMeta = {
	play = function(s)
		if musicCurrentId ~= s.id then
			if musicCurrent then musicCurrent:stop() end
			musicCurrentId = s.id
			musicCurrent = loveAudioNewSource(s.path,"stream")

			musicCurrent:setVolume(musicVolume*s.volume)

			if musicCurrent:getChannels() == 1 then
				musicCurrent:setRelative(true)
			end
			musicCurrent:setLooping(true)

			musicCurrent:play()
		end
	end,
	stop = function(s)
		if musicCurrentId == s.id and musicCurrent then
			musicCurrent:stop()

			musicCurrentId = nil
			musicCurrent = nil
		end
	end,
	pause = function(s)
		if musicCurrentId == s.id and musicCurrent then
			musicCurrent:pause()
		end
	end,
	resume = function(s)
		if musicCurrentId == s.id and musicCurrent then
			musicCurrent:resume()
		end
	end,
	rewind = function(s)
		if musicCurrentId == s.id and musicCurrent then
			musicCurrent:rewind()
		end
	end,
	seek = function(s,offset,unit)
		if musicCurrentId == s.id and musicCurrent then
			musicCurrent:seek(offset,unit)
		end
	end,
	tell = function(s,unit)
		if musicCurrentId == s.id and musicCurrent then
			musicCurrent:tell(unit)
		end
	end,
	setVolume = function(s,newVol)
		s.volume = newVol
		if musicCurrentId == s.id and musicCurrent then
			musicCurrent:setVolume(newVol*musicVolume)
		end
	end,
	isPlaying = function(s)
		if musicCurrentId == s.id and musicCurrent then
			return musicCurrent:isPlaying()
		else
			return false
		end
	end
}
musicMeta.__index = musicMeta

sounds.positionScale = 27

function sounds.newSFX(path,volumeMod,id)
	local suc,new = pcall(loveAudioNewSource,path,"static")

	if suc then
		volumeMod = volumeMod or 1

		new:setVolume(volumeMod*sfxVolume)

		local obj = { source = new,volume = volumeMod }
		setmetatable(obj,sfxMeta)

		if type(id) == "string" then
			sfx[id] = obj
			obj.id = id
		else
			sfxLastId = sfxLastId + 1
			sfx[sfxLastId] = obj
			obj.id = sfxLastId
		end

		return obj
	end
	log("Could not create sfx source... ["..path.."]")
end

local function newMusicObj(path,volumeMod,id)
	local obj = { path = path,volume = volumeMod or 1 }
	setmetatable(obj,musicMeta)

	if type(id) == "string" then
		music[id] = obj
		obj.id = id
	else
		musicLastId = musicLastId + 1
		music[musicLastId] = obj
		obj.id = musicLastId
	end

	return obj
end
function sounds.newMusic(...)
	if sounds.fileParser then
		local parse,source,volumeMod,id = unpack{...}
		local suc,d = pcall(sounds.fileParser,parse)

		if suc and d then
			local obj = newMusicObj(source,d.volume or volumeMod,d.id or id)

			for k,v in pairs(d) do
				if obj[k] == nil then
					obj[k] = v
				end
			end

			return obj
		end
	else
		return newMusicObj(...)
	end
	log("Could not create music source... ["..tostring(({...})[1]).."]")
end

function sounds.setSFXVolume(newVolume)
	if type(newVolume) == "number" then
		sfxVolume = newVolume
		for k,v in pairs(sfx) do
			v.source:setVolume(v.volume*newVolume)
		end

		return true
	else
		return false
	end
end

function sounds.setMusicVolume(newVolume)
	if type(newVolume) == "number" then
		musicVolume = newVolume
		if musicCurrent then
			musicCurrent:setVolume(music[musicCurrentId].volume*newVolume)
		end

		return true
	else
		return false
	end
end

function sounds.stopSFX()
	local musicP
	if musicCurrent then
		musicP = musicCurrent:tell()
	end
	loveAudioStop()
	if musicP then
		musicCurrent:play()
		musicCurrent:seek(musicP)
	end
end

function sounds.stopMusic()
	if musicCurrent then
		musicCurrent:stop()

		musicCurrent = nil
		musicCurrentId = nil
	end
end

function sounds.getCurrentMusic()
	return music[musicCurrentId],musicCurrent
end

function sounds.setListener(x,y)
	loveAudioSetPosition(x/sounds.positionScale,y/sounds.positionScale,-1.4)
	posX = x
	posY = y
end

sounds.update = sounds.setListener

sounds.sfxList = sfx
sounds.sfxClone = sources
sounds.musicList = music
--[[sounds.fileParser = function(t)
	return love.filesystem.load(t)()
end]]

local threadedLoading = false
function sounds.enableThreadedLoading()
	if not threadedLoading then
		threadedLoading = true

		local waitingForSource = false
		local getChannel = love.thread.getChannel("sounds_library_loading_from")
		local toChannel = love.thread.getChannel("sounds_library_loading_to")

		musicMeta.play = function(s)
			if musicCurrentId ~= s.id then
				musicCurrentId = s.id
				waitingForSource = s
				toChannel:push(s.path)
			end
		end

		sounds.loadThread = love.thread.newThread[[
		local function log(...)
			print("[Sound Sec.]",...)
		end

		require "love.sound"
		local newAudio = require "love.audio" .newSource
		local getChannel = love.thread.getChannel("sounds_library_loading_from")
		local toChannel = love.thread.getChannel("sounds_library_loading_to")

		while true do
			local path = toChannel:demand()
			if path then
				log("Requested loading of ["..path.."]")
				if toChannel:getCount() >= 1 then
					for i=1,toChannel:getCount()-1 do toChannel:pop() end
					path = toChannel:pop()
					log("\tFound more requests, latest ["..path.."]")
				end
				local s,new = pcall(newAudio,path,"stream")
				log("\tLoaded file.")
				while toChannel:getCount() >= 1 do
					for i=1,toChannel:getCount()-1 do toChannel:pop() end
					path = toChannel:pop()
					s,new = pcall(newAudio,path,"stream")
					log("\tFound more requests, loaded ["..path.."]")
				end
				if s then
					getChannel:push(new)
					log("\tPushed source to main thread!")
				else
					getChannel:push("error")
					log("Could not load ["..path.."]",new)
				end
			end
		end
		]]
		sounds.loadThread:start()

		function sounds.update(x,y)
			sounds.setListener(x,y)
			if waitingForSource ~= nil then
				local source = getChannel:pop()
				if source ~= nil then
					if musicCurrent then musicCurrent:stop() end
					if source ~= "error" then
						musicCurrent = source

						musicCurrent:setVolume(musicVolume*waitingForSource.volume)

						if musicCurrent:getChannels() == 1 then
							musicCurrent:setRelative(true)
						end
						musicCurrent:setLooping(true)

						musicCurrent:play()
					end
				end
			end
		end
	end
end

return sounds
