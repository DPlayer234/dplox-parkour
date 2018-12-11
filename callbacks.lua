prKeys = {}
prButtons = {}

-- Window resized
function love.resize(w,h)
	winW = w
	winH = h

	local newScale = 2
	if winW/winH > 16/9 then
		newScale = round(winW/640*screen.scaleMult)
	else
		newScale = round(winH/360*screen.scaleMult)
	end
	screen.scale = newScale > 0 and newScale or 1

	vWinW,vWinH = winW/screen.scale,winH/screen.scale

	if bgBatch then
		for k,v in pairs(bgBatch) do
			local s = winH/bgHeight[k]/screen.scale

			bgBatch[k]:clear()
			local n = math.ceil((winW/screen.scale)/(s*bgWidth[k]))+1
			for i=1,n do
				bgBatch[k]:add((i-1)*bgWidth[k],0,0)
			end
		end
	end

	if cnf.light > 0 then
		light = love.graphics.newCanvas(w,h)
		shaders.light:send("LENGTH",(cnf.lightLenght*9)/winH*screen.scale)
		shaders.light:send("X_STEP",2/(winW*cnf.light*3))
		shaders.light:send("Y_STEP",1/(winH*cnf.light))
	end

	shaders.fade:send('screen_width',w)
	shaders.fade:send('screen_height',h)

	shaders.fade:send('x_mult',w/screen.scale/180)
	shaders.fade:send('y_mult',h/screen.scale/180)
end

-- Pause if the window is unfocused
local windowtitle
function love.focus(f)
	if not f then
		if gameStatus == 0 then
			if levels.current == levels.latestHub then
				menus.load("pauseH","pause")
			else
				menus.load("pause","pause")
			end
		end
		windowtitle = love.window.getTitle()
		love.window.setTitle("Get back here! You're not done yet!")
	elseif windowtitle then
		love.window.setTitle(windowtitle)
	end
end

-- Keys and inputs
function love.keypressed(key,us)
	if inputType ~= 0 then inputType = 0 end

	latestKey = us
	prKeys[us] = true

	if us == "f10" then
		toggleFullscreen()
	elseif us == "f1" then
		hud.show = not hud.show
	elseif us == "f2" then
		if screen.scaleMult > 1 then
			screen.scaleMult = screen.scaleMult - .5
			love.resize(winW,winH)
		end
	elseif us == "f3" then
		if screen.scaleMult < 5 then
			screen.scaleMult = screen.scaleMult + .5
			love.resize(winW,winH)
		end
	end
end

function love.gamepadpressed( js,b )
	if js and ctrl then
		if js:getID() == ctrl:getID() then
			if inputType ~= 1 then inputType = 1 end

			latestButton = b
			prButtons[b] = true
		end
	end
end

-- Controller attached or removed
function love.joystickadded( js )
	if not ctrl then
		ctrl = js
	elseif not ctrl:isConnected() then
		ctrl = js
	end
end

function love.joystickremoved( js )
	if js and ctrl then
		if js:getID() == ctrl:getID() then
			ctrl = nil
			if inputType == 1 then
				inputType = 0
			end
		end
	end
end

function love.textinput(text)
	if #text == 1 then lastText = text end
end

-- Rebooting crashed threads
function love.threaderror(thread,errorstring)
	print("Threaderror: "..errorstring)
	if thread == threads.save then
		channels.saveIn:push("Thread Crashed?!-") thread:start()
	elseif thread == threads.gamejolt then
		gj_logged_in = false
		trophy.user = nil
		notice.add("An error occured in the GJ-Thread. You'll need to log in again.")

		threads.gamejolt = nil
	end
end
