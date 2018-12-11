function love.draw()
	local loveGraphics = love.graphics

	loveGraphics.push()
	loveGraphics.scale(screen.scale)
	local screenx = roundm(screen.x,screen.scale)
	local screeny = roundm(screen.y,screen.scale)

	local winW = winW
	local winH = winH
	local vWinW = vWinW
	local vWinH = vWinH

	-- Background
	if bgBatch then
		local bgBatch = bgBatch
		local bgHeight = bgHeight
		local bgWidth = bgWidth
		for k,v in pairs(bgBatch) do
			local s = winH/bgHeight[k]/screen.scale
			local w = bgWidth[k]
			--local scr = tonumber(k) or 1
			loveGraphics.draw(bgBatch[k],(-screenx*k)%(w*s)-w*s,0,0,s)
		end
	end

	local tx = math.ceil(vWinW/2)-screenx
	local ty = math.ceil(vWinH/2)-screeny
	loveGraphics.translate(tx,ty)

	local leftBound = math.ceil((screenx-math.ceil(vWinW/2))/9)
	local rightBound = math.ceil((screenx+math.ceil(vWinW/2))/9)
	local upperBound = math.ceil((screeny-math.ceil(vWinH/2))/9)
	local lowerBound = math.ceil((screeny+math.ceil(vWinH/2))/9)

	-- Bosses Background
	if boss then
		if boss.drawBG then boss.drawBG() end
	end

	local levelBatch = levelBatch
	local tileData = tileData
	local level = level
	local levels = levels
	if cnf.light > 0 then
		-- With light-effects
		-- Background (No shadow)
		levelBatch:clear()
		for y=upperBound > 1 and upperBound or 1,lowerBound < levels.height and lowerBound or levels.height do
			if level[y] then
				for x=leftBound > 1 and leftBound or 1,rightBound < levels.width and rightBound or levels.width do
					local tile = level[y][x]
					if tile ~= 0 then
						local t = tileData[tile]
						if t.d.bg then levelBatch:add(t.q,x*9-9,y*9-9)
						elseif t.d.bgtile then levelBatch:add(t.d.bgtile,x*9-9,y*9-9) end
					end
				end
			end
		end
		loveGraphics.draw(levelBatch,0,0)

		loveGraphics.setCanvas(light)
		loveGraphics.clear(0,0,0,0)

		-- Finish Flag
		if finish then
			finishAnim:draw(finish.x*9-9,finish.y*9-9,0,1,1,0,18)
		end

		-- Actual Tiles
		levelBatch:clear()
		for y=upperBound,lowerBound do
			if level[y] then
				for x=leftBound,rightBound do
					local tile = level[y][x] or levels.outside
					if tile and tile ~= 0 then
						local t = tileData[tile]
						if not t.d.bg then levelBatch:add(t.q,x*9-9,y*9-9) end
					end
				end
			elseif levels.outside then
				for x=leftBound,rightBound do
					levelBatch:add(tileData[levels.outside].q,x*9-9,y*9-9)
				end
			end
		end
		loveGraphics.draw(levelBatch,0,0)
	else
		-- Without light-effects
		-- Finish Flag
		if finish then
			finishAnim:draw(finish.x*9-9,finish.y*9-9,0,1,1,0,18)
		end

		-- Tiles
		levelBatch:clear()
		for y=upperBound,lowerBound do
			if level[y] then
				for x=leftBound,rightBound do
					local tile = level[y][x] or levels.outside
					if tile and tile ~= 0 then
						local t = tileData[tile]
						if t.d.bgtile then levelBatch:add(t.d.bgtile,x*9-9,y*9-9)
						else levelBatch:add(t.q,x*9-9,y*9-9) end
					end
				end
			elseif levels.outside then
				for x=leftBound,rightBound do
					levelBatch:add(tileData[levels.outside].q,x*9-9,y*9-9)
				end
			end
		end
		loveGraphics.draw(levelBatch,0,0)
	end

	-- Warp Doors
	if warps then
		local doorBatch = doorBatch
		doorBatch:clear()
		for i,v in pairs(warps) do
			if v.x >= leftBound and v.x <= rightBound and v.y >= upperBound and v.y <= lowerBound+1 then
				doorBatch:add(v.quad,v.x*9-9,v.y*9-9,0,1,1,0,9)
			end
		end
		loveGraphics.draw(doorBatch,0,0)
	end

	-- NPCs
	if npc then
		local npcBatch = npcBatch
		npcBatch:clear()
		for i=1,#npc do
			npcBatch:add(npc[i].quad,npc[i].x,npc[i].y,0,npc[i].dir,1,npc[i].xo,npc[i].yo)
		end
		loveGraphics.draw(npcBatch,0,0)
	end

	-- Bosses Foreground
	if boss then
		if boss.draw then boss.draw() end
	end

	-- Player
	player.anim:draw(roundm(player.x,screen.scale),roundm(player.y+player.yOff,screen.scale),0,player.dir*player.scale,player.scale,player.tx,player.ty)

	-- Light Effects (Shadows)
	if cnf.light > 0 then
		loveGraphics.setCanvas()

		loveGraphics.push()
		loveGraphics.origin()

		loveGraphics.setShader(shaders.light)
		loveGraphics.draw(light)
		loveGraphics.setShader()

		loveGraphics.pop()
	end

	-- Particles
	partSystem:draw(0,0)

	-- Player Attack
	if player.attackAnim then
		loveGraphics.setColor(player.color)
		attackAnim:draw(roundm(player.attackBox.x,screen.scale),roundm(player.attackBox.y,screen.scale),0,player.attackDir,1,player.attackBox.w/2,player.attackBox.h/2)
		loveGraphics.setColor(255,255,255)
	end

	if hud.show then
		-- Warp Door Text
		if warps then
			loveGraphics.setShader(shaders.fade)
			shaders.fade:send('player_x',(player.x+vWinW*.5-screen.x)/vWinW)
			shaders.fade:send('player_y',(player.y+vWinH*.5-screen.y)/vWinH)
			for i,v in ipairs(warps) do
				local p = (distance(player.x,player.y,v.x*9-4.5,v.y*9-13) < 45 and ((ctrl and inputType == 1) and ctrlKeyName(cnf.actionjs) or goodKey(cnf.action)) or "").."\n  "..(v.name or "")
				loveGraphics.print(p,v.x*9-9,v.y*9-27)
			end
			loveGraphics.setShader()
		end

		loveGraphics.translate(-tx,-ty)

		-- Player Script
		if player.scripts.draw then
			player.scripts.draw(player,tx,ty)
		end

		if boss then
			if boss.drawHud then boss.drawHud(tx,ty) end
			if boss.hp and boss.d.hp then
				loveGraphics.draw(boss._healthbar,boss._healthbase,vWinW*.5-100,vWinH-14)

				boss._healthcont:setViewport(0,14,196*(boss.hp/boss.d.hp),14)
				loveGraphics.draw(boss._healthbar,boss._healthcont,vWinW*.5-98,vWinH-14)
			end
		end

		-- HUD
		loveGraphics.draw(hud.batch,3,16)
		if levels.isEndless then
			if finish then
				loveGraphics.print(string.format("%d (%d Highscore)",levels.currentCollect,savedata.endlessScore),27,19)
			else
				loveGraphics.print(string.format("%d Highscore",savedata.endlessScore),27,19)
			end
		else
			if finish then
				loveGraphics.print(string.format("%d / %d",levels.currentCollect,levels.totalCollect),27,19)
			else
				loveGraphics.print(string.format("%d / %d",savedata.collect,levels.collectLvl.total),27,19)
			end
		end
		loveGraphics.print(savedata.ripCount,27,35)
		if gameTimer then loveGraphics.print("Time:\n"..formatTimer(gameTimer),3,51) end
		loveGraphics.print(levels.currentName,3,3)
	end

	loveGraphics.pop()
end
