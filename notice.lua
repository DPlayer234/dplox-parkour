notice = {
	queue = {}
}

function notice.add(message,duration)
	local t = {
		text = message,
		dur = duration or 300,
		y = 0
	}
	if not notice.box then notice.box = t
	else table.insert(notice.queue,t) end
end

function notice.update()
	if notice.box.dur < 10 then
		notice.box.y = (notice.box.dur-10)*3.5
	else
		notice.box.y = 0
	end
	notice.box.dur = notice.box.dur - 1
	if notice.box.dur <= 0 then
		if #notice.queue > 0 then
			notice.box = notice.queue[1]
			table.remove(notice.queue,1)
		else
			notice.box = nil
		end
	end
end

local noticebgimg = love.graphics.newImage("assets/noticeBox.png")
function notice.draw()
	love.graphics.draw(noticebgimg,(vWinW-140)*screen.scale,notice.box.y*screen.scale,0,screen.scale)
	love.graphics.printf(notice.box.text,(vWinW-136)*screen.scale,(notice.box.y+4)*screen.scale,132,"center",0,screen.scale)
end
