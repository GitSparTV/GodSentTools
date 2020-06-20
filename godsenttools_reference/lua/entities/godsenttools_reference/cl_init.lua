include("shared.lua")

local RT = GetRenderTarget("GSTRef_RT", 1024, 1024)


local ourMat = CreateMaterial("GSTRef_1", "VertexLitGeneric", {
	["$basetexture"] = RT:GetName(),
	["$translucent"] = 1,
	["$vertexalpha"] = 1,
	["$vertexcolor"] = 1
})

if IsValid(REF) then REF:Remove() end
REF = vgui.Create("DHTML")
REF:SetSize(1024 * 5, 1024 * 5)
REF:SetHTML([[
<div style="background-image: url(https://anatomy360.info/wp-content/uploads/2017/04/3d-scan.jpg);
			background-repeat: no-repeat;
			background-size: contain;
			background-position: center center;
			width: 100%%;
			height: 100%%;">
</div>
]])
REF:SetVisible(false)

function ENT:Draw()
	self:DrawModel()
	render.PushFilterMag(1)
	render.PushFilterMin(1)
	REF:UpdateHTMLTexture()
	render.PushRenderTarget( RT )
		render.Clear( 0,0,0,0 )
		cam.Start2D()
		surface.SetDrawColor(255,255,255)
		surface.SetMaterial(REF:GetHTMLMaterial())
		surface.DrawTexturedRect(0,0,1024,1024)
		cam.End2D()
	render.PopRenderTarget()
	render.SuppressEngineLighting(true)
	render.SetMaterial(ourMat)
	render.DrawQuadEasy(self:GetPos() + Vector(0,0,50), self:GetForward(), -100,-100,color_white)
	render.SuppressEngineLighting( false )
	render.PopFilterMag()
	render.PopFilterMin()
end