local convar_enable = CreateClientConVar("godsenttools_second_chance", "1", true, false, "Enables Second Chance addon.", 0, 1)
local convar_hold_time = CreateClientConVar("godsenttools_second_chance_hold_time", "0.7", true, false, "Sets hold time for GodSentTools Second Chance.", 0.1)

hook.Add("AddToolMenuCategories", "GodSentToolsCategory", function()
	spawnmenu.AddToolCategory("Utilities", "GodSent Tools", "#godsenttools.name")
end)

hook.Add("PopulateToolMenu", "GodSentToolsSecondChance", function()
	spawnmenu.AddToolMenuOption("Utilities", "GodSent Tools", "GodSent_Second_Chance", "#godsenttools.secondchance.name", "", "", function(form)
		form:SetName("#godsenttools.secondchance.name")

		form:Help("#godsenttools.secondchance.description")

		form:CheckBox("#godsenttools.enable", "godsenttools_second_chance")

		form:NumSlider("#godsenttools.secondchance.holdtime", "godsenttools_second_chance_hold_time", 0.1, 5, 2)
	end)
end)

local start
local unlock = false
local key
local killed = false
local Think

do
	local hookRemove, notificationAddProgress, SysTime, inputIsKeyDown, notificationKill = hook.Remove, notification.AddProgress, SysTime, input.IsKeyDown, notification.Kill
	local hold_time = convar_hold_time:GetFloat()

	local function ChangeHoldTime(_, _, newValue)
		hold_time = tonumber(newValue)
	end


	function Think()
		do
			local clock = (SysTime() - start) / hold_time
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

	cvars.AddChangeCallback("godsenttools_second_chance_hold_time", ChangeHoldTime, "GodSentToolsSecondChance")
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