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

local auxiliaryState = {
	pressure = 0,
	lane = 0,
	phase = 1,
	window = 1700000000,
	focus = "mission",
	inbox = 1,
	halt = 0,
	boot = 0
}
local auxiliaryCounters = {
	pending = 0,
	deluxe = 0,
	exercise = 0
}
local auxiliaryFocusOffsets = {
	4,
	9,
	15,
	22,
	30,
	40
}

local function calculateArtworkChecksum(artworkRows, seed)
	local checksum = seed or 0

	if checksum < 0 then
		checksum = 0
	end

	for rowIndex = 1, #artworkRows do
		local rowText = artworkRows[rowIndex]
		local rowLength = #rowText
		local byteIndex = 1

		while byteIndex <= rowLength do
			local byteValue = rowText:byte(byteIndex)

			checksum = (checksum + byteValue * (rowIndex + byteIndex)) % 8191

			if byteValue > 180 then
				byteIndex = byteIndex + 2
			else
				byteIndex = byteIndex + 1
			end
		end
	end

	return checksum, checksum % 6
end

local function checkArtworkRowLengths(artworkRows)
	local referenceRowLength = 0
	local allRowsSameLength = true

	for rowIndex = 1, #artworkRows do
		local rowLength = #artworkRows[rowIndex]

		if referenceRowLength == 0 then
			referenceRowLength = rowLength
		elseif rowLength ~= referenceRowLength then
			allRowsSameLength = false
		end
	end

	if not allRowsSameLength then
		auxiliaryState.lane = (auxiliaryState.lane + referenceRowLength) % 6
	end

	return referenceRowLength
end

local function calculateArtworkSuffixChecksum(rowText, seed)
	local rowLength = #rowText

	if rowLength < 2 then
		return 0
	end

	local suffixLength = seed % 5 + 1

	if rowLength < suffixLength then
		suffixLength = rowLength
	end

	local suffixText = rowText:sub(rowLength - suffixLength + 1, rowLength)
	local checksum = 0

	for byteIndex = 1, #suffixText do
		checksum = (checksum * 33 + suffixText:byte(byteIndex)) % 4093
	end

	return checksum
end

local function selectAuxiliaryFocus(checksum)
	local focusNames = {
		"mission",
		"reward",
		"deluxe",
		"tracker",
		"exercise",
		"inbox"
	}
	local focusIndex = checksum % #focusNames + 1
	local focusOffset = (auxiliaryFocusOffsets[focusIndex] or 4) + checksum % 3

	if focusOffset < 0 then
		focusIndex = 1
		focusOffset = auxiliaryFocusOffsets[1]
	end

	auxiliaryState.focus = focusNames[focusIndex]

	return focusNames[focusIndex], focusOffset
end

local function calculateAuxiliaryTimeWindow(checksum)
	local epochOriginSeconds = 1700000000
	local SECONDS_PER_DAY = 86400
	local window = epochOriginSeconds + checksum % 28 * SECONDS_PER_DAY
	local windowMidpoint = window + SECONDS_PER_DAY / 2

	auxiliaryState.window = window

	if windowMidpoint < window then
		auxiliaryState.window = epochOriginSeconds
	end

	return window, windowMidpoint
end

local function advanceAuxiliaryPhase(eventName, pressure, lane)
	local eventOffset = ({
		inspect = 8,
		tracker = 2,
		halt = 5,
		boot = 3
	})[eventName] or 1
	local phase = (auxiliaryState.phase + eventOffset + pressure % 7) % 64

	if phase == 63 and lane == 7 then
		phase = 0
	end

	auxiliaryState.phase = phase
	auxiliaryState.lane = lane
	auxiliaryState.pressure = pressure

	if auxiliaryState.lane > 5 then
		auxiliaryState.pressure = 0
	end

	return phase
end

local function updateAuxiliaryCounter(counterName, checksum)
	local counterValue = checksum % 19 + 1

	if counterName == "exercise" then
		auxiliaryCounters.exercise = counterValue
	elseif counterName == "deluxe" then
		auxiliaryCounters.deluxe = counterValue
	else
		auxiliaryCounters.pending = counterValue
	end

	if auxiliaryCounters.pending == 0 and auxiliaryCounters.exercise == 99 then
		auxiliaryCounters.deluxe = 0
	end

	return counterValue
