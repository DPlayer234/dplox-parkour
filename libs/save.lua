local save = {}

save._write = love.filesystem.write
save._read = love.filesystem.read

function save._compress(d)
	local s,n = pcall(love.math.compress,d,"zlib")
	if s then
		return n:getString()
	else
		print("SAVE._COMPRESS","Could not compress data")
		return d
	end
end

function save._decompress(d)
	local s,n = pcall(love.math.decompress,d,"zlib")
	if s then
		return n
	else
		print("SAVE._DECOMPRESS","Could not decompress data")
		return d
	end
end

local encodedata,writetable

function encodedata(v)
	local t = type(v)
	local d,dt
	if t == "table" then
	-- TABLES
		d = writetable(v)
		if d == nil then
			return nil
		else
			dt = "\000"
			local d2 = string.format("%x",#d)
			local dl = string.char(#d2)
			if string.byte(dl) == #d2 then
				return dt..dl..d2..d
			else
				return nil
			end
		end
	elseif t == "number" then
	-- NUMBERS
		local as = v%1 == 0 and string.format("%d",v) or string.format("%.14f",v):gsub("0*$","")
		local n = false
		if as:find("^%-") then
			n = true
			as = as:gsub("^%-","")
		end
		local p = as:find("%.")
		if p then
			d = string.format("%s%x.%x",n and "-" or "",tonumber(as:sub(1,p-1)),tonumber(as:sub(p+1,#as)))
			dt = "\001"
		else
			d = string.format("%s%x",n and "-" or "",v)
			dt = "\002"
		end
	elseif t == "string" then
	-- STRINGS
		d = v
		dt = "\003"
	elseif t == "boolean" then
	-- BOOLEANS
		if v then
			d = "\001"
		else
			d = "\000"
		end
		dt = "\004"
	else
	-- INVALID
		d = "\000\255"..t
		dt = "\005"
		print("SAVE.WRITE","Invalid value "..tostring(v).." of type "..t)
	end
	local dl = string.char(#d)
	if string.byte(dl) == #d then
		return dt..dl..d
	else
		return nil
	end
end

function writetable(data)
	local out = ""
	for k,v in pairs(data) do
		local ks = encodedata(k)
		local vs = encodedata(v)
		if vs == nil or ks == nil then return nil end
		out = out .. ks .. vs
	end
	return out
end

function save.write(path,data)
	local suc,output = pcall(writetable,data)

	if suc and output then
		return save._write(path,save._compress(output))
	else
		return false,output or "Over-sized element! (>255 bytes)"
	end
end

local readtable
local typedecode = {
	["\000"] = "table",
	["\001"] = "double",
	["\002"] = "integer",
	["\003"] = "string",
	["\004"] = "boolean",
	["\005"] = "invalid",
}

function readtable(data)
	local out = {}
	local b,e = 0,0
	while true do
		local v = {}
		for i=1,2 do
			b,e = data:find("[%z\001\002\003\004\005]",e+1)
			if b and e then
				local t = typedecode[data:sub(b,e)]

				local d
				if t == "table" then
					local dl = string.byte(data:sub(b+1,e+1))
					local d2 = tonumber(data:sub(e+2,e+1+dl),16)
					d = readtable(data:sub(e+2+dl,e+1+dl+d2))

					e = e+1+dl+d2
				else
					local dl = string.byte(data:sub(b+1,e+1))
					d = data:sub(e+2,e+1+dl)

					e = e+1+dl

					if t == "double" then
						local p = d:find("%.")
						if d:find("^%-") then
							d = -tonumber(tostring(tonumber(d:sub(2,p-1),16)).."."..tostring(tonumber(d:sub(p+1,#d),16)))
						else
							d = tonumber(tostring(tonumber(d:sub(1,p-1),16)).."."..tostring(tonumber(d:sub(p+1,#d),16)))
						end
					elseif t == "integer" then
						if d:find("^%-") then
							d = -tonumber(d:sub(1,#d),16)
						else
							d = tonumber(d,16)
						end
					elseif t == "boolean" then
						if d == "\000" then
							d = false
						else
							d = true
						end
					elseif t == "invalid" then
						print("SAVE.READ","Invalid element loaded")
					end
				end
				if i == 1 then
					v.k = d
				else
					v.v = d
				end
			else
				return out
			end
		end
		out[v.k] = v.v
	end
end

function save.read(path)
	local input = save._decompress(save._read(path))

	local suc,output = pcall(readtable,input)

	if suc then
		return output
	else
		return nil,output
	end
end

return save
