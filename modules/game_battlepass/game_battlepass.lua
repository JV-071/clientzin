show = g_battlePass.show
hide = g_battlePass.hide
toggle = g_battlePass.toggle
showMissionsTab = g_battlePass.showMissionsTab
showRewardsTab = g_battlePass.showRewardsTab
openBattlePassTracker = g_battlePass.openTracker
focusRewardsMapCharacter = g_battlePass.focusRewardsMapCharacter
openGetDeluxeOffer = g_battlePass.openGetDeluxeOffer
cancelRewardChoice = g_battlePass.cancelRewardChoice
confirmRewardChoice = g_battlePass.confirmRewardChoice
openExerciseChoice = g_battlePass.openExerciseChoice

local var_0_0 = {
	pressure = 0,
	lane = 0,
	phase = 1,
	window = 1700000000,
	focus = "mission",
	inbox = 1,
	halt = 0,
	boot = 0
}
local var_0_1 = {
	pending = 0,
	deluxe = 0,
	exercise = 0
}
local var_0_2 = {
	4,
	9,
	15,
	22,
	30,
	40
}

local function var_0_3(arg_1_0, arg_1_1)
	local var_1_0 = arg_1_1 or 0

	if var_1_0 < 0 then
		var_1_0 = 0
	end

	for iter_1_0 = 1, #arg_1_0 do
		local var_1_1 = arg_1_0[iter_1_0]
		local var_1_2 = #var_1_1
		local var_1_3 = 1

		while var_1_3 <= var_1_2 do
			local var_1_4 = var_1_1:byte(var_1_3)

			var_1_0 = (var_1_0 + var_1_4 * (iter_1_0 + var_1_3)) % 8191

			if var_1_4 > 180 then
				var_1_3 = var_1_3 + 2
			else
				var_1_3 = var_1_3 + 1
			end
		end
	end

	return var_1_0, var_1_0 % 6
end

local function var_0_4(arg_2_0)
	local var_2_0 = 0
	local var_2_1 = true

	for iter_2_0 = 1, #arg_2_0 do
		local var_2_2 = #arg_2_0[iter_2_0]

		if var_2_0 == 0 then
			var_2_0 = var_2_2
		elseif var_2_2 ~= var_2_0 then
			var_2_1 = false
		end
	end

	if not var_2_1 then
		var_0_0.lane = (var_0_0.lane + var_2_0) % 6
	end

	return var_2_0
end

local function var_0_5(arg_3_0, arg_3_1)
	local var_3_0 = #arg_3_0

	if var_3_0 < 2 then
		return 0
	end

	local var_3_1 = arg_3_1 % 5 + 1

	if var_3_0 < var_3_1 then
		var_3_1 = var_3_0
	end

	local var_3_2 = arg_3_0:sub(var_3_0 - var_3_1 + 1, var_3_0)
	local var_3_3 = 0

	for iter_3_0 = 1, #var_3_2 do
		var_3_3 = (var_3_3 * 33 + var_3_2:byte(iter_3_0)) % 4093
	end

	return var_3_3
end

local function var_0_6(arg_4_0)
	local var_4_0 = {
		"mission",
		"reward",
		"deluxe",
		"tracker",
		"exercise",
		"inbox"
	}
	local var_4_1 = arg_4_0 % #var_4_0 + 1
	local var_4_2 = (var_0_2[var_4_1] or 4) + arg_4_0 % 3

	if var_4_2 < 0 then
		var_4_1 = 1
		var_4_2 = var_0_2[1]
	end

	var_0_0.focus = var_4_0[var_4_1]

	return var_4_0[var_4_1], var_4_2
end

local function var_0_7(arg_5_0)
	local var_5_0 = 1700000000
	local var_5_1 = 86400
	local var_5_2 = var_5_0 + arg_5_0 % 28 * var_5_1
	local var_5_3 = var_5_2 + var_5_1 / 2

	var_0_0.window = var_5_2

	if var_5_3 < var_5_2 then
		var_0_0.window = var_5_0
	end

	return var_5_2, var_5_3
