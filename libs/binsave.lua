--[[
!!ATTENTION, HUMAN!!

This is not really saving data in the usual "binary" way.
It just stores data in one file in such a format that it is impossible to run code through file loading.
And it's trickier to actually modify stored data.
All should work as long as you don't store more than uh... 10 Peta-bytes in a subtable...
I'd be surprised if any user could store close anything close to that amount in their RAM, so it SHOULD not be a problem.

Also, the code might crash if it encounters the unexpected.
Make sure the game identity is set, else this may crash because of that as well.
Or delete System32. (Probably not, you may test it if you want. (Don't!))

An additional note is, that this by default adds itself to the love.filesystem library.
If you do not want that, change line 18 and the last line.

Originally created by DPlayer234:
YOU MAY NOT SHARE THIS CODE UNDER YOUR NAME OR REMOVE ANY OF THIS NOTICE.
YOU MAY HOWEVER USE IT IN YOUR OWN PROJECTS, IF YOU CREDIT THE ORIGINAL CREATOR.
IF YOU DON'T, GO F--- YOURSELF, 'CAUSE I AIN'T HAVE THE POWER OR MONEY TO SUE YOU!
]]
local pairs = pairs
local type = type
local tostring = tostring
local tonumber = tonumber
local byte = string.byte
local rep = string.rep
local sub = string.sub
local open = io.open
local lmath = love.math

local bin = love.filesystem

local savedir = bin.getSaveDirectory()

local function binary(cont,lastindex)
	lastindex = lastindex or 0
	local cindex = lastindex
	local save = ""

	for k,v in pairs(cont) do
		local t = sub(type(v),1,1)
		k = tostring(k)
		if #k > 15 then k = sub(k,1,15) end
		local new

		if t == "t" then
			new,lastindex = binary(v,lastindex)
			lastindex = lastindex + 1

			local l = tostring(#new)
			if #l > 16 then l = rep("9",16) end
			new = l..rep("\0",16-#l)..new
		else
			new = tostring(v)
		end

		local app = #new%16
		if app == 0 then
			new = new..rep("\0",16)
		else
			new = new..rep("\0",16-app)
		end

		if new then
			local index = t..k
			if #index > 16 then index = sub(index,1,16) end
			save = save..index..rep("\0",16-#index)..new
		end
	end

	return save,lastindex
end

local function frombinary(s)
	local cont = {}

	local pos = 1
	local status = "type"
	local data = ""
	local index = ""
	local tcont

	while pos < #s do
		if status == "type" then
			data = sub(s,pos,pos)
			if data == "\0" then
				if sub(s,pos,pos+15) ~= rep("\0",16) then
					error("Invalid file format!")
				end
				pos = pos + 16
			else
				pos = pos + 1

				status = "index"
			end
		elseif status == "index" then
			index = sub(s,pos,pos+14)
			local e = index:find("\0")
			if e then index = sub(index,1,e-1) end

			pos = pos+15

			status = "read"
		elseif status == "read" then
			local oldpos = pos
			for i=pos,#s do
				if sub(s,i,i) == "\0" then
					tcont = sub(s,pos,i-1)

					if data == "n" then
						tcont = tonumber(tcont)
					elseif data == "b" then
						if tcont == "true" then
							tcont = true
						else
							tcont = false
						end
					elseif data == "t" then
						local lenght = tonumber(tcont)
						if lenght then
							tcont = frombinary(sub(s,pos+16,pos+lenght+15))

							pos = pos+lenght+16
						else
							tcont = {}
						end
					end

					if data ~= "t" then
						pos = math.ceil(i/16)*16+1
					end

					local indexn = tonumber(index)
					if indexn then index = indexn end

					cont[index] = tcont

					status = "type"
					break
				end
			end
			if oldpos == pos then
				pos = #s
			end
		end
	end

	return cont
end

function bin.writeBin(path,cont,getCheck)
	savedir = bin.getSaveDirectory()
	if type(path) == "string" and type(cont) == "table" then
		local indir = path:match(".*[/\\]")
		bin.createDirectory(indir or "") --the IO-library will not create directories for you.

		local h = open(savedir.."/"..path,"wb")

		local save = binary(cont)
		local check
		if getCheck then
			check = 0
			local n = { byte(save,1,#save) }
			for i,v in ipairs(n) do
				check = check + v
			end
		end
		if lmath then
			save = lmath.compress(save,"zlib"):getString()
		end

		h:write(save)
		h:close()

		return #save,check
	else
		error("Invalid arguments: *.writeBin(string path, table cont)")
	end
end

function bin.readBin(path)
	savedir = bin.getSaveDirectory()

	if type(path) == "string" then
		local h = open(savedir.."/"..path,"rb")
		if h then
			local s = h:read("*all")
			if lmath then
				s = lmath.decompress(s,"zlib")
			end

			h:close()

			return frombinary(s)
		else
			return false
		end
	else
		error("Invalid arguments: *.readBin(string path)")
	end
end

return { writeBin = bin.writeBin, readBin = bin.readBin }
