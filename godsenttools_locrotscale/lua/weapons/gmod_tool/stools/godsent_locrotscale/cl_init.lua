do
	local languageAdd = language.Add
	languageAdd("tool.godsent_locrotscale.name", "LocRotScale")
	languageAdd("tool.godsent_locrotscale.desc", "LocRotScale")
	languageAdd("tool.godsent_locrotscale.propkeylabel", "Properties tab toggle hotkey")
	languageAdd("tool.godsent_locrotscale.propkeytoggle", "Toggle properties menu")
	languageAdd("tool.godsent_locrotscale.rotationpyrtoggle", "Show PYR rotation")
	languageAdd("tool.godsent_locrotscale.prop.name", "Properties Tab Settings")
	languageAdd("tool.godsent_locrotscale.selectionmenu.title", "LocRotScale Bone Selection")
	languageAdd("tool.godsent_locrotscale.selectionmenu.id", "ID")
	languageAdd("tool.godsent_locrotscale.selectionmenu.name", "Name")
	languageAdd("tool.godsent_locrotscale.selectionmenu.distance", "Distance")
	languageAdd("tool.godsent_locrotscale.selectionmenu.isvisible", "Is Visible")
	languageAdd("tool.godsent_locrotscale.selectionmenu.parent", "Parent")
	languageAdd("tool.godsent_locrotscale.selectionmenu.list", "List")
	languageAdd("tool.godsent_locrotscale.selectionmenu.tree", "Hierarchy")
	languageAdd("tool.godsent_locrotscale.selectionmenu.show", "Show")
	languageAdd("tool.godsent_locrotscale.selectionmenu.use", "Select")
	languageAdd("tool.godsent_locrotscale.selectionmenu.copy", "Copy name")
end

local ceiloor = TOOL.ceiloor

local function Round(n, decimals)
	return ceiloor(n / decimals) * decimals
end

local icons = { Material("godsenttools/rotlocscale/select_7.png", "alphatest mips ignorez"), Material("godsenttools/rotlocscale/move_9.png", "alphatest mips ignorez"), Material("godsenttools/rotlocscale/rotate_4.png", "alphatest mips ignorez"), (Material("godsenttools/rotlocscale/scale_3.png", "alphatest mips ignorez")) }

local R, G, B, Y, Hover = Color(255, 0, 0, 150), Color(0, 255, 0, 150), Color(0, 0, 255, 150), Color(255, 200, 0, 150), Color(255, 255, 0)
local NumToColor

do
	local R, G, B, Y = Color(255, 0, 0), Color(0, 255, 0), Color(0, 0, 255), Color(255, 200, 0)

	NumToColor = {
		[0] = R,
G, B, Y
	}
end

do
	local netReadEntity, netReadAngle, netReadBool, netReadVector, LocalPlayer, netReadDouble, netReadUInt, netReadNormal, bitband = net.ReadEntity, net.ReadAngle, net.ReadBool, net.ReadVector, LocalPlayer, net.ReadDouble, net.ReadUInt, net.ReadNormal, bit.band

	net.Receive("GodSentToolsLocRotScale", function()
		local tool

		do
			local swep = netReadEntity()
			if not swep:IsValid() then return end
			tool = swep:GetToolObject()
			if not tool then return end
		end

		local event = netReadUInt(3)

		if event == 4 then
			local flag = netReadUInt(2)

			if bitband(flag, 1) == 1 then
				tool.BonePos = netReadVector()
			end

			if bitband(flag, 2) == 2 then
				tool.BoneAng = netReadAngle()
				-- tool.BoneAng = Angle(net.ReadFloat(), net.ReadFloat(), net.ReadFloat())
			end
		elseif event == 1 then
			local op = tool:GetOperation()

			if op == 2 then
				tool:RotateStart(netReadNormal(), netReadNormal(), netReadAngle(), netReadAngle(), netReadDouble(), netReadUInt(2))
			end
		elseif event == 5 then
			tool:Reload(LocalPlayer():GetEyeTrace())
		elseif event == 0 then
			local ent = netReadEntity()
			if not ent:IsValid() then return end
			tool:SetTargetEntity(ent, netReadUInt(8))
			tool.TargetBoneMode = netReadBool()
		elseif event == 2 then
			tool:CancelAction(tool:GetOperation())
		end
	end)
end

function TOOL.BuildCPanel(form)
	form:SetName("#tool.godsent_locrotscale.name")
	local general = vgui.Create("DForm")
	general:SetName("#tool.godsent_locrotscale.general.name")
	form:AddItem(general)
	general:CheckBox("#tool.godsent_locrotscale.propkeytoggle", "godsent_locrotscale_proptoggle")
	local binder = vgui.Create("CtrlNumPad")
	binder:SetConVar1("godsent_locrotscale_propkey")
	binder:SetLabel1("#tool.godsent_locrotscale.propkeylabel")
	general:AddItem(binder)
	general:CheckBox("#tool.godsent_locrotscale.rotationpyrtoggle", "godsent_locrotscale_rotationpyr")
end

function TOOL:Holster()
	if self.RightPressed then
		gui.EnableScreenClicker(false)
	end
end

do
	local MOUSE_LEFT, IN_SPEED, inputIsMouseDown, IN_ATTACK = MOUSE_LEFT, IN_SPEED, input.IsMouseDown, IN_ATTACK

	function TOOL:Think()
		local op = self.SelectionMode and 0 or self:GetOperation()
		local E = self.TargetEntity
		local ply = self:GetOwner()
		self.SelectionMode = not self.Pressed and ply:KeyDown(IN_SPEED)
		local LeftClick = not ply:KeyDown(IN_ATTACK) and not inputIsMouseDown(MOUSE_LEFT)

		if op == 0 then
			if self.Pressed then
				-- self:GetOwner():DrawViewModel(true)
				self.Pressed, self.TargetEntity = nil, nil
			end

			self:SelectionThink(ply:GetEyeTrace())
		end

		if E and E:IsValid() then
			local bone = self.TargetBone
			local P, A

			if not self.TargetBoneMode then
				P = E:GetBonePosition(bone)

				if P == E:GetPos() then
					local m = E:GetBoneMatrix(bone)

					if m then
						P = m:GetTranslation()
					end
				end

				P:Add(E:GetManipulateBonePosition(bone))
				-- A:Add(E:GetManipulateBoneAngles(bone))
				A = E:GetManipulateBoneAngles(bone)
				-- local P, A = self.BonePos, self.BoneAng
				self.BonePos, self.BoneAng = P, A
			else
				P, A = self.BonePos, self.BoneAng
			end

			local S = E:GetManipulateBoneScale(bone)
			self.BoneScale = S
			local t = ply:GetEyeTrace()

			do
				local size = P - t.StartPos
				self.EntityDistance = size
				self.EntityDistanceLen = size:Length() * 0.3
			end

			self:PropertiesThink(E, P, A, S)

			if op == 2 then
				if self.Pressed then
					-- ply:DrawViewModel(false)
					if LeftClick then
						self:RotateEnd()

						return
					end
				end

				self:RotationThink(t)
			end

			self:ModeSelectorThink(ply, LeftClick)
		end
	end
