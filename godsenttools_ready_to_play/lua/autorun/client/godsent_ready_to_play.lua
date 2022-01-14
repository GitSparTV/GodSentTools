local convar = CreateClientConVar("godsenttools_ready_to_play", "1", true, false, "Enables Ready To Play.", 0, 1)

hook.Add("PopulateToolMenu", "GodSentToolsReadyToPlay", function()
	spawnmenu.AddToolMenuOption("Utilities", "#godsenttools.name", "GodSent_Ready_To_Play", "#godsenttools.readytoplay.name", "", "", function(form)
		form:SetName("#godsenttools.readytoplay.name")
		form:Help("#godsenttools.readytoplay.description")

		form:CheckBox("#godsenttools.enable", "godsenttools_ready_to_play")
		form:ControlHelp("#godsenttools.readytoplay.enable.help")
	end)
end)

if convar:GetBool() then
	hook.Add("Think", "GodSentToolsReadyToPlay", function()
		system.FlashWindow()
		surface.PlaySound("hl1/fvox/bell.wav")
		hook.Remove("Think", "GodSentToolsReadyToPlay")
	end)
end
