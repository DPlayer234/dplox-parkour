require "love.filesystem"
require "love.math"
local save = require "libs.save"

local c = love.thread.getChannel("save")
local b = love.thread.getChannel("saver")
local print = print
local pcall = pcall
local write = save.write
local select = select
local loadstring = loadstring or load
local type = type

if ({...})[1] == true then
	local p = love.thread.getChannel("print")
	local rprint = print
	print = function(...)
		p:push({...})
		rprint(...)
	end
end

while true do
	v = c:demand()
	if type(v) == "table" then
		local reason,file,content = unpack(v)
		local s = write(file,select(2,pcall(loadstring("return "..content))))
		if s then
			b:push(reason)
			print("Saved "..reason.."!")
		else
			b:push(reason.."-")
			print("An error occurred saving "..reason..":\n",e)
		end
	else
		print("Invalid data sent.")
	end
end