end

do
	do
		local netWriteUInt, ScrW, ScrH, inputGetCursorPos, netSendToServer, mathabs, mathatan2, netStart, guiEnableScreenClicker, IN_ATTACK2 = net.WriteUInt, ScrW, ScrH, input.GetCursorPos, net.SendToServer, math.abs, math.atan2, net.Start, gui.EnableScreenClicker, IN_ATTACK2

		function TOOL:ModeSelectorThink(ply, LeftClick)
			if not self.Pressed and ply:KeyDown(IN_ATTACK2) and LeftClick then
				self.RightPressed = true
				guiEnableScreenClicker(true)
				local deg

				do
					local X, Y = inputGetCursorPos()
					local DX, DY = ScrW() * 0.5 - X, ScrH() * 0.5 - Y

					if mathabs(DX) < 24 and mathabs(DY) < 24 then
						self.ModeSelectorHovered = nil

						return
					end

					deg = mathatan2(DX, DY)
				end

				-- if deg <= 1.0471975511966 and deg > -1.0471975511966 then
				-- self.ModeSelectorHovered = 2
				-- elseif deg > 1.0471975511966 and deg < 3.1415926535898 then
				-- self.ModeSelectorHovered = 4
				-- else
				self.ModeSelectorHovered = 3
				-- end
			elseif self.RightPressed then
				do
					local H = self.ModeSelectorHovered

					if H then
						netStart("GodSentToolsLocRotScale")
						netWriteUInt(1, 1)
						netWriteUInt(H - 2, 2)
						netSendToServer()
						self:SetOperation(H - 1)
					end
				end

				self.RightPressed = false
				guiEnableScreenClicker(false)
			end
		end
	end

	do
		local iconsOffsets = { nil, -32, -64 - 32 - 16, 37, 8, -(64 + 37), 8 }

		local surfaceDrawTexturedRect, drawRoundedBox, Color1, ScrW, surfaceSetMaterial, Color2, Color3, surfaceSetDrawColor, ScrH, renderPopFilterMag, renderPushFilterMag, renderPopFilterMin, renderPushFilterMin = surface.DrawTexturedRect, draw.RoundedBox, Color(75, 75, 75), ScrW, surface.SetMaterial, Color(50, 50, 50), Color(0, 0, 0, 100), surface.SetDrawColor, ScrH, render.PopFilterMag, render.PushFilterMag, render.PopFilterMin, render.PushFilterMin

		function TOOL:DrawModeSelector()
			local CW, CH = ScrW() * 0.5, ScrH() * 0.5
			drawRoundedBox(136, CW - 136, CH - 136, 272, 272, Color2)
			drawRoundedBox(24, CW - 24, CH - 24, 48, 48, Color1)
			surfaceSetDrawColor(255, 255, 255)
			renderPushFilterMag(3)
			renderPushFilterMin(3)
			local icons = icons

			for k = 2, 4 do
				if self.ModeSelectorHovered == k then
					drawRoundedBox(10, CW + iconsOffsets[(k - 1) * 2] - 8, CH + iconsOffsets[(k - 1) * 2 + 1] - 8, 64 + 16, 64 + 16, Color1)
					surfaceSetDrawColor(255, 255, 255)
				end

				surfaceSetMaterial(icons[k])
				surfaceDrawTexturedRect(CW + iconsOffsets[(k - 1) * 2], CH + iconsOffsets[(k - 1) * 2 + 1], 64, 64)

				if k == 2 or k == 4 then
					drawRoundedBox(10, CW + iconsOffsets[(k - 1) * 2] - 8, CH + iconsOffsets[(k - 1) * 2 + 1] - 8, 64 + 16, 64 + 16, Color3)
					surfaceSetDrawColor(255, 255, 255)
				end
			end

			renderPopFilterMag(3)
			renderPopFilterMin(3)
		end
	end
end

do
	local t3D = {
		type = "3D"
	}

	local PivotMin, PivotMax = Vector(), Vector()
	local Y = Color(255, 200, 0)
	local color_black = color_black
	local camEnd, renderSetColorMaterialIgnoreZ, camStart, renderDrawBox = cam.End, render.SetColorMaterialIgnoreZ, cam.Start, render.DrawBox

	function TOOL:DrawHUD()
		local E = self.TargetEntity
		local op = self.SelectionMode and 0 or self:GetOperation()

		if E and E:IsValid() then
			local P, A = self.BonePos, self.BoneAng
			local s = self.EntityDistanceLen
			camStart(t3D)
			-- cam.IgnoreZ(true)
			renderSetColorMaterialIgnoreZ()
			-- render.SetColorMaterial()
			local size = s * 0.03

			do
				local PivotMin = PivotMin

				do
					local msize = -size
					PivotMin:SetUnpacked(msize, msize, msize)
				end

				local PivotMax = PivotMax
				PivotMax:SetUnpacked(size, size, size)
				renderDrawBox(P, A, PivotMin, PivotMax, color_black)
				PivotMin:Mul(0.7)
				PivotMax:Mul(0.7)
				renderDrawBox(P, A, PivotMin, PivotMax, Y)
			end

			size = size * (0.02 / 0.03)

			if op == 2 then
				self:DrawRotation3D(P, size)
			end

			-- cam.IgnoreZ(false)
			camEnd()

			if op == 2 then
				self:DrawRotation2D(P, size)
			end

			self:DrawObjectProperties()
		end

		if op == 0 then
			camStart(t3D)
			-- cam.IgnoreZ(true)
			-- render.SetColorMaterial()
			renderSetColorMaterialIgnoreZ()
			local draw2d = self:DrawSelection3D()
			-- cam.IgnoreZ(false)
			camEnd()

			if draw2d then
				self:DrawSelection2D()
			end
		end

		self:DrawModeMenu()

		if self.RightPressed then
			self:DrawModeSelector()
		end
	end
