hook.Add("PopulateToolMenu", "GodSentToolsGallery", function()
	spawnmenu.AddToolMenuOption("Utilities", "#godsenttools.name", "GodSentTools_Gallery", "#godsenttools.gallery.name", "", "", function(cp)
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

local cv = CreateClientConVar("godsenttools_gallery_dateformat", "%d/%m/%y", true, false, language.GetPhrase("#godsenttools.gallery.convar.dateformat"))

spawnmenu.AddCreationTab("#godsenttools.gallery.name", function()
	local panel = vgui.Create("DPanel")
	panel:Dock(FILL)
	panel.Paint = nil

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
	refresh:SetTooltip("#godsenttools.gallery.refresh")
	refresh:Dock(RIGHT)
	refresh:SetSize(64 - 10, 64)
	refresh:DockMargin(5, 5, 0, 5)
	refresh:SetText("")

	do
		local refresh_image = refresh:Add("DImage")
		refresh_image:SetImage("icon16/arrow_refresh.png")
		refresh_image:Dock(FILL)
		refresh_image:DockMargin(10, 10, 10, 10)
	end

	refresh.label = label
	refresh.next_reload = SysTime()

	local page_select_forward = bar:Add("DButton")
	page_select_forward:SetTooltip("#godsenttools.gallery.nextpage")
	page_select_forward:Dock(RIGHT)
	page_select_forward:SetSize(64 - 10, 64)
	page_select_forward:DockMargin(5, 5, 5, 5)
	page_select_forward:SetEnabled(false)
	page_select_forward.refresh = refresh

	do
		local page_select_forward_image = page_select_forward:Add("DImage")
		page_select_forward_image:SetImage("icon16/arrow_right.png")
		page_select_forward_image:Dock(FILL)
		page_select_forward_image:DockMargin(10, 10, 10, 10)
	end

	function page_select_forward:DoClick()
		self.refresh:DoClick(self.refresh.current_offset + 1)
	end

	local page_select_back = bar:Add("DButton")
	page_select_back:SetTooltip("#godsenttools.gallery.previouspage")
	page_select_back:Dock(RIGHT)
	page_select_back:SetSize(64 - 10, 64)
	page_select_back:DockMargin(5, 5, 5, 5)
	page_select_back:SetEnabled(false)
	page_select_back.refresh = refresh

	do
		local page_select_back_image = page_select_back:Add("DImage")
		page_select_back_image:SetImage("icon16/arrow_left.png")
		page_select_back_image:Dock(FILL)
		page_select_back_image:DockMargin(10, 10, 10, 10)
	end

	function page_select_back:DoClick()
		self.refresh:DoClick(self.refresh.current_offset - 1)
	end

	local page_select_number = bar:Add("ContentHeader")
	page_select_number:SetText("1 / 1")
	page_select_number:Dock(RIGHT)
	page_select_number:DockMargin(0, 0, -16, 0)

	function page_select_number:ChangeText(page, total)
		self:SetText(page .. " / " .. total)
	end

	refresh.back_button = page_select_back
	refresh.forward_button = page_select_forward
	refresh.page_text = page_select_number

	local scroll_panel = panel:Add("DScrollPanel")
	scroll_panel:Dock(FILL)
	refresh.scroll_panel = scroll_panel

	local layout = scroll_panel:Add("DIconLayout")
	layout:Dock(FILL)
	layout:SetSpaceY(5)
	layout:SetSpaceX(5)
	refresh.layout = layout

	function refresh:Think()
		local cur = SysTime()

		if self.next_reload > cur then
			return
		end

		self.next_reload = cur + 60 * 10

		self:DoClick()
	end

	function refresh:DoClick(offset)
		layout:Clear()

		local scr = file.Find("screenshots/*", "GAME", "datedesc")
		local total = #scr

		local last
		local k = 0

		local max_page = math.ceil(total / 5)
		offset = math.min(max_page, offset or 1)
		self.current_offset = offset

		for i = (offset - 1) * 5 + 1, math.min(total, offset * 5) do

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

		self.back_button:SetEnabled(offset ~= 1)
		self.forward_button:SetEnabled(offset ~= max_page)
		self.page_text:ChangeText(offset, max_page)

		self.label:SetText(language.GetPhrase("#godsenttools.gallery.name") .. " (" .. k .. " " .. language.GetPhrase("#godsenttools.gallery.screenshots") .. ")")
		
		scroll_panel.VBar:SetScroll(0)
	end

	local function ConVarRefresh()
		refresh:DoClick()
	end

	cvars.AddChangeCallback("godsenttools_gallery_dateformat", ConVarRefresh, "GodSentToolsGallery")

	return panel
end, "icon16/photos.png", 201, "#godsenttools.gallery.name")

