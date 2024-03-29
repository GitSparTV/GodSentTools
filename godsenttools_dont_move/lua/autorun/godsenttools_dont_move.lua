local convar = CreateConVar("godsenttools_dont_move", "0", bit.band(SERVER and FCVAR_ARCHIVE or 0, FCVAR_NOTIFY, FCVAR_REPLICATED), language and language.GetPhrase("#godsenttools.dontmove.enable.help") or "If enabled, all objects will not move.", 0, 1)

if CLIENT then
	hook.Add("PopulateToolMenu", "GodSentToolsDontMove", function()
		spawnmenu.AddToolMenuOption("Utilities", "#godsenttools.name", "GodSentTools_Dont_Move", "#godsenttools.dontmove.name", "", "", function(form)
			form:SetName("#godsenttools.dontmove.name")
			form:Help(string.format(language.GetPhrase("#godsenttools.dontmove.description"), string.upper(input.LookupBinding("reload") or "R")))
			form:CheckBox("#godsenttools.enable", "godsenttools_dont_move")
			form:ControlHelp("#godsenttools.dontmove.enable.help")
		end)
	end)
else

	local function ApplyToAll() -- FindByClass("prop_*")
		for k, v in ipairs(ents.GetAll()) do
			for i = 0, v:GetPhysicsObjectCount() - 1 do
				local p = v:GetPhysicsObjectNum(i)

				if p:IsValid() then
					p:EnableMotion(false)
				end
			end
		end
	end

	local timerSimple, stringfind = timer.Simple, string.find

	function OnEntityCreated(ent)
		-- if stringfind(ent:GetClass(), "^prop_") then
			timerSimple(0, function()
				for i = 0, ent:GetPhysicsObjectCount() - 1 do
					local p = ent:GetPhysicsObjectNum(i)

					if p:IsValid() then
						p:EnableMotion(false)
					end
				end
			end)
		-- end
	end

	local function PhysgunDrop(_, ent)
		-- if stringfind(ent:GetClass(), "^prop_") then
			timerSimple(0, function()
				for i = 0, ent:GetPhysicsObjectCount() - 1 do
					local p = ent:GetPhysicsObjectNum(i)

					if p:IsValid() then
						p:EnableMotion(false)
					end
				end
			end)
		-- end
	end

	local function OnPhysgunReload()
		return false
	end

	if convar:GetBool() then
		hook.Add("OnEntityCreated", "GodSentToolsDontMove", OnEntityCreated)
		hook.Add("PhysgunDrop", "GodSentToolsDontMove", PhysgunDrop)
		hook.Add("OnPhysgunReload", "GodSentToolsDontMove", OnPhysgunReload)
		ApplyToAll()
	end

	cvars.AddChangeCallback("godsenttools_dont_move", function(_, _, newValue)
		if newValue == "1" then
			ApplyToAll()
			hook.Add("OnEntityCreated", "GodSentToolsDontMove", OnEntityCreated)
			hook.Add("PhysgunDrop", "GodSentToolsDontMove", PhysgunDrop)
			hook.Add("OnPhysgunReload", "GodSentToolsDontMove", OnPhysgunReload)
		else
			hook.Remove("OnEntityCreated", "GodSentToolsDontMove")
			hook.Remove("PhysgunDrop", "GodSentToolsDontMove")
			hook.Remove("OnPhysgunReload", "GodSentToolsDontMove")
		end
	end)
end