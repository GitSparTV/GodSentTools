if not spawnmenu then return end

spawnmenu.AddCreationTab(" ", function()
	local cont = vgui.Create("ContentContainer")
	cont.DoRightClick = nil
	g_SpawnMenu.PropsHistory = cont
	local label = vgui.Create("ContentHeader")
	cont:Add(label)
	label:SetZPos(0)
	label.m_DragSlot = nil
	label:SetText("#godsenttools.propshistory.name")
	cont.IconList:SetReadOnly(true)
	cont.IconList:SetDnD(nil)
	cont.IconList:SetSelectionCanvas(false)

	return cont
end, "icon16/page_paste.png", -100)

hook.Add("PopulateContent", "GodSentToolsPropsHistory", function()
	local cm = g_SpawnMenu.CreateMenu
	local spawnlist = cm.Items[2]

	if spawnlist then
		cm:SetActiveTab(spawnlist.Tab)
	end
end)

hook.Add("PopulateToolMenu", "GodSentToolsPropsHistory", function()
	spawnmenu.AddToolMenuOption("Utilities", "#godsenttools.name", "GodSentTools_Props_History", "#godsenttools.propshistory.name", "", "", function(cp)
		local list = cp:AddControl("listbox", {
			Label = "#godsenttools.propshistory.size"
		})

		list:SetSortItems(false)

		local sizes = {64, 128, 256, 512}

		for a = 1, #sizes do
			local an = sizes[a]

			for b = 1, #sizes do
				local bn = sizes[b]
				local name = an .. "x" .. bn

				list:AddOption(name, {
					godsenttools_propshistory_size = name
				})
			end
		end
	end)
end)

local t = {
	model = false,
	wide = false,
	tall = false,
	skin = false,
	body = false,
}

do
	local cv = CreateClientConVar("godsenttools_propshistory_size", "64x64", true, false, language.GetPhrase("#godsenttools.propshistory.convar.size"))
	local tonumber, stringmatch = tonumber, string.match

	local function SetIconSize(_, _, val)
		local w, h = stringmatch(val, "(%d+)x(%d+)")
		w, h = tonumber(w), tonumber(h)
		if not w or not h then return end
		t.wide = w
		t.tall = h
		local spawnmenu = g_SpawnMenu
		if not spawnmenu then return end
		local propshistory = g_SpawnMenu.PropsHistory

		if propshistory then
			local list = propshistory.IconList
			local children = list:GetChildren()

			for k = 1, #children do
				local v = children[k]

				if v.ClassName ~= "ContentHeader" then
					v:SetSize(w, h)
					v:InvalidateLayout(true)
					v:SetModel(v:GetModelName(), v:GetSkinID(), v:GetBodyGroup())
				end
			end

			list:Layout()
		end
	end

	cvars.AddChangeCallback("godsenttools_propshistory_size", SetIconSize, "GodSentToolsPropsHistory")
	SetIconSize(_, _, cv:GetString())
end

local placeholder = function() end
local spawnmenuGetContentType, netReadString, netReadUInt = spawnmenu.GetContentType, net.ReadString, net.ReadUInt

net.Receive("GodSentToolsPropsHistory", function()
	local model = netReadString()
	local netReadUInt = netReadUInt
	local skin = netReadUInt(8)
	local body = netReadUInt(4) .. netReadUInt(4) .. netReadUInt(4) .. netReadUInt(4) .. netReadUInt(4) .. netReadUInt(4) .. netReadUInt(4) .. netReadUInt(4) .. netReadUInt(4)
	local exists
	local temp = {}
	local PropsHistory = g_SpawnMenu.PropsHistory
	local list = PropsHistory.IconList
	local children = list:GetChildren()

	for k = 1, #children do
		local v = children[k]

		if v.ClassName ~= "ContentHeader" then
			if v:GetModelName() == model and v:GetBodyGroup() == body and v:GetSkinID() == skin then
				exists = v
			else
				temp[#temp + 1] = v
			end

			v:SetParent()
		end
	end

	if exists then
		list:Add(exists)
	else
		local cp = spawnmenuGetContentType("model")

		if cp then
			local t = t
			t.model = model
			t.body = body
			t.skin = skin
			local icon = cp(PropsHistory, t)
			local placeholder = placeholder
			icon.DoRightClick = placeholder
			icon.OpenMenu = placeholder
		end
	end

	for k = 1, #temp do
		list:Add(temp[k])
	end
end)