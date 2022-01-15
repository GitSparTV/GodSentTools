local convar_enable = CreateClientConVar("godsenttools_second_chance", "1", true, false, language.GetPhrase("#godsenttools.secondchance.convar.enable"), 0, 1)
local convar_hold_time = CreateClientConVar("godsenttools_second_chance_hold_time", "0.7", true, false, language.GetPhrase("#godsenttools.secondchance.convar.holdtime"), 0.1)

local bind_key_name = string.upper(input.LookupBinding("gmod_undo"))
local bind_key_code = input.GetKeyCode(input.LookupBinding("gmod_undo"))

hook.Add("PopulateToolMenu", "GodSentToolsSecondChance", function()
	spawnmenu.AddToolMenuOption("Utilities", "#godsenttools.name", "GodSent_Second_Chance", "#godsenttools.secondchance.name", "", "", function(form)
		form:SetName("#godsenttools.secondchance.name")
		form:Help(string.format(language.GetPhrase("#godsenttools.secondchance.description"), bind_key_name))

		form:CheckBox("#godsenttools.enable", "godsenttools_second_chance")
		form:NumSlider("#godsenttools.secondchance.holdtime", "godsenttools_second_chance_hold_time", 0.1, 5, 2)
	end)
end)

local start
local unlock = false
local killed = false
local Think
local notification_hold_phrase = string.format(language.GetPhrase("#godsenttools.secondchance.notification.hold"), bind_key_name)
local notification_done_phrase = string.format(language.GetPhrase("#godsenttools.secondchance.notification.done"), bind_key_name)

do
	local hookRemove, notificationAddProgress, SysTime, inputIsKeyDown, notificationKill = hook.Remove, notification.AddProgress, SysTime, input.IsKeyDown, notification.Kill
	local surfacePlaySound = surface.PlaySound
	local hold_time = convar_hold_time:GetFloat()

	local function ChangeHoldTime(_, _, newValue)
		hold_time = tonumber(newValue)
	end

	function Think()
		do
			local clock = (SysTime() - start) / hold_time

			notificationAddProgress("Second Chance", notification_hold_phrase, clock)

			if clock > 1 then
				notificationAddProgress("Second Chance", notification_done_phrase, 1)

				unlock = true
				killed = false

				hookRemove("Think", "GodSentToolsSecondChance", Think)

				surfacePlaySound("ui/buttonclickrelease.wav")

				return
			end
		end

		if not inputIsKeyDown(bind_key_code) then
			notificationKill("Second Chance")

			hookRemove("Think", "GodSentToolsSecondChance", Think)
		end
	end

	cvars.AddChangeCallback("godsenttools_second_chance_hold_time", ChangeHoldTime, "GodSentToolsSecondChance")
end

local PlayerBindPress

do
	local inputIsKeyDown, SysTime, notificationAddLegacy, notificationAddProgress, hookAdd, KEY_LSHIFT, inputTranslateAlias, notificationKill = input.IsKeyDown, SysTime, notification.AddLegacy, notification.AddProgress, hook.Add, KEY_LSHIFT, input.TranslateAlias, notification.Kill

	function PlayerBindPress(_, bind, press)
		if not press then return end

		bind = inputTranslateAlias(bind) or bind

		if bind == "gmod_undo" then
			if not unlock then
				notificationAddProgress("Second Chance", notification_hold_phrase, 0)

				start = SysTime()
				hookAdd("Think", "GodSentToolsSecondChance", Think)

				return true
			else
				if not killed then
					killed = true

					notificationKill("Second Chance")
				end

				if inputIsKeyDown(KEY_LSHIFT) then
					notificationAddLegacy("#godsenttools.secondchance.notification.locked", 0, 2)

					unlock = false

					return true
				end

				return false
			end
		end
	end
end

if convar_enable:GetBool() then
	hook.Add("PlayerBindPress", "GodSentToolsSecondChance", PlayerBindPress)
end

cvars.AddChangeCallback("godsenttools_second_chance", function(_, _, newValue)
	if newValue == "1" then
		hook.Add("PlayerBindPress", "GodSentToolsSecondChance", PlayerBindPress)
	else
		hook.Remove("PlayerBindPress", "GodSentToolsSecondChance")
		hook.Remove("Think", "GodSentToolsSecondChance", Think)
	end
end)