local username,token = unpack{...}

require "love.filesystem"
require "love.timer"
local gj = require "gamejolt"

gj.init(love.filesystem.load("gamejolt/data.lua")())

local comm = {
	set = love.thread.getChannel("gj_set"),
	ret = love.thread.getChannel("gj_ret"),
}

local orig_print = print
local function print(...)
	orig_print("Gamejolt",...)
end

local function readable(t)
	local n = {}
	for k,v in pairs(t) do
		table.insert(n,tostring(v))
	end
	return "["..table.concat(n,", ").."]"
end

local s = gj.authUser(username,token)

if s then
	local running = true

	comm.ret:push("login_success")

	gj.openSession()

	print("Fetching user-data...")
	local user = gj.fetchUserByName(username)
	if user.success then comm.ret:push({"user",user.developer_name or user.username,user.type--[[,user.id]]}) end

	print("Preparing trophy data...")

	local trophyList = require "gamejolt.trophies"
	local inverseList = {} for k,v in pairs(trophyList) do inverseList[tostring(v.id)] = k end

	local already = gj.fetchTrophiesByStatus(true)
	for k,v in pairs(already) do comm.ret:push({"trophy_achieved",inverseList[v.id]}) end

	gj.pingSession(true)

	local call = {
		trophy = function(id)
			local s = gj.giveTrophy(id)
			return id,s
		end,
		score = function(score,...)
			return gj.addScore(score,string.format("%d points",score),160960,nil,readable{...})
		end,
		logout = function()
			print("Closing session and GJ-Thread.")
			gj.closeSession()
			running = false
		end
	}

	local function handle(e,a,b,c,d)
		print("Handler",e,pcall(call[e],a,b,c,d))
	end

	print("All set!")

	local time = love.timer.getTime()

	while running do
		love.timer.sleep(0.1)

		local nt = love.timer.getTime()
		if time + 25 < nt then
			time = nt
			gj.pingSession(true)

			print("PINGed GJ-Servers")
		end

		local v = comm.set:pop()
		while v do
			if type(v) == "table" then
				handle(unpack(v))
			end
			v = comm.set:pop()
		end
	end
else
	comm.ret:push("login_failed")
end
