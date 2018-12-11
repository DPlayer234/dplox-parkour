_app_version = "v1.1.1"
_started = love.timer.getTime()

--print("lines: "..require "count")

print("Welcome to "..gameTitle.."'s debug console!\nEnjoy your stay!\n")

love.filesystem.setIdentity(love.filesystem.getIdentity(),true)
love.keyboard.setTextInput(false)

require "threads.errhand"

-- Loading Files and Libraries
require "draw"
require "update"
require "run"
require "callbacks"
--require "libs.binsave"
save = require "libs.save"
require "threads.errhand"
anim = require "libs.anim"
utf8 = require "utf8"

require "load"

-- Math related
function round(num)
	return math.floor(num + 0.5)
end

function roundm(num,mult)
	return math.floor(num * mult + 0.5) / mult
end

-- Value Stuff
function valuelize(str,mayt)
	local nstr = tonumber(str)
	if mayt and str:find(",") then
		local t = {}
		local e = 1
		for n=1,#str do
			e = str:find(",")
			if e then
				table.insert(t,valuelize(str:sub(1,e-1)))
				str = str:sub(e+1)
			end
		end
		table.insert(t,valuelize(str))
		return t
	elseif nstr then
		return nstr
	elseif str == "true" then
		return true
	elseif str == "false" then
		return false
	elseif str == "nil" then
		return nil
	else
		return str
	end
end

function serializeTable(val)
	local s = "{"
	for k,v in pairs(val) do
		local t = type(v)
		s = s.."["..(type(k)=="string" and string.format("%q",k) or tostring(k)).."]".."="
		if t == "table" then
			s = s..serializeTable(v)
		elseif t == "string" then
			s = s..string.format("%q",v)
		else
			s = s..tostring(v)
		end
		s = s..","
	end
	return s.."}"
end

