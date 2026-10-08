local MAP_SHADERS = {
	{
		name = "Map - Default"
	},
	{
		name = "Map - Fog",
		frag = "shaders/fragment/fog.frag",
		tex1 = "images/clouds"
	},
	{
		name = "Map - Rain",
		frag = "shaders/fragment/rain.frag"
	},
	{
		name = "Map - Snow",
		frag = "shaders/fragment/snow.frag",
		tex1 = "images/snow"
	},
	{
		name = "Map - Gray Scale",
		frag = "shaders/fragment/grayscale.frag"
	},
	{
		name = "Map - Bloom",
		frag = "shaders/fragment/bloom.frag"
	},
	{
		name = "Map - Sepia",
		frag = "shaders/fragment/sepia.frag"
	},
	{
		name = "Map - Pulse",
		drawViewportEdge = true,
		frag = "shaders/fragment/pulse.frag"
	},
	{
		name = "Map - Old Tv",
		frag = "shaders/fragment/oldtv.frag"
	},
	{
		name = "Map - Party",
		frag = "shaders/fragment/party.frag"
	},
	{
		name = "Map - Radial Blur",
		drawViewportEdge = true,
		frag = "shaders/fragment/radialblur.frag"
	},
	{
		name = "Map - Zomg",
		drawViewportEdge = true,
		frag = "shaders/fragment/zomg.frag"
	},
	{
		name = "Map - Heat",
		drawViewportEdge = true,
		frag = "shaders/fragment/heat.frag"
	},
	{
		name = "Map - Noise",
		frag = "shaders/fragment/noise.frag"
	}
}

OUTFIT_SHADERS = {
	{
		name = "Outfit - Default"
	},
	{
		name = "Outfit - Rainbow",
		frag = "shaders/fragment/party.frag"
	},
	{
		name = "Outfit - Ghost",
		frag = "shaders/fragment/radialblur.frag",
		drawColor = false
	},
	{
		name = "Outfit - Jelly",
		frag = "shaders/fragment/heat.frag"
	},
	{
		name = "Outfit - Fragmented",
		frag = "shaders/fragment/noise.frag"
	},
	{
		name = "Outfit - cyclopedia-black",
		frag = "shaders/fragment/cyclopedia.frag"
	},
	{
		name = "Outfit - Outline",
		useFramebuffer = true,
		frag = "shaders/fragment/outline.frag"
	}
}
ITEM_SHADERS = {
	{
		name = "Item - Default"
	},
	{
		name = "Hover - Desaturate",
		frag = "shaders/fragment/hover_desaturate.frag"
	}
}
MOUNT_SHADERS = {
	{
		name = "Mount - Default"
	},
	{
		name = "Mount - Rainbow",
		frag = "shaders/fragment/party.frag"
	}
}

function registerItemShaders()
	for _, opts in pairs(ITEM_SHADERS) do
		if opts.frag then
			g_shaders.createFragmentShader(opts.name, opts.frag, opts.useFramebuffer or false)
		end
	end
end

local function attachShaders()
	modules.game_interface.getMapPanel():setShader("Default")

	local player = g_game.getLocalPlayer()

	player:setShader("Default")
	player:setMountShader("Default")
end

local function registerShader(opts, method)
	if resolvepath(opts.frag) ~= nil then
		g_shaders.createFragmentShader(opts.name, opts.frag, opts.useFramebuffer or false)

		if opts.tex1 then
			g_shaders.addMultiTexture(opts.name, opts.tex1)
		end

		if opts.tex2 then
			g_shaders.addMultiTexture(opts.name, opts.tex2)
		end

		g_shaders[method](opts.name)
	end
end

ShaderController = Controller:new()

function ShaderController.onInit(self)
	for _, opts in pairs(MAP_SHADERS) do
		registerShader(opts, "setupMapShader")
	end

	for _, opts in pairs(OUTFIT_SHADERS) do
		registerShader(opts, "setupOutfitShader")
	end

	for _, opts in pairs(MOUNT_SHADERS) do
		registerShader(opts, "setupMountShader")
	end

	registerItemShaders()
end

function ShaderController.onTerminate(unusedArgument)
	g_shaders.clear()
end

function ShaderController.onGameStart(unusedArgument)
	attachShaders()
end
