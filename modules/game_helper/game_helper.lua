helperWindow = nil
helperButton = nil
currentTab = nil

local helperConfig = {}
local var_0_1 = {}
local helperLanguage = "en"
local helperUiLanguageCaptured = false
local HELPER_PT_TRANSLATIONS = {
	["Preset:"] = "Perfil:",
	["Auto Ammo"] = "Municao Automatica",
	["Presets:"] = "Perfis:",
	["Auto Accept"] = "Aceite Automatico",
	["Potion Healing"] = "Cura por Pocao",
	["Assign Spell"] = "Selecionar Magia",
	["Posture:"] = "Postura:",
	["Assign Exercise Weapon"] = "Selecionar Arma de Exercicio",
	["Add players using the button below."] = "Adicione jogadores usando o botao abaixo.",
	["Assign Ammunition"] = "Selecionar Municao",
	["Higher priority"] = "Maior prioridade",
	["Anti Idle"] = "Anti Inatividade",
	["No exercise dummy found."] = "Nenhum boneco de treino encontrado.",
	["Add Selected"] = "Adicionar Selecionado",
	["No party players."] = "Nenhum jogador no grupo.",
	["Add Spell"] = "Adicionar Magia",
	Players = "Jogadores",
	["Add Player"] = "Adicionar Jogador",
	["Player name"] = "Nome do jogador",
	["Add Potion"] = "Adicionar Pocao",
	["Player List"] = "Lista de Jogadores",
	["Add Waypoint"] = "Adicionar Waypoint",
	Position = "Posicao",
	Add = "Adicionar",
	Player = "Jogador",
	Action = "Acao",
	["Specific Players"] = "Jogadores Especificos",
	Record = "Gravar",
	["Configured Players"] = "Jogadores Configurados",
	["Refresh Map"] = "Atualizar Mapa",
	["Party players: 0"] = "Jogadores no grupo: 0",
	Remove = "Remover",
	["Party Players"] = "Jogadores do Grupo",
	Rename = "Renomear",
	["Open Helper"] = "Abrir Helper",
	Renew = "Renovar",
	New = "Novo",
	["Route Configuration"] = "Configuracao da Rota",
	Name = "Nome",
	Save = "Salvar",
	["Mana Training"] = "Treino de Mana",
	["Luring:"] = "Luring:",
	["Select an exercise weapon first."] = "Selecione uma arma de exercicio primeiro.",
	["Limit:"] = "Limite:",
	["Send invite to (max 4 players):"] = "Enviar convite para (max. 4 jogadores):",
	Load = "Carregar",
	["Shooter List"] = "Lista do Shooter",
	["Leader (Accept Party):"] = "Lider (aceitar):",
	["Shooter Settings"] = "Configuracoes do Shooter",
	["Interval (s)"] = "Intervalo (s)",
	["Spell Healing"] = "Cura por Magia",
	Haste = "Acelerar",
	Stop = "Parar",
	["Heal Friend"] = "Cura de Aliado",
	Run = "Voltar",
	["General Settings"] = "Configuracoes Gerais",
	["Source:"] = "Origem:",
	Enabled = "Ativado",
	["Stop:"] = "Parar:",
	["Walk diagonally"] = "Andar na diagonal",
	Passage = "Passagem",
	["Start at nearest waypoint"] = "Iniciar no waypoint mais proximo",
	Stairs = "Escada",
	tiles = "SQMs",
	Teleport = "Teleporte",
	["Record every:"] = "Gravar a cada:",
	["Time left:"] = "Tempo restante:",
	["Avoid Echo Raid"] = "Evitar a Echo Raid",
	["3:00 hours"] = "3:00 horas",
	["Step on Echo Raid"] = "Pisar na Echo Raid",
	["0:00 hours"] = "0:00 horas",
	["Echo Raid Mode:"] = "Modo Echo Raid:",
	Expired = "Expirado",
	["General Cavebot Settings"] = "Configuracoes Gerais do Cavebot",
	Up = "Cima",
	["Enable Target"] = "Ativar Target",
	Down = "Baixo",
	["Enable Shooter"] = "Ativar Shooter",
	["Resume:"] = "Voltar:",
	["Enable Heal"] = "Ativar Heal",
	Value = "Valor",
	["Enable Healing"] = "Ativar Cura",
	["When HP"] = "Se HP",
	["Enable Cavebot"] = "Ativar Cavebot",
	["Visible Players"] = "Jogadores Visiveis",
	["Edit Spell"] = "Editar Magia",
	Waypoints = "Waypoints",
	Edit = "Editar",
	["Only show learnt spells"] = "Mostrar somente magias aprendidas",
	["Eat Food"] = "Comer",
	["Type to search"] = "Digite para pesquisar",
	["Distance:"] = "Dist.:",
	Cancel = "Cancelar",
	Disabled = "Desativado",
	["Del."] = "Rem.",
	Delete = "Excluir",
	Reconnect = "Reconectar",
	Creature = "Criatura",
	["PZ Cast"] = "Conjurar em PZ",
	Condition = "Condicao",
	["Priority: "] = "Prior.: ",
	["Prioritize Hotkeys"] = "Priorizar Hotkeys",
	["Priority:"] = "Prior.:",
	["Combo priority"] = "Prioridade de combo",
	Earth = "Terra",
	["Clear All"] = "Limpar Tudo",
	Ice = "Gelo",
	["Clear Action"] = "Limpar Acao",
	Fire = "Fogo",
	Clear = "Limpar",
	Energy = "Energia",
	Close = "Fechar",
	["Which elemental line should the rotation be built around?"] = "Em torno de qual linha elemental a rotacao deve ser montada?",
	["Change Gold"] = "Trocar Ouro",
	["Choose Element"] = "Escolha o Elemento",
	Center = "Centralizar",
	["The preset \"%s\" already exists. Replace it?"] = "O preset \"%s\" ja existe. Substituir?",
	["Renew Cavebot access for 1 hour?"] = "Renovar o Cavebot por 1 hora?",
	["Overwrite Preset"] = "Substituir Preset",
	["Renew Cavebot Time"] = "Renovar Tempo do Cavebot",
	Yes = "Sim",
	["Cavebot Map"] = "Mapa do Cavebot",
	No = "Nao",
	["Auto Training"] = "Treino Automatico",
	["Preset generation failed."] = "Falha ao gerar o preset.",
	["Auto Invite"] = "Convite Automatico"
}
local var_0_5 = {
	["Prioritize Hotkeys:<br><li>When an Action Bar hotkey uses an item or casts a spell, the Helper briefly pauses its automatic actions.</li><li>The pause lasts 200-400 ms based on ping and does not override server cooldowns.</li>"] = "Priorizar Hotkeys:<br><li>Quando uma hotkey da Action Bar usa um item ou conjura uma magia, o Helper pausa brevemente suas acoes automaticas.</li><li>A pausa dura de 200 a 400 ms conforme o ping e nao ignora os cooldowns do servidor.</li>",
	["Move the selected waypoint down."] = "Move o waypoint selecionado para baixo.",
	["Auto-Switch Hotkey Preset:<br><li>On login, selects the client hotkey preset and shared Helper profile whose name exactly matches the character name.</li><li>Helper profiles are shared by all characters and accounts in this client; the active selection and local preferences remain per character.</li><li>If there is no matching preset, each system keeps its current preset.</li>"] = "Troca Automatica de Preset de Hotkeys:<br><li>Ao entrar, seleciona o preset de hotkeys do cliente e o perfil compartilhado do Helper cujo nome corresponde exatamente ao nome do personagem.</li><li>Os perfis do Helper sao compartilhados por todos os personagens e contas deste cliente; a selecao ativa e as preferencias locais continuam por personagem.</li><li>Se nao houver um preset correspondente, cada sistema mantem seu preset atual.</li>",
	["Right-click this Cavebot map to add Position or Passage waypoints."] = "Clique com o botao direito no mapa do Cavebot para adicionar waypoints de Posicao ou Passagem.",
	["Auto Save:<br><li>Saves every change automatically in the active shared profile.</li><li>All characters and accounts in this client can use the updated profile.</li><li>When disabled, changes remain temporary until you use Save.</li>"] = "Salvar Auto:<br><li>Salva automaticamente cada alteracao no perfil compartilhado ativo.</li><li>Todos os personagens e contas deste cliente podem usar o perfil atualizado.</li><li>Quando desativado, as alteracoes ficam temporarias ate voce usar Salvar.</li>",
	["Start recording waypoints while you walk."] = "Inicia a gravacao de waypoints enquanto voce caminha.",
	["Auto Accept:<br><li>Uses only the leader field above.</li><li>When enabled, the helper accepts party invites from the configured leader.</li><li>The leader must be nearby or visible when the invite is detected.</li>"] = "Aceite Automatico:<br><li>Usa apenas o campo de lider acima.</li><li>Quando ativado, aceita convites de grupo enviados pelo lider configurado.</li><li>O lider deve estar proximo ou visivel quando o convite for detectado.</li>",
	["Stop recording waypoints."] = "Para de gravar waypoints.",
	["Auto Invite:<br><li>Uses only the invite list above.</li><li>When enabled, the helper invites configured players when they are nearby and not already in party.</li><li>Fill up to four player names.</li>"] = "Convite Automatico:<br><li>Usa apenas a lista de convites acima.</li><li>Quando ativado, convida os jogadores configurados que estiverem proximos e ainda nao estiverem no grupo.</li><li>Preencha ate quatro nomes de jogadores.</li>",
	["Zoom out."] = "Diminuir zoom.",
	["Shooter settings:<br><li>Presets save independent shooter lists.</li><li>Use the pencil beside a preset to assign a hotkey that selects it.</li><li>PZ Auto enabled: pauses Shooter inside a protection zone and restores it after leaving.</li><li>PZ Auto disabled: turns Shooter off in a protection zone. It stays off after leaving and cannot be enabled while you are inside.</li>"] = "Configuracoes do Shooter:<br><li>Os perfis salvam listas independentes do Shooter.</li><li>Use o lapis ao lado de um perfil para definir uma hotkey que o seleciona.</li><li>PZ Auto ativado: pausa o Shooter dentro de uma protection zone e restaura ao sair.</li><li>PZ Auto desativado: desliga o Shooter dentro de uma protection zone. Ele permanece desligado ao sair e nao pode ser ativado enquanto voce estiver nela.</li>",
	["Zoom in."] = "Aumentar zoom.",
	["PZ Auto:<br><li>Enabled: pauses Shooter inside a protection zone and restores it after leaving.</li><li>Disabled: turns Shooter off in a protection zone. It stays off after leaving and cannot be enabled while you are inside.</li>"] = "PZ Auto:<br><li>Ativado: pausa o Shooter dentro de uma protection zone e restaura ao sair.</li><li>Desativado: desliga o Shooter dentro de uma protection zone. Ele permanece desligado ao sair e nao pode ser ativado enquanto voce estiver nela.</li>",
	["Show the floor above."] = "Mostrar o andar acima.",
	["PZ Auto:<br><li>Enabled: pauses Target inside a protection zone and restores it after leaving.</li><li>Disabled: turns Target off in a protection zone. It stays off after leaving and cannot be enabled while you are inside.</li>"] = "PZ Auto:<br><li>Ativado: pausa o Target dentro de uma protection zone e restaura ao sair.</li><li>Desativado: desliga o Target dentro de uma protection zone. Ele permanece desligado ao sair e nao pode ser ativado enquanto voce estiver nela.</li>",
	["Show the floor below."] = "Mostrar o andar abaixo.",
	["Combo priority: when enabled, casts your enabled spells as a rotating combo (round-robin), reading the list from top to bottom, instead of always repeating the highest-priority ready spell."] = "Prioridade de combo: quando ativada, conjura as magias habilitadas em rotacao, lendo a lista de cima para baixo, em vez de repetir sempre a magia pronta de maior prioridade.",
	["This map belongs to Cavebot. Right-click it to add Position, Box or Passage waypoints; drag to move the camera."] = "Este mapa pertence ao Cavebot. Clique com o botao direito para adicionar waypoints de Posicao, Box ou Passagem; arraste para mover a camera.",
	["The order of entries in the list determines the shooter priority. Entries at the top are checked first.<br><br><li>Drag an entry up or down to reorder it.</li><li>Right-click an entry to open a menu and change its order in the list.</li><li>Uncheck an entry to temporarily disable that spell or rune without removing it.</li>"] = "A ordem das entradas define a prioridade do Shooter. As entradas no topo sao verificadas primeiro.<br><br><li>Arraste uma entrada para cima ou para baixo para reordena-la.</li><li>Clique com o botao direito para abrir o menu e alterar sua ordem.</li><li>Desmarque uma entrada para desativar temporariamente a magia ou runa sem remove-la.</li>",
	["Remove every waypoint from the current route."] = "Remove todos os waypoints da rota atual.",
	["Heal Friend:<br><li>Only confirmed party members are added automatically.</li><li>Players at the top have higher healing priority than players below. Drag a player up or down to reorder.</li><li>Only party members visible on the map can be healed.</li>"] = "Cura de Aliado:<br><li>Somente membros confirmados do grupo sao adicionados automaticamente.</li><li>Jogadores no topo possuem mais prioridade de cura que os de baixo. Arraste um jogador para cima ou para baixo para reordenar.</li><li>Somente membros do grupo visiveis no mapa podem ser curados.</li>",
	["Add a Position waypoint at your current position."] = "Adiciona um waypoint de Posicao na sua posicao atual.",
	["Action: Restore Balance\nFormula: exura tio sio\nCooldown: 2s\nMana: 120"] = "Acao: Restaurar Equilibrio\nFormula: exura tio sio\nRecarga: 2s\nMana: 120",
	["Add a Box waypoint at your current position. The route holds there while monsters are around."] = "Adiciona um waypoint de Box na sua posicao atual. A rota segura nele enquanto houver monstros por perto.",
	["Action: Cast Nature's Embrace\nFormula: exura gran sio\nCooldown: 1min\nMana: 400"] = "Acao: Conjurar Abraco da Natureza\nFormula: exura gran sio\nRecarga: 1min\nMana: 400",
	["Luring modes:<br><li>Disabled: follows the route normally and pauses while Target attacks.</li><li>Continuous: follows the route while Target attacks, without monster-count or Anti-Lost stops; only Speed controls walking.</li><li>Stop / Run: stops the route when the reachable monster count reaches Stop and resumes when it falls to Run.</li><li>Anti-Lost: advances in controlled sections and waits for reachable trailing monsters.</li><br>Stop and Run also control Box waypoints in every mode except Continuous, which passes through them without holding.<br>Only visible, reachable monsters on the player floor are considered."] = "Modos de Luring:<br><li>Desativado: segue a rota normalmente e pausa enquanto o Target ataca.</li><li>Continuo: segue a rota enquanto o Target ataca, sem paradas por quantidade de monstros ou Anti-Lost; somente a Velocidade controla a caminhada.</li><li>Parar / Voltar: para a rota quando a quantidade de monstros alcancaveis chega em Parar e retoma quando cai para Voltar.</li><li>Anti-Lost: avanca em trechos controlados e espera monstros alcancaveis que ficaram para tras.</li><br>Parar e Voltar tambem controlam waypoints de Box em todos os modos, exceto Continuo, que passa por eles sem segurar a rota.<br>Somente monstros visiveis e alcancaveis no andar do jogador sao considerados.",
	["Action: Cast Heal Friend\nFormula: exura sio\nCooldown: 1s\nMana: 120"] = "Acao: Curar Aliado\nFormula: exura sio\nRecarga: 1s\nMana: 120",
	["Number of monsters that stops the route in Stop / Run mode, or that holds a Box waypoint outside Continuous mode."] = "Quantidade de monstros que para a rota no modo Parar / Voltar, ou que segura um waypoint de Box fora do modo Continuo.",
	["Maximum number of eligible players (1-50)."] = "Numero maximo de jogadores elegiveis (1-50).",
	["Number of monsters that resumes the route, and that releases a Box waypoint outside Continuous mode."] = "Quantidade de monstros que retoma a rota, e que libera um waypoint de Box fora do modo Continuo.",
	["Healing actions are checked by their configured HP/MP percent, not by their visual position."] = "As acoes de cura sao verificadas pelo percentual de HP/MP configurado, nao pela posicao visual.",
	["Speed:"] = "Vel.:",
	["Auto preset:<br><li>Builds a Shooter rotation, Healing entries, Target defaults, posture and Auto Haste from this character vocation and level.</li><li>Only spells the character already meets the level for are added. Wheel of Destiny spells are only added when they are unlocked on the active wheel.</li><li>Attack runes are added disabled - enable them if you carry runes.</li><li>The result is saved as its own profile (e.g. Auto RP), so the current profile is not changed.</li>"] = "Preset automatico:<br><li>Monta a rotacao do Shooter, as entradas de cura, os padroes do Target, a postura e o Auto Haste a partir da vocacao e do level deste personagem.</li><li>So entram magias cujo level o personagem ja alcancou. Magias da Wheel of Destiny so entram se estiverem desbloqueadas na roda ativa.</li><li>Runas de ataque entram desligadas - ative se estiver carregando runa.</li><li>O resultado e salvo como um perfil proprio (ex.: Auto RP), sem alterar o perfil atual.</li>",
	["Route walking speed from 5% to 100% in 5% steps. Lower values walk in short sections and give monsters more time to follow; 100% walks the whole path at once. Use the mouse wheel over the bar to adjust it."] = "Velocidade de caminhada da rota de 5% a 100%, em passos de 5%. Valores menores caminham em trechos curtos e dao mais tempo para os monstros acompanharem; 100% percorre o caminho inteiro de uma vez. Use a roda do mouse sobre a barra para ajustar.",
	["Move the selected waypoint up."] = "Move o waypoint selecionado para cima.",
	["Configure Echo Raid behavior."] = "Configure o comportamento da Echo Raid.",
	["Record a passage that completes after a floor change or teleport."] = "Grava uma passagem concluida apos mudar de andar ou teleportar.",
	["Number of tiles walked between automatically recorded waypoints (1-50)."] = "Quantidade de SQMs percorridos entre os waypoints gravados automaticamente (1-50).",
	["Record the current player position:"] = "Gravar a posicao atual do jogador:",
	["Start from the nearest reachable positional waypoint on the current floor whenever Cavebot or Helper is enabled."] = "Inicia pelo waypoint de posicao alcancavel mais proximo no andar atual sempre que o Cavebot ou o Helper for ativado.",
	["Center the Cavebot map on the player."] = "Centraliza o mapa do Cavebot no jogador.",
	["Walk diagonally:<br><li>Checked: the Cavebot takes diagonal steps to reach each waypoint in the fewest steps.</li><li>Unchecked (default): it takes the fastest route, which avoids diagonal steps because each one takes longer than a straight step.</li>"] = "Andar na diagonal:<br><li>Marcado: o Cavebot usa passos na diagonal para chegar a cada waypoint com o menor numero de passos.</li><li>Desmarcado (padrao): segue a rota mais rapida, que evita passos na diagonal porque cada um demora mais que um passo reto.</li>",
	["Record the current player position as a waypoint."] = "Grava a posicao atual do jogador como waypoint.",
	["Select a saved route configuration, then press Load."] = "Selecione uma configuracao de rota salva e pressione Carregar.",
	["Cast with 1+ (single-target spells and runes):<br><li>Checked (default): casts on your target no matter how many monsters are on screen.</li><li>Unchecked: casts only when your target is the only monster on screen. With 2 or more, this entry waits and leaves the attack cooldown free for the area spells in your list.</li>"] = "Cast with 1+ = usar com 1 ou mais monstros (magias e runas de alvo unico):<br><li>Marcado (padrao): usa no seu alvo, nao importa quantos monstros estejam na tela.</li><li>Desmarcado: usa somente quando o seu alvo e o unico monstro na tela. Com 2 ou mais, esta entrada espera e deixa a recarga de ataque livre para as magias de area da sua lista.</li>",
	["Type a route name. Save updates it or creates a new configuration."] = "Digite um nome de rota. Salvar atualiza ou cria uma nova configuracao.",
	["Auto-turn: before casting this directional spell, turn toward the direction that hits the most creatures. If unchecked, the spell is simply forced out in your current facing."] = "Giro automatico: antes de conjurar esta magia direcional, vira para a direcao que atinge mais criaturas. Se desmarcado, a magia e lancada na direcao atual.",
	["Minimum time in seconds between automatic casts of this pulling spell. The server cooldown is still respected."] = "Tempo minimo em segundos entre usos automaticos desta magia de puxar. A recarga do servidor continua sendo respeitada.",
	["Shooter entry conditions:<br><li>HP%: target health percentage required to use this entry.</li><li>Creatures: minimum number needed for area spells, area runes, pulling spells, timed support spells, or exori amp kor. Exori amp kor counts nearby monsters scanned by the Shooter.</li><li>Cast with 1+: other single-target spells and runes only. Uncheck it to use the entry only when your target is the only monster on screen.</li><li>Timer (s): minimum time in seconds between timed-spell casts; server cooldown is always respected.</li><li>Use to: uses the selected spell or rune on the target, yourself, or the best position for area hits.</li><li>Harmony: minimum harmony required for spells that use harmony.</li>"] = "Condicoes da entrada do Shooter:<br><li>HP%: percentual de vida do alvo necessario para usar esta entrada.</li><li>Criaturas: quantidade minima para magias de area, runas de area, magias de puxar, magias de suporte com temporizador ou exori amp kor. Exori amp kor conta os monstros proximos identificados pelo Shooter.</li><li>Cast with 1+: so para as outras magias e runas de alvo unico. Desmarque para usar a entrada somente quando o seu alvo for o unico monstro na tela.</li><li>Timer (s): tempo minimo em segundos entre usos da magia com temporizador; a recarga do servidor sempre e respeitada.</li><li>Usar em: usa a magia ou runa no alvo, em voce ou na melhor posicao para ataques em area.</li><li>Harmonia: harmonia minima exigida pelas magias que usam esse recurso.</li>",
	["Metrics used in the When row:<br><li>HP%: Health Points percentage.</li><li>MP%: Mana Points percentage.</li><br>Condition logic:<br><li>and: both conditions must be true.</li><li>or: at least one condition must be true.</li><br>Condition operators used in the Is row:<br><li>&lt; : value is below the threshold.</li><li>&lt;= : value is at or below the threshold.</li><li>&gt; : value is above the threshold.</li><li>&gt;= : value is at or above the threshold.</li>"] = "Metricas usadas na linha Quando:<br><li>HP%: percentual de pontos de vida.</li><li>MP%: percentual de pontos de mana.</li><br>Logica das condicoes:<br><li>e: ambas as condicoes devem ser verdadeiras.</li><li>ou: pelo menos uma condicao deve ser verdadeira.</li><br>Operadores usados na linha E:<br><li>&lt; : valor abaixo do limite.</li><li>&lt;= : valor igual ou abaixo do limite.</li><li>&gt; : valor acima do limite.</li><li>&gt;= : valor igual ou acima do limite.</li>",
	["Creates a new empty shared profile. The current profile is kept as it is."] = "Cria um novo perfil compartilhado vazio. O perfil atual continua como esta.",
	["Renames this shared profile for every character."] = "Renomeia este perfil compartilhado para todos os personagens.",
	["Deletes this shared profile for every character."] = "Exclui este perfil compartilhado para todos os personagens.",
	["Saves changes to this shared profile for every character."] = "Salva as alteracoes neste perfil compartilhado para todos os personagens.",
	["Shared Helper profile. Saving changes updates it for every character and account in this client."] = "Perfil compartilhado do Helper. Salvar alteracoes o atualiza para todos os personagens e contas deste cliente."
}
local HELPER_LANGUAGE_SKIPPED_PANELS = {
	targetPanel = true,
	MainMenuLeft = true,
	cavebotTimeValueLabel = true
}
local helperStatsWindow
local helperTickEvent
local helperTickIntervalMs = 50
local combatTickEvent
local combatTickIntervalMs = 50
local boundTargetHotkeyWindow
local targetHotkeyPendingCombo
local handleSpellCooldown
local handleSpellGroupCooldown
local handleMultiUseCooldown
local handleAttackingCreatureChange
local handleFollowingCreatureChange
local handleStatesChange
local bindCombatHotkeys
local unusedValue
local unusedValue
local HELPER_JSON_VERSION = 4
local DEFAULT_HELPER_PROFILE_NAME = "Default"
local AUTO_SWITCH_HOTKEY_PRESET_SETTING = "autoSwitchPreset"
local var_0_26
local textValue
local helperSavedOnLogout = false
local autoSaveEvent
local loadingConfig = false
local combatHotkeyBatchActive
local presetHotkey = ""
local var_0_33
local var_0_34 = false
local boundShooterHotkey