-- Formated strings
local pcall = pcall
local loadstring = loadstring
local setfenv = setfenv
local _G = _G
local function rep(t)
	local suc,r = pcall(loadstring("return "..t:sub(3,#t-2)))
	if suc then
		return tostring(r)
	else
		return "[Error]"
	end
end
function formatString(s)
  local pattern = "%%%(.-%)%%"
	if type(s) == "table" then
		local t = {}
		for k,v in pairs(s) do
			if type(v) == "string" then
				t[#t+1] = formatString(v)
			else
				t[#t+1] = v
			end
		end
		return t
	else
		return s:gsub(pattern,rep)
	end
end

function formatTimer(time)
	local frm = time%60

	time = math.floor(time*(1/60))
	local sec = time%60

	time = math.floor(time*(1/60))
	local min = time%60

	time = math.floor(time*(1/60))
	local hour = time

	return string.format("%02d:%02d:%02d,%02d",hour,min,sec,frm)
end

-- Saving
saveQueue = 0
if not _args.singlethread then
	print("Threaded saving enabled.")
	function sendSave(reason,file,content)
		saving = 60
		saveQueue = saveQueue + 1
		hud.write:update("write")
		channels.saveOut:push({reason,file,serializeTable(content)})
	end
else
	print("Saving in main thread.")
	function sendSave(reason,file,content)
		saving = 60
		saveQueue = saveQueue + 1
		hud.write:update("write")
		local s = save.write(file,content)
		if s then
			channels.saveIn:push(reason)
			print("Saved "..reason.."!")
		else
			channels.saveIn:push(reason.."-")
			print("An error occurred saving "..reason..":\n",e)
		end
	end
end

-- Loading
function fileLoad(f,v)
	local file = love.filesystem.lines(f)
	local filecontent = {}
	local k = 0
	local name = ""
	local values = false
	for line in file do
		k = k + 1
		if values then
			filecontent[name] = (#filecontent[name] > 0 and filecontent[name].."\n" or "")..line
		elseif k % 2 == 0 then
			filecontent[name] = valuelize(line,v)
		else
			name = line
			if line == "values" then
				values = true
				filecontent[name] = ""
			end
		end
	end
	if values then
		filecontent[name] = valuelize(filecontent[name],v)
	end
	return filecontent
end

function fileLoadArray(f)
	local file = love.filesystem.lines(f)
	local filecontent = {}
	for line in file do
		table.insert(filecontent,line)
	end
	return filecontent
end

function cloneTable(tab)
	local newTab = {}
	for k,v in pairs(tab) do
		if type(v) == "table" then
			newTab[k] = cloneTable(v)
		else
			newTab[k] = v
		end
	end
	return newTab
end

-- Unlocking a character
function unlockChar(file)
	if not ( unlocks[file] or unlocks[file:sub(1,#file-4)] ) then
		local pfile
		if love.filesystem.isFile("player/"..file..".char") then
			pfile = fileLoad("player/"..file..".char")
		else
			pfile = fileLoad("player/"..file)
		end
		local pname = pfile.name or pfile.shortname or file
		notice.add("Unlocked Character:\n"..pname)

		file = file:gsub("%.char$","")
		unlocks[file] = true

		sendSave("Unlocks","unl.bin",unlocks)
	end
end

-- Full screen Toggle
local nFsData
function toggleFullscreen()
	local fullscreen,fsmode = love.window.getFullscreen()
	if fullscreen then
		love.window.setMode(unpack(nFsData))
	else
		nFsData = { love.window.getMode() }
		local fsres = love.window.getFullscreenModes()
		table.sort(fsres,function(a,b) return a.width*a.height > b.width*b.height end)
		love.window.setMode(fsres[1].width,fsres[1].height,nFsData[3])
		love.window.setFullscreen(true,fsmode)
		nFsData[3].fullscreen = false
	end
	love.resize(love.graphics.getDimensions())
end

-- Collision
function colide(x1,y1,w1,h1,x2,y2,w2,h2)
	return x1 < x2+w2 and x2 < x1+w1 and y1 < y2+h2 and y2 < y1+h1
end

-- Distance
function distance(x1,y1,x2,y2)
	local difx = x1-x2
	local dify = y1-y2
	return (difx*difx+dify*dify)^.5
end

-- Get "Good" Key Name
local keynames = {
	space = "Space",
	kp0 = "Num0",
	kp1 = "Num1",
	kp2 = "Num2",
	kp3 = "Num3",
	kp4 = "Num4",
	kp5 = "Num5",
	kp6 = "Num6",
	kp7 = "Num7",
	kp8 = "Num8",
	kp9 = "Num9",
	["kp."] = "Num.",
	["kp,"] = "Num,",
	["kp/"] = "Num/",
	["kp*"] = "Num*",
	["kp-"] = "Num-",
	["kp+"] = "Num+",
	kpenter = "NumEnter",
	["kp="] = "Num=",
	up = "Up",
	down = "Down",
	left = "Left",
	right = "Right",
	home = "Home",
	["end"] = "End",
	pageup = "Page Up",
	pagedown = "Page Down",
	insert = "Insert",
	backspace = "Backspace",
	tab = "Tab",
	clear = "Clear",
	["return"] = "Enter",
	delete = "Delete",
	numlock = "Num-Lock",
	capslock = "Caps-Lock",
	scrolllock = "Scroll-Lock",
	rshift = "R.Shift",
	lshift = "L.Shift",
	rctrl = "R.Ctrl",
	lctrl = "L.Ctrl",
	ralt = "R.Alt",
	lalt = "L.Alt",
	rgui = "R.Cmd",
	lgui = "L.Cmd",
	mode = "Mode",
	--www,mail,calculator,computer,appsearch,apphome,appback,appforward,apprefresh,appbookmarks
	pause = "Pause",
	escape = "Esc.",
	help = "Help",
	printscreen = "Print",
	--sysreq
	menu = "Menu",
	--application,power
	currencyunit = "$",
	undo = "Undo"
}
_special_keys = keynames

function goodKey(code)
	local key = love.keyboard.getKeyFromScancode(code)
	if key == "unknown" then key = code end
	return "["..( keynames[key] or key:upper() ).."]"
end

-- Key "Names" for controller buttons
local ctrlNames = {
	--XBox 360
	{ a = "♥", b = "♦", x = "♣", y = "♠", leftshoulder = "LB", rightshoulder = "RB", back = "Back", start = "Start", leftstick = "LS", rightstick = "RS", guide = "XBox" },
	--Dual-Shock 4
	{ a = "▲", b = "▼", x = "◄", y = "►", leftshoulder = "L1", rightshoulder = "R1", back = "Share", start = "Options", leftstick = "L3", rightstick = "R3", guide = "PS" },
	-- Others
	{ a = "(A)", b = "(B)", x = "(X)", y = "(Y)", leftshoulder = "[LEFT]", rightshoulder = "[RIGHT]", back = "Back", start = "Start", leftstick = "LStick", rightstick = "RStick", guide = "Guide"}
}

function ctrlKeyName(keyId)
	local t = cnf.ctrlType <= 2 and cnf.ctrlType or 2
	return ctrlNames[cnf.ctrlType+1][keyId] or "("..tostring(keyId)..")"
end
