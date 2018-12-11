trophy.give("unknown")

--LEVEL
return {
	level = {
		{0,0,0,0,1,1,1,0},{0,0,0,0,1,0,1,0},{2,0,0,0,1,1,1,0},{0,0,0,0,0,0,1,0},{0,0,0,0,0,0,1,0},{0,0,0,0,0,0,1,0},{1,1,1,1,1,1,1,0},{1,0,1,0,0,0,0,0},{1,1,1,0,0,0,0,0},
	},
	td = "void",
	music = nil,
	name = "???",
	spawn = {3,5},
	warps = {
		{6,6,"hubtown","",85,41}
	},
	bg = {
		[0] = "void.png"
	},
	textbox = math.random(1,2) == 1 and "GO\nAWAY\n!!" or "DON'T\nBE\nHERE\n!!",
	textboxAlign = "center"
}