local function helperLog(level, message)
	if not g_logger then
		return
	end

	;(g_logger[level] or g_logger.info)("[game_helper] " .. message)
end

local function cancelAutoSave(arg_2_0)
	arg_2_0 = arg_2_0 and arg_2_0:lower() or "status"

	if arg_2_0 == "on" then
		var_0_34 = true
	elseif arg_2_0 == "off" then
		var_0_34 = false
	elseif arg_2_0 ~= "status" then
		return "helperhitch on | off | status"
	end

	return "Helper hitch " .. (var_0_34 and "ON" or "OFF")
end

local function var_0_38()
	local commandEnv = commandEnv

	if not commandEnv and modules.client_terminal then
		commandEnv = modules.client_terminal.commandEnv
	end

	if not commandEnv then
		return
	end

	commandEnv.helperhitch = cancelAutoSave
	boundShooterHotkey = commandEnv
end

local function saveActiveHelperCharacter()
	if boundShooterHotkey and boundShooterHotkey.helperhitch == cancelAutoSave then
		boundShooterHotkey.helperhitch = nil
	end

	boundShooterHotkey = nil
end

local function unbindCombatHotkeys()
	if autoSaveEvent then
		removeEvent(autoSaveEvent)

		autoSaveEvent = nil
	end
end

local function copyConfig(config)
	if type(config) ~= "table" then
		return {}
	end

	local ok, copied = pcall(function()
		return json.decode(json.encode(config))
	end)

	if ok and type(copied) == "table" then
		return copied
	end

	return config
end

local var_0_42 = {
	"hotkey",
	"autoTargetHotkey",
	"shooterHotkey",
	"shooterEnableHotkey",
	"shooterPresetHotkey",
	"sharedCombatHotkey",
	"cavebotHotkey"
}

local function var_0_43(arg_8_0)
	if type(arg_8_0) ~= "table" then
		return false
	end

	local var_8_0 = false

	for unusedValue, entry in ipairs(var_0_42) do
		if arg_8_0[entry] ~= nil then
			arg_8_0[entry] = nil
			var_8_0 = true
		end
	end

	return var_8_0
end

local function normalizeHelperLanguage(language)
	return language == "pt" and "pt" or "en"
end

local function getDefaultProfileName()
	if HelperConfigTab and HelperConfigTab.DEFAULT_PROFILE_NAME then
		return HelperConfigTab.DEFAULT_PROFILE_NAME
	end

	return DEFAULT_HELPER_PROFILE_NAME
end

local function configTableHasContent(config)
	return type(config) == "table" and next(config) ~= nil
end

local function ensureDefaultProfile(data)
	local defaultName = getDefaultProfileName()

	data.profiles = data.profiles or {}

	if next(data.profiles) ~= nil then
		return
	end

	if configTableHasContent(data.current) then
		data.profiles[defaultName] = copyConfig(data.current)
	else
		data.profiles[defaultName] = {}
	end
end

local function normalizeHelperData(raw)
	local data = type(raw) == "table" and raw or {}
	local numericValue = tonumber(data.version) or 0

	if type(data.profiles) ~= "table" then
		data.profiles = {}
	end

	if type(data.current) ~= "table" then
		data.current = {}
	end

	if data.activeProfile ~= nil and type(data.activeProfile) ~= "string" then
		data.activeProfile = nil
	end

	ensureDefaultProfile(data)

	local var_13_2 = var_0_43(data.current)

	for unusedValue, profile in pairs(data.profiles) do
		var_13_2 = var_0_43(profile) or var_13_2
	end

	if data.autoSaveEnabled == nil then
		data.autoSaveEnabled = true
	end

	data.openHelperStatsOnButton = nil
	data.language = normalizeHelperLanguage(data.language)
	data.version = HELPER_JSON_VERSION

	return data, var_13_2 or numericValue < HELPER_JSON_VERSION
end

local function readHelperJSON()
	if not HelperProfileStorage or not HelperProfileStorage.readDocument then
		helperLog("error", "Shared Helper profile storage is unavailable.")

		return normalizeHelperData({})
	end

	local var_14_0, var_14_1 = normalizeHelperData(HelperProfileStorage.readDocument())

	if var_14_1 and HelperProfileStorage.writeDocument then
		HelperProfileStorage.writeDocument(var_14_0)
	end

	return var_14_0
end

local function var_0_50(arg_15_0)
	if not HelperProfileStorage or not HelperProfileStorage.writeDocument then
		helperLog("error", "Shared Helper profile storage is unavailable for writes.")

		return false
	end

	arg_15_0 = normalizeHelperData(arg_15_0)

	return HelperProfileStorage.writeDocument(arg_15_0)
end

local function activateHelperCharacterStorage()
	local localPlayer = g_game.getLocalPlayer()

	if not localPlayer then
		var_0_26 = nil
		textValue = nil

		if HelperProfileStorage and HelperProfileStorage.clearActiveCharacter then
			HelperProfileStorage.clearActiveCharacter()
		end

		return false
	end

	local id = tostring(localPlayer:getId() or "")

	if id == "" or id == "0" then
		helperLog("error", "Cannot activate character Helper storage without a valid player id.")

		var_0_26 = nil
		textValue = nil

		if HelperProfileStorage and HelperProfileStorage.clearActiveCharacter then
			HelperProfileStorage.clearActiveCharacter()
		end

		return false
	end

	local characterName = g_game.getCharacterName() or localPlayer:getName() or ""

	var_0_26 = nil
	textValue = nil

	if HelperProfileStorage and HelperProfileStorage.clearActiveCharacter then
		HelperProfileStorage.clearActiveCharacter()
	end

	if not HelperProfileStorage or not HelperProfileStorage.activateCharacter or not HelperProfileStorage.activateCharacter(id, characterName) then
		helperLog("error", "Failed to activate shared Helper profiles for character id " .. id .. ".")

		return false
	end

	var_0_26 = id
	textValue = tostring(characterName)
	helperSavedOnLogout = false

	local activeStatePath = HelperProfileStorage.getActiveStatePath and HelperProfileStorage.getActiveStatePath() or "unavailable"

	helperLog("info", "Active Helper character state: " .. tostring(activeStatePath) .. " (" .. textValue .. "); profiles are shared.")

	return true
end

local TABS = {
	healing = {
		module = "healer",
		panelId = "healingPanel",
		buttonId = "healing"
	},
	healFriend = {
		module = "healFriend",
		panelId = "healFriendPanel",
		buttonId = "healFriend"
	},
	target = {
		module = "target",
		panelId = "targetPanel",
		buttonId = "targetButton"
	},
	shooter = {
		module = "shooter",
		panelId = "shooterPanel",
		buttonId = "shooterButton"
	},
	cavebot = {
		module = "cavebot",
		panelId = "cavebotPanel",
		buttonId = "cavebotButton"
	},
	party = {
		module = "autoparty",
		panelId = "partyPanel",
		buttonId = "partyButton"
	},
	tools = {
		module = "tools",
		panelId = "toolsPanel",
		buttonId = "toolsButton"
	},
	configs = {
		module = "config",
		panelId = "configsPanel",
		buttonId = "configsButton"
	}
}
local var_0_53 = {
	{
		id = "healing",
		rowId = "helperStatsHealingRow",
		widgetId = "enableHealingCheckBox",
		label = "Healing"
	},
	{
		id = "healFriend",
		rowId = "helperStatsHealFriendRow",
		widgetId = "enableHealFriendCheckBox",
		label = "Heal Friend"
	},
	{
		id = "target",
		rowId = "helperStatsTargetRow",
		widgetId = "enableTargetCheckBox",
		label = "Target Helper"
	},
	{
		id = "shooter",
		rowId = "helperStatsShooterRow",
		widgetId = "enableShooterCheckBox",
		label = "Shooter Helper"
	},
	{
		id = "cavebot",
		rowId = "helperStatsCavebotRow",
		widgetId = "enableCavebotCheckBox",
		label = "Cavebot Helper"
	},
	{
		id = "autoInvite",
		rowId = "helperStatsAutoInviteRow",
		widgetId = "toolsAutoPartyCheckBox",
		label = "Auto Invite"
	},
	{
		id = "autoAccept",
		rowId = "helperStatsAutoAcceptRow",
		widgetId = "toolsAutoPartyAcceptCheckBox",
		label = "Auto Accept"
	},
	{
		id = "autoHaste",
		rowId = "helperStatsAutoHasteRow",
		widgetId = "toolsAutoHasteCheckBox",
		label = "Auto Haste"
	},
	{
		id = "autoTraining",
		rowId = "helperStatsAutoTrainingRow",
		widgetId = "toolsAutoTrainingCheckBox",
		label = "Auto Training"
	},
	{
		id = "antiIdle",
		rowId = "helperStatsAntiIdleRow",
		widgetId = "toolsAntiIdleCheckBox",
		label = "Anti Idle"
	},
	{
		id = "manaTraining",
		rowId = "helperStatsManaTrainingRow",
		widgetId = "toolsManaTrainingCheckBox",
		label = "Mana Training"
	},
	{
		id = "changeGold",
		rowId = "helperStatsChangeGoldRow",
		widgetId = "toolsChangeGoldCheckBox",
		label = "Change Gold"
	},
	{
		id = "eatFood",
		rowId = "helperStatsEatFoodRow",
		widgetId = "toolsEatFoodCheckBox",
		label = "Eat Food"
	},
	{
		id = "reconnect",
		rowId = "helperStatsReconnectRow",
		widgetId = "toolsReconnectCheckBox",
		label = "Reconnect"
	}
}

