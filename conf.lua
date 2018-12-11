function love.conf(t)
	-- Main settings
	t.identity = "DPloxParkour"
	gameTitle = "DPlox Parkour"

	t.window.title = gameTitle
	t.window.icon = "assets/icon.png"
	t.window.width = 1280
	t.window.height = 720
	t.window.resizable = true
	t.window.minwidth = 640
	t.window.minheight = 360
	t.window.vsync = true
	t.gammacorrect = true

	t.version = "0.10.1"
	t.accelerometerjoystick = false

	t.modules.physics = false
	t.modules.video = false
	t.appendidentity = false

	-- Argument processing
	if type(arg) == "table" then
		local args = {}
		for i,v in ipairs(arg) do
			local _,p = v:find("^.+%=.")
			if p ~= nil then
				local value = v:sub(p,#v)
				local asnum = tonumber(value)
				if asnum ~= nil then value = asnum
				elseif value == "true" then value = true
				elseif value == "false" then value = false end
				args[v:sub(1,p-2)] = value
			else
				args[v] = true
			end
		end

		t.window.fullscreentype = (args.fstype == "desktop" or args.fstype == "exclusive") and args.fstype or "desktop"

		t.gammacorrect = not args.nosrgb
		t.console = args.console or false
		if type(args.identity) == "string" then t.identity = args.identity end
		if type(args.window) == "string" then
			local p = args.window:find(",")
			if p ~= nil then
				t.window.width = tonumber(args.window:sub(1,p-1)) or t.window.width
				t.window.height = tonumber(args.window:sub(p+1,#args.window)) or t.window.height
			end
		end

		if args.debug ~= nil then _startup = t end

		_args = args
	else
		_args = {}
	end

	-- Remove this function after initialization
	love.conf = nil
end
