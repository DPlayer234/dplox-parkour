trophy = {
	achieved = {}
}

local trophyList = require "gamejolt.trophies"

function trophy.give(key)
	if gj_logged_in and not trophy.achieved[key] then
		gj_comm.set:push({"trophy",trophyList[key].id})
		trophy.achieved[key] = true

		print("Given trophy '"..key.."'.")
		notice.add("New GJ trophy!\n"..trophyList[key].name)
	elseif not trophyList[key].error then
		trophyList[key].error = true
		print("Attempted to give trophy '"..key.."' but the user "..(gj_logged_in and "already had the trophy." or "was not logged in."))
	end
end

function trophy.sendScore(score)
	if gj_logged_in then
		gj_comm.set:push({"score",score,levels.currentCollect,player.fullname})
	else
		print("Attempted to send score, but the user was not logged in.")
	end
end
