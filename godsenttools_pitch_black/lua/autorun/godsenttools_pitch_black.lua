if CLIENT then
	local convar = CreateClientConVar("godsenttools_pitch_black_fog", "0", true, false, language.GetPhrase("#godsenttools.pitchblack.fogtoggle"), 0, 1)

	hook.Add("PopulateToolMenu", "GodSentToolsPitchBlack", function()
		spawnmenu.AddToolMenuOption("Utilities", "#godsenttools.name", "GodSentTools_Pitch_Black", "#godsenttools.pitchblack.name", "", "", function(form)
			form:SetName("#godsenttools.pitchblack.name")

			form:Help("#godsenttools.pitchblack.description")

			form:CheckBox("#godsenttools.pitchblack.fogtoggle", "godsenttools_pitch_black_fog")
			form:CheckBox("#godsenttools.pitchblack.matfullbright", "mat_fullbright")

			form:Button("#godsenttools.pitchblack.blacksky", "godsenttools_pitch_black_changesky", "1")
			form:Button("#godsenttools.pitchblack.whitesky", "godsenttools_pitch_black_changesky", "2")
		end)
	end)

	do
		local renderFogMode = render.FogMode

		local function HookOverride(scale)
			renderFogMode(0)

			return true
		end

		if convar:GetBool() then
			hook.Add("SetupSkyboxFog", "GodSentToolsPitchBlack", HookOverride)
			hook.Add("SetupWorldFog", "GodSentToolsPitchBlack", HookOverride)
		end

		cvars.AddChangeCallback("godsenttools_pitch_black_fog", function(_, _, newValue)
			if newValue == "1" then
				hook.Add("SetupSkyboxFog", "GodSentToolsPitchBlack", HookOverride)
				hook.Add("SetupWorldFog", "GodSentToolsPitchBlack", HookOverride)
			else
				hook.Remove("SetupSkyboxFog", "GodSentToolsPitchBlack")
				hook.Remove("SetupWorldFog", "GodSentToolsPitchBlack")
			end
		end, "GodSentToolsPitchBlack")
	end
else
	local RemoveSun

	do
		local ipairs, entsFindByClass = ipairs, ents.FindByClass

		function RemoveSun()
			for k, v in ipairs(entsFindByClass("env_sun")) do
				v:SetKeyValue("size", 0)
				v:SetKeyValue("overlaysize", 0)
				v:SetKeyValue("overlaycolor", "0 0 0")
				v:SetKeyValue("suncolor", "0 0 0")
			end
		end
	end

	local MakeDark

	do
		local Vec0 = Vector()
		local ipairs, entsFindByClass = ipairs, ents.FindByClass

		function MakeDark()
			local Vec0 = Vec0

			for k, v in ipairs(entsFindByClass("env_skypaint")) do
				v:SetTopColor(Vec0)
				v:SetBottomColor(Vec0)
				v:SetFadeBias(0)
				v:SetSunNormal(Vec0)
				v:SetSunColor(Vec0)
				v:SetSunSize(0)
				v:SetDuskColor(Vec0)
				v:SetDuskScale(0)
				v:SetDuskIntensity(0)
				v:SetDrawStars(false)
				v:SetHDRScale(0)
			end
		end
	end

	local MakeWhite

	do
		local Vec1 = Vector(1, 1, 1)
		local ipairs, entsFindByClass = ipairs, ents.FindByClass

		function MakeWhite()
			local Vec1 = Vec1

			for k, v in ipairs(entsFindByClass("env_skypaint")) do
				v:SetTopColor(Vec1)
				v:SetBottomColor(Vec1)
				v:SetFadeBias(0)
				v:SetSunNormal(Vec1)
				v:SetSunColor(Vec1)
				v:SetSunSize(0)
				v:SetDuskColor(Vec1)
				v:SetDuskScale(0)
				v:SetDuskIntensity(0)
				v:SetDrawStars(false)
				v:SetHDRScale(0)
			end
		end
	end

	concommand.Add("godsenttools_pitch_black_changesky", function(_, _, args)
		_ = args[1]

		if _ == "1" then
			MakeDark()
		elseif _ == "2" then
			MakeWhite()
		end

		RemoveSun()
	end, nil, "Changes the sky")
end