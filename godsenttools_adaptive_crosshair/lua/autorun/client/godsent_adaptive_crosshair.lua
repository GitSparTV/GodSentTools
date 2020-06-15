hook.Add("PostDrawHUD","GodSentToolsAdaptiveCrosshair",function()
	local CW,CH = ScrW() * 0.5, ScrH() * 0.5

	render.OverrideBlend(true, 3, 1, 1)
	surface.SetDrawColor(255,255,255)
	-- surface.SetDrawColor(0,0,0)
	-- surface.DrawOutlinedRect(CW-16,CH-1,6,3)
	-- surface.DrawOutlinedRect(CW-2,CH-13,3,6)
	-- surface.DrawOutlinedRect(CW+9,CH-1,6,3)
	-- surface.DrawOutlinedRect(CW-2,CH+8,3,6)
	-- surface.DrawOutlinedRect(CW-1,CH-13,3,6)
	surface.DrawLine(CW-12,CH,CW-6,CH)
	surface.DrawLine(CW+9,CH,CW+3,CH)

	surface.DrawLine(CW-1,CH-9,CW-1,CH-3)
	surface.DrawLine(CW-1,CH+8,CW-1,CH+2)
	surface.DrawLine(CW-2,CH-1,CW-1,CH)
	render.OverrideBlend(false)
end)

hook.Add("HUDShouldDraw","GodSentToolsAdaptiveCrosshair",function(n)
	if n == "CHudCrosshair" then return false end
end)