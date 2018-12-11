if not savedata.levels[13] then
 savedata.levels[13] = true
 cutscene.start({{"move","denniz",0.1},{"move","diana",0.3},{"emote","denniz","bored"},{"emote","diana","bored"},{"text","denniz","I won't even question this."},{"text","diana","Me neither..."},{"emote","denniz","bigeyes"},{"emote","diana","bigeyes"},{"move","weggs",0.9,-1},{"text","weggs","HOW ARE YOU HERE ALREADY?!"},{"text","weggs","To the Arctic!"},{"move","weggs",1.3},{"emote","denniz","facepalm"},{"emote","diana","facepalm"},{"text","siblings","*facepalm*\nWhy did he tell us, where he'd go?"}},true)
elseif savedata.levels[18] and not savedata.levels[19] then
 savedata.levels[19] = true
 cutscene.start({{"move","denniz",0.1},{"move","diana",0.9,-1},{"text","denniz","It looks like he opened a portal to his \"Secret\" Hide-Out."},{"text","diana","And...\nTo other dimensions."},{"emote","denniz","bored"},{"text","denniz","._. Uhhh... Let's hope we don't meet a certain purple haired girl who's gonna give some builders a new job."},{"emote","diana","bored"},{"text","diana","Uh... her...\nWe will. I mean... she's not the main character but still."},{"text","denniz","Yeah. And thanks for being her this time."},{"text","diana","... No comment ..."},{"emote","denniz","n"},{"text","denniz","BACK ON TRACK!\nTO ZE HIDE-OUT!"}},true)
end

