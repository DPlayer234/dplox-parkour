editor = {}
local editor = editor

local init = false

local filename
local tset
local timg
local w,h
local tiles
local tileimg
local screen
local levelbatch,tiledata
local selector,selectorimg,selectionred,selectionbatch,selectionrimg,selectionrbatch
local selectedTile
local selection
local hX,hY
local fillSelection,fillOrigPoint
local level

function editor.load(f,s,_w,_h,i)
	filename = f or _args.editor
	tset = s or _args.tileset
	w = _w or _args.editor_w or 50
	h = _h or _args.editor_h or 50

	if love.filesystem.isFile("editor_out/"..filename..".lua") then
		level = love.filesystem.load("editor_out/"..filename..".lua")()
		w = #level[1]
		h = #level
	else
		level = {}
		for y=1,h do
			level[y] = {}
			for x=1,w do
				level[y][x] = 0
			end
		end
	end

	tiles = tileSets[tset or levels.tileset]
	tileimg = love.graphics.newImage("assets/tiles/"..(i or tiles.image))
	tileimg:setFilter("nearest","nearest")
	tiledata = {}
	for i=1,#tiles.data do
		tiledata[i-1] = { q = love.graphics.newQuad(tiles.data[i][1]*9-9,tiles.data[i][2]*9-9,9,9,tileimg:getDimensions()) }
	end

	screen = {x=9,y=9}

	levelbatch = love.graphics.newSpriteBatch(tileimg,20000)

	selector = love.graphics.newImage("editor/cursor.png")
	selectionimg = love.graphics.newImage("editor/selection.png")
	selectionbatch = love.graphics.newSpriteBatch(selectionimg,20000)
	selectionrimg = love.graphics.newImage("editor/selectionred.png")
	selectionrbatch = love.graphics.newSpriteBatch(selectionrimg,20000)

	selectedTile = 1
	hX,hY = 1,1

	levels.set({level=level,td=tset or levels.tileset,bg=levels.bgs[tset],name="EDITOR"})

	init = true
	gameStatus = 4
	love.mouse.setVisible(true)

	function load(file)
		love.filesystem.load(file)()
	end
end