end

do
	local HovEntBones, HovBoneChildren, HovEnt, HovBone, HovBoneParent, HovEntBoneK, HovBoneName, HovBoneNameLen, HovBoneNameH = { }, { }
	local TempParentInfo = { }

	do
		local surfaceGetTextSize, mathhuge, surfaceSetFont, BONE_USED_BY_VERTEX_LOD0, BONE_ALWAYS_PROCEDURAL = surface.GetTextSize, math.huge, surface.SetFont, BONE_USED_BY_VERTEX_LOD0, BONE_ALWAYS_PROCEDURAL

		function TOOL:SelectionThink(t)
			local E = t.Entity

			if not E or not E:IsValid() then
				HovEnt = nil

				return
			end

			local k = E:GetBoneCount()
			local hit = t.HitPos
			local closest, closestbone = mathhuge
			HovEnt = E
			HovEntBoneK = k - 1
			local TempParentInfo = TempParentInfo

			do
				local HovEntBones = HovEntBones
				local epos = E:GetPos()

				for i = 0, k - 1 do
					local v = E:GetBonePosition(i)

					if not v or v == epos then
						local m = E:GetBoneMatrix(i)

						if m then
							v = m:GetTranslation()
						end
					end

					local dist = hit:DistToSqr(v)
					HovEntBones[i] = v
					TempParentInfo[i] = E:GetBoneParent(i)

					if not E:BoneHasFlag(i, BONE_ALWAYS_PROCEDURAL) and closest > dist then
						closest = dist
						closestbone = i
					end
				end
			end

			HovBone = closestbone

			if closestbone then
				HovBoneName = E:GetBoneName(closestbone)
				surfaceSetFont("Trebuchet18")
				HovBoneNameLen, HovBoneNameH = surfaceGetTextSize(HovBoneName)
				HovBoneParent = E:GetBoneParent(closestbone)

				do
					local c = 1
					local HovBoneChildren = HovBoneChildren

					for i = 1, k - 1 do
						if TempParentInfo[i] == closestbone and E:BoneHasFlag(i, BONE_USED_BY_VERTEX_LOD0) and not E:BoneHasFlag(i, BONE_ALWAYS_PROCEDURAL) then
							HovBoneChildren[c] = i
							c = c + 1
						end
					end

					if c == 1 then
						HovBoneChildren[1] = nil
					else
						HovBoneChildren[c] = nil
					end
				end
			end
		end
	end

	do
		local OutlineColor, ParentColor, ChildColor, BoneColor = Color(0, 0, 0), Color(150, 150, 150, 200), Color(255, 255, 255, 200), Color(200, 200, 200)
		local renderDrawBeam, ipairs, BONE_ALWAYS_PROCEDURAL, renderDrawSphere, renderOverrideBlend, EyePos, BONE_USED_BY_VERTEX_LOD0 = render.DrawBeam, ipairs, BONE_ALWAYS_PROCEDURAL, render.DrawSphere, render.OverrideBlend, EyePos, BONE_USED_BY_VERTEX_LOD0

		function TOOL:DrawSelection3D()
			if not HovEnt or not HovBone then return end
			local HovEntBones = HovEntBones
			local HovBonePos = HovEntBones[HovBone]
			local scale = HovBonePos - EyePos()
			scale = scale:Length() * (0.3 * 0.02)
			local OutlineColor = OutlineColor

			do
				local ChildColor = ChildColor

				for k, v in ipairs(HovBoneChildren) do
					renderDrawBeam(HovBonePos, HovEntBones[v], scale + 0.1, 0, 1, OutlineColor)
					renderDrawBeam(HovBonePos, HovEntBones[v], scale, 0, 1, ChildColor)
				end
			end

			do
				local parent = HovBoneParent

				if parent ~= -1 then
					renderDrawBeam(HovBonePos, HovEntBones[parent], scale + 0.1, 0, 1, OutlineColor)
					renderDrawBeam(HovBonePos, HovEntBones[parent], scale, 0, 1, ParentColor)
				end
			end

			renderOverrideBlend(true, 1, 1, 1)

			do
				local BoneColor = BoneColor

				for i = 0, HovEntBoneK do
					if HovEnt:BoneHasFlag(i, BONE_USED_BY_VERTEX_LOD0) and not HovEnt:BoneHasFlag(i, BONE_ALWAYS_PROCEDURAL) then
						renderDrawSphere(HovEntBones[i], scale, 5, 5, BoneColor)
					end
				end
			end

			renderOverrideBlend(false)
			renderDrawSphere(HovBonePos, scale, 5, 5, G)

			return true
		end
	end

	do
		local surfaceSetTextColor, surfaceDrawRect, surfaceSetTextPos, surfaceSetFont, surfaceSetDrawColor, surfaceDrawText = surface.SetTextColor, surface.DrawRect, surface.SetTextPos, surface.SetFont, surface.SetDrawColor, surface.DrawText

		function TOOL:DrawSelection2D()
			surfaceSetFont("Trebuchet18")
			surfaceSetTextColor(255, 255, 255)
			surfaceSetDrawColor(50, 50, 50, 200)
			local x, y

			do
				local v = HovEntBones[HovBone]:ToScreen()
				x, y = v.x, v.y
			end

			do
				local len, h = HovBoneNameLen, HovBoneNameH
				y = y - h - 16
				surfaceDrawRect(x + 4, y, len + 4, h + 4)
				surfaceSetTextPos(x + 6, y + 2)
			end

			surfaceDrawText(HovBoneName)
		end
	end

	do
		local t3D = {
			type = "3D"
		}

		local Frame
		local ParentColor, ChildColor, BoneColor, R = Color(150, 150, 150, 200), Color(255, 255, 255, 200), Color(200, 200, 200), Color(255, 0, 0)
		local renderDrawBeam, renderDrawSphere, renderSetColorMaterialIgnoreZ, SysTime, camEnd3D, camStart3D = render.DrawBeam, render.DrawSphere, render.SetColorMaterialIgnoreZ, SysTime, cam.End3D, cam.Start3D

		function TOOL:SelectionShowBone(E, bonen)
			local children = E:GetChildBones(bonen)
			local parent = E:GetBoneParent(bonen)
			local start = SysTime()

			hook.Add("PostRender", "GodSentToolsLocRotScale", function()
				if not E:IsValid() then
					hook.Remove("PostRender", "GodSentToolsLocRotScale")

					if Frame and Frame:IsValid() then
						Frame:Show()
					end

					return
				end

				local clock = SysTime() - start

				if clock % 0.7 >= 0.35 then
					camStart3D(t3D)
					local epos = E:GetPos()
					local HovBonePos = E:GetBonePosition(bonen)

					if not HovBonePos or HovBonePos == epos then
						HovBonePos = E:GetBoneMatrix(bonen):GetTranslation()
					end

					local scale = epos - EyePos()
					scale = scale:Length() * (0.3 * 0.02)
					renderSetColorMaterialIgnoreZ()

					do
						local ChildColor = ChildColor

						for k, v in ipairs(children) do
							local pos = E:GetBonePosition(v)

							if not pos or pos == epos then
								pos = E:GetBoneMatrix(v):GetTranslation()
							end

							renderDrawBeam(HovBonePos, pos, scale, 0, 1, ChildColor)
						end
					end

					do
						local ParentColor = ParentColor

						if parent ~= -1 then
							local pos = E:GetBonePosition(parent)

							if not pos or pos == epos then
								pos = E:GetBoneMatrix(parent):GetTranslation()
							end

							renderDrawBeam(HovBonePos, pos, scale, 0, 1, ParentColor)
						end
					end

					renderDrawSphere(HovBonePos, scale, 5, 5, R)
					camEnd3D()
				end

				if clock > 4 then
					hook.Remove("PostRender", "GodSentToolsLocRotScale")

					if Frame and Frame:IsValid() then
						Frame:Show()
					end
				end
			end)
		end

		do
			local netWriteUInt, netWriteEntity, netStart, netSendToServer = net.WriteUInt, net.WriteEntity, net.Start, net.SendToServer

			function TOOL:SelectionSetBone(E, bonen)
				netStart("GodSentToolsLocRotScale")
				netWriteUInt(0, 1)
				netWriteEntity(E)
				netWriteUInt(bonen, 8)
				netSendToServer()
			end
		end

		function TOOL:SelectionMenu(E, t)
			if not E or not E:IsValid() then return end

			if Frame and Frame:IsValid() then
				Frame:Close()
			end

			Frame = vgui.Create("DFrame")
			Frame:SetSize(math.min(ScrW() * 0.9, 1280), math.min(ScrH() * 0.9, 720))
			Frame:Center()
			Frame:SetTitle("#tool.godsent_locrotscale.selectionmenu.title")
			Frame:SetScreenLock(true)
			Frame:SetSizable(true)
			Frame:MakePopup()
			local tabs = Frame:Add("DPropertySheet")
			tabs:Dock(FILL)
			local listp = tabs:Add("DPanel")
			tabs:AddSheet("#tool.godsent_locrotscale.selectionmenu.list", listp, "icon16/text_list_numbers.png")
			local listsearch = listp:Add("DTextEntry")
			listsearch:Dock(TOP)
			listsearch:DockMargin(0, 0, 0, 5)
			local list = listp:Add("DListView")
			list:Dock(FILL)
			list:SetMultiSelect(false)
			local col = list:AddColumn("#tool.godsent_locrotscale.selectionmenu.id")
			local col1 = list:AddColumn("#tool.godsent_locrotscale.selectionmenu.name")
			local col2 = list:AddColumn("#tool.godsent_locrotscale.selectionmenu.distance")
			local col3 = list:AddColumn("#tool.godsent_locrotscale.selectionmenu.isvisible")
			local col4 = list:AddColumn("#tool.godsent_locrotscale.selectionmenu.parent")
			col:SetMaxWidth(30)
			col1:SetWidth(200)
			col2:SetMaxWidth(50)
			col3:SetMaxWidth(50)
			col4:SetMaxWidth(50)

			function Frame:OnSizeChanged()
				col:SetMaxWidth(30)
				col1:SetWidth(200)
				col2:SetMaxWidth(50)
				col3:SetMaxWidth(50)
				col4:SetMaxWidth(50)
			end

			local BonesParents = { }
			local BonesInfo = { }
			local k = E:GetBoneCount()

			do
				local hit = t.HitPos

				do
					local epos = E:GetPos()

					for i = 0, k - 1 do
						local v = E:GetBonePosition(i)
						-- if not v or v == epos then
						-- v = E:GetBoneMatrix(i):GetTranslation()
						-- end
						local name = E:GetBoneName(i)
						local parent = E:GetBoneParent(i)
						BonesParents[i] = parent
						BonesInfo[i * 5] = name
						local dist, vis = Round(hit:Distance(v), 0.01), E:BoneHasFlag(i, BONE_USED_BY_VERTEX_LOD0)
						BonesInfo[i * 5 + 1] = dist
						BonesInfo[i * 5 + 2] = vis
						BonesInfo[i * 5 + 3] = parent
						local tooltip = name .. " (" .. i .. ")"
						BonesInfo[i * 5 + 4] = tooltip
						local line = list:AddLine(i, name, dist, vis and "✔" or "❌", parent)
						line:SetTooltip(tooltip)
						line.BoneID = i
					end
				end

				list:SortByColumn(3)
			end

			function listsearch:OnChange()
				local text = string.lower(self:GetText())
				list:Clear()

				if text == "" then
					for i = 0, k - 1 do
						local line = list:AddLine(i, BonesInfo[i * 5], BonesInfo[i * 5 + 1], BonesInfo[i * 5 + 2] and "✔" or "❌", BonesInfo[i * 5 + 3])
						line:SetTooltip(BonesInfo[i * 5 + 4])
						line.BoneID = i
					end

					list:SortByColumn(3)

					return
				end

				for i = 0, k - 1 do
					if string.find(string.lower(tostring(i)), text, 1, true) or string.find(string.lower(tostring(BonesInfo[i * 5])), text, 1, true) or string.find(string.lower(tostring(BonesInfo[i * 5 + 3])), text, 1, true) then
						local line = list:AddLine(i, BonesInfo[i * 5], BonesInfo[i * 5 + 1], BonesInfo[i * 5 + 2] and "✔" or "❌", BonesInfo[i * 5 + 3])
						line:SetTooltip(BonesInfo[i * 5 + 4])
						line.BoneID = i
					end
				end

				list:SortByColumn(3)
			end

			do
				local tool = self

				function list:DoDoubleClick(lineID, line)
					tool:SelectionSetBone(E, line.BoneID)
					Frame:Close()
				end

				function list:OnRowRightClick(lineID, line)
					local menu = DermaMenu(line)

					menu:AddOption("#tool.godsent_locrotscale.selectionmenu.show", function()
						Frame:Hide()
						tool:SelectionShowBone(E, line.BoneID)
					end):SetIcon("icon16/find.png")

					menu:AddOption("#tool.godsent_locrotscale.selectionmenu.use", function()
						tool:SelectionSetBone(E, line.BoneID)
						Frame:Close()
					end):SetIcon("icon16/cursor.png")

					menu:AddOption("#tool.godsent_locrotscale.selectionmenu.copy", function()
						SetClipboardText(BonesInfo[line.BoneID * 5])
					end):SetIcon("icon16/paste_plain.png")

					menu:Open()
				end
			end

			local tree = tabs:Add("DTree")
			tabs:AddSheet("#tool.godsent_locrotscale.selectionmenu.tree", tree, "icon16/chart_organisation.png")

			function tree:DoRightClick(node)
				list:OnRowRightClick(nil, node)
			end

			local parent = -1

			repeat
				for i = 0, k - 1 do
					if BonesParents[i] == parent then
						if parent == -1 then
							local node = tree:AddNode(E:GetBoneName(i) .. " (" .. i .. ")", "icon16/vector.png")
							node:ExpandRecurse(true)
							node.BoneID = i
							BonesParents[i] = node
						else
							local node = BonesParents[parent]:AddNode(E:GetBoneName(i) .. " (" .. i .. ")", "icon16/vector.png")
							node:ExpandRecurse(true)
							node.BoneID = i
							BonesParents[i] = node
						end
					end
				end

				parent = parent + 1
			until parent > k
		end
	end
