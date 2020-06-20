language.Add("godsenttools.gallery.name", "Gallery")
language.Add("godsenttools.gallery.refresh", "Refresh")

local function OpenScreenshot(self)
	local frame = vgui.Create("DFrame")
	frame:SetSize(ScrW() * 0.95, ScrH() * 0.95)
	frame:Center()
	frame:SetTitle(self.ScrName)
	local img = frame:Add("DImage")
	img:SetMaterial(self.m_Image:GetMaterial())
	img:Dock(FILL)
	frame:MakePopup()
end

spawnmenu.AddCreationTab("#godsenttools.gallery.name", function()
	local panel = vgui.Create("DScrollPanel")
	panel:Dock(FILL)
	local bar = panel:Add("DPanel")
	bar:Dock(TOP)
	local refresh = bar:Add("DButton")
	refresh:SetText("#godsenttools.gallery.refresh")
	refresh:SetIcon("icon16/arrow_refresh.png")
	refresh:Dock(FILL)
	local total = bar:Add("DLabel")
	total:Dock(LEFT)
	total:SetDark(true)
	total:DockMargin(10, 0, 100, 0)
	local layout = panel:Add("DIconLayout")
	layout:Dock(FILL)
	layout:SetSpaceY(5)
	layout:SetSpaceX(5)
	local function Refresh()
	layout:Clear()
	local scr = file.Find("screenshots/*", "GAME", "datedesc")
	local last
	local k = 0

	for i = 1, #scr do
		local v = scr[i]

		do
			local ext = string.match(v, "%.(.-)$")

			if ext ~= "jpg" and ext ~= "png" and ext ~= "jpeg" then
				goto ignore
			end
		end

		do
			local time = os.date("%y/%m/%d", file.Time("screenshots/" .. v, "GAME"))

			if time ~= last then
				local head = layout:Add("ContentHeader")
				head:SetText(time)
				last = time
			end
		end

		do
			local item = layout:Add("DImageButton")
			k = k + 1
			item:SetImage("./screenshots/" .. v)
			item:SizeToContents()
			item:SetKeepAspect(true)
			item.ScrName = v
			item.m_Image:SetFailsafeMatName("gui/noicon")
			item.DoClick = OpenScreenshot
			local w, h = item:GetWide(), item:GetTall()

			local aspect = w / h

			h = math.floor(ScrH() * 0.3)
			w = math.floor(aspect * h)

			item:SetSize(w, h)
			item:SetTooltip(v)
		end

		::ignore::
	end

	total:SetText(k .. " screenshots")
	total:SizeToContents()

	end
	Refresh()
	refresh.DoClick = Refresh


	return panel
end, "icon16/photos.png", 201, "#godsenttools.gallery.name")