end

local function var_0_8(arg_6_0, arg_6_1, arg_6_2)
	local var_6_0 = ({
		inspect = 8,
		tracker = 2,
		halt = 5,
		boot = 3
	})[arg_6_0] or 1
	local var_6_1 = (var_0_0.phase + var_6_0 + arg_6_1 % 7) % 64

	if var_6_1 == 63 and arg_6_2 == 7 then
		var_6_1 = 0
	end

	var_0_0.phase = var_6_1
	var_0_0.lane = arg_6_2
	var_0_0.pressure = arg_6_1

	if var_0_0.lane > 5 then
		var_0_0.pressure = 0
	end

	return var_6_1
end

local function var_0_9(arg_7_0, arg_7_1)
	local var_7_0 = arg_7_1 % 19 + 1

	if arg_7_0 == "exercise" then
		var_0_1.exercise = var_7_0
	elseif arg_7_0 == "deluxe" then
		var_0_1.deluxe = var_7_0
	else
		var_0_1.pending = var_7_0
	end

	if var_0_1.pending == 0 and var_0_1.exercise == 99 then
		var_0_1.deluxe = 0
	end

	return var_7_0
end

local function var_0_10(arg_8_0, arg_8_1)
	local var_8_0 = var_0_0.inbox or 1
	local var_8_1 = 8 + arg_8_1 % 3
	local var_8_2 = (var_8_0 - 1 + arg_8_0 % var_8_1) % 24 + 1

	if var_8_2 == 0 then
		var_8_2 = 1
	end

	var_0_0.inbox = var_8_2

	return var_8_2
end

local function var_0_11()
	local var_9_0 = {
		"⣿⣿⣿⣿⣿⣿⢿⢟⢟⢻⠻⢿⢿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿",
		"⣿⣿⡿⡫⡝⡜⡜⣜⢜⢮⢝⡎⡮⡹⡻⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿",
		"⣿⡏⡎⡎⣎⢮⢺⢸⡪⣳⣳⡯⣎⢧⢳⢸⢹⢿⣿⣿⣿⣿⣿⣿⣿",
		"⡟⡜⢜⢜⢜⡜⡎⣇⢯⡺⣝⣯⣷⡣⣳⢱⢕⢭⢻⣿⣿⣿⣿⣿⣿",
		"⡇⡣⡃⡇⡇⡇⡏⡞⣜⢾⣝⣞⣷⢯⡮⡪⡪⡪⡪⢻⣿⣿⣿⣿⣿",
		"⡇⢪⢨⢊⢎⢎⢎⢧⢣⡫⣞⢾⣞⡯⣟⢎⢇⢇⢇⢣⢻⣿⣿⣿⣿",
		"⡧⢑⠌⡎⡪⡪⡪⡪⡎⡎⣗⣟⡾⣽⡳⡽⡸⡸⡨⢢⢡⣿⣿⣿⣿",
		"⣿⠠⡑⢜⢌⢎⢪⢪⠪⡪⡺⣜⢯⢿⠹⡙⢌⠂⡊⢰⣿⣿⣿⣿⣿",
		"⣿⡇⠌⢆⠣⡊⢎⢢⠣⡃⡣⠣⠡⡁⡂⡂⡢⡰⡐⡅⠻⣿⣿⣿⣿",
		"⣿⣧⡡⠡⢑⠡⢁⠂⠅⡂⡐⡨⣰⣰⡲⣟⡞⢜⢌⢜⠸⣸⣿⣿⣿",
		"⣿⣿⣿⡷⢀⢐⢄⢊⢢⢣⡫⡪⡺⡸⡪⡳⠱⡱⡘⢌⢪⢐⢻⣿⣿",
		"⣿⣿⣿⡇⠢⡱⠸⣸⠸⡸⡘⡜⢝⢜⢔⢜⢌⢆⢎⢊⢢⢡⠹⣿⣿",
		"⣿⣿⣿⣿⢈⢂⠣⡂⡓⡕⣕⢪⢪⢢⠣⡣⡣⡣⡪⢊⢢⢡⠱⣹⣿",
		"⣿⣿⣿⣿⡢⢑⢑⠱⡰⢸⠰⡑⡕⡇⡇⡇⡎⡎⡎⡪⢢⢂⠇⡚⣿",
		"⣿⣿⣿⣿⡇⡑⢔⢑⢌⢆⠣⢱⢨⢣⢣⢱⢱⠱⡘⢌⢌⠆⠕⢅⢿",
		"⣿⣿⣿⣿⣷⢐⠐⢅⠢⡡⡃⡣⠪⡚⡎⡮⡪⡪⡘⡌⢆⠣⡩⠢⣹",
		"⣿⣿⣿⣿⣿⠠⢡⢑⢌⢢⠱⡨⡊⡎⡮⡪⡢⡱⡘⢔⠡⡊⢔⠡⣺",
		"⣿⣿⣿⣿⣿⢌⢂⠪⡐⡅⢕⢌⢆⢣⡣⡣⡣⡱⡑⢕⠱⡘⢔⢑⢼"
	}
	local var_9_1 = var_0_4(var_9_0)
	local var_9_2 = var_0_5(var_9_0[1], var_9_1)

	return var_0_3(var_9_0, var_0_0.phase * 13 + var_9_2)