end

do
	local RotationDisks, RotationDisksLen = { }, 0
	local mathpi2, mathsin, mathcos = math.pi * 2, math.sin, math.cos
	local step = math.rad(10)
	local CheckDrag = TOOL.CheckDrag
	local GetPlaneNormal = TOOL.GetPlaneNormal
	local ToDegVector = Vector()
	local RotationDegText, RotationDegTextLen, RotationDegTextH
	local IN_SPEED, surfaceGetTextSize, surfaceSetFont, LocalPlayer, mathNormalizeAngle = IN_SPEED, surface.GetTextSize, surface.SetFont, LocalPlayer, math.NormalizeAngle

	function TOOL:RotationThink(t)
		local E, bone = self.TargetEntity, self.TargetBone
		local P, A = self.BonePos, self.BoneAng
		local scale = self.EntityDistance

		if not self.Pressed then
			local LF, LU, LR

			do
				local LA = scale:Angle()
				LF, LU, LR = LA:Forward(), LA:Up(), LA:Right()
			end

			local ux, uy, uz = A:Forward(), A:Right(), A:Up()
			scale = scale:LengthSqr()

			do
				local hscale = scale * (0.3 ^ 2)
				local tolerance = hscale * 0.1
				local EyePos, TraceNormal = t.StartPos, t.Normal
				local CheckDrag = CheckDrag
				local closest, dircolor = math.huge

				do
					local dir = ux
					local pos, _, close = CheckDrag(P, dir, EyePos, TraceNormal, hscale, tolerance)

					if pos and closest > close then
						closest, dircolor = close, 0
					end
				end

				do
					local dir = uy
					local pos, _, close = CheckDrag(P, dir, EyePos, TraceNormal, hscale, tolerance)

					if pos and closest > close then
						closest, dircolor = close, 1
					end
				end

				do
					local dir = uz
					local pos, _, close = CheckDrag(P, dir, EyePos, TraceNormal, hscale, tolerance)

					if pos and closest > close then
						closest, dircolor = close, 2
					end
				end

				do
					hscale = hscale * 1.5
					local pos, _, close = CheckDrag(P, LF, EyePos, TraceNormal, hscale, hscale * 0.1)

					if pos and closest > close then
						closest, dircolor = close, 3
					end
				end

				self.RotationHoverDisk = dircolor
			end

			scale = (scale ^ 0.5) * 0.3

			do
				local AMul = ux.Mul
				AMul(ux, scale)
				AMul(uy, scale)
				AMul(uz, scale)
				scale = scale * 1.2
				AMul(LU, scale)
				AMul(LR, scale)
			end

			local i = 0
			local step = step

			for l = 0, mathpi2, step do
				local s, c, sn, cn

				do
					local next = l + step
					s, c, sn, cn = mathsin(l), mathcos(l), mathsin(next), mathcos(next)
				end

				local VAdd = P.Add

				do
					local UZC = uz * c
					local UZCN = uz * cn

					do
						local V1 = uy * s
						VAdd(V1, UZC)
						local V2 = uy * sn
						VAdd(V2, UZCN)
						VAdd(V1, P)
						VAdd(V2, P)
						RotationDisks[i] = V1
						RotationDisks[i + 1] = V2
					end

					do
						local UXS = ux * s
						local UXSN = ux * sn

						do
							local V1 = UXS + UZC
							local V2 = UXSN + UZCN
							VAdd(V1, P)
							VAdd(V2, P)
							RotationDisks[i + 2] = V1
							RotationDisks[i + 3] = V2
						end

						do
							local V1 = uy * c
							VAdd(V1, UXS)
							local V2 = uy * cn
							VAdd(V2, UXSN)
							VAdd(V1, P)
							VAdd(V2, P)
							RotationDisks[i + 4] = V1
							RotationDisks[i + 5] = V2
						end
					end
				end

				do
					local V1 = LU * s
					local V2 = LU * sn
					VAdd(V1, LR * c)
					VAdd(V2, LR * cn)
					VAdd(V1, P)
					VAdd(V2, P)
					RotationDisks[i + 6] = V1
					RotationDisks[i + 7] = V2
				end

				i = i + 8
			end

			RotationDisksLen = i
		else
			RotationDisks = { }
			local LU, LR

			do
				local LA = self.RotationDir:Angle()
				LU, LR = LA:Up(), LA:Right()
			end

			scale = scale:Length() * 0.3

			do
				local cur, hit = GetPlaneNormal(P, self.RotationDir, t.StartPos, t.Normal)
				self.RotationCurrent = cur
				self.RotationHit = hit

				if hit then
					do
						local localized = WorldToLocal(hit, angle_zero, P, self.RotationDirAng)
						ToDegVector:SetUnpacked(localized[2], localized[3], 0)
					end

					do
						local d

						do
							local e = ToDegVector:Angle()[2]

							if LocalPlayer():KeyDown(IN_SPEED) then
								d = mathNormalizeAngle(ceiloor((e - self.RotationStartDeg) * 0.2) * 5)
							else
								d = mathNormalizeAngle(e - self.RotationStartDeg)
							end
						end

						local text = Round(d, 0.1) .. "°"
						RotationDegText = text
						surfaceSetFont("Trebuchet18")
						RotationDegTextLen, RotationDegTextH = surfaceGetTextSize(text)
					end
				end
			end

			if self.RotationDirColor == 3 then
				scale = scale * 1.2
			end

			do
				local AMul = LU.Mul
				AMul(LU, scale)
				AMul(LR, scale)
			end

			local i = 0
			local step = step

			for l = 0, mathpi2, step do
				local s, c, sn, cn
				s, c = mathsin(l), mathcos(l)

				do
					local next = l + step
					sn, cn = mathsin(next), mathcos(next)
				end

				local VAdd = P.Add

				do
					local V1 = LU * s
					local V2 = LU * sn
					VAdd(V1, LR * c)
					VAdd(V2, LR * cn)
					VAdd(V1, P)
					VAdd(V2, P)
					RotationDisks[i] = V1
					RotationDisks[i + 1] = V2
				end

				i = i + 2
			end

			RotationDisksLen = i
		end
	end

	local renderAddBeam, renderDrawBeam, renderStartBeam, renderEndBeam = render.AddBeam, render.DrawBeam, render.StartBeam, render.EndBeam

	function TOOL:DrawRotation3D(P, size)
		do
			local RotationDisks = RotationDisks
			local RotationDisksLen = RotationDisksLen

			if not self.Pressed then
				local diskpart = RotationDisksLen * (1 / 4)
				local HoverDisk = self.RotationHoverDisk

				do
					renderStartBeam(diskpart)
					local R = R

					if HoverDisk == 0 then
						R = Hover
					end

					for i = 0, RotationDisksLen, 8 do
						renderAddBeam(RotationDisks[i], size, 1, R)
						renderAddBeam(RotationDisks[i + 1], size, 1, R)
					end

					renderEndBeam()
				end

				do
					renderStartBeam(diskpart)
					local G = G

					if HoverDisk == 1 then
						G = Hover
					end

					for i = 0, RotationDisksLen, 8 do
						renderAddBeam(RotationDisks[i + 2], size, 1, G)
						renderAddBeam(RotationDisks[i + 3], size, 1, G)
					end

					renderEndBeam()
				end

				do
					renderStartBeam(diskpart)
					local B = B

					if HoverDisk == 2 then
						B = Hover
					end

					for i = 0, RotationDisksLen, 8 do
						renderAddBeam(RotationDisks[i + 4], size, 1, B)
						renderAddBeam(RotationDisks[i + 5], size, 1, B)
					end

					renderEndBeam()
				end

				do
					renderStartBeam(diskpart)
					local Y = Y

					if HoverDisk == 3 then
						Y = Hover
					end

					for i = 0, RotationDisksLen, 8 do
						renderAddBeam(RotationDisks[i + 6], size, 1, Y)
						renderAddBeam(RotationDisks[i + 7], size, 1, Y)
					end

					renderEndBeam()
				end
			else
				do
					renderStartBeam(RotationDisksLen)
					local dircolor = self.RotationDirColor
					local C = NumToColor[dircolor]

					for i = 0, RotationDisksLen, 2 do
						renderAddBeam(RotationDisks[i], size, 1, C)
						renderAddBeam(RotationDisks[i + 1], size, 1, C)
					end

					renderEndBeam()

					do
						local r = self.EntityDistanceLen

						if dircolor == 3 then
							r = r * 1.2
						end

						do
							local dir = self.RotationStart * r
							dir:Add(P)
							renderDrawBeam(P, dir, size, 0, 1, Y)
						end

						if self.RotationCurrent then
							local dir = self.RotationCurrent * r
							dir:Add(P)
							renderDrawBeam(P, dir, size, 0, 1, Hover)
						end
					end
				end
			end
		end
	end

	do
		local surfaceSetTextColor, surfaceDrawRect, surfaceSetTextPos, surfaceSetFont, surfaceSetDrawColor, surfaceDrawText = surface.SetTextColor, surface.DrawRect, surface.SetTextPos, surface.SetFont, surface.SetDrawColor, surface.DrawText

		function TOOL:DrawRotation2D(P, size)
			if not self.Pressed or not self.RotationHit then return end
			surfaceSetDrawColor(50, 50, 50, 200)

			do
				local x, y

				do
					local V = self.RotationCurrent * self.EntityDistanceLen
					V:Mul(0.5)
					V:Add(P)
					local v = V:ToScreen()
					x, y = v.x, v.y
				end

				local len, h = RotationDegTextLen, RotationDegTextH
				x, y = x - len * 0.5, y - h * 0.5
				surfaceDrawRect(x - 2, y - 2, len + 4, h + 4)
				surfaceSetTextPos(x, y)
			end

			surfaceSetTextColor(255, 255, 255)
			surfaceSetFont("Trebuchet18")
			surfaceDrawText(RotationDegText)
		end
	end