--LEVEL
return {
	level = {{44,44,44,44,44,44,44,44,44,44,44,44,44,44,44,44,44,44,44,44,44,44,44,44,44,44,44,44,44,44,44,44,44,44,44,44,44,44,44,44,44,44,44,44,44,44,44,44,44,44,44,44,44,44,44,44,44,44,44,44,44,44,44,44,44,44,44,44,44,44,44,44,44,44,44,44,44,44,44,44,44,44,44,44,44,44,44,44,44,44,44,44,44,44,44,44,44,44,44,44,},{44,44,44,44,44,44,44,44,44,44,44,44,44,44,44,44,44,44,44,44,44,44,44,44,44,44,44,44,44,44,44,44,44,44,44,44,44,44,44,44,44,44,44,44,44,44,44,44,44,44,44,44,44,44,44,44,44,44,44,44,44,44,44,44,44,44,44,44,44,44,44,44,44,44,44,44,44,44,44,44,44,44,44,44,44,44,44,44,44,44,44,44,44,44,44,44,44,44,44,44,},{44,44,44,44,44,44,44,44,44,44,44,44,44,44,44,44,44,44,44,44,44,44,44,44,44,44,44,44,44,44,44,44,44,44,44,44,44,44,44,44,44,44,44,44,44,44,44,44,44,44,44,44,44,44,44,44,44,44,44,44,44,44,44,44,44,44,44,44,44,44,44,44,44,44,44,44,44,44,44,44,44,44,44,44,44,44,44,44,44,44,44,44,44,44,44,44,44,44,44,44,},{44,44,44,44,44,44,44,44,44,44,44,44,44,44,44,44,44,44,44,44,44,44,44,44,44,44,44,44,44,44,44,44,44,44,44,44,44,44,44,44,44,44,44,44,44,44,44,44,44,44,44,44,44,44,44,44,44,44,44,44,44,44,44,44,44,44,44,44,44,44,44,44,44,44,44,44,44,44,44,44,44,44,44,44,44,44,44,44,44,44,44,44,44,44,44,44,44,44,44,44,},{44,44,44,44,44,44,44,44,44,44,44,44,44,44,44,44,44,44,44,44,44,44,44,44,44,44,44,44,44,44,44,44,44,44,44,44,44,44,44,44,44,44,44,44,44,44,44,44,44,44,44,44,44,44,44,44,44,44,44,44,44,44,44,44,44,44,44,44,44,44,44,44,44,44,44,44,44,44,44,44,44,44,44,44,44,44,44,44,44,44,44,44,44,44,44,44,44,44,44,44,},{44,44,44,44,44,1,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,3,44,44,44,44,44,44,},{44,44,44,44,44,4,1,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,3,6,44,44,44,44,44,44,},{44,44,44,44,44,4,6,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,4,6,44,44,44,44,44,44,},{44,44,44,44,44,4,6,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,4,6,44,44,44,44,44,44,},{44,44,44,44,44,4,6,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,46,0,0,0,0,0,0,46,0,0,0,0,0,0,46,0,0,0,0,0,0,0,0,0,46,0,0,0,0,0,0,46,0,0,0,0,0,0,46,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,4,6,44,44,44,44,44,44,},{44,44,44,44,44,4,6,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,4,6,44,44,44,44,44,44,},{44,44,44,44,44,4,6,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,4,6,44,44,44,44,44,44,},{44,44,44,44,44,4,6,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,4,6,44,44,44,44,44,44,},{44,44,44,44,44,4,6,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,4,6,44,44,44,44,44,44,},{44,44,44,44,44,4,6,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,4,6,44,44,44,44,44,44,},{44,44,44,44,44,4,6,42,0,39,40,41,43,0,39,40,40,40,40,40,40,40,41,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,39,40,40,40,40,40,40,40,41,0,43,39,40,41,0,42,4,6,44,44,44,44,44,44,},{44,44,44,44,44,4,6,8,8,8,8,28,29,30,38,38,38,38,38,38,38,38,38,28,29,29,30,0,0,0,46,0,0,0,0,0,0,46,0,0,0,0,0,0,46,0,0,0,0,0,0,0,0,0,46,0,0,0,0,0,0,46,0,0,0,0,0,0,46,0,0,0,19,20,20,21,38,38,38,38,38,38,38,38,38,19,20,21,8,8,8,8,4,6,44,44,44,44,44,44,},{44,44,44,44,44,4,6,40,40,40,40,31,32,33,0,0,0,0,0,0,0,0,0,31,32,32,33,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,22,23,23,24,0,0,0,0,0,0,0,0,0,22,23,24,40,40,40,40,4,6,44,44,44,44,44,44,},{44,44,44,44,44,4,6,8,8,8,8,31,32,33,0,0,0,0,0,0,0,0,0,31,32,32,33,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,22,23,23,24,0,0,0,0,0,0,0,0,0,22,23,24,8,8,8,8,4,6,44,44,44,44,44,44,},{44,44,44,44,44,4,6,0,0,0,0,31,32,33,0,0,0,0,0,0,0,0,0,34,35,35,36,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,25,26,26,27,0,0,0,0,0,0,0,0,0,22,23,24,0,0,0,0,4,6,44,44,44,44,44,44,},{44,44,44,44,44,4,6,8,8,8,8,31,32,33,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,22,23,24,8,8,8,8,4,6,44,44,44,44,44,44,},{44,44,44,44,44,4,6,40,40,40,40,31,32,33,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,22,23,24,40,40,40,40,4,6,44,44,44,44,44,44,},{44,44,44,44,44,4,6,8,8,8,8,31,32,33,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,22,23,24,8,8,8,8,4,6,44,44,44,44,44,44,},{44,44,44,44,44,4,6,0,0,0,0,31,32,33,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,46,0,0,0,0,0,0,46,0,0,45,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,45,0,0,46,0,0,0,0,0,0,46,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,22,23,24,0,0,0,0,4,6,44,44,44,44,44,44,},{44,44,44,44,44,4,6,8,8,8,8,31,32,33,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,22,23,24,8,8,8,8,4,6,44,44,44,44,44,44,},{44,44,44,44,44,4,6,40,40,40,40,31,32,33,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,22,23,24,40,40,40,40,4,6,44,44,44,44,44,44,},{44,44,44,44,44,4,6,8,8,8,8,31,32,33,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,39,40,40,40,40,40,40,40,40,41,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,39,40,40,40,40,40,40,40,40,41,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,22,23,24,8,8,8,8,4,6,44,44,44,44,44,44,},{44,44,44,44,44,4,6,0,0,0,0,31,32,32,29,29,29,29,29,29,29,29,29,29,29,29,30,1,3,38,38,38,38,38,38,38,38,38,38,1,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,3,38,38,38,38,38,38,38,38,38,38,1,3,19,20,20,20,20,20,20,20,20,20,20,20,20,23,23,24,0,0,0,0,4,6,44,44,44,44,44,44,},{44,44,44,44,44,4,6,8,8,8,8,31,32,32,32,32,32,32,32,32,32,32,32,32,32,32,33,7,9,0,0,0,0,0,0,0,0,39,1,9,40,40,40,40,40,40,40,40,40,40,40,40,40,40,40,40,40,40,40,7,3,41,0,0,0,0,0,0,0,0,7,9,22,23,23,23,23,23,23,23,23,23,23,23,23,23,23,24,8,8,8,8,4,6,44,44,44,44,44,44,},{44,44,44,44,44,4,6,40,40,40,40,34,35,35,35,35,35,35,35,35,35,35,35,35,35,35,36,6,0,0,0,0,0,0,0,0,0,1,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,3,0,0,0,0,0,0,0,0,0,4,25,26,26,26,26,26,26,26,26,26,26,26,26,26,26,27,40,40,40,40,4,6,44,44,44,44,44,44,},{44,44,44,44,44,4,6,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,9,0,0,0,0,0,0,0,39,1,9,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,7,3,41,0,0,0,0,0,0,0,7,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,4,6,44,44,44,44,44,44,},{44,44,44,44,44,4,6,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,3,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,4,6,44,44,44,44,44,44,},{44,44,44,44,44,4,6,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,39,1,9,40,40,40,40,40,40,40,40,40,40,40,40,40,40,40,40,40,40,40,40,40,40,40,40,40,40,40,7,3,41,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,4,6,44,44,44,44,44,44,},{44,44,44,44,44,4,6,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,3,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,4,6,44,44,44,44,44,44,},{44,44,44,44,44,4,6,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,39,1,9,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,7,3,41,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,4,6,44,44,44,44,44,44,},{44,44,44,44,44,4,6,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,3,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,4,6,44,44,44,44,44,44,},{44,44,44,44,44,4,6,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,39,1,9,40,40,40,40,40,40,40,40,40,40,40,40,40,40,40,40,40,40,40,40,40,40,40,40,40,40,40,40,40,40,40,40,40,40,40,7,3,41,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,4,6,44,44,44,44,44,44,},{44,44,44,44,44,4,6,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,3,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,4,6,44,44,44,44,44,44,},{44,44,44,44,44,4,6,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,39,1,9,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,7,3,41,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,4,6,44,44,44,44,44,44,},{44,44,44,44,44,4,6,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,3,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,4,6,44,44,44,44,44,44,},{44,44,44,44,44,4,6,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,39,1,9,40,40,40,40,40,40,40,40,40,40,40,40,40,40,40,40,40,40,40,40,40,40,40,40,40,40,40,40,40,40,40,40,40,40,40,40,40,40,40,40,40,40,40,7,3,41,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,4,6,44,44,44,44,44,44,},{44,44,44,44,44,4,6,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,3,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,4,6,44,44,44,44,44,44,},{44,44,44,44,44,4,6,1,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,3,1,6,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,4,3,1,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,3,4,6,44,44,44,44,44,44,},{44,44,44,44,44,4,6,4,5,5,5,5,5,5,5,5,5,5,5,5,5,5,5,6,7,9,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,7,9,4,5,5,5,5,5,5,5,5,5,5,5,5,5,5,5,6,4,6,44,44,44,44,44,44,},{44,44,44,44,44,4,6,4,5,5,5,5,5,5,5,5,5,5,5,5,5,5,5,6,40,40,40,40,40,40,40,40,40,40,40,40,40,40,40,40,40,40,40,40,40,40,40,40,40,40,40,40,40,40,40,40,40,40,40,40,40,40,40,40,40,40,40,40,40,40,40,40,40,40,40,4,5,5,5,5,5,5,5,5,5,5,5,5,5,5,5,6,4,6,44,44,44,44,44,44,},{44,44,44,44,44,7,9,7,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,9,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,7,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,9,7,9,44,44,44,44,44,44,},{44,44,44,44,44,44,44,44,44,44,44,44,44,44,44,44,44,44,44,44,44,44,44,44,44,44,44,44,44,44,44,44,44,44,44,44,44,44,44,44,44,44,44,44,44,44,44,44,44,44,44,44,44,44,44,44,44,44,44,44,44,44,44,44,44,44,44,44,44,44,44,44,44,44,44,44,44,44,44,44,44,44,44,44,44,44,44,44,44,44,44,44,44,44,44,44,44,44,44,44,},{44,44,44,44,44,44,44,44,44,44,44,44,44,44,44,44,44,44,44,44,44,44,44,44,44,44,44,44,44,44,44,44,44,44,44,44,44,44,44,44,44,44,44,44,44,44,44,44,44,44,44,44,44,44,44,44,44,44,44,44,44,44,44,44,44,44,44,44,44,44,44,44,44,44,44,44,44,44,44,44,44,44,44,44,44,44,44,44,44,44,44,44,44,44,44,44,44,44,44,44,},{44,44,44,44,44,44,44,44,44,44,44,44,44,44,44,44,44,44,44,44,44,44,44,44,44,44,44,44,44,44,44,44,44,44,44,44,44,44,44,44,44,44,44,44,44,44,44,44,44,44,44,44,44,44,44,44,44,44,44,44,44,44,44,44,44,44,44,44,44,44,44,44,44,44,44,44,44,44,44,44,44,44,44,44,44,44,44,44,44,44,44,44,44,44,44,44,44,44,44,44,},{44,44,44,44,44,44,44,44,44,44,44,44,44,44,44,44,44,44,44,44,44,44,44,44,44,44,44,44,44,44,44,44,44,44,44,44,44,44,44,44,44,44,44,44,44,44,44,44,44,44,44,44,44,44,44,44,44,44,44,44,44,44,44,44,44,44,44,44,44,44,44,44,44,44,44,44,44,44,44,44,44,44,44,44,44,44,44,44,44,44,44,44,44,44,44,44,44,44,44,44,},{44,44,44,44,44,44,44,44,44,44,44,44,44,44,44,44,44,44,44,44,44,44,44,44,44,44,44,44,44,44,44,44,44,44,44,44,44,44,44,44,44,44,44,44,44,44,44,44,44,44,44,44,44,44,44,44,44,44,44,44,44,44,44,44,44,44,44,44,44,44,44,44,44,44,44,44,44,44,44,44,44,44,44,44,44,44,44,44,44,44,44,44,44,44,44,44,44,44,44,44,},{44,44,44,44,44,44,44,44,44,44,44,44,44,44,44,44,44,44,44,44,44,44,44,44,44,44,44,44,44,44,44,44,44,44,44,44,44,44,44,44,44,44,44,44,44,44,44,44,44,44,44,44,44,44,44,44,44,44,44,44,44,44,44,44,44,44,44,44,44,44,44,44,44,44,44,44,44,44,44,44,44,44,44,44,44,44,44,44,44,44,44,44,44,44,44,44,44,44,44,44,},{44,44,44,44,44,44,44,44,44,44,44,44,44,44,44,44,44,44,44,44,44,44,44,44,44,44,44,44,44,44,44,44,44,44,44,44,44,44,44,44,44,44,44,44,44,44,44,44,44,44,44,44,44,44,44,44,44,44,44,44,44,44,44,44,44,44,44,44,44,44,44,44,44,44,44,44,44,44,44,44,44,44,44,44,44,44,44,44,44,44,44,44,44,44,44,44,44,44,44,44,},},
	td = "multi",
	spawn = {50,26},
	bg = levels.bgs.finale,
  music = "final",
	name = "Intra-dimensional Base",
	warps = {
	 {16,27,"hub2","Loominarty\nDesert",90,42},
	 {84,27,"hub3","Arctic\nIsolation"},
	 levels.rIfSave(18,{12,42,"hub4","Obvious Hide-Out"}),
	 levels.rIfSave(18,{91,42,"hdn_hub","Hyper\nDimension"}),
	 --levels.rIfSave(24,{86,42,"cs_abyss","Hell?"}),
	 levels.rIfSave(24,{83,42,"endless_hub","Endless\nMode"}),
	},
	textbox = not savedata.levels[18] and "<<< Loominarty Desert <<< \n >>> Arctic Isolation >>>\n<<< ??? <<< \n >>> ??? >>>" or "<<< Loominarty Desert <<< \n >>> Arctic Isolation >>>\n<<< Obvious Hide-Out <<< \n >>> Beyond the 4th wall >>>",
	textboxAlign = "justify",
	outside = 44,
}