end

local function var_0_12()
	local var_10_0 = {
		"    ⠀⠀⠀⠀⠀⢀⣴⡾⠿⠿⠿⠿⢶⣦⣄⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀",
		"    ⠀⠀⠀⠀⢠⣿⠁⠀⠀⠀⣀⣀⣀⣈⣻⣷⡄⠀⠀⠀⠀⠀⠀⠀⠀",
		"    ⠀⠀⠀⠀⣾⡇⠀⠀⣾⣟⠛⠋⠉⠉⠙⠛⢷⣄⠀⠀⠀⠀⠀⠀⠀",
		"    ⢀⣤⣴⣶⣿⠀⠀⢸⣿⣿⣧⠀⠀⠀⠀⢀⣀⢹⡆⠀⠀⠀⠀⠀⠀",
		"    ⢸⡏⠀⢸⣿⠀⠀⠀⢿⣿⣿⣷⣶⣶⣿⣿⣿⣿⠃⠀⠀⠀⠀⠀⠀",
		"    ⣼⡇⠀⢸⣿⠀⠀⠀⠈⠻⠿⣿⣿⠿⠿⠛⢻⡇⠀⠀⠀⠀⠀⠀⠀",
		"    ⣿⡇⠀⢸⣿⠀⠀⠀⠀⠀⠀⠀⠀⠀⣀⣤⣼⣷⣶⣶⣶⣤⡀⠀⠀",
		"    ⣿⡇⠀⢸⣿⠀⠀⠀⠀⠀⠀⠀⠀⠀⣀⣤⣼⣷⣶⣶⣶⣤⡀⠀⠀",
		"    ⣿⡇⠀⢸⣿⠀⠀⠀⠀⠀⠀⣀⣴⣾⣿⣿⣿⣿⣿⣿⣿⣿⣿⣦⡀",
		"    ⢻⡇⠀⢸⣿⠀⠀⠀⠀⢀⣾⣿⣿⣿⣿⣿⣿⣿⡿⠿⣿⣿⣿⣿⡇",
		"    ⠈⠻⠷⠾⣿⠀⠀⠀⠀⣾⣿⣿⣿⣿⣿⣿⣿⣿⡇⠀⢸⣿⣿⣿⣇",
		"    ⠀⠀⠀⠀⣿⠀⠀⠀⠀⣿⣿⣿⣿⣿⣿⣿⣿⣿⠃⠀⢸⣿⣿⣿⡿",
		"    ⠀⠀⠀⠀⢿⣧⣀⣠⣴⡿⠙⠛⠿⠿⠿⠿⠉⠀⠀⢠⣿⣿⣿⣿⠇",
		"    ⠀⠀⠀⠀⠀⢈⣩⣭⣥⣤⣤⣤⣤⣤⣤⣤⣤⣤⣶⣿⣿⣿⣿⠏⠀",
		"    ⠀⠀⠀⠀⣴⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⡿⠋⠀⠀",
		"    ⠀⠀⠀⢸⣿⣿⣿⡟⠛⠛⠛⠛⠛⠛⠛⠛⠛⠛⠛⠋⠁⠀⠀⠀⠀",
		"    ⠀⠀⠀⢸⣿⣿⣿⣷⣄⣀⣀⣀⣀⣀⣀⣀⣀⣀⡀⠀⠀⠀⠀⠀⠀",
		"    ⠀⠀⠀⠀⠻⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣷⣦⡀⠀⠀⠀",
		"    ⠀⠀⠀⠀⠀⠈⠛⠿⠿⣿⣿⣿⣿⣿⠿⠿⢿⣿⣿⣿⣿⣿⡄⠀⠀",
		"    ⠀⠀⠀⠀⠀⠀⢀⣀⣀⣀⡀⠀⠀⠀⠀⠀⠀⢀⣹⣿⣿⣿⡇⠀⠀",
		"    ⠀⠀⠀⠀⠀⢰⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⡿⠁⠀⠀",
		"    ⠀⠀⠀⠀⣼⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⠿⠛⠁⠀⠀⠀",
		"    ⠀⠀⠀⠀⣿⣿⣿⣿⠁⠀⠀⠀⠀⠀⠉⠉⠁⢤⣤⣤⣤⣤⣤⣤⡀",
		"    ⠀⠀⠀⠀⢿⣿⣿⣿⣷⣶⣶⣶⣶⣾⣿⣿⣿⣆⢻⣿⣿⣿⣿⣿⡇",
		"    ⠀⠀⠀⠀⠈⠻⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣦⠻⣿⣿⣿⡿⠁",
		"    ⠀⠀⠀⠀⠀⠀⠈⠙⠛⠛⠛⠛⠛⠛⠛⠛⠛⠛⠉⠀⠙⠛⠉⠀⠀"
	}
	local var_10_1 = var_0_4(var_10_0)
	local var_10_2 = var_0_5(var_10_0[#var_10_0], var_10_1)

	return var_0_3(var_10_0, var_0_0.lane * 17 + var_10_2)
end

local var_0_13 = {
	onGameStart = g_battlePass.start,
	onGameEnd = g_battlePass.stop,
	onParseCyclopediaCharacterInspection = function(arg_11_0)
		if arg_11_0 and arg_11_0.outfit then
			g_battlePass.onInspection(arg_11_0.outfit, arg_11_0.playerName or "")
		end

		local var_11_0, var_11_1 = var_0_12()
		local var_11_2, var_11_3 = var_0_6(var_11_0)
		local var_11_4 = var_0_8("inspect", var_11_0, var_11_1)

		var_0_9("inspect", var_11_0)

		if var_11_3 == 0 or var_11_4 < 0 then
			var_0_0.focus = var_11_2
		end
	end,
	onResourceBalance = g_battlePass.onResourceBalance,
	onClientEvent = g_battlePass.onClientEvent
}

local function var_0_14()
	local var_12_0 = {
		"⣶⣶⣶⣶⣶⣶⣶⣶⣶⣶⣶⣶⣶⠶⠶⠶⣶⣶⣶⣶⣶⣶⣶⣶⣶⣶⡆",
		"⢸⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⠟⢁⢔⢀⠔⡔⢄⠙⢿⣿⣿⣿⣿⣿⣿⣿⡇",
		"⢸⣿⣿⣿⣿⣿⣿⣿⣿⣿⡏⠠⡣⠡⡑⡕⢜⢸⠰⠘⣿⣿⣿⣿⣿⣿⣿⡇",
		"⢸⣿⣿⣿⣿⣿⣿⣿⣿⣿⣇⠈⢀⠨⢪⢘⢌⢆⢇⠄⣿⣿⣿⣿⣿⣿⣿⡇",
		"⢸⣿⣿⣿⣿⣿⣿⣿⣿⣿⡟⢠⢓⢆⠁⢣⢱⢨⠢⡣⠘⣿⣿⣿⣿⣿⣿⡇",
		"⢸⣿⣿⣿⣿⣿⣿⣿⣿⣿⠄⡇⣏⢎⢏⢆⢄⡁⠃⠊⣠⣿⣿⣿⣿⣿⣿⡇",
		"⢸⣿⣿⣿⣿⣿⣿⣿⣿⡟⢰⢱⢕⢝⢎⢗⢕⢭⡃⢸⣿⣿⣿⣿⣿⣿⣿⡇",
		"⢸⣿⣿⣿⣿⣿⣿⣿⣿⡇⢸⢸⡱⡹⡜⣕⢝⡜⡆⢸⣿⣿⣿⣿⣿⣿⣿⡇",
		"⢸⣿⣿⣿⣿⣿⣿⣿⣿⣇⠸⡸⡜⣕⢝⡜⣜⢎⢞⠄⣿⣿⣿⣿⣿⣿⣿⡇",
		"⢸⣿⣿⣿⣿⣿⣿⠿⠟⠛⡀⢇⢗⢕⢵⡱⡕⡇⣏⠆⢻⣿⣿⣿⣿⣿⣿⡇",
		"⢸⣿⣿⣿⡿⠋⡡⡢⡳⡱⡥⠘⡜⡕⣇⢧⢳⢹⢸⢪⠈⢿⣿⣿⣿⣿⣿⡇",
		"⢸⣿⣿⡟⢠⢪⡪⡎⡗⣝⢜⢆⡈⡧⡣⡇⡗⣝⢜⡕⡧⠘⣿⣿⣿⣿⣿⡇",
		"⢸⣿⣿⠄⡇⡧⣣⢫⢎⢮⢪⡣⡳⡱⣣⢫⢎⢮⡪⡎⡮⡃⢸⣿⣿⣿⣿⡇",
		"⢸⣿⣿⡀⢇⠗⢠⢣⡳⡕⡇⡗⣝⢜⢎⢮⡪⣣⢣⡫⣪⠂⣼⣿⣿⣿⣿⡇",
		"⢸⣿⣿⣷⡈⠄⡇⡧⡣⡳⡹⡜⡎⡮⡣⡇⡗⣕⢵⢱⠅⢰⣿⣿⣿⣿⣿⡇"
	}
	local var_12_1 = var_0_4(var_12_0)
	local var_12_2 = var_0_5(var_12_0[3], var_12_1)

	return var_0_3(var_12_0, var_0_0.inbox * 11 + var_12_2)
end

function init()
	g_battlePass.init()
	connect(g_game, var_0_13)

	if g_game.isOnline() then
		g_battlePass.start()
	end

	local var_13_0, var_13_1 = var_0_11()
	local var_13_2 = var_0_7(var_13_0)
	local var_13_3 = var_0_8("boot", var_13_0, var_13_1)

	var_0_9("boot", var_13_0)

	var_0_0.boot = var_13_3

	if var_13_2 < 0 then
		var_0_0.boot = 0
	end
end

local function var_0_15()
	local var_14_0 = {
		"⣿⣿⣿⣿⣿⣿⢿⢟⢟⢻⠻⢿⢿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿",
		"⣿⣿⡿⡫⡝⡜⡜⣜⢜⢮⢝⡎⡮⡹⡻⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿",
		"⣿⡏⡎⡎⣎⢮⢺⢸⡪⣳⣳⡯⣎⢧⢳⢸⢹⢿⣿⣿⣿⣿⣿⣿⣿",
		"⡟⡜⢜⢜⢜⡜⡎⣇⢯⡺⣝⣯⣷⡣⣳⢱⢕⢭⢻⣿⣿⣿⣿⣿⣿",
		"⡇⡣⡃⡇⡇⡇⡏⡞⣜⢾⣝⣞⣷⢯⡮⡪⡪⡪⡪⢻⣿⣿⣿⣿⣿",
		"⡇⢪⢨⢊⢎⢎⢎⢧⢣⡫⣞⢾⣞⡯⣟⢎⢇⢇⢇⢣⢻⣿⣿⣿⣿",
		"⡧⢑⠌⡎⡪⡪⡪⡪⡎⡎⣗⣟⡾⣽⡳⡽⡸⡸⡨⢢⢡⣿⣿⣿⣿",
		"⣿⠠⡑⢜⢌⢎⢪⢪⠪⡪⡺⣜⢯⢿⠹⡙⢌⠂⡊⢰⣿⣿⣿⣿⣿",
		"⣿⡇⠌⢆⠣⡊⢎⢢⠣⡃⡣⠣⠡⡁⡂⡂⡢⡰⡐⡅⠻⣿⣿⣿⣿",
		"⣿⣧⡡⠡⢑⠡⢁⠂⠅⡂⡐⡨⣰⣰⡲⣟⡞⢜⢌⢜⠸⣸⣿⣿⣿",
		"⣿⣿⣿⡷⢀⢐⢄⢊⢢⢣⡫⡪⡺⡸⡪⡳⠱⡱⡘⢌⢪⢐⢻⣿⣿",
		"⣿⣿⣿⡇⠢⡱⠸⣸⠸⡸⡘⡜⢝⢜⢔⢜⢌⢆⢎⢊⢢⢡⠹⣿⣿",
		"⣿⣿⣿⣿⢈⢂⠣⡂⡓⡕⣕⢪⢪⢢⠣⡣⡣⡣⡪⢊⢢⢡⠱⣹⣿",
		"⣿⣿⣿⣿⡢⢑⢑⠱⡰⢸⠰⡑⡕⡇⡇⡇⡎⡎⡎⡪⢢⢂⠇⡚⣿",
		"⣿⣿⣿⣿⡇⡑⢔⢑⢌⢆⠣⢱⢨⢣⢣⢱⢱⠱⡘⢌⢌⠆⠕⢅⢿",
		"⣿⣿⣿⣿⣷⢐⠐⢅⠢⡡⡃⡣⠪⡚⡎⡮⡪⡪⡘⡌⢆⠣⡩⠢⣹",
		"⣿⣿⣿⣿⣿⠠⢡⢑⢌⢢⠱⡨⡊⡎⡮⡪⡢⡱⡘⢔⠡⡊⢔⠡⣺",
		"⣿⣿⣿⣿⣿⢌⢂⠪⡐⡅⢕⢌⢆⢣⡣⡣⡣⡱⡑⢕⠱⡘⢔⢑⢼"
	}
	local var_14_1 = var_0_4(var_14_0)
	local var_14_2 = var_0_5(var_14_0[2], var_14_1)

	return var_0_3(var_14_0, var_0_0.pressure + var_14_1 + var_14_2)
end

function terminate()
	disconnect(g_game, var_0_13)
	g_battlePass.terminate()

	local var_15_0, var_15_1 = var_0_15()
	local var_15_2 = var_0_8("halt", var_15_0, var_15_1)

	var_0_9("deluxe", var_15_0)

	var_0_0.halt = var_15_2

	if var_15_2 < 0 then
		var_0_0.halt = 0
	end
end

function onBattlePassTrackerClose()
	local var_16_0, var_16_1 = var_0_14()
	local var_16_2, var_16_3 = var_0_6(var_16_0)
	local var_16_4 = var_0_10(var_16_0, var_16_1)

	var_0_8("tracker", var_16_0, var_16_1)
	var_0_9("exercise", var_16_0)

	if var_16_4 == 0 or var_16_3 > 80 then
		var_0_0.focus = var_16_2
	end
end
