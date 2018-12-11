local function terrain(obj)
	-- x movement
	local closest
	local pC
	pC = { math.ceil((obj.y-6)/9),math.ceil(obj.y/9),math.floor((obj.y+17)/9) }
	for k=1,#pC do
		local yt = level[pC[k]]
		if yt then
			local xt = -1
			if yt[round((obj.x+obj.xv+8.5)/9)] and obj.xv > 0 then
				xt = round((obj.x+obj.xv+8.5)/9)
			elseif yt[round((obj.x+obj.xv)/9)] and obj.xv < 0 then
				xt = round((obj.x+obj.xv)/9)
			end
			if xt >= 0 then
				if tileData[yt[xt] ] then
					local tile = tileData[yt[xt] ]
					if tile.d.hori then -- Solid
						closest = xt
						break
					end
				end
			end
		end
	end
	if closest then -- Position Calculation
		obj.data.w = true
		obj.xv = 0
		if obj.data.m then
			obj.data.m = false
		end
	else
		obj.x = obj.x + obj.xv
		obj.data.w = false
	end

	-- y movement
	local closest
	local pC2 = { math.floor((obj.x+5.1)/9),math.ceil((obj.x+3.9)/9) }
	for k=1,2 do
		local j = pC2[k]
		if obj.yv > 0 then -- y positive (down)
			local yt = round((obj.y+obj.yv+14)/9)
			local ytt = level[yt]
			if ytt then
				if ytt[j] then
					local tile = tileData[ytt[j]]
					if tile then
						if tile.d.vert or tile.d.nonsolid then -- Solid Collision +y and Dropping
							obj.data.g = true
							closest = yt
							break
						end
					end
				end
			end
		elseif obj.yv < 0 then -- y negative (up)
			local yt = round((obj.y+obj.yv-4)/9)
			local ytt = level[yt]
			if ytt then
				if ytt[j] then
					local tile = tileData[ytt[j]]
					if tile then
						if tile.d.vertneg then -- Solid Collision -y
							closest = yt
						end
					end
				end
			end
		else
			break
		end
	end
	if closest then -- Position Calculation
		if obj.yv > 0 then
			obj.y = closest*9-18
		else
			obj.y = closest*9+8
		end
		obj.yv = 0
	else
		if obj.data.g then
			obj.data.g = false
		end
		obj.y = obj.y + obj.yv
	end
end

local sans = {
	reset = function()
		sans.data = { g = false, m = false, w = false }
		sans.x = 36
		sans.y = 297
	end
}
sans.reset()

local quote = {
	reset = function()
		quote.data = { g = false, m = false, w = false }
		quote.x = 297
		quote.y = 297
	end
}
quote.reset()

local speechProgress = 0
local speech = {
	{1,"Huh."},
	{1,"if i was you, i'd be stopping this now"},
	{2,"No, monster."},
	{1,"you're really calling me a monster? that's funny"},
	{1,"just go ahead"},
	{1,"because on days like these, kids like you--"},
	{2,"You're not scaring me. That's all you've got?"},
	{1,"guess you want to see my full power?"},
	{1,"you've got guts, i'll give you that"},
	{1,"but it's not gonna save you"}
}

local boss = {
	reset = function()
		sans.reset()
		quote.reset()

		speechProgress = 0
	end,
	update = function()
		sans.update()
		quote.update()

		speechProgress = speechProgress + 1
	end,
	draw = function()
		sans.draw()
		quote.draw()
	end,
	drawHud = function(tx,ty)
		local line = speech[math.ceil(speechProgress/120)]
		if line then
			local x,y
			if line[1] == 1 then
				x = sans.x
				y = sans.y
			else
				x = quote.x
				y = quote.y
			end
			love.graphics.printf(line[2],x+tx,y-27+ty,500,"center")
		end
	end
}

return boss
