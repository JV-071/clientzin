WheelGemActions = {}

function WheelGemActions.send(actionType, param, pos)
	if WheelOfDestiny.isPreview then
		return
	end

	param = param or 0
	pos = pos or 0

	g_game.gemAction(actionType, param, pos)

	if actionType == 3 and GemAtelier and GemAtelier.onLockActionSent then
		GemAtelier.onLockActionSent(param)
	end
end

function sendgemAction(actionType, param, pos)
	return WheelGemActions.send(actionType, param, pos)
end
