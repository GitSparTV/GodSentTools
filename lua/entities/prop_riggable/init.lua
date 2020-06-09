AddCSLuaFile("shared.lua")
AddCSLuaFile("cl_init.lua")
include("shared.lua")

function ENT:Initialize()
	self:SetModel("models/Kleiner.mdl")
	self:PhysicsInit(SOLID_OBB)
end

