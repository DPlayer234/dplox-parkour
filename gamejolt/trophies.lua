local trophyList = {
	the_basics = {
		id = 59724,
		name = "The Basics"
	},
	boss_a = {
		id = 59725,
		name = "SMASHING!!"
	},
	boss_b = {
		id = 59726,
		name = "Creativity is not my strength"
	},
	boss_c = {
		id = 59727,
		name = "Freeze!"
	},
	boss_d = {
		id = 60092,
		name = "Downfall"
	},
	boss_hdn = {
		id = 59728,
		name = "I hate eggplants"
	},
	epic_fail = {
		id = 59741,
		name = "FA11!!"
	},
	no_death = {
		id = 60104,
		name = "No(-Save) RIPs for you"
	},
	fezzes_are_cool = {
		id = 60105,
		name = "Fezzes are cool!"
	},
	unknown = {
		id = 60106,
		name = "???"
	},
	area1_ace = {
		id = 60485,
		name = "Area 1 aced!"
	},
	its_over_1k = {
		id = 68905,
		name = "It's over 1k"
	},
	master_collector = {
		id = 69147,
		name = "Master Collector"
	}
}

setmetatable(trophyList,{
	__index = function(t,k)
		return {
			id = 0,
			name = "NULL"
		}
	end
})

return trophyList
