do
	local hookRun, surfaceDrawLine, ScrW, ScrH, renderOverrideBlend, surfaceSetDrawColor = hook.Run, surface.DrawLine, ScrW, ScrH, render.OverrideBlend, surface.SetDrawColor

	hook.Add("PostDrawHUD","GodSentToolsAdaptiveCrosshair",function()
		if not hookRun("HUDShouldDraw", "CHudGMod") then return end

		renderOverrideBlend(true, 3, 1, 1) -- BLEND_ONE_MINUS_DST_COLOR, BLEND_ONE, BLENDFUNC_SUBTRACT
		surfaceSetDrawColor(255, 0, 127)

		do
			local CW, CH = ScrW() * 0.5, ScrH() * 0.5

			surfaceDrawLine(CW - 12, CH, CW - 6, CH)
			surfaceDrawLine(CW + 9, CH, CW + 3, CH)
			surfaceDrawLine(CW - 1, CH - 9, CW - 1, CH - 3)
			surfaceDrawLine(CW - 1, CH + 8, CW - 1, CH + 2)
			surfaceDrawLine(CW - 2, CH - 1, CW - 1, CH)
		end

		renderOverrideBlend(false)
	end)
end

hook.Add("HUDShouldDraw", "GodSentToolsAdaptiveCrosshair", function(n)
	if n == "CHudCrosshair" then
		return false
	end
end)