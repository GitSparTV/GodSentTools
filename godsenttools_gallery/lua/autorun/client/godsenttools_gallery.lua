hook.Add("AddToolMenuCategories", "GodSentToolsCategory", function()
	spawnmenu.AddToolCategory("Utilities", "GodSent Tools", "#godsenttools.name")
end)

hook.Add("PopulateToolMenu", "GodSentToolsGallery", function()
	spawnmenu.AddToolMenuOption("Utilities", "GodSent Tools", "GodSentTools_Gallery", "#godsenttools.gallery.name", "", "", function(cp)
		local list = cp:AddControl("listbox", {
			Label = "#godsenttools.gallery.dateformat"
		})

		list:AddOption("DD/MM/YY", {
			godsenttools_gallery_dateformat = "%d/%m/%y"
		})

		list:AddOption("MM/DD/YY", {
			godsenttools_gallery_dateformat = "%m/%d/%y"
		})

		list:AddOption("YY/MM/DD", {
			godsenttools_gallery_dateformat = "%y/%m/%d"
		})
	end)
end)

local function OpenScreenshot(self)
	local frame = vgui.Create("DFrame")
	local height = ScrH() * 0.95

	frame:SetSize(self.aspect * height, height)
	frame.aspect = self.aspect
	frame:Center()
	frame:SetTitle(self.ScrName)
	frame:SetSizable(true)

	local img = frame:Add("DImage")
	img:SetMaterial(self.m_Image:GetMaterial())
	img:SizeToContents()
	img:SetKeepAspect(true)
	frame.image = img

	function frame:OnSizeChanged(w, h)
		local l, t, r, b = self:GetDockPadding()

		local original_width, original_height = w, h
		h = h
		w = self.aspect * h

		if w > original_width then
			w, h = original_width, original_width / self.aspect
		end

		self.image:SetSize(w - l - r, h - t - b)
		self.image:SetPos(l + math.floor((original_width - w) / 2), t + math.floor(original_height - h) / 2)
	end
	frame:OnSizeChanged(frame:GetSize())

	frame:MakePopup()
end

local cv = CreateClientConVar("godsenttools_gallery_dateformat", "%d/%m/%y", true, false, "Date format in Gallery tab")

spawnmenu.AddCreationTab("#godsenttools.gallery.name", function()
	local panel = vgui.Create("DScrollPanel")
	panel:Dock(FILL)

	local bar = panel:Add("DPanel")
	bar:Dock(TOP)
	bar:SetSize(0, 64)
	bar.Paint = nil

	local label = vgui.Create("ContentHeader")
	bar:Add(label)
	label:SetZPos(0)
	label:Dock(FILL)
	label.m_DragSlot = nil

	local refresh = bar:Add("DButton")
	refresh:SetText("#godsenttools.gallery.refresh")
	refresh:SetIcon("icon16/arrow_refresh.png")
	refresh:Dock(RIGHT)
	refresh:SetFont("DermaLarge")
	refresh:SizeToContentsX(42)
	refresh:SetContentAlignment(5)
	refresh.label = label
	refresh.next_reload = SysTime()

	local layout = panel:Add("DIconLayout")
	layout:Dock(FILL)
	layout:SetSpaceY(5)
	layout:SetSpaceX(5)

	function refresh:Think()
		local cur = SysTime()

		if self.next_reload > cur then
			return
		end

		self.next_reload = cur + 60 * 10

		self:DoClick()
	end

	function refresh:DoClick()
		layout:Clear()
		local scr = file.Find("screenshots/*", "GAME", "datedesc")
		local last
		local k = 0

		for i = 1, #scr do
			local v = scr[i]

			local ext = string.match(v, "%.([^.]+)$")

			if ext == "jpg" or ext == "png" or ext == "jpeg" then
				do
					local time = os.date(cv:GetString(), file.Time("screenshots/" .. v, "GAME"))

					if time ~= last then
						local head = layout:Add("ContentHeader")
						head:SetText(time)
						last = time
					end
				end

				do
					local item = layout:Add("DImageButton")
					k = k + 1

					item:SetImage("../screenshots/" .. v)
					item:SizeToContents()
					item:SetKeepAspect(true)

					item.ScrName = v
					item.m_Image:SetFailsafeMatName("gui/noicon.png")
					item.DoClick = OpenScreenshot

					local w, h = item:GetWide(), item:GetTall()
					local aspect = w / h
					h = math.floor(ScrH() * 0.3)
					w = math.floor(aspect * h)
					item.aspect = aspect
					item:SetSize(w, h)

					item:SetTooltip(v)
				end
			end
		end

		self.label:SetText(language.GetPhrase("#godsenttools.gallery.name") .. " (" .. k .. " " .. language.GetPhrase("#godsenttools.gallery.screenshots") .. ")")
	end

	local function ConVarRefresh()
		refresh:DoClick()
	end

	cvars.AddChangeCallback("godsenttools_gallery_dateformat", ConVarRefresh, "GodSentToolsGallery")

	return panel
end, "icon16/photos.png", 201, "#godsenttools.gallery.name")