local function syncButton()
	if not helperButton or helperButton:isDestroyed() or not helperButton.setTooltip then
		return
	end

	helperButton:setTooltip(tr("Open Helper"))
end

local function var_0_55()
	if helperButton and not helperButton:isDestroyed() then
		local var_18_0 = helperWindow and not helperWindow:isDestroyed() and not helperWindow:isHidden()

		helperButton:setOn(var_18_0 == true)
		syncButton()
	end
end

local function getWidget(id)
	return helperWindow and helperWindow:recursiveGetChildById(id)
end

local function setCharacterCardText(id, text, tooltip)
	local widget = getWidget(id)

	if not widget then
		return
	end

	if widget.setText then
		widget:setText(text or "")
	end

	if widget.setTooltip and tooltip then
		widget:setTooltip(tooltip)
	end
end

local function setCharacterCardName(fullName)
	local label = getWidget("helperCharacterName")

	if not label then
		return
	end

	fullName = tostring(fullName or "")

	label:setTooltip(fullName)
	label:setText(fullName)

	local budget = label:getWidth()

	if not budget or budget < 40 then
		budget = 98
	end

	local budget = math.max(1, budget - 2)

	if budget >= label:getTextSize().width then
		return
	end

	local dots = "..."
	local low = 0
	local high = #fullName
	local best = dots

	while low <= high do
		local middle = math.floor((low + high) / 2)
		local candidate = fullName:sub(1, middle) .. dots

		label:setText(candidate)

		if budget >= label:getTextSize().width then
			best = candidate
			low = middle + 1
		else
			high = middle - 1
		end
	end

	label:setText(best)
end

local function isCurrentAccountPremium(player)
	local account = G and G.characterAccount or nil

	if account and account.subStatus ~= nil and SubscriptionStatus then
		if account.subStatus == SubscriptionStatus.Premium then
			return true
		end

		if account.subStatus == SubscriptionStatus.Free then
			return false
		end
	end

	return player and player:isPremium() == true or false
end

local function refreshHelperCharacterCard()
	local player = g_game.isOnline() and g_game.getLocalPlayer() or nil
	local isPortuguese = 0

	if player then
		if player.getTotalMoney then
			isPortuguese = player:getTotalMoney() or 0
		elseif player.getResourceBalance then
			isPortuguese = (player:getResourceBalance(ResourceBank) or 0) + (player:getResourceBalance(ResourceInventary) or 0)
		end
	end

	local var_23_2 = player and (type(comma_value) == "function" and comma_value(isPortuguese) or tostring(isPortuguese)) or "?"

	setCharacterCardText("helperGoldBalance", var_23_2)
end

local function var_0_61()
	if not g_game.isOnline() then
		return
	end

	if g_game.requestResource then
		g_game.requestResource(ResourceBank)
		g_game.requestResource(ResourceInventary)
	elseif g_game.sendResourceBalance then
		g_game.sendResourceBalance()
	end
end

local function var_0_62()
	if not helperWindow or helperWindow:isDestroyed() then
		return
	end

	local localPlayer = g_game.isOnline() and g_game.getLocalPlayer() or nil
	local var_25_1 = helperLanguage == "pt"
	local var_25_2 = getWidget("helperCharacterOutfit")

	if var_25_2 then
		var_25_2:setVisible(localPlayer ~= nil)

		if localPlayer then
			var_25_2:setOutfit(localPlayer:getOutfit())

			local creature = var_25_2:getCreature()

			if creature and creature.setDirection then
				creature:setDirection(South)
			end
		end
	end

	local name = localPlayer and localPlayer:getName() or var_25_1 and "Desconectado" or "Offline"

	setCharacterCardName(name)

	local level = var_25_1 and "Nivel: -" or "Level: -"

	if localPlayer then
		level = string.format(var_25_1 and "Nivel: %d" or "Level: %d", localPlayer:getLevel())
	end

	setCharacterCardText("helperCharacterLevel", level)
	setCharacterCardText("helperAccountCaption", var_25_1 and "Status da Conta:" or "Account Status:")

	local var_25_6 = var_25_1 and "Desconectado" or "Offline"
	local var_25_7 = "/images/game/entergame/nopremium"

	if localPlayer then
		if isCurrentAccountPremium(localPlayer) then
			var_25_6 = var_25_1 and "Conta Premium" or "Premium Account"
			var_25_7 = "/images/game/entergame/premium"
		else
			var_25_6 = var_25_1 and "Conta Gratuita" or "Free Account"
		end
	end

	setCharacterCardText("helperAccountStatus", var_25_6, var_25_6)

	local var_25_8 = getWidget("helperAccountStatusIcon")

	if var_25_8 then
		var_25_8:setImageSource(var_25_7)
		var_25_8:setTooltip(var_25_6)
	end

	refreshHelperCharacterCard()

	local var_25_9 = getWidget("helperLanguageButton")

	if var_25_9 then
		var_25_9:setText(var_25_1 and "Portugues" or "English")
		var_25_9:setTooltip(var_25_1 and "Mudar idioma para ingles." or "Switch language to Portuguese.")
	end

	local var_25_10 = getWidget("helperLanguageFlagPt")

	if var_25_10 then
		var_25_10:setVisible(var_25_1)
	end

	local var_25_11 = getWidget("helperLanguageFlagEn")

	if var_25_11 then
		var_25_11:setVisible(not var_25_1)
	end
end

local function onHelperCharacterChanged()
	var_0_62()
end

local function handleResourceBalance(arg_27_0)
	if not arg_27_0 or arg_27_0 == ResourceBank or arg_27_0 == ResourceInventary then
		refreshHelperCharacterCard()
	end
end

local function var_0_65(HELPER_STATS_ITEMS, arg_28_1)
	if not HELPER_STATS_ITEMS then
		return
	end

	local id = HELPER_STATS_ITEMS.getId and HELPER_STATS_ITEMS:getId() or nil

	if HELPER_LANGUAGE_SKIPPED_PANELS[id] then
		return
	end

	local className = HELPER_STATS_ITEMS.getClassName and HELPER_STATS_ITEMS:getClassName() or ""

	if className ~= "UITextEdit" and className ~= "UIComboBox" and HELPER_STATS_ITEMS.getText and HELPER_STATS_ITEMS.setText then
		local text = HELPER_STATS_ITEMS:getText()

		if arg_28_1 and text and HELPER_PT_TRANSLATIONS[text] then
			HELPER_STATS_ITEMS.helperLanguageSourceText = text
		end

		local helperLanguageSourceText = HELPER_STATS_ITEMS.helperLanguageSourceText

		if helperLanguageSourceText then
			local helperLanguageAppliedText = HELPER_STATS_ITEMS.helperLanguageAppliedText

			if helperLanguageAppliedText and text ~= helperLanguageAppliedText and text ~= helperLanguageSourceText then
				if HELPER_PT_TRANSLATIONS[text] then
					helperLanguageSourceText = text
					HELPER_STATS_ITEMS.helperLanguageSourceText = text
				else
					helperLanguageSourceText = nil
					HELPER_STATS_ITEMS.helperLanguageSourceText = nil
					HELPER_STATS_ITEMS.helperLanguageAppliedText = nil
				end
			end

			if helperLanguageSourceText then
				local helperLanguageAppliedText = helperLanguage == "pt" and HELPER_PT_TRANSLATIONS[helperLanguageSourceText] or helperLanguageSourceText

				HELPER_STATS_ITEMS:setText(helperLanguageAppliedText)

				HELPER_STATS_ITEMS.helperLanguageAppliedText = helperLanguageAppliedText
			end
		end
	end

	if HELPER_STATS_ITEMS.getTooltip and HELPER_STATS_ITEMS.setTooltip then
		local tooltip = HELPER_STATS_ITEMS:getTooltip()

		if arg_28_1 and tooltip and var_0_5[tooltip] then
			HELPER_STATS_ITEMS.helperLanguageSourceTooltip = tooltip
		end

		local helperLanguageSourceTooltip = HELPER_STATS_ITEMS.helperLanguageSourceTooltip

		if helperLanguageSourceTooltip then
			local var_28_8 = helperLanguage == "pt" and var_0_5[helperLanguageSourceTooltip] or helperLanguageSourceTooltip

			HELPER_STATS_ITEMS:setTooltip(var_28_8)
		end
	end

	if HELPER_STATS_ITEMS.getChildren then
		for _, item in ipairs(HELPER_STATS_ITEMS:getChildren()) do
			var_0_65(item, arg_28_1)
		end
	end
end

local function var_0_66(arg_29_0)
	if not helperWindow then
		return
	end

	local var_29_0 = arg_29_0 == true or not helperUiLanguageCaptured

	var_0_65(helperWindow, var_29_0)

	helperUiLanguageCaptured = true
end

local function var_0_67(arg_30_0)
	helperLanguage = normalizeHelperLanguage(arg_30_0)

	for name, cfg in pairs(var_0_1) do
		if cfg and cfg.refreshLanguage then
			local var_30_0, var_30_1 = pcall(cfg.refreshLanguage, helperLanguage)

			if not var_30_0 then
				helperLog("warning", "refreshLanguage failed for " .. tostring(name) .. ": " .. tostring(var_30_1))
			end
		end
	end

	var_0_66(false)
	var_0_62()

	return helperLanguage
end

local function var_0_68(arg_31_0)
	if not helperStatsWindow or helperStatsWindow:isDestroyed() then
		return nil
	end

	return helperStatsWindow:recursiveGetChildById(arg_31_0.rowId)
end

local function var_0_69()
	local game_actionbar = modules.game_actionbar

	if game_actionbar and game_actionbar.refreshHelperActionBarSlots then
		game_actionbar.refreshHelperActionBarSlots()
	end
end

local function refreshHelperStatsWindow()
	if not helperStatsWindow or helperStatsWindow:isDestroyed() then
		var_0_69()

		return
	end

	for unusedValue, entry in ipairs(var_0_53) do
		local var_33_0 = var_0_68(entry)

		if entry.id == "healFriend" then
			local var_33_1 = HelperHealFriend and HelperHealFriend.isAllowedVocation and HelperHealFriend.isAllowedVocation()

			if var_33_0 then
				var_33_0:setVisible(var_33_1 == true)
			end

			if not var_33_1 then
				goto label_33_0
			end
		end

		do
			local statusIcon = var_33_0 and var_33_0:getChildById("statusIcon")
			local statusLabel = var_33_0 and var_33_0:getChildById("statusLabel")
			local var_33_4 = getWidget(entry.widgetId)
			local var_33_5 = var_33_4 and var_33_4:isChecked()
			local var_33_6 = false

			if entry.id == "shooter" and HelperShooter and HelperShooter.isDisabledByFollow and HelperShooter.isDisabledByFollow() then
				var_33_6 = true
			end

			if entry.id == "target" and HelperTarget and HelperTarget.isDisabledByProtectionZone and HelperTarget.isDisabledByProtectionZone() then
				var_33_6 = true
			end

			if entry.id == "shooter" and HelperShooter and HelperShooter.isDisabledByProtectionZone and HelperShooter.isDisabledByProtectionZone() then
				var_33_6 = true
			end

			if entry.id == "autoHaste" and var_33_5 then
				local var_33_7 = getWidget("toolsAutoHastePzCastCheckBox")
				local localPlayer = g_game.getLocalPlayer()

				if localPlayer and localPlayer.isInProtectionZone and localPlayer:isInProtectionZone() and var_33_7 and not var_33_7:isChecked() then
					var_33_6 = true
				end
			end

			local var_33_9 = var_33_5 or var_33_6

			if statusIcon then
				if var_33_6 then
					statusIcon:setImageSource("/images/icons/icon-paused")
				else
					statusIcon:setImageSource(var_33_9 and "/images/icons/icon-yes" or "/images/icons/icon-no")
				end
			end

			if statusLabel then
				statusLabel:setText(var_33_9 and tr("Enabled") or tr("Disabled"))

				local var_33_10 = "#5ff75f"
				local var_33_11 = "#f75f5f"

				if var_33_6 then
					var_33_10 = "#ff9854"
				end

				statusLabel:setColor(var_33_9 and var_33_10 or var_33_11)
			end
		end

		::label_33_0::
	end

	var_0_69()
end

function isHealFriendAllowed()
	return HelperHealFriend and HelperHealFriend.isAllowedVocation and HelperHealFriend.isAllowedVocation() == true
end

function isHelperStatsEntryEnabled(arg_35_0)
	if type(arg_35_0) ~= "string" or arg_35_0 == "" then
		return false
	end

	for unusedValue, entry in ipairs(var_0_53) do
		if entry.id == arg_35_0 then
			local var_35_0 = getWidget(entry.widgetId)

			return var_35_0 and var_35_0:isChecked() == true
		end
	end

	return false
end

function refreshHelperStats()
	refreshHelperStatsWindow()
end

local function unusedValue()
	local rightPanel = modules.game_interface and modules.game_interface.getRightPanel and modules.game_interface.getRightPanel()

	helperStatsWindow = g_ui.createWidget("HelperStatsWindow", rightPanel or rootWidget)

	if helperStatsWindow.setup then
		helperStatsWindow:setup()
	end

	if helperStatsWindow.setContentMinimumHeight then
		helperStatsWindow:setContentMinimumHeight(80)
	end

	for unusedValue, iter_37_1 in ipairs({
		"newWindowButton",
		"toggleFilterButton",
		"contextMenuButton",
		"lockButton"
	}) do
		local var_37_1 = helperStatsWindow:recursiveGetChildById(iter_37_1)

		if var_37_1 then
			var_37_1:setVisible(false)
			var_37_1:setOn(false)
		end
	end

	local closeButton = helperStatsWindow:recursiveGetChildById("closeButton")

	if closeButton then
		closeButton:setVisible(true)

		function closeButton.onClick()
			if helperStatsWindow and not helperStatsWindow:isDestroyed() then
				helperStatsWindow:closeAndForgetLayout()
			end

			var_0_55()
		end
	end

	for unusedValue, entry in ipairs(var_0_53) do
		local var_37_3 = var_0_68(entry)

		if var_37_3 then
			local titleLabel = var_37_3:getChildById("titleLabel")

			if titleLabel then
				titleLabel:setText(tr(entry.label))
			end

			var_37_3.helperStatsItemId = entry.id

			function var_37_3.onMousePress(arg_39_0, unusedArgument, arg_39_2)
				if arg_39_2 ~= MouseLeftButton then
					return false
				end

				modules.game_helper.toggleHelperStatsEntry(arg_39_0.helperStatsItemId)

				return true
			end
		end
	end

	local helperStatsOpenHelperButton = helperStatsWindow:recursiveGetChildById("helperStatsOpenHelperButton")

	if helperStatsOpenHelperButton then
		function helperStatsOpenHelperButton.onClick()
			modules.game_helper.openHelperFromStats()
		end
	end

	function helperStatsWindow.onVisibilityChange()
		var_0_55()
	end

	helperStatsWindow:hide()
	refreshHelperStatsWindow()
	var_0_55()
