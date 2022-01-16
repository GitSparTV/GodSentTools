local convar = CreateClientConVar("godsenttools_gpu_saver", "1", true, false, language.GetPhrase("#godsenttools.gpusaver.enable.help"), 0, 1)
local manual = false
local KeyboardController = NULL

hook.Add("PopulateToolMenu", "GodSentToolsGPUSaver", function()
	if KeyboardController:IsValid() then
		KeyboardController:Remove()
	end

	KeyboardController = vgui.Create("DPanel")
	KeyboardController.Paint = nil

	function KeyboardController:OnKeyCodeReleased(keyCode)
		manual = false

		KeyboardController:SetKeyboardInputEnabled(false)
		KeyboardController:SetMouseInputEnabled(false)
	end

	spawnmenu.AddToolMenuOption("Utilities", "#godsenttools.name", "GodSentTools_GPU_Saver", "#godsenttools.gpusaver.name", "", "", function(form)
		form:SetName("#godsenttools.gpusaver.name")
		form:Help("#godsenttools.gpusaver.description")

		if system.IsOSX() then
			form:Help("#godsenttools.gpusaver.osxwarning")

			convar:SetBool(false)
		end

		form:CheckBox("#godsenttools.enable", "godsenttools_gpu_saver")
		form:ControlHelp("#godsenttools.gpusaver.enable.help")

		form:Button("#godsenttools.gpusaver.enable.manual").DoClick = function()
			if not convar:GetBool() then return end
			local start = RealTime()

			hook.Add("PostRenderVGUI", "GodSentToolsGPUSaver", function()
				local anim = (RealTime() - start) * 1.5

				surface.SetDrawColor(0, 130, 255, anim * 255)
				surface.DrawRect(0, 0, ScrW(), ScrH())

				if anim > 1.2 then
					manual = true

					hook.Remove("PostRenderVGUI", "GodSentToolsGPUSaver")
				end
			end)
		end
	end)
end)

do
	surface.SetFont("DermaLarge")

	local Line1len = surface.GetTextSize("#godsenttools.gpusaver.screen.enabled") * 0.5

	local Line2len, Line2h = surface.GetTextSize("#godsenttools.gpusaver.screen.presskey")
	Line2len = Line2len * 0.5

	local Line2h2, Line2h02, Line2h15 = Line2h * 2, Line2h * 0.5, Line2h * 1.5
	local Line3len = surface.GetTextSize("#godsenttools.gpusaver.screen.howtodisable") * 0.5

	local where_to_disable = string.format(language.GetPhrase("#godsenttools.gpusaver.screen.wheretodisable"), string.upper(input.LookupBinding("menu") or input.LookupBinding("gm_showhelp") or "Q"))
	local Line4len = surface.GetTextSize(where_to_disable) * 0.5

	local surfaceSetTextColor, systemHasFocus, camStart, surfaceSetTextPos, surfaceSetFont, camEnd2D, surfaceDrawText = surface.SetTextColor, system.HasFocus, cam.Start, surface.SetTextPos, surface.SetFont, cam.End2D, surface.DrawText
	local surfaceSetDrawColor, surfaceDrawRect = surface.SetDrawColor, surface.DrawRect
	local ScrW, ScrH = ScrW, ScrH

	local state = false

	local t2D = {
		type = "2D"
	}

	local function GPUSaver()
		if not systemHasFocus() or manual then
			if not state then
				if KeyboardController:IsValid() then
					KeyboardController:MakePopup()
				end

				state = true
			end

			local W, H = ScrW() * 0.5, ScrH() * 0.5

			camStart(t2D)

			surfaceSetDrawColor(0, 130, 255)
			surfaceDrawRect(0, 0, W * 2, H * 2)

			surfaceSetFont("DermaLarge")
			surfaceSetTextColor(255, 255, 255)

			surfaceSetTextPos(W - Line1len, H - Line2h2)
			surfaceDrawText("#godsenttools.gpusaver.screen.enabled")

			surfaceSetTextPos(W - Line2len, H - Line2h02)
			surfaceDrawText("#godsenttools.gpusaver.screen.presskey")

			surfaceSetTextPos(W - Line3len, H + Line2h02)
			surfaceDrawText("#godsenttools.gpusaver.screen.howtodisable")

			surfaceSetTextPos(W - Line4len, H + Line2h15)
			surfaceDrawText(where_to_disable)

			camEnd2D()

			return true
		elseif state then
			state = false

			if KeyboardController:IsValid() then
				KeyboardController:SetKeyboardInputEnabled(false)
				KeyboardController:SetMouseInputEnabled(false)
			end
		end
	end

	if convar:GetBool() then
		hook.Add("PreRender", "GodSentToolsGPUSaver", GPUSaver)
	end

	cvars.AddChangeCallback("godsenttools_gpu_saver", function(_, _, newValue)
		if newValue == "1" then
			hook.Add("PreRender", "GodSentToolsGPUSaver", GPUSaver)
		else
			hook.Remove("PreRender", "GodSentToolsGPUSaver")
		end
	end, "GodSentToolsGPUSaver")
end