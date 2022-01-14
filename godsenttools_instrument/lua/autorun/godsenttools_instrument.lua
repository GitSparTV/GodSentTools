local HackMeta = {}

HackMeta.ShootSound = Sound( "weapons/ar2/ar2_empty.wav" )

function HackMeta:Reload()
	local ply = self:GetOwner()
	if (not ply:KeyPressed(IN_RELOAD)) then return end
	local trace = ply:GetEyeTrace()
	if (not trace.Hit) then return end
	local tool = self:GetToolObject()
	if (not tool) then return end
	tool:CheckObjects()
	if (not tool:Reload(trace)) then return end
	self:DoShootEffect(trace.HitPos, trace.HitNormal, trace.Entity, trace.PhysicsBone, IsFirstTimePredicted())
end

function HackMeta:PrimaryAttack()
	local trace = self:GetOwner():GetEyeTrace()
	if (not trace.Hit) then return end
	local tool = self:GetToolObject()
	if (not tool) then return end
	tool:CheckObjects()
	if (not tool:LeftClick(trace)) then return end
	self:DoShootEffect(trace.HitPos, trace.HitNormal, trace.Entity, trace.PhysicsBone, IsFirstTimePredicted())
end

function HackMeta:SecondaryAttack()
	local trace = self:GetOwner():GetEyeTrace()
	if (not trace.Hit) then return end
	local tool = self:GetToolObject()
	if (not tool) then return end
	tool:CheckObjects()
	if (not tool:RightClick(trace)) then return end
	self:DoShootEffect(trace.HitPos, trace.HitNormal, trace.Entity, trace.PhysicsBone, IsFirstTimePredicted())
end

local function HackToolguns()
	local wep = weapons.GetStored("gmod_tool")

	for k, v in pairs(HackMeta) do
		wep[k] = v
	end

	wep.GodSentToolsInstrumentHacked = true

	for k, v in ipairs(ents.FindByClass("gmod_tool")) do
		for K, V in pairs(HackMeta) do
			v[K] = V
		end

		v.GodSentToolsInstrumentHacked = true

		do
			local effectdata = EffectData()
			effectdata:SetOrigin(v:GetOwner():EyePos())
			effectdata:SetNormal(v:GetOwner():GetAimVector())
			effectdata:SetMagnitude(3)
			effectdata:SetScale(2)
			effectdata:SetRadius(20)
			util.Effect("Sparks", effectdata)
		end
	end
end

if CLIENT then
	language.Add("godsenttools.instrument.name", "Instrument")
	language.Add("godsenttools.instrument.description", "")
	language.Add("godsenttools.instrument.notsuperadmin", "[GodSent Tools Instrument] You must be a superadmin to use this command.")

	hook.Add("PopulateToolMenu", "GodSentToolsInstrument", function()
		spawnmenu.AddToolMenuOption("Utilities", "#godsenttools.name", "GodSent_Instrument", "#godsenttools.instrument.name", "", "", function(form)
			form:SetName("#godsenttools.instrument.name")
			form:Help("#godsenttools.instrument.description")
			form:Button("#godsenttools.instrument.hackon", "godsenttools_instrument_hack", "1")
			form:Button("#godsenttools.instrument.hackoff", "godsenttools_instrument_hack", "2")
		end)
	end)

	net.Receive("GodSentToolsInstrument", function()
		local event = net.ReadUInt(1)
		if event == 0 then
			HackToolguns()
		end
	end)
else
	util.AddNetworkString("GodSentToolsInstrument")
	concommand.Add("godsenttools_instrument_hack", function(ply, cmd, args, argsStr)
		-- if ply:IsValid() and not ply:IsSuperAdmin() then
			ply:ChatPrint("#godsenttools.instrument.notsuperadmin")

			-- return
		-- end

		HackToolguns()
		net.Start("GodSentToolsInstrument")
		net.WriteUInt(0,1)
		net.Broadcast()
	end)
end