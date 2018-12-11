cutscene = {}
local cutscene = cutscene

local cutscenebox = {
	image = love.graphics.newImage("assets/cutsceneBox.png"),
	main = love.graphics.newQuad(0,14,244,46,244,60),
	lname = love.graphics.newQuad(0,0,5,14,244,60),
	mname = love.graphics.newQuad(5,0,1,14,244,60),
	rname = love.graphics.newQuad(9,0,5,14,244,60),
}
local rawActors = love.filesystem.load("assets/actors.lua")()
local csActorImg = love.graphics.newImage("assets/actors.png")

local actors = {}
for k,v in pairs(rawActors) do
	local nActor = {}
	for l,w in pairs(v) do
		if l ~= "quads" then
			nActor[l] = w
		else
			local q = {}
			for k,v in pairs(w) do
				q[k] = love.graphics.newQuad(v[1],v[2],v[3],v[4],csActorImg:getDimensions())
			end
			nActor.quads = q
		end
	end
	actors[k] = nActor
end

-- Variable Declarations
local csWait,csLatest,csName,csText,csTextPos,csDrawnText,csTextAlign,chars
-- Cutscene Updates
function cutscene.update()
	if ctrl and inputType == 1 then
		input.jump = prButtons[cnf.jumpjs]
		input.pause = prButtons[cnf.startjs]
	else
		input.jump = prKeys[cnf.jump]
		input.pause = prKeys[cnf.start]
	end

	if cutscene.background then
		love.draw()
	end

	-- Skipping
	if input.pause then
		sound.select:play()
		cutscene.quit()
		input.pause = false
	elseif not csWait or ( csWait and input.jump ) then
		if csWait then
			sound.select:play()
		end
		if not csTextPos then
			-- Progressing the cutscene's script
			cutscene.progress = cutscene.progress + 1
			csWait = nil

			if cutscene.script[cutscene.progress] then
				local a = cutscene.script[cutscene.progress]
				csLatest = a.act
				if a.act == "move" then
					-- Moving an actor/Adding him onto the scene
					if chars[a.who] then
						chars[a.who].toposx = a.arg
						chars[a.who].toposy = 0.25
					else
						chars[a.who] = {
							quad = a.who.quads.n,
							dir = a.arg2 or 1,
							height = a.who.height,
							posx = a.arg,
							toposx = a.arg,
							posy = 1,
							toposy = 0.25
						}
					end
				elseif a.act == "text" then
					-- Make an actor say something
					csName = a.who.name
					csText = formatString(a.arg)
					csWait = true
					csTextPos = 0
					csDrawnText = ""
					csTextAlign = a.arg2 or "left"
				elseif a.act == "wait" then
					-- Waiting for input (also true for text)
					csWait = true
				elseif a.act == "disappear" then
					-- Make an actor disappear
					if chars[a.who] then
						chars[a.who].toposy = 1.05
					end
				elseif a.act == "emote" then
					-- Changing an actor's emotion
					if chars[a.who] then
						if a.who.quads[a.arg] then
							chars[a.who].quad = a.who.quads[a.arg]
						end
					end
				elseif a.act == "audio" then
					-- Play a sound
					sound[a.arg]:play()
				elseif a.act == "run" then
					-- Run a lua script
					a.arg()
				end
			else
				-- Quit the cutscene if it's over
				cutscene.quit()
			end
		else
			csTextPos = nil
			csDrawnText = csText
		end
	end

	-- Update the active actors
	if chars then
		for k,v in pairs(chars) do
			v.posx = v.posx + 0.05*(v.toposx-v.posx)
			local posX = v.posx
			v.posy = v.posy + 0.1*(v.toposy-v.posy)
			local posY = v.posy

			love.graphics.draw(csActorImg,v.quad,math.floor(winW*posX),math.floor(winH*posY),0,winH*0.75/v.height*v.dir,winH*0.75/v.height)
		end
	end

	-- Update the text box
	if csText then
		if csTextPos then
			csTextPos = csTextPos + 0.5
			if csTextPos <= utf8.len(csText) then
				if csTextPos == math.floor(csTextPos) then
					csDrawnText = csDrawnText .. csText:sub(utf8.offset(csText,csTextPos),utf8.offset(csText,csTextPos+1)-1) --csText:sub(csTextPos,csTextPos)
				end
			else
				csTextPos = nil
			end
		end

		love.graphics.push()
		local x = winW*0.5
		local scale = round(x*(1/244))
		love.graphics.scale(scale)

		x = x/scale
		local y = winH/scale

		love.graphics.draw(cutscenebox.image,cutscenebox.main,x-122,y-46)
		love.graphics.printf(csDrawnText,x-118,y-42,236,csTextAlign)

		if csName then
			local nameWidth = fonts.normal:getWidth(csName)

			love.graphics.draw(cutscenebox.image,cutscenebox.lname,x-122,y-57)
			love.graphics.draw(cutscenebox.image,cutscenebox.mname,x-117,y-57,0,nameWidth-2,1)
			love.graphics.draw(cutscenebox.image,cutscenebox.rname,x-119+nameWidth,y-57)
			love.graphics.print(csName,x-118,y-54)
		end

		love.graphics.pop()
	end
end

-- Start a cutscene
local preStatus
function cutscene.start(script,draw,endscript)
	if gameStatus ~= 2 then preStatus = gameStatus end
	gameStatus = 2

	local evscript = {}
	local customactors = {}
	for i,v in pairs(script) do
		evscript[i] = {}
		evscript[i].act = v[1]

		local who = v[2]
		if actors[who] then
			evscript[i].who = actors[who]
		else
			local ts = tostring(who)
			if customactors[ts] then
				evscript[i].who = customactors[ts]
			else
				local nactor = who == nil and {} or {name = ts}
				customactors[ts] = nactor
				evscript[i].who = nactor
			end
		end
		evscript[i].arg = v[3]
		evscript[i].arg2 = v[4]
	end
	cutscene.script = evscript

	cutscene.progress = 0
	chars = {}
	cutscene.background = draw
	if type(endscript) == "function" then
		cutscene.endingScript = endscript
	end
end

-- Quitting a cutscene and resetting values
function cutscene.quit()
	gameStatus = preStatus
	cutscene.script = nil
	if cutscene.endingScript then cutscene.endingScript() cutscene.endingScript = nil end
	csLatest,chars,csName,csText,csWait,csTextPos = nil
end

-- Check whether an actor exists (outside of this file)
function cutscene.isActor(id)
	if actors[id] then
		return true
	else
		return false
	end
end
