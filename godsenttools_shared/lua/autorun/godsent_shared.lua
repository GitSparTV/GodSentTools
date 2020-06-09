if CLIENT then
	language.Add("godsenttools.name", "GodSent Tools")
	language.Add("godsenttools.enable","Enable")

	hook.Add("AddToolMenuCategories", "GodSentToolsCategory", function()
		spawnmenu.AddToolCategory("Utilities", "GodSent Tools", "#godsenttools.name")
	end)
end