end

local function var_0_72()
	local localPlayer = g_game.getLocalPlayer()

	if not localPlayer then
		return 0
	end

	return translateVocation(localPlayer:getVocation())
end

local function var_0_73()
	if HelperConfigTab and HelperConfigTab.getProfileNameForAutoSave then
		return HelperConfigTab.getProfileNameForAutoSave()
	end

	return nil
end

function isAutoSaveEnabled()
	local var_44_0 = getWidget("configsAutoSaveCheckBox")

	if var_44_0 then
		return var_44_0:isChecked()
	end

	return readHelperJSON().autoSaveEnabled ~= false
end

local function var_0_74(arg_45_0)
	local var_45_0 = getWidget("configsAutoSaveCheckBox")

	if not var_45_0 then
		return
	end

	local var_45_1 = arg_45_0 ~= false

	if var_45_0:isChecked() ~= var_45_1 then
		loadingConfig = true

		var_45_0:setChecked(var_45_1)

		loadingConfig = false
	end
end

local function isAutoSwitchHotkeyPresetEnabled()
	if modules.client_options and modules.client_options.getOption then
		local var_46_0, var_46_1 = pcall(modules.client_options.getOption, AUTO_SWITCH_HOTKEY_PRESET_SETTING)

		if var_46_0 and type(var_46_1) == "boolean" then
			return var_46_1
		end
	end

	return g_settings and g_settings.getBoolean and g_settings.getBoolean(AUTO_SWITCH_HOTKEY_PRESET_SETTING) or false
end

local function applyAutoSwitchHotkeyPresetToCheckbox(enabled)
	local var_47_0 = getWidget("configsAutoSwitchHotkeyPresetCheckBox")

	if not var_47_0 then
		return
	end

	local var_47_1 = enabled == true

	if var_47_0:isChecked() ~= var_47_1 then
		loadingConfig = true

		var_47_0:setChecked(var_47_1)

		loadingConfig = false
	end
end

local function setAutoSwitchHotkeyPresetEnabled(enabled)
	local var_48_0 = enabled == true

	local function var_48_1()
		if not g_settings or not g_settings.save then
			return true
		end

		local var_49_0, var_49_1 = pcall(g_settings.save)

		if not var_49_0 then
			helperLog("error", "Failed to save native auto-switch option: " .. tostring(var_49_1))

			return false
		end

		return true
	end

	if modules.client_options and modules.client_options.setOption then
		local var_48_2, var_48_3 = pcall(modules.client_options.setOption, AUTO_SWITCH_HOTKEY_PRESET_SETTING, var_48_0, true)

		if var_48_2 and isAutoSwitchHotkeyPresetEnabled() == var_48_0 then
			return var_48_1()
		end

		if not var_48_2 then
			helperLog("warning", "Failed to update native auto-switch option: " .. tostring(var_48_3))
		end
	end

	if g_settings and g_settings.set then
		local var_48_4, var_48_5 = pcall(g_settings.set, AUTO_SWITCH_HOTKEY_PRESET_SETTING, var_48_0)

		if var_48_4 then
			return var_48_1()
		end

		helperLog("error", "Failed to persist native auto-switch option: " .. tostring(var_48_5))
	end

	return false
end

local function var_0_78()
	helperConfig.enableHelper = true
	helperConfig.enableHealing = getWidget("enableHealingCheckBox") and getWidget("enableHealingCheckBox"):isChecked() or false
	helperConfig.enableHealFriend = getWidget("enableHealFriendCheckBox") and getWidget("enableHealFriendCheckBox"):isChecked() or false

	local var_50_0 = getWidget("configsPrioritizeHotkeysCheckBox")

	helperConfig.prioritizeHotkeys = var_50_0 and var_50_0:isChecked() or false

	var_0_43(helperConfig)

	for unusedValue, cfg in pairs(TABS) do
		local mod = var_0_1[cfg.module]

		if mod and mod.collectConfig then
			mod.collectConfig(helperConfig)
		end
	end

	if HelperConditions and HelperConditions.collectConfig then
		HelperConditions.collectConfig(helperConfig)
	end

	return copyConfig(helperConfig)
end

local function var_0_79()
	if loadingConfig then
		return false
	end

	if not helperWindow then
		return false
	end

	local var_51_0 = var_0_78()

	helperConfig = var_51_0

	local var_51_1 = readHelperJSON()

	var_51_1.autoSaveEnabled = isAutoSaveEnabled()
	var_51_1.current = copyConfig(var_51_0)

	if var_51_1.autoSaveEnabled then
		local activeProfile = var_0_73()

		if not activeProfile or activeProfile == "" then
			activeProfile = var_51_1.activeProfile
		end

		if not activeProfile or activeProfile == "" then
			activeProfile = getDefaultProfileName()
		end

		if activeProfile and activeProfile ~= "" then
			var_51_1.profiles = var_51_1.profiles or {}
			var_51_1.profiles[activeProfile] = copyConfig(var_51_0)
			var_51_1.activeProfile = activeProfile

			if HelperConfigTab and HelperConfigTab.setSelectedProfileName then
				HelperConfigTab.setSelectedProfileName(activeProfile)
			end
		end
	end

	local var_51_3 = var_0_50(var_51_1)

	if not var_51_3 then
		helperLog("error", "Auto-save failed.")
	end

	refreshHelperStatsWindow()

	return var_51_3
end

local function var_0_80()
	if not autoSaveEvent then
		return
	end

	unbindCombatHotkeys()
	var_0_79()
end

local function var_0_81()
	if not var_0_26 or helperSavedOnLogout then
		return false
	end

	unbindCombatHotkeys()

	if var_0_79() then
		helperSavedOnLogout = true

		return true
	end

	return false
end

function closeShooterHotkeyWindow()
	if combatHotkeyBatchActive and not combatHotkeyBatchActive:isDestroyed() then
		combatHotkeyBatchActive:destroy()
	end

	combatHotkeyBatchActive = nil
	presetHotkey = ""
	var_0_33 = nil
end

local unusedValue
local var_0_83 = {
	CHAT_MODE.ON,
	CHAT_MODE.OFF
}

local function var_0_84(arg_55_0)
	if not Keybind or not arg_55_0 or arg_55_0 == "" then
		return false
	end

	if Keybind.isKeyComboUsed then
		for unusedValue, entry in ipairs(var_0_83) do
			if Keybind.isKeyComboUsed(arg_55_0, nil, nil, entry) then
				return true
			end
		end

		return false
	end

	if Keybind.reservedKeys and Keybind.reservedKeys[arg_55_0] then
		return true
	end

	if not Keybind.defaultKeybinds or not Keybind.getKeybindKeys then
		return false
	end

	for unusedValue, entry in ipairs(var_0_83) do
		for unusedValue, defaultKeybind in pairs(Keybind.defaultKeybinds) do
			local keybindKeys = Keybind.getKeybindKeys(defaultKeybind.category, defaultKeybind.action, entry, Keybind.currentPreset)

			if keybindKeys and (keybindKeys.primary == arg_55_0 or keybindKeys.secondary == arg_55_0) then
				return true
			end
		end
	end

	return false
end

local function var_0_85(arg_56_0)
	for unusedValue, entry in ipairs(var_0_83) do
		if Keybind and Keybind.isKeyComboUsedOnActionBar and Keybind.isKeyComboUsedOnActionBar(arg_56_0, entry) then
			return true
		end

		local game_actionbar = modules.game_actionbar

		if (not Keybind or not Keybind.isKeyComboUsedOnActionBar) and game_actionbar and game_actionbar.isKeyComboUsedOnActionBar and game_actionbar.isKeyComboUsedOnActionBar(arg_56_0, entry == CHAT_MODE.ON) then
			return true
		end
	end

	return false
end

local function var_0_86(arg_57_0)
	for unusedValue, entry in ipairs(var_0_83) do
		if Keybind and Keybind.isKeyComboUsedOnCustomHotkeys and Keybind.isKeyComboUsedOnCustomHotkeys(arg_57_0, entry) then
			return true
		end

		if (not Keybind or not Keybind.isKeyComboUsedOnCustomHotkeys) and CustomHotkeyManager and CustomHotkeyManager.isKeyComboUsed and CustomHotkeyManager.isKeyComboUsed(arg_57_0, nil, entry) then
			return true
		end
	end

	return false
end

local function var_0_87(arg_58_0, arg_58_1)
	if type(arg_58_0) ~= "string" or arg_58_0 == "" then
		return false, nil
	end

	if g_keyboard.isReservedMovementHotkey and g_keyboard.isReservedMovementHotkey(arg_58_0) then
		return true, helperLanguage == "pt" and "Esta hotkey e reservada para movimento." or "This hotkey is reserved for movement."
	end

	if var_0_84(arg_58_0) then
		return true, helperLanguage == "pt" and "Hotkey usada nos controles. Escolha outra." or "Hotkey used in Controls. Choose another."
	end

	if HelperShooter and HelperShooter.hasPresetHotkey and HelperShooter.hasPresetHotkey(arg_58_0, arg_58_1) or var_0_85(arg_58_0) or var_0_86(arg_58_0) then
		return true, helperLanguage == "pt" and "Esta hotkey ja esta em uso." or "This hotkey is already in use."
	end

	return false, nil
end

local function var_0_88(arg_59_0, arg_59_1, arg_59_2)
	if combatHotkeyBatchActive and not combatHotkeyBatchActive:isDestroyed() then
		combatHotkeyBatchActive:destroy()
	end

	combatHotkeyBatchActive = g_ui.loadUI("/game_actionbar/assign_hotkey", g_ui.getRootWidget())

	if not combatHotkeyBatchActive then
		return
	end

	var_0_33 = arg_59_2
	presetHotkey = HelperShooter and HelperShooter.getPresetHotkey and HelperShooter.getPresetHotkey(var_0_33) or ""

	combatHotkeyBatchActive:setText(tr(arg_59_0))

	local chatMode = combatHotkeyBatchActive:recursiveGetChildById("chatMode")

	if chatMode then
		chatMode:setVisible(false)
	end

	local hotkeyInstructionLabel = combatHotkeyBatchActive:recursiveGetChildById("hotkeyInstructionLabel")

	if hotkeyInstructionLabel then
		hotkeyInstructionLabel:setText(tr(arg_59_1))
	end

	local comboPreview = combatHotkeyBatchActive:recursiveGetChildById("comboPreview")
	local errorLabel = combatHotkeyBatchActive:recursiveGetChildById("errorLabel")
	local applyButton = combatHotkeyBatchActive:recursiveGetChildById("applyButton")

	local function var_59_5()
		if comboPreview then
			comboPreview:setText(tr("%s", presetHotkey or ""))
			comboPreview:resizeToText()
		end

		local var_60_0 = presetHotkey or ""
		local var_60_1, var_60_2 = var_0_87(var_60_0, var_0_33)

		if errorLabel then
			errorLabel:setText(var_60_2 or helperLanguage == "pt" and "Esta hotkey ja esta em uso." or "This hotkey is already in use.")
			errorLabel:setVisible(var_60_1)
		end

		if applyButton then
			applyButton:setEnabled(var_60_0 ~= "" and not var_60_1)
		end
	end

	var_59_5()

	function combatHotkeyBatchActive.onKeyDown(unusedArgument, arg_61_1, arg_61_2, arg_61_3)
		if not combatHotkeyBatchActive or combatHotkeyBatchActive:isDestroyed() then
			return false
		end

		combatHotkeyBatchActive:raise()
		combatHotkeyBatchActive:focus()

		presetHotkey = determineKeyComboDesc(arg_61_1, arg_61_2, arg_61_3) or ""

		var_59_5()

		return true
	end

	combatHotkeyBatchActive.onEscape = closeShooterHotkeyWindow

	if applyButton then
		function applyButton.onClick()
			local var_62_0 = presetHotkey or ""
			local var_62_1 = var_0_87(var_62_0, var_0_33)

			if var_62_0 == "" or var_62_1 then
				var_59_5()

				return
			end

			if not HelperShooter or not HelperShooter.setPresetHotkey or not HelperShooter.setPresetHotkey(var_0_33, var_62_0) then
				closeShooterHotkeyWindow()

				return
			end

			bindCombatHotkeys()
			var_0_79()
			closeShooterHotkeyWindow()
		end
	end

	local clearButton = combatHotkeyBatchActive:recursiveGetChildById("clearButton")

	if clearButton then
		function clearButton.onClick()
			if HelperShooter and HelperShooter.setPresetHotkey then
				HelperShooter.setPresetHotkey(var_0_33, "")
			end

			bindCombatHotkeys()
			var_0_79()
			closeShooterHotkeyWindow()
		end
	end

	local cancelButton = combatHotkeyBatchActive:recursiveGetChildById("cancelButton")

	if cancelButton then
		cancelButton.onClick = closeShooterHotkeyWindow
	end

	combatHotkeyBatchActive:grabKeyboard()
	combatHotkeyBatchActive:raise()
	combatHotkeyBatchActive:focus()
end

function openPresetHotkeyWindow(profileName)
	if not HelperShooter or not HelperShooter.getPresetHotkey or HelperShooter.getPresetHotkey(profileName) == nil then
		return
	end

	local var_64_0 = helperLanguage == "pt" and string.format("Editar Hotkey do Perfil %s", profileName) or string.format("Edit Hotkey for Profile %s", profileName)
	local var_64_1 = helperLanguage == "pt" and "Clique Ok para definir. Limpar remove a hotkey deste perfil." or "Click Ok to assign. Clear removes this profile hotkey."

	var_0_88(var_64_0, var_64_1, profileName)
end

local function var_0_89(arg_65_0)
	helperConfig = copyConfig(arg_65_0 or {})

	var_0_43(helperConfig)

	loadingConfig = true

	local var_65_0 = getWidget("checkbox")
	local var_65_1 = getWidget("enableHealingCheckBox")
	local var_65_2 = getWidget("enableHealFriendCheckBox")

	if var_65_0 then
		var_65_0:setChecked(true)
	end

	if var_65_1 then
		var_65_1:setChecked(helperConfig.enableHealing == true)
	end

	if var_65_2 then
		var_65_2:setChecked(helperConfig.enableHealFriend == true)
	end

	local var_65_3 = getWidget("configsPrioritizeHotkeysCheckBox")

	if var_65_3 then
		var_65_3:setChecked(helperConfig.prioritizeHotkeys == true)
	end

	if helperConfig.prioritizeHotkeys ~= true and HelperActionCoordinator then
		HelperActionCoordinator.clearManualHotkeyAction()
	end

	initDistanceControls()

	for unusedValue, entry in pairs(TABS) do
		local var_65_4 = var_0_1[entry.module]

		if var_65_4 and var_65_4.loadFromConfig then
			local var_65_5, var_65_6 = pcall(var_65_4.loadFromConfig, helperConfig)

			if not var_65_5 then
				helperLog("warning", "loadFromConfig failed for " .. tostring(entry.module) .. ": " .. tostring(var_65_6))
			end
		end
	end

	if HelperConditions and HelperConditions.loadFromConfig then
		HelperConditions.loadFromConfig(helperConfig)
	end

	local healFriend = var_0_1.healFriend

	if healFriend and healFriend.refreshAllPrioritySteppers then
		healFriend.refreshAllPrioritySteppers()
	end

	loadingConfig = false

	bindCombatHotkeys()

	if HelperShooter and HelperShooter.syncHotkeyStatus then
		HelperShooter.syncHotkeyStatus()
	end

	if syncCombatSchedulerState then
		syncCombatSchedulerState()
	end

	refreshHelperStatsWindow()
end

