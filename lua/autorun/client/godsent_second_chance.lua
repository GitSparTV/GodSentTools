local convar = CreateClientConVar("godsent_second_chance", "1", true, false, "Enables Second Chance addon.", 0, 1)

do
	language.Add("godsenttools.secondchance.name", "Second Chance")
	language.Add("godsenttools.secondchance.description", "\"Second Chance\" ")
	language.Add("godsenttools.secondchance.enable.help", "")
	language.Add("godsenttools.secondchance.notification.hold", "Hold to unlock Undo.")
	language.Add("godsenttools.secondchance.notification.done", "Undo is unlocked.")
	language.Add("godsenttools.secondchance.notification.locked", "Undo is locked.")
end

hook.Add("PopulateToolMenu", "GodSentToolsSecondChance", function()
	spawnmenu.AddToolMenuOption("Utilities", "GodSent Tools", "GotSent_Second_Chance", "#godsenttools.secondchance.name", "", "", function(form)
		form:SetName("#godsenttools.secondchance.name")
		form:Help("#godsenttools.secondchance.description")
		form:CheckBox("#godsenttools.enable", "godsent_second_chance")
		form:ControlHelp("#godsenttools.secondchance.enable.help")
	end)
end)

local start
local unlock = false
local key
local killed = false
local Think

do
	local hookRemove, notificationAddProgress, SysTime, inputIsKeyDown, notificationKill = hook.Remove, notification.AddProgress, SysTime, input.IsKeyDown, notification.Kill

	function Think()
		do
			local clock = (SysTime() - start) / 1.5
			notificationAddProgress("Second Chance", "#godsenttools.secondchance.notification.hold", clock)

			if clock > 1 then
				notificationAddProgress("Second Chance", "#godsenttools.secondchance.notification.done", 1)
				unlock = true
				killed = false
				hookRemove("Think", "GodSentToolsSecondChance", Think)

				return
			end
		end

		if not inputIsKeyDown(key) then
			notificationKill("Second Chance")
			hookRemove("Think", "GodSentToolsSecondChance", Think)
		end
	end
end

local PlayerBindPress

do
	local inputLookupBinding, inputIsKeyDown, SysTime, notificationAddLegacy, notificationAddProgress, hookAdd, KEY_LSHIFT, inputGetKeyCode, inputTranslateAlias, notificationKill = input.LookupBinding, input.IsKeyDown, SysTime, notification.AddLegacy, notification.AddProgress, hook.Add, KEY_LSHIFT, input.GetKeyCode, input.TranslateAlias, notification.Kill

	function PlayerBindPress(_, bind, press)
		if not press then return end
		bind = inputTranslateAlias(bind) or bind

		if bind == "gmod_undo" then
			if not unlock then
				notificationAddProgress("Second Chance", "#godsenttools.secondchance.notification.hold", 0)
				key = inputGetKeyCode(inputLookupBinding(bind))
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

if convar:GetBool() then
	hook.Add("PlayerBindPress", "GodSentToolsSecondChance", PlayerBindPress)
end

cvars.AddChangeCallback("godsent_dont_move", function(_, _, newValue)
	if newValue == "1" then
		hook.Add("PlayerBindPress", "GodSentToolsSecondChance", PlayerBindPress)
	else
		hook.Remove("PlayerBindPress", "GodSentToolsSecondChance")
		hook.Remove("Think", "GodSentToolsSecondChance", Think)
	end
end)