function editor.draw()
	love.graphics.setScissor(-screen.x-9,-screen.y-9,#level[1]*9+18,#level*9+18)

	love.graphics.clear(0,150,255)

	levelbatch:clear()
	local leftBound = math.floor(screen.x/9)-1
	local rightBound = math.ceil((screen.x+winW)/9)+1
	local upperBound = math.floor(screen.y/9)-1
	local lowerBound = math.ceil((screen.y+winH)/9)+1
	for y=upperBound,lowerBound do
		if level[y] then
			for x=leftBound,rightBound do
				if level[y][x] ~= 0 and x >= 1 and x <= #level[y] then
					levelbatch:add(tiledata[level[y][x]].q,x*9-screen.x,y*9-screen.y)
				end
			end
		end
	end

	levelbatch:add(tiledata[selectedTile].q,0,0,0,2)
	love.graphics.draw(levelbatch,0,0)

	if fillSelection then
		selectionbatch:clear()
		for x=fillSelection[1],fillSelection[2] do
			for y=fillSelection[3],fillSelection[4] do
				selectionbatch:add(x*9-screen.x,y*9-screen.y)
			end
		end
		love.graphics.draw(selectionbatch,0,0)
	end

	if selection then
		selectionrbatch:clear()
		for x=selection[1],selection[2] do
			for y=selection[3],selection[4] do
				selectionrbatch:add(x*9-screen.x,y*9-screen.y)
			end
		end
		love.graphics.draw(selectionrbatch,0,0)
	end

	if level[hY] then if level[hY][hX] then
		love.graphics.draw(selector,hX*9-screen.x,hY*9-screen.y)
	end end

	local printtext = string.format("Hover : %d,%d\nScrolled : %d,%d",hX,hY,screen.x/9,screen.y/9)
	if selection then
		printtext = printtext.."\nSelection = "..simpleTable(selection,nil,true)
	end
	love.graphics.printf(printtext,19,1,winW-2,"left")

	love.graphics.setScissor()
end

function editor.update()
	hX,hY = math.floor((love.mouse.getX()+screen.x)/9),math.floor((love.mouse.getY()+screen.y)/9)

	if prKeys["f3"] then
		love.system.openURL("file://"..love.filesystem.getSaveDirectory().."/editor_out/")
		love.filesystem.write("editor_out/"..filename..".lua","return "..simpleTable(level,nil,true))
	end

	if love.keyboard.isDown("d") then
		screen.x = screen.x + 9
		if screen.x > (#level[1]-math.floor(winW/9)+1)*9 then
			screen.x = (#level[1]-math.floor(winW/9)+1)*9
		end
	elseif love.keyboard.isDown("a") then
		screen.x = screen.x - 9
		if screen.x < 9 then
			screen.x = 9
		end
	end
	if love.keyboard.isDown("s") then
		screen.y = screen.y + 9
		if screen.y > (#level-math.floor(winH/9)+1)*9 then
			screen.y = (#level-math.floor(winH/9)+1)*9
		end
	elseif love.keyboard.isDown("w") then
		screen.y = screen.y - 9
		if screen.y < 9 then
			screen.y = 9
		end
	end

	if prKeys["q"] or prKeys["wd"] then
		selectedTile = selectedTile - 1
		if selectedTile < 1 then
			selectedTile = #tiledata
		end
	elseif prKeys["e"] or prKeys["wu"] then
		selectedTile = selectedTile + 1
		if selectedTile > #tiledata then
			selectedTile = 1
		end
	elseif love.keyboard.isDown("1") then
		selectedTile = selectedTile - 1
		if selectedTile < 1 then
			selectedTile = #tiledata
		end
	elseif love.keyboard.isDown("3") then
		selectedTile = selectedTile + 1
		if selectedTile > #tiledata then
			selectedTile = 1
		end
	end

	if love.mouse.isDown(1) then
		if love.keyboard.isDown("lshift") then
			if not fillSelection then
				fillSelection = {hX,hX,hY,hY}
				fillOrigPoint = {hX,hY}
			else
				if fillSelection[1] >= hX or ( fillSelection[1] < hX and hX <= fillOrigPoint[1] ) then
					fillSelection[1] = hX
				elseif hX > fillOrigPoint[1] then
					fillSelection[1] = fillOrigPoint[1]
				end

				if fillSelection[2] <= hX or ( fillSelection[2] > hX and hX >= fillOrigPoint[1] ) then
					fillSelection[2] = hX
				elseif hX < fillOrigPoint[1] then
					fillSelection[2] = fillOrigPoint[1]
				end

				if fillSelection[3] >= hY or ( fillSelection[3] < hY and hY <= fillOrigPoint[2] ) then
					fillSelection[3] = hY
				elseif hX > fillOrigPoint[2] then
					fillSelection[3] = fillOrigPoint[2]
				end

				if fillSelection[4] <= hY or ( fillSelection[4] > hY and hY >= fillOrigPoint[2] ) then
					fillSelection[4] = hY
				elseif hX < fillOrigPoint[2] then
					fillSelection[4] = fillOrigPoint[2]
				end
			end
		else
			if fillSelection then
				fillSelection = nil
				fillOrigPoint = nil
			end
			if level[hY] then
				if level[hY][hX] then
					level[hY][hX] = selectedTile
				end
			end
		end
	elseif love.mouse.isDown(2) then
		if love.keyboard.isDown("lshift") then
			if not selection then
				selection = {hX,hX,hY,hY}
				origPoint = {hX,hY}
			else
				if selection[1] >= hX or ( selection[1] < hX and hX <= origPoint[1] ) then
					selection[1] = hX
				elseif hX > origPoint[1] then
					selection[1] = origPoint[1]
				end

				if selection[2] <= hX or ( selection[2] > hX and hX >= origPoint[1] ) then
					selection[2] = hX
				elseif hX < origPoint[1] then
					selection[2] = origPoint[1]
				end

				if selection[3] >= hY or ( selection[3] < hY and hY <= origPoint[2] ) then
					selection[3] = hY
				elseif hX > origPoint[2] then
					selection[3] = origPoint[2]
				end

				if selection[4] <= hY or ( selection[4] > hY and hY >= origPoint[2] ) then
					selection[4] = hY
				elseif hX < origPoint[2] then
					selection[4] = origPoint[2]
				end
			end
		else
			if level[hY] then
				if level[hY][hX] then
					level[hY][hX] = 0
				end
			end
		end
	end

	if fillSelection and love.keyboard.isDown("lshift") and not love.mouse.isDown(1) then
		for y=fillSelection[3],fillSelection[4] do
			if level[y] then
				for x=fillSelection[1],fillSelection[2] do
					if level[y][x] then
						level[y][x] = selectedTile
					end
				end
			end
		end
		fillSelection = nil
	end

	if selection then
		if love.keyboard.isDown("lctrl") and prKeys["c"] then
			local clip = "{"
			for y=selection[3],selection[4] do
				clip = clip.."{"
				for x=selection[1],selection[2] do
					clip = clip..tostring(level[y][x])..","
				end
				clip = clip.."},"
			end
			clip = clip.."}"
			love.system.setClipboardText(clip)
		elseif love.keyboard.isDown("lctrl") and prKeys["v"] then
			local f = loadstring("return "..love.system.getClipboardText())
			local r = ""
			if f then
				r = f()
				if type(r) == "table" then
					for y=1,#r do
						for x=1,#r[y] do
							level[selection[3]+y-1][selection[1]+x-1] = r[y][x]
						end
					end
				end
			end
		end
	end

	if prKeys["r"] or love.mouse.isDown(1) then
		selection = nil
		origPoint = nil
	end

	if prKeys["t"] then
		player.x = hX*9
		player.y = hY*9
		player.respawn = { player.x,player.y }
	end

	if love.keyboard.isDown("pageup") then
		if prKeys["up"] then
			table.insert(level,1,cloneTable(level[1]))
		elseif prKeys["down"] then
			table.insert(level,cloneTable(level[#level]))
		elseif prKeys["left"] then
			for i=1,#level do
				table.insert(level[i],1,level[i][1])
			end
		elseif prKeys["right"] then
			for i=1,#level do
				table.insert(level[i],level[i][#level[i] ])
			end
		end
	elseif love.keyboard.isDown("pagedown") then
		if prKeys["up"] then
			table.remove(level,1)
		elseif prKeys["down"] then
			table.remove(level,#level)
		elseif prKeys["left"] then
			for i=1,#level do
				table.remove(level[i],1)
			end
		elseif prKeys["right"] then
			for i=1,#level do
				table.remove(level[i],#level[i])
			end
		end
	end

	prKeys = {}
end

function editor.export()
	return level
end

local origkeypressed = love.keypressed
function love.keypressed(key,us,rep)
	origkeypressed(key,us,rep)

	if us=="f2" then
		if gameStatus == 0 and init then
			gameStatus = 4
			love.mouse.setVisible(true)
		elseif gameStatus == 4 then
			gameStatus = 0
			local c = cloneTable(level)
			set2d(c)
			_G.level = c
			levels.width = #c[1]
			levels.height = #c
			npc = nil
			warps = nil
			finish = nil
			love.mouse.setVisible(false)
		end
	end
end

function love.mousepressed(x,y,key,t)
	prKeys[key] = true
end

function simpleTable(val, name, skipnewlines)
	skipnewlines = skipnewlines or false
	local tmp = ""
	if type(val) == "table" then
		tmp = tmp .. "{" .. (not skipnewlines and "\n" or "")
		for k, v in pairs(val) do
			tmp =	tmp .. simpleTable(v, k, skipnewlines) .. "," .. (not skipnewlines and "\n" or "")
		end
		tmp = tmp .. "}"
	elseif type(val) == "number" then
		tmp = tmp .. tostring(val)
	elseif type(val) == "string" then
		tmp = tmp .. string.format("%q", val)
	elseif type(val) == "boolean" then
		tmp = tmp .. (val and "true" or "false")
	end
	return tmp
end