local function var_0_90()
	local var_66_0 = readHelperJSON()
	local fallbackProfileName = HelperConfigTab and HelperConfigTab.getFallbackProfileName and HelperConfigTab.getFallbackProfileName(var_66_0.profiles) or getDefaultProfileName()
	local var_66_2 = false

	if HelperConfigTab and HelperConfigTab.setLanguage then
		HelperConfigTab.setLanguage(var_66_0.language, false)
	end

	local activeProfile = textValue

	if isAutoSwitchHotkeyPresetEnabled() and activeProfile and activeProfile ~= "" and type(var_66_0.profiles[activeProfile]) == "table" and var_66_0.activeProfile ~= activeProfile then
		var_66_0.activeProfile = activeProfile
		var_66_0.current = copyConfig(var_66_0.profiles[activeProfile])
		var_66_2 = true

		helperLog("info", "Auto-switched Helper profile to \"" .. activeProfile .. "\".")
	end

	if var_66_0.autoSaveEnabled == nil then
		var_66_0.autoSaveEnabled = true
		var_66_2 = true
	end

	if not var_66_0.activeProfile or var_66_0.activeProfile == "" or type(var_66_0.profiles[var_66_0.activeProfile]) ~= "table" then
		var_66_0.activeProfile = fallbackProfileName
		var_66_2 = true
	end

	local var_66_4 = var_66_0.current or {}

	if var_66_0.activeProfile and type(var_66_0.profiles) == "table" and type(var_66_0.profiles[var_66_0.activeProfile]) == "table" then
		var_66_4 = var_66_0.profiles[var_66_0.activeProfile]

		if HelperConfigTab and HelperConfigTab.setSelectedProfileName then
			HelperConfigTab.setSelectedProfileName(var_66_0.activeProfile)
			HelperConfigTab.syncProfileNameEdit(var_66_0.activeProfile)
		end
	elseif type(var_66_0.profiles) == "table" and type(var_66_0.profiles[fallbackProfileName]) == "table" then
		var_66_4 = var_66_0.profiles[fallbackProfileName]

		if var_66_0.activeProfile == fallbackProfileName and HelperConfigTab then
			if HelperConfigTab.setSelectedProfileName then
				HelperConfigTab.setSelectedProfileName(fallbackProfileName)
			end

			if HelperConfigTab.syncProfileNameEdit then
				HelperConfigTab.syncProfileNameEdit(fallbackProfileName)
			end
		end
	end

	var_0_89(var_66_4)

	if var_66_0.autoSaveEnabled == false then
		var_0_74(false)
	else
		if var_66_0.autoSaveEnabled ~= true then
			var_66_2 = true
		end

		var_66_0.autoSaveEnabled = true

		var_0_74(true)
	end

	if var_66_2 then
		var_0_50(var_66_0)
	end

	if HelperConfigTab and HelperConfigTab.refreshProfileList then
		HelperConfigTab.refreshProfileList()
	end
end

local function var_0_91(arg_67_0, arg_67_1)
	if not modules.game_textmessage then
		return
	end

	if arg_67_0 then
		modules.game_textmessage.displayFailureMessage(arg_67_1)
	else
		modules.game_textmessage.displayGameMessage(arg_67_1)
	end
end

local function var_0_92()
	local localPlayer = g_game.getLocalPlayer()

	if not localPlayer then
		return nil
	end

	local maxHealth = localPlayer:getMaxHealth() or 0
	local health = localPlayer:getHealth()
	local healthPercent = maxHealth > 0 and health and health / maxHealth * 100 or localPlayer.getHealthPercent and localPlayer:getHealthPercent() or 100
	local maxMana = localPlayer:getMaxMana() or 0
	local mana = maxMana > 0 and localPlayer:getMana() / maxMana * 100 or 100

	return {
		nowMs = g_clock.millis(),
		player = localPlayer,
		healthPercent = healthPercent,
		manaPercent = mana
	}
end

local function helperShouldRunTick()
	return g_game.isOnline()
end

local function var_0_94()
	if not helperShouldRunTick() then
		return false, false
	end

	local var_70_0 = getWidget("enableTargetCheckBox")
	local var_70_1 = getWidget("enableShooterCheckBox")

	return var_70_0 and var_70_0:isChecked() or false, var_70_1 and var_70_1:isChecked() or false
end

local function var_0_95()
	if HelperActionCoordinator and HelperActionCoordinator.isAutomaticActionBlocked and HelperActionCoordinator.isAutomaticActionBlocked() then
		return true
	end

	local var_71_0 = g_clock.realMicros()
	local var_71_1, var_71_2 = var_0_94()

	if not var_71_1 and not var_71_2 then
		return false
	end

	local var_71_3 = g_clock.realMicros()
	local var_71_4 = var_0_92()
	local var_71_5 = g_clock.realMicros() - var_71_3

	if not var_71_4 then
		return true
	end

	local var_71_6 = 0
	local target = var_0_1.target

	if var_71_1 and target and target.runTick then
		local var_71_8 = g_clock.realMicros()
		local var_71_9, var_71_10 = pcall(target.runTick, var_71_4)

		var_71_6 = g_clock.realMicros() - var_71_8

		if not var_71_9 and g_logger and g_logger.error then
			g_logger.error("[game_helper] combatTick target failure: " .. tostring(var_71_10))
		end
	end

	local var_71_11 = 0
	local var_71_12 = 0
	local var_71_13 = 0
	local var_71_14 = 0
	local var_71_15 = "none"
	local var_71_16 = 0
	local shooter = var_0_1.shooter

	if var_71_2 and shooter and shooter.runTick then
		local var_71_18 = g_clock.realMicros()
		local var_71_19, var_71_20 = pcall(shooter.runTick, var_71_4)

		var_71_11 = g_clock.realMicros() - var_71_18

		if shooter.getLastTickProfile then
			var_71_12, var_71_13, var_71_14, var_71_15, var_71_16 = shooter.getLastTickProfile()
		end

		if not var_71_19 and g_logger and g_logger.error then
			g_logger.error("[game_helper] combatTick shooter failure: " .. tostring(var_71_20))
		end
	end

	local var_71_21 = g_clock.realMicros() - var_71_0

	if var_0_34 and var_71_21 >= 5000 and g_logger and g_logger.warning then
		g_logger.warning(string.format("[HelperHitch] total=%.2fms state=%.2fms target=%.2fms shooter=%.2fms scan=%.2fms creatures=%d priorities=%d hot=%s/%.2fms active=%s/%s", var_71_21 / 1000, var_71_5 / 1000, var_71_6 / 1000, var_71_11 / 1000, (tonumber(var_71_12) or 0) / 1000, tonumber(var_71_13) or 0, tonumber(var_71_14) or 0, tostring(var_71_15 or "none"), (tonumber(var_71_16) or 0) / 1000, tostring(var_71_1), tostring(var_71_2)))
	end

	return true
end

local function stopCombatScheduler()
	if combatTickEvent then
		removeEvent(combatTickEvent)

		combatTickEvent = nil
	end
end

local function var_0_97()
	if combatTickEvent then
		return
	end

	local var_73_0, var_73_1 = var_0_94()

	if not var_73_0 and not var_73_1 then
		return
	end

	combatTickEvent = scheduleEvent(function()
		combatTickEvent = nil

		local var_74_0, var_74_1 = pcall(var_0_95)

		if not var_74_0 then
			if g_logger and g_logger.error then
				g_logger.error("[game_helper] combatTick failure: " .. tostring(var_74_1))
			end
		elseif not var_74_1 then
			return
		end

		var_0_97()
	end, combatTickIntervalMs)
end

function syncCombatSchedulerState()
	local var_75_0, var_75_1 = var_0_94()

	if var_75_0 or var_75_1 then
		var_0_97()
	else
		stopCombatScheduler()
	end
end

function bindCombatHotkeys()
	if HelperShooter and HelperShooter.unbindPresetHotkeys then
		HelperShooter.unbindPresetHotkeys()
	end

	local var_76_0 = {}

	if HelperShooter and HelperShooter.bindPresetHotkeys then
		var_76_0 = HelperShooter.bindPresetHotkeys(function(arg_77_0, arg_77_1)
			return var_0_87(arg_77_1, arg_77_0)
		end) or {}
	end

	for unusedValue, entry in ipairs(var_76_0) do
		helperLog("warning", string.format("Shooter profile hotkey not bound because it is already in use: %s (%s)", tostring(entry.profile), tostring(entry.key)))
	end
end

local function closeHelperHotkeyWindow()
	if HelperShooter and HelperShooter.unbindPresetHotkeys then
		HelperShooter.unbindPresetHotkeys()
	end
end

local function loadConfigIntoWidgets()
	function boundTargetHotkeyWindow(arg_80_0)
		local target = var_0_1.target

		if target and target.onCreatureAppear then
			target.onCreatureAppear(arg_80_0)
		end
	end

	function targetHotkeyPendingCombo(arg_81_0)
		local target = var_0_1.target

		if target and target.onCreatureDisappear then
			target.onCreatureDisappear(arg_81_0)
		end
	end

	function handleSpellCooldown(arg_82_0, arg_82_1)
		if HelperShooter and HelperShooter.onSpellCooldown then
			HelperShooter.onSpellCooldown(arg_82_0, arg_82_1)
		end
	end

	function handleSpellGroupCooldown(arg_83_0, arg_83_1)
		if HelperShooter and HelperShooter.onSpellGroupCooldown then
			HelperShooter.onSpellGroupCooldown(arg_83_0, arg_83_1)
		end
	end

	function handleMultiUseCooldown(arg_84_0)
		if HelperShooter and HelperShooter.onMultiUseCooldown then
			HelperShooter.onMultiUseCooldown(arg_84_0)
		end
	end

	function handleAttackingCreatureChange(arg_85_0, arg_85_1)
		local target = var_0_1.target

		if target and target.onAttackingCreatureChange then
			target.onAttackingCreatureChange(arg_85_0, arg_85_1)
		end

		local shooter = var_0_1.shooter

		if shooter and shooter.onAttackingCreatureChange then
			local var_85_2, var_85_3 = pcall(shooter.onAttackingCreatureChange, arg_85_0, arg_85_1)

			if not var_85_2 and g_logger and g_logger.error then
				g_logger.error("[game_helper] attackingCreatureChange shooter failure: " .. tostring(var_85_3))
			end
		end
	end

	function handleFollowingCreatureChange(arg_86_0, arg_86_1)
		local shooter = var_0_1.shooter

		if shooter and shooter.onFollowingCreatureChange then
			shooter.onFollowingCreatureChange(arg_86_0, arg_86_1)
		end
	end

	function handleStatesChange(unusedArgument, arg_87_1, arg_87_2)
		local var_87_0 = PlayerStates and PlayerStates.Pz

		if not var_87_0 or bit.band(bit.bxor(arg_87_1, arg_87_2), var_87_0) == 0 then
			return
		end

		local target = var_0_1.target

		if target and target.refreshProtectionZoneState then
			target.refreshProtectionZoneState()
		end

		local shooter = var_0_1.shooter

		if shooter and shooter.refreshProtectionZoneState then
			shooter.refreshProtectionZoneState()
		end
	end

	connect(Creature, {
		onAppear = boundTargetHotkeyWindow,
		onDisappear = targetHotkeyPendingCombo
	})
	connect(LocalPlayer, {
		onStatesChange = handleStatesChange
	})
	connect(g_game, {
		onSpellCooldown = handleSpellCooldown,
		onSpellGroupCooldown = handleSpellGroupCooldown,
		onMultiUseCooldown = handleMultiUseCooldown,
		onAttackingCreatureChange = handleAttackingCreatureChange,
		onFollowingCreatureChange = handleFollowingCreatureChange
	})
end

local function disconnectCombatEvents()
	if boundTargetHotkeyWindow then
		disconnect(Creature, {
			onAppear = boundTargetHotkeyWindow,
			onDisappear = targetHotkeyPendingCombo
		})
	end

	if handleSpellCooldown or handleAttackingCreatureChange then
		disconnect(g_game, {
			onSpellCooldown = handleSpellCooldown,
			onSpellGroupCooldown = handleSpellGroupCooldown,
			onMultiUseCooldown = handleMultiUseCooldown,
			onAttackingCreatureChange = handleAttackingCreatureChange,
			onFollowingCreatureChange = handleFollowingCreatureChange
		})
	end

	if handleStatesChange then
		disconnect(LocalPlayer, {
			onStatesChange = handleStatesChange
		})
	end
end

local function var_0_101()
	if not helperShouldRunTick() then
		return
	end

	if HelperActionCoordinator and HelperActionCoordinator.isAutomaticActionBlocked and HelperActionCoordinator.isAutomaticActionBlocked() then
		return
	end

	local var_89_0 = var_0_92()

	if not var_89_0 then
		return
	end

	local healer = var_0_1.healer

	if healer and healer.runTick and healer.runTick(var_89_0) then
		return
	end

	if healer and healer.shouldYieldToHealing and healer.shouldYieldToHealing(var_89_0.player) then
		return
	end

	local healFriend = var_0_1.healFriend

	if healFriend and healFriend.runTick then
		healFriend.runTick(var_89_0)
	end
end

local function startScheduler()
	if helperTickEvent then
		return
	end

	tagHitchEventSource("game_helper.runHelperTick")

	helperTickEvent = cycleEvent(function()
		local var_91_0, var_91_1 = pcall(var_0_101)

		if not var_91_0 and g_logger and g_logger.error then
			g_logger.error("[game_helper] helperTick failure: " .. tostring(var_91_1))
		end
	end, helperTickIntervalMs)
end

local function stopScheduler()
	if helperTickEvent then
		removeEvent(helperTickEvent)

		helperTickEvent = nil
	end
end

local function initModules()
	var_0_1.healer = HelperHealer
	var_0_1.healFriend = HelperHealFriend
	var_0_1.target = HelperTarget
	var_0_1.shooter = HelperShooter
	var_0_1.cavebot = HelperCavebot
	var_0_1.conditions = HelperConditions
	var_0_1.tools = HelperTools
	var_0_1.autoparty = HelperAutoParty
	var_0_1.config = HelperConfigTab

	local var_93_0 = {
		getWidget = getWidget,
		getPlayerVoc = var_0_72,
		saveConfig = var_0_79,
		isLoadingConfig = function()
			return loadingConfig
		end,
		getLanguage = function()
			return helperLanguage
		end,
		applyWidgetLanguage = function(arg_96_0)
			var_0_65(arg_96_0, true)
		end,
		rebindCombatHotkeys = function()
			if bindCombatHotkeys then
				bindCombatHotkeys()
			end
		end,
		requestAutoSave = function()
			autoSave()
		end,
		isTabActive = function(arg_99_0)
			return currentTab == arg_99_0 and helperWindow and not helperWindow:isHidden()
		end,
		readDistanceValue = readDistanceValue,
		applyDistanceValue = applyDistanceValue,
		collectConfig = var_0_78,
		applyConfig = var_0_89
	}

	for unusedValue, entry in pairs(TABS) do
		if entry.module ~= "config" then
			local var_93_1 = var_0_1[entry.module]

			if var_93_1 and var_93_1.init then
				var_93_1.init(var_93_0)
			end
		end
	end

	if HelperConditions and HelperConditions.init then
		HelperConditions.init(var_93_0)
	end

	if HelperPresets and HelperPresets.init then
		HelperPresets.init(var_93_0)
	end

	if HelperConfigTab and HelperConfigTab.init then
		HelperConfigTab.init({
			getWidget = getWidget,
			readHelperJSON = readHelperJSON,
			writeHelperJSON = var_0_50,
			refreshProfileLibrary = function()
				return HelperProfileStorage and HelperProfileStorage.refreshLibrary and HelperProfileStorage.refreshLibrary() or false
			end,
			copyConfig = copyConfig,
			collectConfig = var_0_78,
			applyConfig = var_0_89,
			applyConfigSnapshot = function(arg_101_0)
				helperConfig = copyConfig(arg_101_0)
			end,
			isAutoSaveEnabled = isAutoSaveEnabled,
			isLoadingConfig = function()
				return loadingConfig
			end,
			getLanguage = function()
				return helperLanguage
			end,
			applyLanguage = var_0_67,
			getProfileNameForAutoSave = var_0_73,
			applyAutoSavePreferenceToCheckbox = var_0_74,
			isAutoSwitchHotkeyPresetEnabled = isAutoSwitchHotkeyPresetEnabled,
			applyAutoSwitchHotkeyPresetToCheckbox = applyAutoSwitchHotkeyPresetToCheckbox,
			cancelAutoSave = unbindCombatHotkeys,
			flushAutoSave = var_0_80,
			showMessage = var_0_91,
			log = helperLog,
			openHelperWindow = function()
				if helperWindow then
					helperWindow:show()
					helperWindow:raise()
					helperWindow:focus()
				end
			end
		})
	end
end

local function getModuleForTab(tab)
	local var_105_0 = tab and TABS[tab]

	return var_105_0 and var_0_1[var_105_0.module] or nil
end

