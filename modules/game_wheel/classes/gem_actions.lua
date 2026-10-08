WheelGemActions = {}

function WheelGemActions.send(arg_1_0, arg_1_1, arg_1_2)
	if WheelOfDestiny.isPreview then
		return
	end

	arg_1_1 = arg_1_1 or 0
	arg_1_2 = arg_1_2 or 0

	g_game.gemAction(arg_1_0, arg_1_1, arg_1_2)

	if arg_1_0 == 3 and GemAtelier and GemAtelier.onLockActionSent then
		GemAtelier.onLockActionSent(arg_1_1)
	end
end

function sendgemAction(arg_2_0, arg_2_1, arg_2_2)
	return WheelGemActions.send(arg_2_0, arg_2_1, arg_2_2)
end
