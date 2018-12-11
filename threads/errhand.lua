--[=[local reppatt = "[\r\n\t\v\\%z\"]"
local rep = { ["\n"] = "\\n", ["\r"] = "\\r", ["\t"] = "\\t", ["\v"] = "\\v", ["\\"] = "\\\\", ["\0"] = "\\0", ["\""] = "\\\"" }
local function getcont(t,dpt,alr)
	dpt = dpt or 1
	alr = alr or {[t]=t}
	local s = "{\n"

	for k,v in pairs(t) do
		local key = tostring(k):find("^[_a-zA-Z][_a-zA-Z0-9]*$") and k or "["..(type(k)=="string" and string.format("%q",k) or tostring(k)).."]"
		s = s..string.rep("\t",dpt)..key.." = "
		local tp = type(v)
		if tp == "table" then
			if alr[v] then
				s = s.."{} --[[Already serialized "..tostring(v).."]],\n"
			else
				alr[v] = v
				s = s.."--[["..tostring(v).."]] "..getcont(v,dpt+1,alr)..",\n"
			end
		elseif tp == "string" then
			s = s.."\""..v:gsub(reppatt,rep).."\",\n"
		elseif tp == "number" or tp == "boolean" then
			s = s..tostring(v)..",\n"
		else
			s = s.."\""..(type(v)..":"..tostring(v)):gsub(reppatt,rep).."\", --Inserializable\n"
		end
	end

	return s..string.rep("\t",dpt-1).."}"
end]=]

function love.errhand(msg)
	local traceback = debug.traceback():gsub("\r",""):gsub("\n.-boot.lua.-\n","")

	print(traceback)

	local crashname = os.date("%y-%m-%d_%H.%M.%S"):lower()
	local path = "crash/"..crashname..".txt"
	local fullpath = love.filesystem.getSaveDirectory().."/"..path

	if not love.filesystem.isDirectory("crash") then
		love.filesystem.createDirectory("crash")
	end
	local saveerror = ("A critical error has occured, report to the dev:\n"..msg.."\n\n"..traceback:gsub("stack traceback","Traceback")):gsub("\n","\r\n")

	--local environment = getcont(_G)
	--local report = "--[[\n"..saveerror:gsub("%]%]","%] %]").."\n\nEnvironment:\n]]\nlocal _G = "..environment.."\nreturn _G"
	local report = saveerror:gsub("%]%]","%] %]")
	love.filesystem.write(path,report)

	local b = love.window.showMessageBox("Error!!",string.format("A critical error occured:\n\t%s\n\nA more detailed error report has been saved to %q.",msg,fullpath),{[3]=enableDebug and "Debug" or nil,[2]="Exit",[1]="Open Report",enter=2,escape=2},"error",false)

	if b == 1 then
		love.system.openURL("file://"..fullpath)
	elseif b == 3 then
		love._openConsole()

		print("Debugger started... [F4]")
		local path = "_G"
		local lastpath = ""
		local doRun = true

		local prp
		prp = {
			["goto"] = function(arg)
				local dots = arg:match("^%.+$")
				if dots then
					for i=1,#dots do
						if path:find("^getmetatable%(.*%)$") then
							local _,b = path:find("^getmetatable%(.")
							local e = path:find(".%)$")
							path = path:sub(b,e)
						else
							local a,ac = path:gsub("%[.-%]$","",1)
							local b,bc = path:gsub("%.[_a-zA-Z][_a-zA-Z0-9]*$","",1)
							path = ac>0 and a or bc>0 and b or "_G"
						end
					end
				elseif arg:find("^%.[^%.]") or arg:find("^%[.+%]") then
					path = path .. arg
				else
					path = arg
				end
			end,
			exec = function(arg)
				print(pcall(loadstring(arg)))
			end,
			quit = function(arg)
				doRun = false
			end,
			help = function(arg)
				if arg then
					print("Help for "..tostring(arg))
					print("",({
						["goto"] = "Move to the specified path.\n\tStart with '.' to append, use only '.'s to go back.",
						exec = "Run the specified code.",
						quit = "Quit the application.",
						help = "Print help."
					})[arg] or "No help.")
				else
					print("List of commands:")
					for k,v in pairs(prp) do
						print("",k)
					end
				end
			end
		}

		while doRun do
			if path ~= lastpath then
				local s,v = pcall(loadstring("return "..path))
				if s then
					print(type(v),path,tostring(v))
					if type(v) == "table" then
						for k,v in pairs(v) do
							print("",k,type(v),v)
						end
					end
				else
					print("Invalid path",path)
				end

				lastpath = path
			end

			io.write("> ")
			local input = io.read()
			local cmd = input:match("^.-%s") or input
			if cmd then
				cmd = cmd:gsub("%s","")
				if prp[cmd] then
					local arg = input:match("%s.+$")
					if arg then
						arg = arg:sub(2,#arg)
						arg = tonumber(arg) or arg
					end
					pcall(prp[cmd],arg)
				else
					print("Cannot find command.")
				end
			end
		end
	end
end
