help = {}
local help = help

local preStatus
local helpString,helpStringR,charHelp
local widthL
local inputString
local page
function help.load()
	if #player.helpInfoTable > 0 then
		charHelp = formatString(player.helpInfoTable)
	else
		charHelp = formatString(player.helpInfo)
	end

	local baseColor = {127,146,255}
	local tinted = {255,255,255}
	helpString = {
		baseColor,"Move: \n\tLeft: ",tinted,goodKey(cnf.moveLeft),
		baseColor,"\n\tRight: ",tinted,goodKey(cnf.moveRight),
		baseColor,"\n\tUp: ",tinted,goodKey(cnf.moveUp),
		baseColor,"\n\tDown: ",tinted,goodKey(cnf.moveDown),
		baseColor,"\nJump: ",tinted,goodKey(cnf.jump),
		baseColor,"\nAction: ",tinted,goodKey(cnf.action),
		baseColor,"\nStart: ",tinted,goodKey(cnf.start),
		baseColor,"\nSelect: ",tinted,goodKey(cnf.select),
	}
	helpStringR = {
		tinted,"LStick or DPad\n\n\n"..
		ctrlKeyName(cnf.upjs).."\n"..
		ctrlKeyName(cnf.downjs).."\n"..
		ctrlKeyName(cnf.jumpjs).."\n"..
		ctrlKeyName(cnf.actionjs).."\n"..
		ctrlKeyName(cnf.startjs).."\n"..
		ctrlKeyName(cnf.selectjs)
	}
	widthL = fonts.normal:getWrap(helpString,236)

	help.img = love.graphics.newImage("assets/help.png")
	if cnf.ctrlType == 0 then
		help.quad = love.graphics.newQuad(0,27,42,27,help.img:getDimensions())
	elseif cnf.ctrlType == 1 then
		help.quad = love.graphics.newQuad(0,0,42,27,help.img:getDimensions())
	end
	help._2 = love.graphics.newQuad(42,0,117,83,help.img:getDimensions())

	local pstr = goodKey(cnf.action).."/"..ctrlKeyName(cnf.actionjs).." > Exit\n"..goodKey(cnf.jump).."/"..ctrlKeyName(cnf.jumpjs).." > Switch Page"
	inputString = pstr

	preStatus = gameStatus
	gameStatus = 3

	page = 0
end

function help.unload()
	gameStatus = preStatus
	helpString,helpStringR,charHelp,inputString = nil

	help.img,help.quad = nil
end

function help.update()
	if ctrl and inputType == 1 then
		input.action = prButtons[cnf.actionjs]
		input.jump = prButtons[cnf.jumpjs]
		input.pause = prButtons[cnf.startjs]
		input.select = prButtons[cnf.selectjs]
	else
		input.action = prKeys[cnf.action]
		input.jump = prKeys[cnf.jump]
		input.pause = prKeys[cnf.start]
		input.select = prKeys[cnf.select]
	end

	help.draw()

	if input.action then
		help.unload()
		sound.select:play()
	elseif input.jump then
		page = 1-page
		sound.select:play()
	end
end

function help.draw()
	love.draw()

	love.graphics.push()

	local s = math.floor(screen.scale/screen.scaleMult*1.5)
	love.graphics.scale(s)

	local vWinW,vWinH = winW/s,winH/s
	local centerX,centerY = math.floor(vWinW/2),math.floor(vWinH/2)

	love.graphics.draw(menus.bgImg,menus.bgQuads.main,centerX,centerY,0,1,1,122,102)

	if page == 0 then
		love.graphics.setFont( fonts.bold )
		love.graphics.print("Controls – Button Layout",centerX-118,centerY-98)

		love.graphics.setFont( fonts.normal )

		love.graphics.printf(helpString,centerX-118,centerY-83,widthL,"justify")
		love.graphics.print(helpStringR,centerX-112+widthL,centerY-83)

		if cnf.ctrlType <= 1 then
			love.graphics.draw(help.img,help.quad,centerX+33,centerY+12,0,2)
		end

		love.graphics.print(charHelp,centerX-118,centerY+8)
	else
		love.graphics.setFont( fonts.bold )
		love.graphics.print("Controls – Basic Actions",centerX-118,centerY-98)

		love.graphics.setFont( fonts.normal )

		love.graphics.draw(help.img,help._2,centerX-117,centerY-89,0,2)
	end

	love.graphics.print(inputString,centerX-118,centerY+79)

	love.graphics.pop()
end
