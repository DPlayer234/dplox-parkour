local items = {}
local tile,_x,_y

local boss = {
	d = {},

	update = function()
		for k,v in pairs(items) do
			if colide(player.x+player.hitBox.xo,player.y+player.hitBox.yo,player.hitBox.w,player.hitBox.h,v.x-4,v.y-4,8,8) or (player.attack > 0 and colide(player.attackBox.x-player.attackBox.w/2,player.attackBox.y-player.attackBox.h/2,player.attackBox.w,player.attackBox.h,v.x-4,v.y-4,8,8)) then
				items[k] = nil
				levels.collectSth()
			else
				if v.yv == 0 then
					v.xv = v.xv * 0.87
				else
					v.xv = v.xv * 0.97
				end
				local xt = round((v.x+v.xv + (v.xv > 0 and 4 or -4))*(1/9))
				local yt = round((v.y+v.yv + (v.yv >= 0 and -1 or -8))*(1/9))
				if level[yt] then
					local t = tileData[level[yt][xt]]
					if t ~= nil then
						if t.d.hori then
							v.xv = 0
						end
					end
					v.x = v.x + v.xv
					local t2 = tileData[level(xt,yt+1)]
					if t2 ~= nil then
						if t2.d.vertneg or t2.d.nonsolid then
							v.yv = 0
						else
							v.yv = (v.yv + .14) * 0.985
						end
					else v.yv = (v.yv + .14) * 0.985 end
					v.y = v.y + v.yv

					if t ~= nil then
						if t.d.death then
							partSystem:spawnParticles("smoke",5,v.x,v.y,4,4)
							v.x = _x v.y = _y
							v.xv = math.random(-20,20)*.1 v.yv = math.random(-20,-2)*.1
							partSystem:spawnParticles("smoke",5,v.x,v.y,4,4)
						end
					end
				else
					partSystem:spawnParticles("smoke",5,v.x,v.y,4,4)
					v.x = _x v.y = _y
					v.xv = math.random(-20,20)*.1 v.yv = math.random(-20,-2)*.1
					partSystem:spawnParticles("smoke",5,v.x,v.y,4,4)
				end
			end
		end
	end,

	draw = function()
		for k,v in pairs(items) do
			love.graphics.draw(tileImg,tileData[tile].q,v.x,v.y,0,1,1,4.5,4.5)
		end
	end,

	init = function(t,n,x,y)
		tile = t
		_x = x
		_y = y
		for i=1,n do
			table.insert(items,{
				x = x, y = y, xv = math.random(-20,20)*.1, yv = math.random(-20,-2)*.1
			})
		end
	end
}

return boss
