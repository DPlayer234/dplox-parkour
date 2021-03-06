local presettiles = {
	coin = {1,10,"collect","anim",{{1,1,10},{7,2,10},{13,3,10},{19,4,10},{25,5,10},{31,6,10},{39,"loop"}}},
	gem = {1,11,"collect","anim",{{1,1,11},{50,2,11},{55,3,11},{60,2,11},{65,"loop"}}},
	prezule = {4,11,"collect"}
}

local hitfunc = {
	destroy = function(x,y,part)
		level[y][x] = 0
		sound.destroy:play(x*9+4,y*9+4)
		if part then
			partSystem:spawnParticles(particleId[part],9,x*9-4,y*9-4,4,4)
		end
	end,
	text = function(x,y,_,att)
		if not att then cutscene.start({{"text",nil,levels.textbox,levels.textboxAlign}},true) end
	end,
	destroyinto = function(x,y,arg)
		local into = arg[1] or 0
		level[y][x] = into
		sound.destroy:play(x*9+4,y*9+4)
		local part = arg[2]
		if part then
			partSystem:spawnParticles(particleId[part],9,x*9-4,y*9-4,4,4)
		end
	end
}

tileSets = {
	forest = {
		data = {
			{1,1,"preason"},
			{1,2,"solid","part",2}, --grass:1-9
			{2,2,"solid","part",2},
			{3,2,"solid","part",2},
			{1,3,"solid"},
			{2,3,"solid"},
			{3,3,"solid"},
			{1,4,"solid"},
			{2,4,"solid"},
			{3,4,"solid"},
			{4,2,"solid"}, --stone:10-18
			{5,2,"solid"},
			{6,2,"solid"},
			{4,3,"solid"},
			{5,3,"solid"},
			{6,3,"solid"},
			{4,4,"solid"},
			{5,4,"solid"},
			{6,4,"solid"},
			{1,1,"solid","stair"}, --test:19
			{2,1,"nonsolid"},
			{3,1,"bg"},
			{4,1,"bg"},
			{5,1,"bg"},
			{6,1,"bg"},
			{1,5,"solid"},
			{2,5,"solid"},
			{3,5,"solid"},
			{1,6,"solid"},
			{2,6,"solid"},
			{3,6,"solid"},
			{1,7,"solid"},
			{2,7,"solid"},
			{3,7,"solid"},
			{4,5,"solid"},
			{4,7},
			{5,7,"solid"},
			{6,7},
			{4,6,"solid"},
			{5,6,"solid"},
			{5,5,"solid"},
			{6,5,"solid"},
			{6,6,"anim",{{1,6,6},{30,6,11},{50,6,6},{80,5,11},{100,"loop"}},"bg"},
			{1,8,"death"},
			{2,8,"death"},
			{3,8,"death"},
			{4,8,"death"},
			{5,8,"death"},
			{6,8,"death"},
			{1,9,"death"},
			{2,9,"death"},
			{3,9,"death"},
			{4,9,"death"},
			{5,9,"death"},
			{6,9,"death"},
			presettiles.coin,
			presettiles.gem,
			presettiles.prezule,
			{7,1,"solid","hit",hitfunc.text}
		},
		image = "forest.png"
	},
	cave = {
		data = {
			{1,1,"preason"},
			{1,2,"solid"},
			{2,2,"solid"},
			{3,2,"solid"},
			{1,3,"solid"},
			{2,3,"solid"},
			{3,3,"solid"},
			{1,4,"solid"},
			{2,4,"solid"},
			{3,4,"solid"},
			{4,2,"solid"},
			{5,2,"solid"},
			{6,2,"solid"},
			{4,3,"solid"},
			{5,3,"solid"},
			{6,3,"solid"},
			{4,4,"solid"},
			{5,4,"solid"},
			{6,4,"solid"},
			{1,1,"solid","stair"},
			{2,1,"nonsolid"},
			{3,1,"bg"},
			{4,1,"bg"},
			{5,1,"bg"},
			{6,1,"bg"},
			{1,5,"death"},
			{2,5,"death"},
			{3,5,"death"},
			{1,6,"death"},
			{2,6,"death"},
			{3,6,"death"},
			{1,7,"death"},
			{2,7,"death"},
			{3,7,"death"},
			{4,5,"death"},
			{5,5,"death"},
			{4,6,"death"},
			{5,6,"death"},
			{1,8,"death"},
			{2,8,"death"},
			{3,8,"death"},
			{4,8,"death"},
			{5,8,"death"},
			{6,8,"death"},
			{1,9,"death"},
			{2,9,"death"},
			{3,9,"death"},
			{4,9,"death"},
			{5,9,"death"},
			{6,9,"death"},
			presettiles.coin,
			presettiles.gem,
			presettiles.prezule,
		},
		image = "cave.png"
	},
	desert = {
		data = {
			{1,1,"preason"},
			{1,2,"solid","part",3}, --sand:1-9
			{2,2,"solid","part",3},
			{3,2,"solid","part",3},
			{1,3,"solid"},
			{2,3,"solid"},
			{3,3,"solid"},
			{1,4,"solid"},
			{2,4,"solid"},
			{3,4,"solid"},
			{4,2,"solid","part",3}, --sandstone:10-18
			{5,2,"solid","part",3},
			{6,2,"solid","part",3},
			{4,3,"solid"},
			{5,3,"solid"},
			{6,3,"solid"},
			{4,4,"solid"},
			{5,4,"solid"},
			{6,4,"solid"},
			{5,7,"solid","hit"},
			{6,7,"solid","hit",hitfunc.destroy,"hitarg",4},
			{4,6,"solid","part",2},
			{5,6,"solid","part",2},
			{6,6,"solid","part",2},
			{1,1,"solid","stair"}, --test:19
			{2,1,"nonsolid"},
			{3,1,"bg"},
			{4,1,"bg"},
			{5,1,"bg"},
			{6,1,"bg"},
			{4,5,"anim",{{1,4,5},{30,5,5},{50,4,5},{80,6,5},{100,"loop"}},"bg"},
			{3,5,"bg"},
			{2,6,"bg"},
			{3,6,"bg"},
			{2,7,"bg"},
			{3,7,"bg"},
			{4,7,"death"},
			{1,5,"death"},
			{1,6,"death"},
			{1,7,"death"},
			{2,5,"death"},
			{1,8,"death"},
			{2,8,"death"},
			{3,8,"death"},
			{4,8,"death"},
			{5,8,"death"},
			{6,8,"death"},
			{1,9,"death"},
			{2,9,"death"},
			{3,9,"death"},
			{4,9,"death"},
			{5,9,"death"},
			{6,9,"death"},
			presettiles.coin,
			presettiles.gem,
			presettiles.prezule,
			{5,11,"solid"}
		},
		image = "desert.png"
	},
	ice = {
		data = {
			{1,1,"preason"},
			{1,2,"solid"}, --snow
			{2,2,"solid"},
			{3,2,"solid"},
			{1,3,"solid"},
			{2,3,"solid"},
			{3,3,"solid"},
			{1,4,"solid"},
			{2,4,"solid"},
			{3,4,"solid"},
			{4,2,"solid","hit",hitfunc.destroyinto,"hitarg",{19,5}}, --ice
			{5,2,"solid","hit",hitfunc.destroyinto,"hitarg",{20,5}},
			{6,2,"solid","hit",hitfunc.destroyinto,"hitarg",{21,5}},
			{4,3,"solid","hit",hitfunc.destroyinto,"hitarg",{22,5}},
			{5,3,"solid","hit",hitfunc.destroyinto,"hitarg",{23,5}},
			{6,3,"solid","hit",hitfunc.destroyinto,"hitarg",{24,5}},
			{4,4,"solid","hit",hitfunc.destroyinto,"hitarg",{25,5}},
			{5,4,"solid","hit",hitfunc.destroyinto,"hitarg",{26,5}},
			{6,4,"solid","hit",hitfunc.destroyinto,"hitarg",{27,5}},
			{4,7,"solid"}, --brokenIce
			{5,7,"solid"},
			{6,7,"solid"},
			{4,8,"solid"},
			{5,8,"solid"},
			{6,8,"solid"},
			{4,9,"solid"},
			{5,9,"solid"},
			{6,9,"solid"},
			{5,5,"solid"},
			{1,9},
			{5,6,"solid"},
			{2,9},
			{6,5,"solid"},
			{3,8},
			{6,6,"solid"},
			{3,9},
			{3,7,"solid"},
			{1,8,"solid"},
			{2,8,"solid"},
			{1,1,"solid","stair"}, --test
			{2,1,"nonsolid"},
			{3,1,"bg"},
			{4,1,"bg"},
			{5,1,"bg"},
			{6,1,"bg"},
			{1,5,"death","hori"},
			{2,5,"death","hori"},
			{3,5,"death","vert","vertneg"},
			{4,5,"death","vert","vertneg"},
			{1,6,"death","hori"},
			{2,6,"death","hori"},
			{3,6,"death","vert","vertneg"},
			{4,6,"death","vert","vertneg"},
			{1,7,"death"},
			{2,7,"death","vert"},
			presettiles.coin,
			presettiles.gem,
			{7,1,"solid"},
			{7,2,"solid"},
			{7,3,"solid"},
			{7,4,"solid"},
			{7,5,"bg"},
			{7,6,"bg"},
		},
		image = "ice.png",
		script = function()
			partSystem:spawnParticles("snowfall",1,screen.x,screen.y,vWinW,vWinH)
		end
	},
	city = {
		data = {
			{1,1,"preason"},
			{1,2,"solid"},
			{2,2,"solid"},
			{3,2,"solid"},
			{1,3,"solid"},
			{2,3,"solid"},
			{3,3,"solid"},
			{1,4,"solid"},
			{2,4,"solid"},
			{3,4,"solid"},
			{4,2,"nonsolid","bgtile",{1,5}},
			{2,5,"nonsolid","bg"},
			{3,5,"nonsolid","bg"},
			{4,2,"bgtile",{1,6}},
			{2,6,"bg"},
			{3,6,"bg"},
			{4,2,"bgtile",{1,7}},
			{2,7,"bg"},
			{3,7,"bg"},
			{4,2,"nonsolid","bgtile",{4,5}},
			{5,5,"nonsolid","bg"},
			{6,5,"nonsolid","bg"},
			{4,2,"bgtile",{4,6}},
			{5,6,"bg"},
			{6,6,"bg"},
			{4,2,"bgtile",{4,7}},
			{5,7,"bg"},
			{6,7,"bg"},
			{1,8,"solid"},
			{2,8,"solid"},
			{1,1,"solid","stair"},
			{2,1,"nonsolid"},
			{3,1,"bg"},
			{4,1,"bg"},
			{5,1,"bg"},
			{6,1,"bg"},
			presettiles.coin,
			presettiles.gem,
			presettiles.prezule,
		},
		image = "city.png"
	},
	tutorial = {
		data = {
			{1,1,"preason"},
			{1,1,"solid"},
			{2,1,"solid"},
			{3,1,"solid"},
			{1,2,"solid"},
			{2,2,"solid"},
			{3,2,"solid"},
			{1,3,"solid"},
			{2,3,"solid"},
			{3,3,"solid"},
			{4,2,"solid"},--
			{5,2,"solid"},
			{4,3,"solid"},
			{5,3,"solid"},
			{4,1,"solid","stair"},
			{5,1,"nonsolid"},
			{1,4,"solid"},
			{2,4,"solid"},
			{3,4,"solid"},
			{4,4,"solid"},
			{5,4,"solid"},--
			{1,5,"solid"},
			{2,5,"solid"},
			{3,5,"solid"},
			{4,5,"solid"},
			{5,5,"solid"},
			{1,6,"solid"},
			{2,6,"solid"},
			{3,6,"solid"},
			{4,6,"solid"},
			{5,6,"solid"},--
			{1,7,"solid"},
			{2,7,"solid"},
			{3,7,"solid"},
			{4,7,"solid"},
			{5,7,"bg"},
			{1,8,"solid"},
			{2,8,"solid"},
			{3,8,"solid"},
			{4,8,"solid"},
			{5,8,"solid"},
			{1,9,"bg"},
			{2,9,"bg"},
			{3,9,"bg"},
			{1,10,"bg"},
			{2,10,"bg"},
			{3,10,"bg"},
			{4,9,"death"}
		},
		image = "tutorial.png"
	},
	multi = {
		data = {
			{1,1,"preason"},
			{1,2,"solid","stair"}, --main
			{2,2,"solid"},
			{3,2,"solid","stair"},
			{1,3,"solid"},
			{2,3,"solid"},
			{3,3,"solid"},
			{1,4,"solid"},
			{2,4,"solid"},
			{3,4,"solid"},
			{4,2,"solid","part",2}, --grass
			{5,2,"solid","part",2},
			{6,2,"solid","part",2},
			{4,3,"solid"},
			{5,3,"solid"},
			{6,3,"solid"},
			{4,4,"solid"},
			{5,4,"solid"},
			{6,4,"solid"},
			{7,2,"solid"}, --stone
			{8,2,"solid"},
			{9,2,"solid"},
			{7,3,"solid"},
			{8,3,"solid"},
			{9,3,"solid"},
			{7,4,"solid"},
			{8,4,"solid"},
			{9,4,"solid"},
			{10,2,"solid","part",3}, --sandstone
			{11,2,"solid","part",3},
			{12,2,"solid","part",3},
			{10,3,"solid"},
			{11,3,"solid"},
			{12,3,"solid"},
			{10,4,"solid"},
			{11,4,"solid"},
			{12,4,"solid"},
			{1,1,"solid","stair"}, --test:19
			{2,1,"nonsolid"},
			{3,1,"bg"},
			{4,1,"bg"},
			{5,1,"bg"},
			{6,1,"bg"},
			{7,1,"solid"},
			{4,11,"solid","anim",{{1,4,11},{3,5,11},{5,6,11},{7,7,11},{9,8,11},{11,9,11},{13,10,11},{15,11,11},{17,12,11},{19,"loop"}}},
			{8,1,"solid","hit",hitfunc.text},
			presettiles.coin,
			presettiles.gem,
			{7,10,"collect"},
		},
		image = "multi.png"
	},
	finale = {
		data = {
			{1,1,"preason"},
			{1,2,"solid","stair"}, --main
			{2,2,"solid"},
			{3,2,"solid","stair"},
			{1,3,"solid"},
			{2,3,"solid"},
			{3,3,"solid"},
			{1,4,"solid"},
			{2,4,"solid"},
			{3,4,"solid"},
			{4,2,"nonsolid"},
			{5,2,"nonsolid"},
			{6,2,"nonsolid"},
			{7,2,"solid","hit",hitfunc.destroy,"anim",{{1,7,2},{11,8,2},{21,9,2},{31,8,2},{41,"loop"}}},
			{4,3,"solid","anim",{{1,4,3},{6,5,3},{11,6,3},{16,5,3},{21,"loop"}}},
			{4,4,"solid","anim",{{1,4,4},{6,5,4},{11,6,4},{16,5,4},{21,"loop"}}},
			{5,3,"solid","anim",{{1,4,3},{5,5,3},{9,6,3},{13,5,3},{17,"loop"}}},
			{5,4,"solid","anim",{{1,4,4},{5,5,4},{9,6,4},{13,5,4},{17,"loop"}}},
			{6,3,"solid","anim",{{1,4,3},{4,5,3},{7,6,3},{10,5,3},{13,"loop"}}},
			{6,4,"solid","anim",{{1,4,4},{4,5,4},{7,6,4},{10,5,4},{13,"loop"}}},
			{1,5,"death"}, --spikes
			{2,5,"death"},
			{3,5,"death"},
			{1,6,"death"},
			{3,6,"death"},
			{1,7,"death"},
			{2,7,"death"},
			{3,7,"death"},
			{4,5,"death"},
			{2,1,"nonsolid"},
			{3,1,"bg"},
			{4,1,"bg"},
			{5,1,"bg"},
			{6,1,"bg"},
			{7,1,"solid"},
			{7,3,"solid"},
			{8,3,"solid"},
			{7,4,"death","anim",{{1,7,4},{5,7,5},{9,7,6},{13,7,5},{17,"loop"}}},
			{8,4,"death","anim",{{1,8,4},{5,8,5},{9,8,6},{13,8,5},{17,"loop"}}},
			{1,9,"solid","anim",{{1,1,9},{3,2,9},{5,3,9},{7,4,9},{9,5,9},{11,6,9},{13,7,9},{15,8,9},{17,9,9},{19,"loop"}}},
			{8,1,"solid","hit",hitfunc.text},
			presettiles.coin,
			presettiles.gem,
			{7,10,"collect"},
		},
		image = "finale.png"
	},
	void = {
		data = {
			{1,1,"preason"},
			{1,1,"solid"},
			{1,1,"solid","hit",hitfunc.text}
		},
		image = "void.png"
	},
	endless = {
		data = {
			{1,1,"preason"},
			{1,1,"solid"},
			{2,1,"nonsolid"},
			{3,1,"death","anim",{{1,3,1},{5,3,2},{9,3,3},{13,3,2},{17,"loop"}}},
			{1,2,"solid","stair"},
			{2,2,"collect","anim",{{1,2,2},{21,2,3},{41,"loop"}}},
			{1,3,"solid","hit",hitfunc.text},
		},
		image = "endless.png"
	}
}
