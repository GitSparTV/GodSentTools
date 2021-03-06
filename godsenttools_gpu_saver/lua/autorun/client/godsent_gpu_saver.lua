local convar = CreateClientConVar("godsent_gpu_saver", "1", true, false, "Enables GPU Saving when the game is minimized", 0, 1)
local convar_load = CreateClientConVar("godsent_load_notification", "1", true, false, "Enables notification when the game is loaded.", 0, 1)
local manual = false
local KeyboardController

do
	language.Add("godsenttools.gpusaver.name", "GPU Saver")
	language.Add("godsenttools.gpusaver.description", "\"GPU Saver\" disables entire rendering when the game window is not focused or minimized. This helps to reduce GPU load and maybe save you from VRAM crash.")
	language.Add("godsenttools.gpusaver.osxwarning", "Warning! MacOS detected, this addon is not working with this operation system.\nThe addon will be automatically disabled.\nYou can still use this addon with \"Enable manually\" button.")
	language.Add("godsenttools.gpusaver.enable.help", "Enables GPU Saver, this is required to work in automatic and manual mode.")
	language.Add("godsenttools.gpusaver.enable.manual", "Enable manually")
	language.Add("godsenttools.gpusaver.loadnotification.enable", "Enable \"Load Notification\"")
	language.Add("godsenttools.gpusaver.loadnotification.enable.help", "\"Load Notification\" will inform you when the game is loaded by blinking the icon on the taskbar (Windows only) and playing a sound. Works only in windowed mode and when unfocused.")
end

hook.Add("PopulateToolMenu", "GodSentToolsGPUSaver", function()
	if IsValid(KeyboardController) then
		KeyboardController:Remove()
	end

	KeyboardController = vgui.Create("DPanel")
	KeyboardController.Paint = nil

	function KeyboardController:OnKeyCodeReleased(keyCode)
		manual = false
		KeyboardController:SetKeyboardInputEnabled(false)
		KeyboardController:SetMouseInputEnabled(false)
	end

	spawnmenu.AddToolMenuOption("Utilities", "GodSent Tools", "GodSent_GPU_Saver", "#godsenttools.gpusaver.name", "", "", function(form)
		form:SetName("#godsenttools.gpusaver.name")
		form:Help("#godsenttools.gpusaver.description")

		if system.IsOSX() then
			form:Help("#godsenttools.gpusaver.osxwarning")
			convar:SetBool(false)
		end

		form:CheckBox("#godsenttools.enable", "godsent_gpu_saver")
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

		form:CheckBox("#godsenttools.gpusaver.loadnotification.enable", "godsent_load_notification")
		form:ControlHelp("#godsenttools.gpusaver.loadnotification.enable.help")
	end)
end)

do
	surface.SetFont("DermaLarge")
	local Line1len = surface.GetTextSize("GPU Saver is enabled.") * 0.5
	local Line2len, Line2h = surface.GetTextSize("Press any key to disable manually.")
	Line2len = Line2len * 0.5
	local Line2h2, Line2h02, Line2h15 = Line2h * 2, Line2h * 0.5, Line2h * 1.5
	local Line3len = surface.GetTextSize("To disable this entirely go to:") * 0.5
	local Line4len = surface.GetTextSize("Q > Utilities > GodSent Tools > GPU Saver.") * 0.5
	local surfaceSetTextColor, systemHasFocus, camStart, surfaceSetTextPos, surfaceSetFont, camEnd2D, surfaceDrawText, IsValid = surface.SetTextColor, system.HasFocus, cam.Start, surface.SetTextPos, surface.SetFont, cam.End2D, surface.DrawText, IsValid
	local surfaceSetDrawColor, surfaceDrawRect = surface.SetDrawColor, surface.DrawRect
	local ScrW, ScrH = ScrW, ScrH
	local state = false

	local t2D = {
		type = "2D"
	}

	local function GPUSaver()
		if not systemHasFocus() or manual then
			if not state then
				if IsValid(KeyboardController) then
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
			surfaceDrawText("GPU Saver is enabled.")
			surfaceSetTextPos(W - Line2len, H - Line2h02)
			surfaceDrawText("Press any key to disable manually.")
			surfaceSetTextPos(W - Line3len, H + Line2h02)
			surfaceDrawText("To disable this entirely go to:")
			surfaceSetTextPos(W - Line4len, H + Line2h15)
			surfaceDrawText("Q > Utilities > GodSent Tools > GPU Saver.")
			camEnd2D()

			return true
		elseif state then
			state = false

			if IsValid(KeyboardController) then
				KeyboardController:SetKeyboardInputEnabled(false)
				KeyboardController:SetMouseInputEnabled(false)
			end
		end
	end

	if convar:GetBool() then
		hook.Add("PreRender", "GodSentToolsGPUSaver", GPUSaver)
	end

	cvars.AddChangeCallback("godsent_gpu_saver", function(_, _, newValue)
		if newValue == "1" then
			hook.Add("PreRender", "GodSentToolsGPUSaver", GPUSaver)
		else
			hook.Remove("PreRender", "GodSentToolsGPUSaver")
		end
	end, "GodSentToolsGPUSaver")
end

if convar_load:GetBool() and system.IsWindowed() and (system.IsOSX() or not system.HasFocus()) then
	hook.Add("Think", "GodSentToolsGPUSaver", function()
		system.FlashWindow()
		surface.PlaySound("hl1/fvox/bell.wav")
		hook.Remove("Think", "GodSentToolsGPUSaver")
	end)
end