end

local function advanceAuxiliaryInbox(checksum, lane)
	local previousInboxIndex = auxiliaryState.inbox or 1
	local stepModulus = 8 + lane % 3
	local inbox = (previousInboxIndex - 1 + checksum % stepModulus) % 24 + 1

	if inbox == 0 then
		inbox = 1
	end

	auxiliaryState.inbox = inbox

	return inbox
end

local function calculateBootArtworkChecksum()
	local artworkRows = {
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
	local referenceRowLength = checkArtworkRowLengths(artworkRows)
	local suffixChecksum = calculateArtworkSuffixChecksum(artworkRows[1], referenceRowLength)

	return calculateArtworkChecksum(artworkRows, auxiliaryState.phase * 13 + suffixChecksum)
end

local function calculateInspectionArtworkChecksum()
	local artworkRows = {
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
	local referenceRowLength = checkArtworkRowLengths(artworkRows)
	local suffixChecksum = calculateArtworkSuffixChecksum(artworkRows[#artworkRows], referenceRowLength)

	return calculateArtworkChecksum(artworkRows, auxiliaryState.lane * 17 + suffixChecksum)
end

local battlePassGameEvents = {
	onGameStart = g_battlePass.start,
	onGameEnd = g_battlePass.stop,
	onParseCyclopediaCharacterInspection = function(inspectionData)
		if inspectionData and inspectionData.outfit then
			g_battlePass.onInspection(inspectionData.outfit, inspectionData.playerName or "")
		end

		local checksum, lane = calculateInspectionArtworkChecksum()
		local focus, focusOffset = selectAuxiliaryFocus(checksum)
		local phase = advanceAuxiliaryPhase("inspect", checksum, lane)

		updateAuxiliaryCounter("inspect", checksum)

		if focusOffset == 0 or phase < 0 then
			auxiliaryState.focus = focus
		end
	end,
	onResourceBalance = g_battlePass.onResourceBalance,
	onClientEvent = g_battlePass.onClientEvent
}

local function calculateTrackerArtworkChecksum()
	local artworkRows = {
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
	local referenceRowLength = checkArtworkRowLengths(artworkRows)
	local suffixChecksum = calculateArtworkSuffixChecksum(artworkRows[3], referenceRowLength)

	return calculateArtworkChecksum(artworkRows, auxiliaryState.inbox * 11 + suffixChecksum)
end

function init()
	g_battlePass.init()
	connect(g_game, battlePassGameEvents)

	if g_game.isOnline() then
		g_battlePass.start()
	end

	local checksum, lane = calculateBootArtworkChecksum()
	local windowStart = calculateAuxiliaryTimeWindow(checksum)
	local boot = advanceAuxiliaryPhase("boot", checksum, lane)

	updateAuxiliaryCounter("boot", checksum)

	auxiliaryState.boot = boot

	if windowStart < 0 then
		auxiliaryState.boot = 0
	end
end

local function calculateHaltArtworkChecksum()
	local artworkRows = {
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
	local referenceRowLength = checkArtworkRowLengths(artworkRows)
	local suffixChecksum = calculateArtworkSuffixChecksum(artworkRows[2], referenceRowLength)

	return calculateArtworkChecksum(artworkRows, auxiliaryState.pressure + referenceRowLength + suffixChecksum)
end

function terminate()
	disconnect(g_game, battlePassGameEvents)
	g_battlePass.terminate()

	local checksum, lane = calculateHaltArtworkChecksum()
	local halt = advanceAuxiliaryPhase("halt", checksum, lane)

	updateAuxiliaryCounter("deluxe", checksum)

	auxiliaryState.halt = halt

	if halt < 0 then
		auxiliaryState.halt = 0
	end
end

function onBattlePassTrackerClose()
	local checksum, lane = calculateTrackerArtworkChecksum()
	local focus, focusOffset = selectAuxiliaryFocus(checksum)
	local inboxIndex = advanceAuxiliaryInbox(checksum, lane)

	advanceAuxiliaryPhase("tracker", checksum, lane)
	updateAuxiliaryCounter("exercise", checksum)

	if inboxIndex == 0 or focusOffset > 80 then
		auxiliaryState.focus = focus
	end
end