local function showCurrentTabModule()
	local var_106_0 = getModuleForTab(currentTab)

	if var_106_0 and var_106_0.onShow then
		var_106_0.onShow()
	end
end

local function hideCurrentTabModule()
	local var_107_0 = getModuleForTab(currentTab)

	if var_107_0 and var_107_0.onHide then
		var_107_0.onHide()
	end
end

local function var_0_108()
	return g_game and g_game.isCavebotAuthorized and g_game.isCavebotAuthorized()
end

local function var_0_109(arg_109_0)
	local var_109_0 = getWidget("partyButtonFrame")

	if not var_109_0 then
		return
	end

	local var_109_1 = arg_109_0 and "cavebotButtonFrame" or "shooterButtonFrame"

	var_109_0:breakAnchors()
	var_109_0:addAnchor(AnchorTop, var_109_1, AnchorBottom)
	var_109_0:addAnchor(AnchorLeft, "parent", AnchorLeft)
	var_109_0:setMarginLeft(7)
	var_109_0:setMarginTop(5)
end

local function refreshHelperCharacterCard(arg_110_0)
	local var_110_0 = getWidget("cavebotButtonFrame")
	local var_110_1 = getWidget("cavebotButton")
	local var_110_2 = getWidget("cavebotPanel")

	if var_110_0 then
		var_110_0:setVisible(arg_110_0)
	end

	if var_110_1 then
		var_110_1:setVisible(arg_110_0)
	end

	if var_110_2 and not arg_110_0 then
		var_110_2:setVisible(false)
	end

	var_0_109(arg_110_0)

	if not arg_110_0 and currentTab == "cavebot" then
		currentTab = nil

		showTab("healing")
	end
end

function onCavebotAuthorized(unusedArgument, arg_111_1, arg_111_2, arg_111_3)
	refreshHelperCharacterCard(true)

	local cavebot = var_0_1.cavebot

	if cavebot and cavebot.onAuthorized then
		cavebot.onAuthorized(arg_111_1, arg_111_2, arg_111_3)
	end
end

function onCavebotStatus(arg_112_0, arg_112_1, arg_112_2, arg_112_3)
	local cavebot = var_0_1.cavebot

	if cavebot and cavebot.onStatus then
		cavebot.onStatus(arg_112_0, arg_112_1, arg_112_2, arg_112_3)
	end
end

function showTab(tab)
	if tab == "cavebot" and not var_0_108() then
		return
	end

	if not helperWindow or currentTab == tab then
		return
	end

	local var_113_0 = currentTab

	currentTab = tab

	for key, entry in pairs(TABS) do
		local var_113_1 = key == tab
		local var_113_2 = getWidget(entry.buttonId)
		local var_113_3 = getWidget(entry.panelId)

		if var_113_2 then
			var_113_2:setOn(var_113_1)
		end

		if var_113_3 then
			var_113_3:setVisible(var_113_1)
		end
	end

	if var_113_0 and TABS[var_113_0] then
		local var_113_4 = getModuleForTab(var_113_0)

		if var_113_4 and var_113_4.onHide then
			var_113_4.onHide()
		end
	end

	if TABS[tab] then
		local var_113_5 = getModuleForTab(tab)

		if var_113_5 and var_113_5.onShow then
			var_113_5.onShow()
		end
	end

	var_0_66(false)
end

local var_0_111 = 1
local var_0_112 = 7
local var_0_113 = 7

function clampDistanceValue(value, default)
	local numericValue = tonumber(value)

	if not numericValue then
		return default or var_0_113
	end

	local var_114_1 = math.floor(numericValue)

	if var_114_1 < var_0_111 then
		var_114_1 = var_0_111
	end

	if var_114_1 > var_0_112 then
		var_114_1 = var_0_112
	end

	return var_114_1
end

local function var_0_114(arg_115_0)
	if not arg_115_0 then
		return nil
	end

	if arg_115_0.getCurrentOption then
		local currentOption = arg_115_0:getCurrentOption()

		if type(currentOption) == "table" then
			return currentOption.text
		end

		return currentOption
	end

	if arg_115_0.getText then
		return arg_115_0:getText()
	end

	return nil
end

local function var_0_115(arg_116_0, arg_116_1, arg_116_2)
	if not arg_116_0 then
		return
	end

	local textValue = tostring(clampDistanceValue(arg_116_1, arg_116_2 or var_0_113))

	if arg_116_0.setCurrentOption then
		arg_116_0:setCurrentOption(textValue, true)
	elseif arg_116_0.setText then
		arg_116_0:setText(textValue)
	end
end

local function var_0_116(arg_117_0)
	if not arg_117_0 or not arg_117_0.addOption then
		return
	end

	if arg_117_0.getOptionsCount and arg_117_0:getOptionsCount() > 0 then
		return
	end

	for iter_117_0 = var_0_111, var_0_112 do
		arg_117_0:addOption(tostring(iter_117_0), iter_117_0)
	end
end

function readDistanceValue(id)
	local var_118_0 = getWidget(id)

	return clampDistanceValue(var_0_114(var_118_0), var_0_113)
end

function applyDistanceValue(id, value)
	local var_119_0 = getWidget(id)

	var_0_116(var_119_0)
	var_0_115(var_119_0, value, var_0_113)
end

function initDistanceControls()
	applyDistanceValue("targetDistanceCombo", var_0_113)
end

function onTargetDistanceChange(unusedArgument)
	if loadingConfig then
		return
	end

	autoSave()
end

function onTargetModeChange(unusedArgument)
	if loadingConfig then
		return
	end

	local target = var_0_1.target

	if target and target.onTargetModeChange then
		target.onTargetModeChange()
	else
		autoSave()
	end
end

function onTargetPriorityChange(unusedArgument)
	if loadingConfig then
		return
	end

	local target = var_0_1.target

	if target and target.onTargetPriorityChange then
		target.onTargetPriorityChange()
	else
		autoSave()
	end
end

function onTargetPzAutoChange(unusedArgument)
	if loadingConfig then
		return
	end

	local target = var_0_1.target

	if target and target.onTargetPzAutoChange then
		target.onTargetPzAutoChange()
	else
		autoSave()
	end
end

function autoSave()
	if loadingConfig then
		return
	end

	unbindCombatHotkeys()

	autoSaveEvent = scheduleEvent(function()
		autoSaveEvent = nil

		var_0_79()
	end, 800)

	refreshHelperStatsWindow()
end

function openHelperFromStats()
	if not helperWindow then
		return
	end

	local var_127_0 = helperWindow:isHidden()

	helperWindow:show()
	helperWindow:raise()
	helperWindow:focus()

	if not currentTab then
		showTab("healing")
	elseif var_127_0 then
		showCurrentTabModule()
	end

	var_0_55()
end

function closeHelperStatsWindow()
	if helperStatsWindow and not helperStatsWindow:isDestroyed() then
		helperStatsWindow:closeAndForgetLayout()
	end

	var_0_55()
end

function toggleHelperStatsWindow()
	if not helperStatsWindow or helperStatsWindow:isDestroyed() then
		return
	end

	if not helperStatsWindow:isHidden() then
		helperStatsWindow:closeAndForgetLayout()
	else
		if not helperStatsWindow:getParent() then
			local minimumHeight = modules.game_interface.findContentPanelAvailable(helperStatsWindow, helperStatsWindow:getMinimumHeight())

			if not minimumHeight then
				return
			end

			minimumHeight:addChild(helperStatsWindow)
		end

		helperStatsWindow:open()
		refreshHelperStatsWindow()
		helperStatsWindow:raise()
		helperStatsWindow:focus()
	end

	var_0_55()
end

function toggleHelperStatsEntry(itemId)
	if loadingConfig then
		return
	end

	for unusedValue, entry in ipairs(var_0_53) do
		if entry.id == itemId then
			if entry.id == "target" and HelperTarget and HelperTarget.isDisabledByProtectionZone and HelperTarget.isDisabledByProtectionZone() and HelperTarget.disableProtectionZonePause then
				HelperTarget.disableProtectionZonePause()
				refreshHelperStatsWindow()

				return
			end

			if entry.id == "shooter" and HelperShooter and (HelperShooter.isDisabledByFollow and HelperShooter.isDisabledByFollow() or HelperShooter.isDisabledByProtectionZone and HelperShooter.isDisabledByProtectionZone()) and HelperShooter.disablePausedState then
				HelperShooter.disablePausedState()
				refreshHelperStatsWindow()

				return
			end

			local var_130_0 = getWidget(entry.widgetId)

			if var_130_0 then
				local var_130_1 = not var_130_0:isChecked()

				if var_130_1 and entry.id == "target" and HelperTarget and HelperTarget.enableProtectionZonePause and HelperTarget.enableProtectionZonePause() then
					refreshHelperStatsWindow()

					return
				end

				if var_130_1 and entry.id == "shooter" and HelperShooter and HelperShooter.enableProtectionZonePause and HelperShooter.enableProtectionZonePause() then
					refreshHelperStatsWindow()

					return
				end

				var_130_0:setChecked(var_130_1)
				refreshHelperStatsWindow()
			end

			return
		end
	end
end

function openProfileWindow()
	if HelperConfigTab and HelperConfigTab.openProfileWindow then
		HelperConfigTab.openProfileWindow()
	end
end

function onSaveProfile()
	if HelperConfigTab and HelperConfigTab.saveProfile then
		HelperConfigTab.saveProfile()
	end
end

function onLoadProfile()
	if HelperConfigTab and HelperConfigTab.loadProfile then
		HelperConfigTab.loadProfile()
	end
end

function onDeleteProfile()
	if HelperConfigTab and HelperConfigTab.deleteProfile then
		HelperConfigTab.deleteProfile()
	end
end

function onQuickProfileNew()
	if HelperConfigTab and HelperConfigTab.newQuickProfile then
		HelperConfigTab.newQuickProfile()
	end
end

function onQuickProfileSave()
	if HelperConfigTab and HelperConfigTab.saveQuickProfile then
		HelperConfigTab.saveQuickProfile()
	end
end

function onQuickProfileRename()
	if HelperConfigTab and HelperConfigTab.renameQuickProfile then
		HelperConfigTab.renameQuickProfile()
	end
end

function onQuickProfileDelete()
	if HelperConfigTab and HelperConfigTab.deleteQuickProfile then
		HelperConfigTab.deleteQuickProfile()
	end
end

local var_0_117

local function var_0_118()
	if var_0_117 and not var_0_117:isDestroyed() then
		var_0_117:destroy()
	end

	var_0_117 = nil
end

local var_0_119

local function var_0_120()
	if var_0_119 and not var_0_119:isDestroyed() then
		var_0_119:destroy()
	end

	var_0_119 = nil
end

local function var_0_121(arg_141_0)
	if not arg_141_0 or arg_141_0 == "" then
		return false
	end

	local var_141_0 = readHelperJSON()

	return type(var_141_0.profiles) == "table" and var_141_0.profiles[arg_141_0] ~= nil
end

local function var_0_122(arg_142_0, arg_142_1)
	var_0_80()

	local var_142_0, var_142_1, var_142_2 = pcall(HelperPresets.generate, arg_142_0)

	if not var_142_0 then
		helperLog("error", "Preset generation failed: " .. tostring(var_142_1))
		var_0_91(true, tr("Preset generation failed."))

		return false
	end

	if var_142_1 ~= true then
		if var_142_2 then
			var_0_91(true, var_142_2)
		end

		return false
	end

	if arg_142_1 and arg_142_1 ~= "" and HelperConfigTab and HelperConfigTab.saveProfile then
		HelperConfigTab.saveProfile(arg_142_1)
	end

	if var_142_2 then
		var_0_91(false, var_142_2)
	end

	return true
end

local function var_0_123(arg_143_0)
	var_0_120()

	local profileName = HelperPresets.getProfileName and HelperPresets.getProfileName(arg_143_0)

	if not var_0_121(profileName) then
		return var_0_122(arg_143_0, profileName)
	end

	var_0_119 = displayGeneralBox(tr("Overwrite Preset"), tr("The preset \"%s\" already exists. Replace it?", profileName), {
		{
			text = tr("No"),
			callback = var_0_120
		},
		{
			text = tr("Yes"),
			callback = function()
				var_0_120()
				var_0_122(arg_143_0, profileName)
			end
		}
	}, nil, var_0_120)
end

function onQuickProfileAutoGenerate()
	if not HelperPresets or type(HelperPresets.generate) ~= "function" then
		return
	end

	var_0_118()
	var_0_120()

	local elementOptions = HelperPresets.getElementOptions and HelperPresets.getElementOptions()

	if type(elementOptions) ~= "table" or #elementOptions == 0 then
		return var_0_123(nil)
	end

	local var_145_1 = {
		{
			text = tr("Cancel"),
			callback = var_0_118
		}
	}

	for iter_145_0 = #elementOptions, 1, -1 do
		local var_145_2 = elementOptions[iter_145_0]

		table.insert(var_145_1, {
			text = tr(var_145_2.label),
			callback = function()
				var_0_118()
				var_0_123(var_145_2.id)
			end
		})
	end

	var_0_117 = displayGeneralBox(tr("Choose Element"), tr("Which elemental line should the rotation be built around?"), var_145_1, nil, var_0_118)
end

local function countAttackRunes()
	if not SpellRunesData then
		return 0
	end

	local var_147_0 = 0

	for key, entry in pairs(SpellRunesData) do
		if entry.group == 1 and Spells.getRuneSpellByItem(key) then
			var_147_0 = var_147_0 + 1
		end
	end

	return var_147_0
end

local function validateHelperRuntime()
	local warnings = {}

	if not helperWindow or helperWindow:isDestroyed() then
		table.insert(warnings, "HelperWindow missing or destroyed after init")
	else
		for unusedValue, iter_148_1 in ipairs({
			"presetBar",
			"quickProfileCombo",
			"quickProfileAutoButton",
			"quickProfileNewButton",
			"quickProfileSaveButton",
			"quickProfileRenameButton",
			"quickProfileDeleteButton",
			"helperCharacterCard",
			"helperCharacterOutfit",
			"helperCharacterName",
			"helperCharacterLevel",
			"helperAccountStatus",
			"helperLanguageButton",
			"toolsAutoAmmoSection",
			"toolsAutoAmmoSlot",
			"toolsAutoAmmoCheckBox",
			"toolsAutoAmmoTargetCombo",
			"enableCavebotCheckBox",
			"cavebotWaypointsList",
			"cavebotMapPreview"
		}) do
			if not getWidget(iter_148_1) then
				table.insert(warnings, "Helper UI widget missing: " .. iter_148_1)
			end
		end

		for name, iter_148_3 in pairs(TABS) do
			if not getWidget(iter_148_3.panelId) then
				table.insert(warnings, "Tab panel missing: " .. name .. " (" .. iter_148_3.panelId .. ")")
			end

			if not getWidget(iter_148_3.buttonId) then
				table.insert(warnings, "Tab button missing: " .. name .. " (" .. iter_148_3.buttonId .. ")")
			end

			if not var_0_1[iter_148_3.module] then
				table.insert(warnings, "Module missing for tab: " .. name)
			end
		end
	end

	local modalPaths = {
		"assign_healing",
		"assign_target",
		"assign_shooter",
		"assign_shooter_spell",
		"assign_helper",
		"shooter_preset"
	}

	for _, path in ipairs(modalPaths) do
		if not (g_resources.fileExists("/modules/game_helper/" .. path .. ".otui") or g_resources.fileExists("modules/game_helper/" .. path .. ".otui")) then
			table.insert(warnings, "Modal OTUI missing: " .. path)
		end
	end

	local runeCount = countAttackRunes()

	if runeCount == 0 then
		table.insert(warnings, "No attack runes in SpellRunesData")
	else
		helperLog("info", "Attack runes available: " .. runeCount)
	end

	local data = readHelperJSON()

	if type(data) ~= "table" then
		table.insert(warnings, "Helper JSON read returned invalid data")
	else
		local probe = copyConfig({
			validateProbe = true,
			version = HELPER_JSON_VERSION
		})

		if type(probe) == "table" and probe.validateProbe then
			helperLog("info", "Profile JSON round-trip OK")
		end
	end

	if #warnings == 0 then
		helperLog("info", "Helper runtime validation passed (init, tabs, modals, runes, JSON).")
	else
		for _, msg in ipairs(warnings) do
			helperLog("warning", "Validate: " .. msg)
		end
	end
end

