do
		language.Add("godsenttools.graphicsprofile.name", "Graphics Profile")
		language.Add("godsenttools.graphicsprofile.description", "\"Graphics Profile\" allows you to switch additional graphics settings with profiles in the runtime.")
		language.Add("godsenttools.graphicsprofile.folder", "Profiles can be added in \"data/gotsenttools_graphicsprofile/\" folder.\nThe first line should start from \"//\", this is a display name.")
		language.Add("godsenttools.graphicsprofile.svcheats", "Note:\n    Some console commands commands can't be run by Graphics Profile in multiplayer unless sv_cheats is 1.")
	end

	file.CreateDir("gotsenttools_graphicsprofile")

	if not file.Exists("gotsenttools_graphicsprofile/ultra.dat", "DATA") then
		file.Write("gotsenttools_graphicsprofile/ultra.dat", "a") --[[ util.Decompress("")--]]
	end

	if not file.Exists("gotsenttools_graphicsprofile/default.dat", "DATA") then
		file.Write("gotsenttools_graphicsprofile/default.dat", "a") --[[ util.Decompress("")--]]
	end

	hook.Add("PopulateToolMenu", "GodSentToolsGraphicsProfile", function()
		spawnmenu.AddToolMenuOption("Utilities", "GodSent Tools", "GotSent_Graphics_Profile", "#godsenttools.graphicsprofile.name", "", "", function(form)
			form:SetName("#godsenttools.graphicsprofile.name")
			form:Help("#godsenttools.graphicsprofile.description")
			local reload = vgui.Create("DButton")
			reload:SetText("Refresh the list")
			reload:SetIcon("icon16/arrow_refresh.png")
			form:AddItem(reload)
			local list = vgui.Create("DListView")
			list:SetMultiSelect(false)
			list:AddColumn("Profiles")
			list:SetTall(100)
			form:AddItem(list)
			form:Help("#godsenttools.graphicsprofile.folder")

			local function ReloadList()
				for k, v in ipairs(file.Find("gotsenttools_graphicsprofile/*.dat", "DATA")) do
					local f = file.Open("gotsenttools_graphicsprofile/" .. v, "r", "DATA")

					if f then
						local name = f:ReadLine()

						if name:sub(1, 2) == "//" then
							list:AddLine(name:sub(3):match("^%s*(.-)%s*$")).file = v
						end

						f:Close()
					end
				end
			end

			ReloadList()
			local apply = vgui.Create("DButton")

			function reload:DoClick()
				list:Clear()
				apply:SetEnabled(false)
				ReloadList()
			end

			apply:SetText("Select profile")
			apply:SetIcon("icon16/control_play.png")
			apply:SetEnabled(false)
			form:AddItem(apply)

			local function Run(name)
				local f = file.Open("gotsenttools_graphicsprofile/" .. name, "r", "DATA")

				if not f then
					chat.AddText("File not found")
					goto close
				end

				do
					f:ReadLine()
					local lines = { }

					for l in f.ReadLine,f do
						local cmd, val = string.match(l, "^(.-)%s(.+)$")

						if cmd then
							lines[#lines + 1] = { cmd, val }
						end
					end


					f:Close()
					local len = #lines

					for k = 1, len do
						RunConsoleCommand(lines[k][1], lines[k][2])
						coroutine.yield(k, len, (lines[k][1] .. " " .. lines[k][2]):sub(1, -2))
					end
				end

				::close::
				hook.Remove("PostRenderVGUI", "GodSentToolsGraphicsProfile")
			end

			function apply:DoClick()
				if not self.file then
					chat.AddText("File not found")

					return
				end

				local start = SysTime()
				surface.SetFont("DermaLarge")
				local worker = coroutine.wrap(Run)
				local text = "Applying " .. self.name .. " profile..."
				local len, h = surface.GetTextSize(text)
				local current, total, command = 0, 1
				len, h = len / 2, h / 2

				hook.Add("PostRenderVGUI", "GodSentToolsGraphicsProfile", function()
					render.Clear(0,0,0,0)
					surface.SetFont("DermaLarge")
					surface.SetTextColor(255, 255, 255)
					surface.SetTextPos(ScrW() / 2 - len, ScrH() / 2 - h)
					surface.DrawText(text)
					surface.SetDrawColor(100, 100, 100)
					surface.DrawRect(ScrW() / 2 - 200, ScrH() / 2 + h + 20, 400, 20)
					surface.SetDrawColor(255, 255, 255)
					surface.DrawRect(ScrW() / 2 - 200, ScrH() / 2 + h + 20, (current / total) * 400, 20)

					if command then
						local t = "\"" .. command .. "\" (" .. current .. " / " .. total .. ")"
						local Llen = surface.GetTextSize(t)
						surface.SetTextPos(ScrW() / 2 - Llen / 2, ScrH() / 2 + h + 50)
						surface.DrawText(t)
					end

					if SysTime() - start > 2 then
						current, total, command = worker(self.file)
					end
				end)
			end

			function list:OnRowSelected(_, row)
				apply:SetText("Run " .. row:GetColumnText(1) .. " profile")
				apply:SetEnabled(true)
				apply.file = row.file
				apply.name = row:GetColumnText(1)
			end

			form:Help("#godsenttools.graphicsprofile.svcheats")
		end)
	end)