end

do
	local oQuerp

	do
		local pow, clmp = math.pow, math.Clamp

		function oQuerp(t, d, b, c)
			return (c - b) * (pow(clmp(t, 0, d) / d - 1, 5) + 1) + b
		end
	end

	do
		do
			local surfaceDrawTexturedRect, surfaceSetMaterial, surfaceSetDrawColor, surfaceDrawRect = surface.DrawTexturedRect, surface.SetMaterial, surface.SetDrawColor, surface.DrawRect

			function TOOL:DrawToolScreen(w, h)
				surfaceSetDrawColor(75, 75, 75)
				surfaceDrawRect(0, 0, w, h)
				surfaceSetDrawColor(255, 255, 255)
				local op = self.SelectionMode and 1 or self:GetOperation() + 1
				surfaceSetMaterial(icons[op])
				surfaceDrawTexturedRect(10, 10, 64, 64)

				do
					surface.SetTextColor(255, 255, 255)
					surface.SetFont("DermaLarge")
					local t = "This is a Beta version of LocRotScale. Report issues to Spar#6665."
					local len, th = surface.GetTextSize(t)
					surface.SetTextPos(w * 2 - (SysTime() * 100) % (w * 2 + len), h - th - 10)
					surface.DrawText(t)
					surface.SetFont("Trebuchet24")
					len, th = surface.GetTextSize(t)

					do
						local VL = surface.GetTextSize(self.LOCROTSCALEVERSION)
						surface.SetTextPos((w - VL - 80) * 0.5, h - th - 50)
					end

					surface.DrawText("Version: ")
					surface.DrawText(self.LOCROTSCALEVERSION)
					surface.SetTextPos(64 + 10 + 10, 10)
					surface.DrawText("Mode: " .. op)
					surface.SetTextPos(64 + 10 + 10, 10 + th + 5)
					surface.DrawText("BoneMode: ")
					surface.DrawText(self.TargetBoneMode and "phys" or "bone")

					if self.SelectionMode then
						surface.SetTextPos(64 + 10 + 10, 10 + (th + 5) * 2)
						surface.DrawText("SHIFT")
					elseif self.Pressed then
						surface.SetTextPos(64 + 10 + 10, 10 + (th + 5) * 2)
						surface.DrawText("Pressed")
					end
				end
			end
		end

		do
			local lastMode = -1
			local lastTime = 0
			local animstate = false
			local position
			local surfaceSetDrawColor, surfaceDrawTexturedRect, renderPushFilterMag, ScrH, SysTime, mathfloor, surfaceSetAlphaMultiplier, surfaceSetMaterial, drawRoundedBoxEx, renderPopFilterMin, renderPopFilterMag, drawRoundedBox, renderPushFilterMin = surface.SetDrawColor, surface.DrawTexturedRect, render.PushFilterMag, ScrH, SysTime, math.floor, surface.SetAlphaMultiplier, surface.SetMaterial, draw.RoundedBoxEx, render.PopFilterMin, render.PopFilterMag, draw.RoundedBox, render.PushFilterMin
			local Color1, Color2, Color3, Color4 = Color(50, 50, 50), Color(100, 100, 100), Color(75, 75, 75), Color(0, 0, 0, 127)

			function TOOL:DrawModeMenu()
				local w, h, icon, iconshift

				do
					local factor = mathfloor(ScrH() * (1 / 480))
					w, h, icon, iconshift = 75 * factor, 270 * factor, 55 * factor, 10 * factor
				end

				local clock = SysTime() - lastTime
				local shift

				if animstate then
					shift = oQuerp(clock, 2, position or -w + 2, 0)

					if clock >= 2 then
						animstate = false
						clock = 0
						lastTime = SysTime() + 1
					end
				else
					shift = oQuerp(clock, 2, 0, -w + 2)
				end

				local op = self:GetOperation()

				if lastMode ~= op and not animstate then
					lastMode = op
					lastTime = SysTime()
					position = shift
					animstate = true
				end

				surfaceSetAlphaMultiplier(0.9)
				drawRoundedBoxEx(10, shift, 160, w + 2, h, Color2, false, true, false, true)
				drawRoundedBoxEx(10, shift, 162, w, h - 4, Color1, false, true, false, true)
				surfaceSetAlphaMultiplier(1)

				if animstate or clock < 2 then
					local wicon = (w - icon) * 0.5 + shift
					local icon_iconshift = (icon + iconshift)

					do
						local padding = icon + 10
						drawRoundedBox(10, wicon - 5, 165 + (self.SelectionMode and 0 or op) * icon_iconshift, padding, padding, Color3)
					end

					renderPushFilterMag(3)
					renderPushFilterMin(3)

					do
						surfaceSetDrawColor(255, 255, 255)
						local icons = icons

						for k = 1, 4 do
							surfaceSetMaterial(icons[k])
							surfaceDrawTexturedRect(wicon, 170 + (k - 1) * icon_iconshift, icon, icon)
						end
					end

					renderPopFilterMag()
					renderPopFilterMin()

					if not self.TargetEntity or not self.TargetEntity:IsValid() then
						drawRoundedBox(10, wicon - 5, 170 + icon + 5, icon + 10, icon_iconshift * 3, Color4)
					end
				end
			end
		end
	end

	do
		local lastTime = 0
		local animstate = true
		local keystate = false
		local position
		local keylock = false
		local HotKeyConvar = GetConVar("godsent_locrotscale_propkey")
		local PYRConvar = GetConVar("godsent_locrotscale_rotationpyr")

		cvars.AddChangeCallback("godsent_locrotscale_proptoggle", function(_, _, val)
			if val == "1" then
				keylock = true
				keystate = true
				animstate = true
				lastTime = SysTime()
				position = nil
			else
				keylock = false
				animstate = false
				lastTime = SysTime()
				position = nil
			end
		end)

		hook.Add("PostReloadToolsMenu", "GodSentToolsLocRotScale", function()
			HotKeyConvar = GetConVar("godsent_locrotscale_propkey")
			PYRConvar = GetConVar("godsent_locrotscale_rotationpyr")

			if GetConVar("godsent_locrotscale_proptoggle"):GetBool() then
				keylock = true
				keystate = true
				animstate = true
				lastTime = SysTime()
				position = nil
			end
		end)

		do
			local Properties = { }
			local EntityName, EntityNameLen, PYRConvarValue = "", 0, false
			local BoneName, BoneNameLen = "", 0

			do
				local stringsub, inputIsKeyDown, surfaceGetTextSize, ScrH, surfaceSetFont, mathfloor, SysTime = string.sub, input.IsKeyDown, surface.GetTextSize, ScrH, surface.SetFont, math.floor, SysTime

				function TOOL:PropertiesThink(E, P, A, S)
					if not animstate and SysTime() - lastTime > 1 then
						goto hidden
					end

					surfaceSetFont("Trebuchet18")

					do
						local text = "[" .. E:EntIndex() .. "] [" .. E:GetClass() .. "]"

						if #text > 25 then
							text = stringsub(text, 1, 22) .. "..."
						end

						local len = surfaceGetTextSize(text) * 0.5
						EntityName, EntityNameLen = text, len
					end

					do
						local text = "[" .. tostring(E:GetBoneName(self.TargetBone)) .. "] [" .. self.TargetBone .. "]"

						if #text > 25 then
							text = "..." .. stringsub(text, -22, -1)
						end

						local len = surfaceGetTextSize(text) * 0.5
						BoneName, BoneNameLen = text, len
					end

					do
						local Round = Round

						do
							local x, y, z = P:Unpack()
							Properties[0] = Round(x, 0.01)
							Properties[1] = Round(y, 0.01)
							Properties[2] = Round(z, 0.01)
						end

						do
							local x, y, z = A:Unpack()
							PYRConvarValue = PYRConvar:GetBool()
							Properties[3] = Round(x, 0.01)
							Properties[4] = Round(y, 0.01)
							Properties[5] = Round(z, 0.01)
						end

						do
							local x, y, z = S:Unpack()
							Properties[6] = Round(x, 0.01)
							Properties[7] = Round(y, 0.01)
							Properties[8] = Round(z, 0.01)
						end
					end

					::hidden::

					if inputIsKeyDown(HotKeyConvar:GetInt()) then
						if not keystate then
							keystate = true

							do
								local w = 180 * mathfloor(ScrH() * (1 / 480))

								if animstate then
									position = oQuerp(SysTime() - lastTime, 1, position or 4, w)
								else
									position = oQuerp(SysTime() - lastTime, 1, position or w, 4)
								end
							end

							animstate = not animstate
							lastTime = SysTime()
						end
					elseif not keylock then
						keystate = false
					end
				end
			end

			do
				surface.SetFont("Trebuchet18")
				local _, Sh = surface.GetTextSize(" ")
				local m = Matrix()
				local mTran, mScale = Vector(), Vector()
				local ScrW, ScrH, SysTime, mathfloor, surfaceSetTextColor, surfaceSetAlphaMultiplier, camPushModelMatrix, drawRoundedBoxEx, surfaceSetTextPos, surfaceSetFont, camPopModelMatrix, surfaceDrawText = ScrW, ScrH, SysTime, math.floor, surface.SetTextColor, surface.SetAlphaMultiplier, cam.PushModelMatrix, draw.RoundedBoxEx, surface.SetTextPos, surface.SetFont, cam.PopModelMatrix, surface.DrawText
				local renderPopFilterMag, renderPushFilterMag = render.PopFilterMag, render.PushFilterMag
				local Color1, Color2 = Color(50, 50, 50), Color(100, 100, 100)

				function TOOL:DrawObjectProperties()
					surfaceSetFont("Trebuchet18")
					surfaceSetTextColor(255, 255, 255)
					local factor = mathfloor(ScrH() * (1 / 480))
					local w, h = 180 * factor, 12 * Sh * factor
					local ST, s = SysTime()

					if animstate then
						s = oQuerp(ST - lastTime, 1, position or 4, w)
					else
						s = oQuerp(ST - lastTime, 1, position or w, 4)
					end

					do
						surfaceSetAlphaMultiplier(0.9)
						local SW = ScrW() - s
						drawRoundedBoxEx(10, SW, 160, w, h, Color2, true, false, true, false)
						drawRoundedBoxEx(10, SW + 2, 162, w, h - 4, Color1, true, false, true, false)
						surfaceSetAlphaMultiplier(1)
						if not animstate and ST - lastTime > 1 then return end
						m:Identity()

						do
							local mTran = mTran
							mTran:SetUnpacked(SW, 160, 0)
							m:Translate(mTran)
						end

						do
							local mScale = mScale
							mScale:SetUnpacked(factor, factor, 0)
							m:Scale(mScale)
						end

						-- renderPushFilterMag(3)
						camPushModelMatrix(m)
					end

					do
						surfaceSetTextPos(2 + ((180 - 2) / 2) - EntityNameLen, 5)
						surfaceDrawText(EntityName)
					end

					do
						surfaceSetTextPos(2 + ((180 - 2) / 2) - BoneNameLen, 20)
						surfaceDrawText(BoneName)
					end

					do
						local Properties = Properties

						do
							surfaceSetTextPos(5, 40)
							surfaceDrawText("Location:")
							surfaceSetTextPos(10, 55)
							surfaceDrawText("X: ")
							surfaceDrawText(Properties[0])
							surfaceSetTextPos(10, 67)
							surfaceDrawText("Y: ")
							surfaceDrawText(Properties[1])
							surfaceSetTextPos(10, 79)
							surfaceDrawText("Z: ")
							surfaceDrawText(Properties[2])
						end

						do
							local PYRConvarValue = PYRConvarValue
							surfaceSetTextPos(5, 99)
							surfaceDrawText("Rotation:")
							surfaceSetTextPos(10, 114)
							surfaceDrawText(PYRConvarValue and "P: " or "X: ")
							surfaceDrawText(Properties[3])
							surfaceSetTextPos(10, 126)
							surfaceDrawText(PYRConvarValue and "Y: " or "Y: ")
							surfaceDrawText(Properties[4])
							surfaceSetTextPos(10, 138)
							surfaceDrawText(PYRConvarValue and "R: " or "Z: ")
							surfaceDrawText(Properties[5])
						end

						do
							surfaceSetTextPos(5, 158)
							surfaceDrawText("Scale:")
							surfaceSetTextPos(10, 173)
							surfaceDrawText("X: ")
							surfaceDrawText(Properties[6])
							surfaceSetTextPos(10, 185)
							surfaceDrawText("Y: ")
							surfaceDrawText(Properties[7])
							surfaceSetTextPos(10, 197)
							surfaceDrawText("Z: ")
							surfaceDrawText(Properties[8])
						end
					end

					camPopModelMatrix()
					-- renderPopFilterMag()
					-- if input.IsKeyDown(HotKeyConvar:GetInt()) then
					-- 	if not keystate then
					-- 		keystate = true
					-- 		animstate = not animstate
					-- 		lastTime = ST
					-- 		position = s
					-- 	end
					-- elseif not keylock then
					-- 	keystate = false
					-- end
				end
			end
		end
	end
end
-- local SysTime, s = SysTime, 0
-- hook.Add("PreRender", "a", function()
-- 	s = SysTime()
-- end)
-- hook.Add("PostRender", "a", function()
-- 	local e = SysTime()
-- end)
-- print(F / (e - s) * 100)