function init()
	g_ui.importStyle("game_helper")
	var_0_38()

	if not HelperProfileStorage or not HelperProfileStorage.initialize or not HelperProfileStorage.initialize(helperLog) then
		helperLog("error", "Shared Helper profile storage could not be initialized.")
	end

	if HelperActionCoordinator and HelperActionCoordinator.init then
		HelperActionCoordinator.init()
	end

	connect(g_game, {
		onGameEnd = onGameEnd,
		onGameStart = onGameStart,
		onLogout = onLogout,
		onResourceBalance = handleResourceBalance,
		onCavebotAuthorized = onCavebotAuthorized,
		onCavebotStatus = onCavebotStatus
	})

	helperWindow = g_ui.createWidget("HelperWindow", rootWidget)

	helperWindow:hide()
	connect(LocalPlayer, {
		onLevelChange = onHelperCharacterChanged,
		onOutfitChange = onHelperCharacterChanged,
		onPremiumChange = onHelperCharacterChanged
	})

	if g_game.isOnline() and not activateHelperCharacterStorage() then
		helperLog("error", "Character Helper storage could not be activated during initialization.")
	end

	initModules()
	refreshHelperCharacterCard(var_0_108())
	var_0_61()
	var_0_62()
	loadConfigIntoWidgets()
	var_0_90()

	if helperShouldRunTick() then
		startScheduler()
		syncCombatSchedulerState()
	end

	validateHelperRuntime()

	if modules.game_mainpanel then
		helperButton = modules.game_mainpanel.addSpecialToggleButton("helperButton", tr("Open Helper"), "/images/options/button_helper", toggleHelperMainButton, false, 1002, "HelperMainToggleButton")

		helperButton:setImageBorder(0)
		syncButton()
		var_0_55()

		if modules.game_mainpanel.reorderMainPanelSpecialButtons then
			modules.game_mainpanel.reorderMainPanelSpecialButtons()
		end
	end
end

function onGameStart()
	local startedAt = g_clock.realMillis()

	if HelperActionCoordinator and HelperActionCoordinator.onGameStart then
		HelperActionCoordinator.onGameStart()
	end

	if var_0_26 and not helperSavedOnLogout then
		var_0_81()
	end

	unbindCombatHotkeys()

	helperSavedOnLogout = false

	refreshHelperCharacterCard(var_0_108())

	if not activateHelperCharacterStorage() then
		helperLog("error", "Character Helper storage could not be activated on game start.")
	end

	var_0_90()

	local cavebot = var_0_1.cavebot

	if cavebot and cavebot.onGameStart then
		cavebot.onGameStart()
	end

	helperLog("info", string.format("[login] Helper config ready in %d ms.", g_clock.realMillis() - startedAt))
	scheduleEvent(function()
		var_0_61()
		var_0_62()

		if not modules.game_mainpanel then
			return
		end

		helperButton = modules.game_mainpanel.getButton("helperButton") or helperButton

		var_0_55()

		if helperShouldRunTick() then
			startScheduler()
			syncCombatSchedulerState()
		else
			stopScheduler()
			stopCombatScheduler()
		end

		local targetMod = var_0_1.target

		if targetMod and targetMod.onGameStart then
			targetMod.onGameStart()
		end

		local shooterMod = var_0_1.shooter

		if shooterMod and shooterMod.onGameStart then
			shooterMod.onGameStart()
		end

		bindCombatHotkeys()

		local healer = var_0_1.healer

		if healer and healer.onGameStart then
			healer.onGameStart()
		end

		local mod = var_0_1.healFriend

		if mod and mod.applyVocationGate then
			mod.applyVocationGate()
		end
	end, 100)
end

function onLogout()
	local cavebot = var_0_1.cavebot

	if cavebot and cavebot.onLogout then
		cavebot.onLogout()
	end

	var_0_81()
end

function onGameEnd()
	if HelperActionCoordinator and HelperActionCoordinator.onGameEnd then
		HelperActionCoordinator.onGameEnd()
	end

	local cavebot = var_0_1.cavebot

	if cavebot and cavebot.onLogout then
		cavebot.onLogout()
	end

	stopScheduler()
	stopCombatScheduler()
	var_0_81()
	refreshHelperCharacterCard(false)
	onHelperClose()
end

function terminate()
	saveActiveHelperCharacter()
	var_0_81()
	unbindCombatHotkeys()
	closeHelperHotkeyWindow()
	closeShooterHotkeyWindow()
	stopScheduler()
	stopCombatScheduler()
	disconnectCombatEvents()

	if HelperActionCoordinator and HelperActionCoordinator.terminate then
		HelperActionCoordinator.terminate()
	end

	disconnect(g_game, {
		onGameEnd = onGameEnd,
		onGameStart = onGameStart,
		onLogout = onLogout,
		onResourceBalance = handleResourceBalance,
		onCavebotAuthorized = onCavebotAuthorized,
		onCavebotStatus = onCavebotStatus
	})
	disconnect(LocalPlayer, {
		onLevelChange = onHelperCharacterChanged,
		onOutfitChange = onHelperCharacterChanged,
		onPremiumChange = onHelperCharacterChanged
	})

	for _, tab in pairs(TABS) do
		local mod = var_0_1[tab.module]

		if tab.module ~= "config" and mod and mod.terminate then
			mod.terminate()
		end
	end

	if HelperConfigTab and HelperConfigTab.terminate then
		HelperConfigTab.terminate()
	end

	if HelperConditions and HelperConditions.terminate then
		HelperConditions.terminate()
	end

	if HelperPresets and HelperPresets.terminate then
		HelperPresets.terminate()
	end

	if helperButton then
		helperButton:destroy()
	end

	if helperStatsWindow and not helperStatsWindow:isDestroyed() then
		helperStatsWindow:destroy()
	end

	if helperWindow and not helperWindow:isDestroyed() then
		helperWindow:destroy()
	end

	helperStatsWindow = nil
	helperWindow = nil
	helperUiLanguageCaptured = false
	var_0_26 = nil
	textValue = nil

	if HelperProfileStorage and HelperProfileStorage.clearActiveCharacter then
		HelperProfileStorage.clearActiveCharacter()
	end

	helperSavedOnLogout = false
end

function beginManualEquipmentAction(arg_155_0)
	if not HelperActionCoordinator or not HelperActionCoordinator.beginManualEquipmentAction then
		return false
	end

	return HelperActionCoordinator.beginManualEquipmentAction(arg_155_0)
end

function beginManualHotkeyAction()
	if helperConfig.prioritizeHotkeys ~= true or not HelperActionCoordinator or not HelperActionCoordinator.beginManualHotkeyAction then
		return false
	end

	return HelperActionCoordinator.beginManualHotkeyAction()
end

function isAutomaticActionBlocked()
	return HelperActionCoordinator and HelperActionCoordinator.isAutomaticActionBlocked and HelperActionCoordinator.isAutomaticActionBlocked() or false
end

function onHelperClose()
	if helperWindow then
		helperWindow:hide()
	end

	var_0_62()

	local current = getModuleForTab(currentTab) or var_0_1.healer

	if current and current.onHide then
		current.onHide()
	end

	local mod = var_0_1.healer

	if mod and mod ~= current and mod.onHide then
		mod.onHide()
	end

	if not g_game.isOnline() then
		stopScheduler()
		stopCombatScheduler()
	end

	var_0_55()
end

local function saveConfig()
	if not helperWindow or helperWindow:isDestroyed() then
		return
	end

	local opening = helperWindow:isHidden()

	if not opening then
		hideCurrentTabModule()
	end

	helperWindow:setVisible(opening)

	if opening then
		if not currentTab then
			showTab("healing")
		else
			showCurrentTabModule()

			local mod = var_0_1.healer

			if mod and mod.clearListSelection then
				mod.clearListSelection()
			end
		end

		var_0_61()
		var_0_62()
		var_0_66(false)
	end

	var_0_55()
end

function toggle()
	saveConfig()
end

function onHelperLanguageToggle()
	if HelperConfigTab and HelperConfigTab.toggleLanguage then
		HelperConfigTab.toggleLanguage()
	end
end

function onConfigsAutoSaveChange(_, _)
	if loadingConfig then
		return
	end

	var_0_79()
end

function onConfigsPrioritizeHotkeysChange(unusedArgument, arg_163_1)
	if loadingConfig then
		return
	end

	helperConfig.prioritizeHotkeys = arg_163_1 == true

	if not arg_163_1 and HelperActionCoordinator then
		HelperActionCoordinator.clearManualHotkeyAction()
	end

	autoSave()
end

function toggleHelperMainButton()
	saveConfig()
end

function onConfigsAutoSwitchHotkeyPresetChange(_, checked)
	if loadingConfig then
		return
	end

	if not setAutoSwitchHotkeyPresetEnabled(checked) then
		applyAutoSwitchHotkeyPresetToCheckbox(isAutoSwitchHotkeyPresetEnabled())
		helperLog("error", "Auto-switch hotkey preset preference was not changed.")
	end
end

function onEnableTargetChange(self, checked)
	if loadingConfig then
		return
	end

	local mod = var_0_1.target

	if mod and mod.onEnableTargetCheckChange then
		mod.onEnableTargetCheckChange(self)
	elseif mod and mod.toggleAutoTarget then
		mod.toggleAutoTarget(self, true)
	else
		autoSave()
	end

	refreshHelperStatsWindow()
end

function onEnableShooterChange(self, checked)
	if loadingConfig then
		return
	end

	local mod = var_0_1.shooter

	if mod and mod.toggleMagicShooter then
		mod.toggleMagicShooter(self, nil, true)
	else
		autoSave()
	end

	refreshHelperStatsWindow()
end

function onEnableCavebotChange(arg_168_0, arg_168_1)
	if loadingConfig then
		return
	end

	local cavebot = var_0_1.cavebot

	if cavebot and cavebot.onEnableChange then
		cavebot.onEnableChange(arg_168_0, arg_168_1)
	else
		autoSave()
	end

	refreshHelperStatsWindow()
end

function openCavebotEchoRaidWindow()
	local cavebot = var_0_1.cavebot

	if cavebot and cavebot.openEchoRaidWindow then
		cavebot.openEchoRaidWindow()
	end
end

function closeCavebotEchoRaidWindow()
	local cavebot = var_0_1.cavebot

	if cavebot and cavebot.closeEchoRaidWindow then
		cavebot.closeEchoRaidWindow()
	end
end

function confirmCavebotEchoRaidWindow()
	local cavebot = var_0_1.cavebot

	if cavebot and cavebot.confirmEchoRaidWindow then
		cavebot.confirmEchoRaidWindow()
	end
end

function onCavebotEchoRaidModeChange(arg_172_0)
	local cavebot = var_0_1.cavebot

	if cavebot and cavebot.onEchoRaidModeChange then
		cavebot.onEchoRaidModeChange(arg_172_0)
	end
end

function onCavebotStartNearestWaypointChange(arg_173_0, arg_173_1)
	local cavebot = var_0_1.cavebot

	if cavebot and cavebot.onStartNearestWaypointChange then
		cavebot.onStartNearestWaypointChange(arg_173_0, arg_173_1)
	end
end

function onCavebotDiagonalWalkChange(arg_174_0, arg_174_1)
	local cavebot = var_0_1.cavebot

	if cavebot and cavebot.onDiagonalWalkChange then
		cavebot.onDiagonalWalkChange(arg_174_0, arg_174_1)
	end
end

function addCavebotWaypoint(arg_175_0)
	local cavebot = var_0_1.cavebot

	if cavebot and cavebot.addCurrentWaypoint then
		cavebot.addCurrentWaypoint(arg_175_0)
	end
end

function toggleCavebotRecording()
	local cavebot = var_0_1.cavebot

	if cavebot and cavebot.toggleRecording then
		cavebot.toggleRecording()
	end
end

function newCavebotPreset()
	local cavebot = var_0_1.cavebot

	if cavebot and cavebot.newPreset then
		cavebot.newPreset()
	end
end

function deleteCavebotPreset()
	local cavebot = var_0_1.cavebot

	if cavebot and cavebot.deleteNamedPreset then
		cavebot.deleteNamedPreset()
	end
end

function moveCavebotWaypoint(arg_179_0)
	local cavebot = var_0_1.cavebot

	if cavebot and cavebot.moveSelectedWaypoint then
		cavebot.moveSelectedWaypoint(arg_179_0)
	end
end

function removeCavebotWaypoint()
	local cavebot = var_0_1.cavebot

	if cavebot and cavebot.removeSelectedWaypoint then
		cavebot.removeSelectedWaypoint()
	end
end

function clearCavebotWaypoints()
	local cavebot = var_0_1.cavebot

	if cavebot and cavebot.requestClearWaypoints then
		cavebot.requestClearWaypoints()
	end
end

function openCavebotRenewWindow()
	local cavebot = var_0_1.cavebot

	if cavebot and cavebot.openRenewWindow then
		cavebot.openRenewWindow()
	end
end

function setCavebotMinimapView(arg_183_0, arg_183_1)
	local cavebot = var_0_1.cavebot

	if not cavebot or not cavebot.setExternalMapPreview then
		return false
	end

	return cavebot.setExternalMapPreview(arg_183_0, arg_183_1)
end

function closeCavebotRenewWindow()
	local cavebot = var_0_1.cavebot

	if cavebot and cavebot.closeRenewWindow then
		cavebot.closeRenewWindow()
	end
end

function confirmCavebotRenewWindow()
	local cavebot = var_0_1.cavebot

	if cavebot and cavebot.confirmRenewWindow then
		cavebot.confirmRenewWindow()
	end
end

function centerCavebotMap()
	local cavebot = var_0_1.cavebot

	if cavebot and cavebot.centerMapOnPlayer then
		cavebot.centerMapOnPlayer()
	end
end

function toggleCavebotAutoRoute()
	local cavebot = var_0_1.cavebot

	if cavebot and cavebot.toggleAutoRouteSelection then
		cavebot.toggleAutoRouteSelection()
	end
end

function navigateCavebotMap(arg_188_0)
	local cavebot = var_0_1.cavebot

	if cavebot and cavebot.navigateMap then
		cavebot.navigateMap(arg_188_0)
	end
end

function zoomCavebotMap(arg_189_0)
	local cavebot = var_0_1.cavebot

	if cavebot and cavebot.zoomMap then
		cavebot.zoomMap(arg_189_0)
	end
end

function changeCavebotMapFloor(arg_190_0)
	local cavebot = var_0_1.cavebot

	if cavebot and cavebot.changeMapFloor then
		cavebot.changeMapFloor(arg_190_0)
	end
end

function openAddHealingWindow()
	local healer = var_0_1.healer

	if healer and healer.openAddHealingWindow then
		healer.openAddHealingWindow()
	end
end

function openAddHealingSpellWindow()
	local healer = var_0_1.healer

	if healer and healer.openAddHealingSpellWindow then
		healer.openAddHealingSpellWindow()
	end
end

function openAddHealingPotionWindow()
	local healer = var_0_1.healer

	if healer and healer.openAddHealingPotionWindow then
		healer.openAddHealingPotionWindow()
	end
end

function openEditHealingWindow()
	local healer = var_0_1.healer

	if healer and healer.openEditHealingWindow then
		healer.openEditHealingWindow()
	end
end

function closeAddHealingWindow()
	local healer = var_0_1.healer

	if healer and healer.closeAddHealingWindow then
		healer.closeAddHealingWindow()
	end
end

function addHealingEntryOk()
	local healer = var_0_1.healer

	if healer and healer.addHealingEntryOk then
		healer.addHealingEntryOk()
	end
end

function addHealingEntryApply()
	local healer = var_0_1.healer

	if healer and healer.addHealingEntryApply then
		healer.addHealingEntryApply()
	end
end

function addHealingEntryConfirm()
	addHealingEntryOk()
end

function onHealingRemoveClick()
	local healer = var_0_1.healer

	if healer and healer.removeSelectedEntry then
		healer.removeSelectedEntry()
	end
end

function onAddHealingThresholdChange(edit)
	local healer = var_0_1.healer

	if healer and healer.onAddHealingThresholdChange then
		healer.onAddHealingThresholdChange(edit)
	end
end

function onAddHealingThresholdFocusChange(edit, focused)
	local healer = var_0_1.healer

	if healer and healer.onAddHealingThresholdFocusChange then
		healer.onAddHealingThresholdFocusChange(edit, focused)
	end
end

