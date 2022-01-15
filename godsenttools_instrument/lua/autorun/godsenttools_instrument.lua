local HackMeta = {}
local Backup = {}

HackMeta.ShootSound = Sound( "weapons/ar2/ar2_empty.wav" )

function HackMeta:Reload()
	local ply = self:GetOwner()

	if not ply:KeyPressed(IN_RELOAD) then
		return
	end

	local trace = ply:GetEyeTrace()

	if not trace.Hit then
		return
	end

	local tool = self:GetToolObject()

	if not tool then
		return
	end

	tool:CheckObjects()

	if not tool:Reload(trace) then
		return
	end

	self:DoShootEffect(trace.HitPos, trace.HitNormal, trace.Entity, trace.PhysicsBone, IsFirstTimePredicted())
end

function HackMeta:PrimaryAttack()
	local trace = self:GetOwner():GetEyeTrace()

	if not trace.Hit then
		return
	end

	local tool = self:GetToolObject()

	if not tool then
		return
	end

	tool:CheckObjects()

	if not tool:LeftClick(trace) then
		return
	end

	self:DoShootEffect(trace.HitPos, trace.HitNormal, trace.Entity, trace.PhysicsBone, IsFirstTimePredicted())
end

function HackMeta:SecondaryAttack()
	local trace = self:GetOwner():GetEyeTrace()

	if not trace.Hit then
		return
	end

	local tool = self:GetToolObject()

	if not tool then
		return
	end

	tool:CheckObjects()

	if not tool:RightClick(trace) then
		return
	end

	self:DoShootEffect(trace.HitPos, trace.HitNormal, trace.Entity, trace.PhysicsBone, IsFirstTimePredicted())
end

local function HackToolguns()
	local wep = weapons.GetStored("gmod_tool")

	if wep.GodSentToolsInstrumentHacked then
		return
	end

	for k, v in pairs(HackMeta) do
		Backup[k] = wep[k]
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

local function RevertToolguns()
	local wep = weapons.GetStored("gmod_tool")

	if not wep.GodSentToolsInstrumentHacked then
		return
	end

	for k, v in pairs(HackMeta) do
		wep[k] = Backup[k]
	end

	wep.GodSentToolsInstrumentHacked = false

	for k, v in ipairs(ents.FindByClass("gmod_tool")) do
		for K, V in pairs(HackMeta) do
			v[K] = Backup[k]
		end

		v.GodSentToolsInstrumentHacked = false

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
	language.Add("godsenttools.instrument.description", "description")
	language.Add("godsenttools.instrument.hackon", "On")
	language.Add("godsenttools.instrument.hackoff", "Off")
	language.Add("godsenttools.instrument.notsuperadmin", "[GodSentTools Instrument] You must be a superadmin to use this command.")

	hook.Add("PopulateToolMenu", "GodSentToolsInstrument", function()
		spawnmenu.AddToolMenuOption("Utilities", "#godsenttools.name", "GodSentTools_Instrument", "#godsenttools.instrument.name", "", "", function(form)
			form:SetName("#godsenttools.instrument.name")
			form:Help("#godsenttools.instrument.description")
			form:Button("#godsenttools.instrument.hackon", "godsenttools_instrument_hack", "1")
			form:Button("#godsenttools.instrument.hackoff", "godsenttools_instrument_hack", "0")
		end)
	end)

	net.Receive("GodSentToolsInstrument", function()
		local event = net.ReadUInt(1)

		if event == 1 then
			HackToolguns()
		else
			RevertToolguns()
		end
	end)
else
	util.AddNetworkString("GodSentToolsInstrument")

	concommand.Add("godsenttools_instrument_hack", function(ply, cmd, args, argsStr)
		if ply:IsValid() and not ply:IsSuperAdmin() then
			ply:ChatPrint("#godsenttools.instrument.notsuperadmin")

			return
		end

		if args[1] == "1" then
			HackToolguns()
		else
			RevertToolguns()
		end

		net.Start("GodSentToolsInstrument")
		net.WriteUInt(args[1],1)
		net.Broadcast()
	end)
end