function onEnableHealingChange(self, on)
	local healer = var_0_1.healer

	if healer and healer.onEnableHealingChange then
		healer.onEnableHealingChange(self, on)
	else
		var_0_79()
	end

	refreshHelperStatsWindow()
end

function onEnableHealFriendChange(self, on)
	local healFriend = var_0_1.healFriend

	if healFriend and healFriend.onEnableHealFriendChange then
		healFriend.onEnableHealFriendChange(self, on)
	else
		var_0_79()
	end

	refreshHelperStatsWindow()
end

function onHealFriendClassToggle(self, on)
	local healFriend = var_0_1.healFriend

	if healFriend and healFriend.onHealFriendClassToggle then
		healFriend.onHealFriendClassToggle(self, on)
	else
		var_0_79()
	end
end

function onHealFriendThresholdChange(edit)
	local healFriend = var_0_1.healFriend

	if healFriend and healFriend.onThresholdChange then
		healFriend.onThresholdChange(edit)
	else
		autoSave()
	end
end

function onHealFriendThresholdFocusChange(edit, focused)
	local healFriend = var_0_1.healFriend

	if healFriend and healFriend.onThresholdFocusChange then
		healFriend.onThresholdFocusChange(edit, focused)
	end
end

function setupHealFriendPriorityStepper(stepper, valueId, defaultValue)
	local healFriend = var_0_1.healFriend

	if healFriend and healFriend.setupPriorityStepper then
		healFriend.setupPriorityStepper(stepper, valueId, defaultValue)
	end
end

function refreshHealFriendPriorityStepper(stepper)
	local healFriend = var_0_1.healFriend

	if healFriend and healFriend.refreshPriorityStepper then
		healFriend.refreshPriorityStepper(stepper)
	end
end

function onHealFriendPriorityClick(widget, action)
	local healFriend = var_0_1.healFriend

	if healFriend and healFriend.onPriorityClick then
		healFriend.onPriorityClick(widget, action)
	end
end

function openHealFriendPlayersWindow()
	local healFriend = var_0_1.healFriend

	if healFriend and healFriend.openPlayerListWindow then
		healFriend.openPlayerListWindow()
	end
end

function closeHealFriendPlayersWindow()
	local healFriend = var_0_1.healFriend

	if healFriend and healFriend.closePlayerListWindow then
		healFriend.closePlayerListWindow()
	end
end

function addHealFriendTypedPlayer()
	local healFriend = var_0_1.healFriend

	if healFriend and healFriend.addTypedPlayer then
		healFriend.addTypedPlayer()
	end
end

function addHealFriendVisiblePlayer()
	local healFriend = var_0_1.healFriend

	if healFriend and healFriend.addVisiblePlayer then
		healFriend.addVisiblePlayer()
	end
end

function removeHealFriendConfiguredPlayer()
	local healFriend = var_0_1.healFriend

	if healFriend and healFriend.removeConfiguredPlayer then
		healFriend.removeConfiguredPlayer()
	end
end

function refreshHealFriendVisiblePlayers()
	local healFriend = var_0_1.healFriend

	if healFriend and healFriend.refreshVisiblePlayers then
		healFriend.refreshVisiblePlayers()
	end
end

local function var_0_127()
	return modules.game_actionbar
end

local function var_0_128()
	local var_217_0 = var_0_127()

	if var_217_0 and var_217_0.getSpellAssignFilterText then
		return var_217_0.getSpellAssignFilterText()
	end

	return ""
end

function closeHelperAssignWindow()
	if HelperTools and HelperTools.isToolsItemAssignActive and HelperTools.isToolsItemAssignActive() then
		HelperTools.closeToolsItemAssignWindow()

		return
	end

	local healer = var_0_1.healer

	if healer and healer.isHelperItemAssignActive and healer.isHelperItemAssignActive() then
		healer.closeHelperItemAssignWindow()

		return
	end

	if healer and healer.cancelPendingHealingEntryAssign then
		healer.cancelPendingHealingEntryAssign()
	end

	closeHelperSpellAssignWindow()
end

function closeHelperSpellAssignWindow()
	local var_219_0 = var_0_127()

	if var_219_0 and var_219_0.closeSpellAssignWindow then
		var_219_0.closeSpellAssignWindow()
	end
end

function helperAssignOk()
	if HelperTools and HelperTools.isToolsItemAssignActive and HelperTools.isToolsItemAssignActive() then
		HelperTools.toolsItemAssignOk()

		return
	end

	local healer = var_0_1.healer

	if healer and healer.isHelperItemAssignActive and healer.isHelperItemAssignActive() then
		healer.helperItemAssignOk()

		return
	end

	helperSpellAssignOk()
end

function helperSpellAssignOk()
	local var_221_0 = var_0_127()

	if var_221_0 and var_221_0.spellAssignOk then
		var_221_0.spellAssignOk()
	end
end

function helperAssignApply()
	local healer = var_0_1.healer

	if healer and healer.isHelperItemAssignActive and healer.isHelperItemAssignActive() then
		return
	end

	helperSpellAssignApply()
end

function helperSpellAssignApply()
	local var_223_0 = var_0_127()

	if var_223_0 and var_223_0.spellAssignApply then
		var_223_0.spellAssignApply()
	end
end

function filterHelperAssign(text)
	if HelperTools and HelperTools.isToolsItemAssignActive and HelperTools.isToolsItemAssignActive() then
		HelperTools.filterToolsItemAssignEntries(text)

		return
	end

	local healer = var_0_1.healer

	if healer and healer.isHelperItemAssignActive and healer.isHelperItemAssignActive() then
		healer.filterHelperAssignEntries(text)

		return
	end

	filterHelperSpells(text)
end

function filterHelperSpells(text)
	local var_225_0 = var_0_127()

	if var_225_0 and var_225_0.filterSpells then
		var_225_0.filterSpells(text)
	end
end

function clearHelperAssignFilter()
	if HelperTools and HelperTools.isToolsItemAssignActive and HelperTools.isToolsItemAssignActive() then
		HelperTools.clearToolsItemAssignFilter()

		return
	end

	local healer = var_0_1.healer

	if healer and healer.isHelperItemAssignActive and healer.isHelperItemAssignActive() then
		healer.clearHelperItemAssignFilter()

		return
	end

	clearHelperSpellFilter()
end

function clearHelperSpellFilter()
	local var_227_0 = var_0_127()

	if var_227_0 and var_227_0.clearSpellFilter then
		var_227_0.clearSpellFilter()
	end
end

function onHelperAssignLearntChange()
	local healer = var_0_1.healer

	if healer and healer.isHelperItemAssignActive and healer.isHelperItemAssignActive() then
		healer.onHelperAssignLearntChange()

		return
	end

	filterHelperSpells(var_0_128())
end

function filterPotions(text)
	filterHelperAssign(text)
end

function clearPotionFilter()
	local healer = var_0_1.healer

	if healer and healer.clearPotionFilter then
		healer.clearPotionFilter()
	end
end

function potionAssignOk()
	local healer = var_0_1.healer

	if healer and healer.potionAssignOk then
		healer.potionAssignOk()
	end
end

function closePotionAssignWindow()
	local healer = var_0_1.healer

	if healer and healer.closePotionAssignWindow then
		healer.closePotionAssignWindow()
	end
end

function openTargetAssignWindow()
	local target = var_0_1.target

	if target and target.openAssignWindow then
		target.openAssignWindow()
	end
end

function openTargetEditWindow()
	local target = var_0_1.target

	if target and target.openEditAssignWindow then
		target.openEditAssignWindow()
	end
end

function closeTargetAssignWindow()
	local target = var_0_1.target

	if target and target.closeAssignWindow then
		target.closeAssignWindow()
	end
end

function targetAssignOk()
	local target = var_0_1.target

	if target and target.assignOk then
		target.assignOk()
	end
end

function filterTargetMonsters(text)
	local target = var_0_1.target

	if target and target.filterMonsters then
		target.filterMonsters(text)
	end
end

function clearTargetMonsterFilter()
	local target = var_0_1.target

	if target and target.clearMonsterFilter then
		target.clearMonsterFilter()
	end
end

function onTargetAllCreaturesChange(self, checked)
	local target = var_0_1.target

	if target and target.onAllCreaturesChange then
		target.onAllCreaturesChange(self, checked)
	end
end

function onTargetRemoveClick()
	local target = var_0_1.target

	if target and target.onRemoveClick then
		target.onRemoveClick()
	end
end

function openShooterAssignWindow()
	local shooter = var_0_1.shooter

	if shooter and shooter.openAssignWindow then
		shooter.openAssignWindow()
	end
end

function openShooterEditWindow()
	local shooter = var_0_1.shooter

	if shooter and shooter.openEditAssignWindow then
		shooter.openEditAssignWindow()
	end
end

function closeShooterAssignWindow()
	local shooter = var_0_1.shooter

	if shooter and shooter.closeAssignWindow then
		shooter.closeAssignWindow()
	end
end

function closeShooterEntryWindow()
	local shooter = var_0_1.shooter

	if shooter and shooter.closeEntryWindow then
		shooter.closeEntryWindow()
	end
end

function shooterAssignOk()
	local shooter = var_0_1.shooter

	if shooter and shooter.assignOk then
		shooter.assignOk()
	end
end

function filterShooterSpells(text)
	local shooter = var_0_1.shooter

	if shooter and shooter.filterSpells then
		shooter.filterSpells(text)
	end
end

function clearShooterSpellFilter()
	local shooter = var_0_1.shooter

	if shooter and shooter.clearSpellFilter then
		shooter.clearSpellFilter()
	end
end

function onShooterAssignLearntChange()
	local shooter = var_0_1.shooter

	if shooter and shooter.onAssignLearntChange then
		shooter.onAssignLearntChange()
	end
end

function addShooterEntryOk()
	local shooter = var_0_1.shooter

	if shooter and shooter.addEntryOk then
		shooter.addEntryOk()
	end
end

function onAddShooterHpChange(edit)
	local shooter = var_0_1.shooter

	if shooter and shooter.onHpTextChange then
		shooter.onHpTextChange(edit)
	end
end

function onAddShooterHpFocusChange(edit, focused)
	local shooter = var_0_1.shooter

	if shooter and shooter.onHpFocusChange then
		shooter.onHpFocusChange(edit, focused)
	end
end

function onShooterAssignModeSpells()
	local shooter = var_0_1.shooter

	if shooter and shooter.setAssignMode then
		shooter.setAssignMode("spells")
	end
end

function onShooterAssignModeRunes()
	local shooter = var_0_1.shooter

	if shooter and shooter.setAssignMode then
		shooter.setAssignMode("runes")
	end
end

function onShooterRemoveClick()
	local shooter = var_0_1.shooter

	if shooter and shooter.onRemoveClick then
		shooter.onRemoveClick()
	end
end

function onShooterPriorityClick(widget, action)
	local shooter = var_0_1.shooter

	if shooter and shooter.onPriorityClick then
		shooter.onPriorityClick(widget, action)
	end
end

function onShooterPriorityChange(edit)
	local shooter = var_0_1.shooter

	if shooter and shooter.onPriorityChange then
		shooter.onPriorityChange(edit)
	end
end

function onToolsAutoPartyChange(self, on)
	if HelperAutoParty and HelperAutoParty.onEnableChange then
		HelperAutoParty.onEnableChange(self, on)
	end

	refreshHelperStatsWindow()
end

function onToolsAutoPartyAcceptChange(self, on)
	if HelperAutoParty and HelperAutoParty.onAcceptChange then
		HelperAutoParty.onAcceptChange(self, on)
	end

	refreshHelperStatsWindow()
end

function openAutoPartySettings()
	if HelperAutoParty and HelperAutoParty.openSettings then
		HelperAutoParty.openSettings()
	end
end

function onAutoPartySettingsTextChange()
	if HelperAutoParty and HelperAutoParty.onSettingsTextChange then
		HelperAutoParty.onSettingsTextChange()
	end
end

function focusAutoPartyTextEdit(edit)
	if HelperAutoParty and HelperAutoParty.focusTextEdit then
		HelperAutoParty.focusTextEdit(edit)
	elseif edit and edit.setCursorVisible then
		edit:setCursorVisible(true)
	end
end

function onShooterEntryCreaturesChange(combo)
	if not combo then
		return
	end

	local parent = combo:getParent()

	if not parent or not parent.shooterEntryIndex then
		return
	end

	local currentOption = combo:getCurrentOption()
	local var_262_2 = (type(currentOption) == "table" and currentOption.text or tostring(currentOption or "1")):match("%d+")

	if HelperShooter and HelperShooter.updateEntryCreatures then
		HelperShooter.updateEntryCreatures(parent.shooterEntryIndex, var_262_2)
	end
end

function onShooterEntryEnabledChange(check)
	if not check then
		return
	end

	local parent = check:getParent()
	local parent = parent and parent:getParent()

	if not parent or not parent.shooterEntryIndex then
		return
	end

	if HelperShooter and HelperShooter.updateEntryEnabled then
		HelperShooter.updateEntryEnabled(parent.shooterEntryIndex, check:isChecked())
	end
end

function onShooterMoveUpClick()
	if HelperShooter and HelperShooter.onMoveUpClick then
		HelperShooter.onMoveUpClick()
	end
end

function onShooterMoveDownClick()
	if HelperShooter and HelperShooter.onMoveDownClick then
		HelperShooter.onMoveDownClick()
	end
end

function onShooterPresetChange(combo)
	if loadingConfig then
		return
	end

	if HelperShooter and HelperShooter.toggleShooterPreset then
		HelperShooter.toggleShooterPreset(combo, false)
	end
end

function onShooterPresetMenu(combo)
	if HelperShooter and HelperShooter.openPresetMenu then
		return HelperShooter.openPresetMenu(combo)
	end

	return false
end

function onShooterPzAutoChange(unusedArgument)
	if loadingConfig then
		return
	end

	if HelperShooter and HelperShooter.onShooterPzAutoChange then
		HelperShooter.onShooterPzAutoChange()
	else
		autoSave()
	end
end

function onShooterComboModeChange(unusedArgument, checked)
	if loadingConfig then
		return
	end

	if HelperShooter and HelperShooter.setComboMode then
		HelperShooter.setComboMode(checked == true)
	end
end

function onShooterRenamePreset()
	if HelperShooter and HelperShooter.sendRenameOrAddWindow then
		HelperShooter.sendRenameOrAddWindow(true)
	end
end

function onShooterNewPreset()
	if HelperShooter and HelperShooter.sendRenameOrAddWindow then
		HelperShooter.sendRenameOrAddWindow(false)
	end
end

function onShooterRemovePreset()
	if HelperShooter and HelperShooter.removeProfile then
		HelperShooter.removeProfile()
	end
end

function onShooterSettingChange()
	if loadingConfig then
		return
	end

	autoSave()
end

function onEnableConditionsChange(unusedArgument, unusedArgument)
	if loadingConfig then
		return
	end

	if HelperConditions and HelperConditions.onEnableConditionsChange then
		HelperConditions.onEnableConditionsChange()
	else
		var_0_79()
	end
end

function onToolsReconnectChange(self, on)
	if HelperTools and HelperTools.onReconnectChange then
		HelperTools.onReconnectChange(self, on)
	end

	refreshHelperStatsWindow()
end

function onToolsChangeGoldChange(self, on)
	if HelperTools and HelperTools.onChangeGoldChange then
		HelperTools.onChangeGoldChange(self, on)
	end

	refreshHelperStatsWindow()
end

function onToolsEatFoodChange(self, on)
	if HelperTools and HelperTools.onEatFoodChange then
		HelperTools.onEatFoodChange(self, on)
	end

	refreshHelperStatsWindow()
end

function onToolsAutoTrainingChange(self, on)
	if loadingConfig then
		return
	end

	if HelperTools and HelperTools.onAutoTrainingChange then
		HelperTools.onAutoTrainingChange(self, on)
	end

	refreshHelperStatsWindow()
end

function onToolsAutoAmmoChange(self, on)
	if loadingConfig then
		return
	end

	if HelperTools and HelperTools.onAutoAmmoChange then
		HelperTools.onAutoAmmoChange(self, on)
	end

	refreshHelperStatsWindow()
end

function onToolsAutoAmmoTargetChange()
	if loadingConfig then
		return
	end

	if HelperTools and HelperTools.onAutoAmmoTargetChange then
		HelperTools.onAutoAmmoTargetChange()
	end
end
