util.AddNetworkString("GodSentToolsLocRotScale")
local ceiloor = TOOL.ceiloor

net.Receive("GodSentToolsLocRotScale", function(len, ply)
	local swep = ply:GetActiveWeapon()
	if not swep:IsValid() then return end
	local tool = swep:GetToolObject()
	if not tool then return end
	local event = net.ReadUInt(1)

	if event == 0 then
		local ent = net.ReadEntity()
		if not ent:IsValid() then return end
		local bonen = net.ReadUInt(8)
		tool:SetTargetEntity(ent, bonen)
	end
end)

local function BoneToPhysBone(ent, bone)
	for i = 0, ent:GetPhysicsObjectCount() - 1 do
		local b = ent:TranslatePhysBoneToBone(i)
		if bone == b then return i end
	end

	return nil
end

local function SetBoneOffsets(ent,ostable,sbone)
	local RTable = {}
	RTable[0] = {}
	RTable[0].pos = ostable[0].pos
	RTable[0].ang = ostable[0].ang
	if sbone.b == 0 then
		RTable[0].pos = sbone.p
		RTable[0].ang = sbone.a
	end
	for i=1,ent:GetBoneCount()-1 do
		local pb = BoneToPhysBone(ent,i)
		if ostable[pb] then
			local parent = ostable[pb].parent
			local bn = ent:GetBoneName(i)
			local ppos,pang = RTable[parent].pos,RTable[parent].ang
			local pos,ang = LocalToWorld(ostable[pb].pos,ostable[pb].ang,ppos,pang)
			if pb == sbone.b then
				pos = sbone.p
				ang = sbone.a
			end
			RTable[pb] = {}
			RTable[pb].pos = pos*1
			RTable[pb].ang = ang*1
		end
	end
	return RTable
end

local function SetOffsets(tool,ent,ostable,physbone, physpos, physang)
	
	local postable = SetBoneOffsets(ent,ostable,{b = physbone,p = physpos,a = physang})

	for i=0,ent:GetPhysicsObjectCount()-1 do
		if postable[i] and !postable[i].dontset then
			local obj = ent:GetPhysicsObjectNum(i)
			-- postable[i].pos.x = math.Round(postable[i].pos.x,3)
			-- postable[i].pos.y = math.Round(postable[i].pos.y,3)
			-- postable[i].pos.z = math.Round(postable[i].pos.z,3)
			-- postable[i].ang.p = math.Round(postable[i].ang.p,3)
			-- postable[i].ang.y = math.Round(postable[i].ang.y,3)
			-- postable[i].ang.r = math.Round(postable[i].ang.r,3)
			
			local poslen = postable[i].pos:Length();
			local anglen = Vector(postable[i].ang.p,postable[i].ang.y,postable[i].ang.r):Length();
			
			//Temporary solution for INF and NaN decimals crashing the game (Even rounding doesnt fix it)
			if poslen > 2 and anglen > 2 then
				obj:EnableMotion(true)
				obj:Wake()
				obj:SetPos(postable[i].pos)
				obj:SetAngles(postable[i].ang)
				obj:EnableMotion(false)
				obj:Wake()
			end
		end
	end
end

do
	local ToDegVector, DegToAngle = Vector(), Angle()
	local vector_origin, WorldToLocal, utilIntersectRayWithPlane, IN_ATTACK, IN_SPEED, LocalToWorld = vector_origin, WorldToLocal, util.IntersectRayWithPlane, IN_ATTACK, IN_SPEED, LocalToWorld

	function TOOL:RotateThink(E)
		local ply = self:GetOwner()
		local EPos = self.BonePos
		local RotationDirAng = self.RotationDirAng
		local temp

		do
			local t = ply:GetEyeTrace()
			local intersect = utilIntersectRayWithPlane(t.StartPos, t.Normal, EPos, self.RotationDir)

			if not intersect then
				goto skip
			end

			temp = WorldToLocal(intersect, angle_zero, EPos, RotationDirAng)
		end

		do
			local ToDegVector = ToDegVector
			ToDegVector:SetUnpacked(temp[2], temp[3], 0)
			temp = ToDegVector:Angle()[2]
		end

		if ply:KeyDown(IN_SPEED) then
			temp = self.RotationStartSnapOffset + ceiloor(temp * 0.2) * 5
		end

		DegToAngle:SetUnpacked(0, 0, temp)

		do
			local ang
			temp, ang = LocalToWorld(vector_origin, DegToAngle, EPos, RotationDirAng)
			temp, ang = LocalToWorld(vector_origin, self.RotationStartAng, EPos, ang)

			-- p:SetPos(temp)
			if not self.TargetBoneMode then
				local p = E:GetPhysicsObject()
				p:EnableMotion(true)
				p:Wake()
				self.TargetEntity:ManipulateBoneAngles(self.TargetBone, ang)
				p:EnableMotion(false)
				p:Wake()

			else
				local p = self.TargetPhys
				p:EnableMotion(true)
				p:Wake()
				p:SetAngles(ang)
				-- p:SetPos(temp)
				p:EnableMotion(false)
				p:Wake()

				SetOffsets(self, self.TargetEntity, self.PhysBoneOffsetsKeys, self.TargetPhysBone, p:GetPos(), ang)
			end
		end

		::skip::

		if not ply:KeyDown(IN_ATTACK) then
			self:RotateEnd()
		end
	end
end

do
	local BonePosCache, BoneAngCache

	function TOOL:CacheBone(E)
		local bone = self.TargetBone

		if self.TargetBoneMode then
			local P, A = self.TargetPhys:GetPos(), self.TargetPhys:GetAngles()
			self.BonePos, self.BoneAng, self.BoneScale = P, A, E:GetManipulateBoneScale(bone)
			local RP, RA = P ~= BonePosCache, A ~= BoneAngCache

			if self.RefreshCache then
				self.RefreshCache = false
				RP, RA = true, true
			end

			if RP or RA then
				net.Start("GodSentToolsLocRotScale")
				net.WriteEntity(self.SWEP)
				net.WriteUInt(4, 3)
				net.WriteUInt((RP and 1 or 0) + (RA and 2 or 0), 2)

				if RP then
					BonePosCache = P
					net.WriteVector(P)
				end

				if RA then
					BoneAngCache = A
					-- local x,y,z = A:Unpack()
					-- net.WriteFloat(x)
					-- net.WriteFloat(y)
					-- net.WriteFloat(z)
					net.WriteAngle(A)
				end

				net.Send(self:GetOwner())
			end
		else
			local P = E:GetBonePosition(bone)

			if P == E:GetPos() then
				local m = E:GetBoneMatrix(bone)
				P = m:GetTranslation()
			end

			P:Add(E:GetManipulateBonePosition(bone))
			-- A:Add(E:GetManipulateBoneAngles(bone))
			local A = E:GetManipulateBoneAngles(bone)
			-- debugoverlay.Cross(P,10,5)
			self.BonePos, self.BoneAng, self.BoneScale = P, A, E:GetManipulateBoneScale(bone)
			-- local RP, RA = P ~= BonePosCache, A ~= BoneAngCache
			-- if self.RefreshCache then
			-- 	self.RefreshCache = false
			-- 	RP, RA = true, true
			-- end
			-- if RP or RA then
			-- 	net.Start("GodSentToolsLocRotScale", true)
			-- 	net.WriteEntity(self.SWEP)
			-- 	net.WriteUInt(4, 3)
			-- 	net.WriteUInt((RP and 1 or 0) + (RA and 2 or 0), 2)
			-- 	if RP then
			-- 		BonePosCache = P
			-- 		net.WriteVector(P)
			-- 	end
			-- 	if RA then
			-- 		BoneAngCache = A
			-- 		net.WriteAngle(A)
			-- 	end
			-- 	net.Send(self:GetOwner())
			-- end
		end
	end
end

local function GetPhysBoneParent(ent, bone)
	if not bone then return nil end
	local b = ent:TranslatePhysBoneToBone(bone)
	local pb
	local cont = false
	local i = 1

	while i < 256 do
		b = ent:GetBoneParent(b)
		local parent = BoneToPhysBone(ent, b)
		if parent and parent ~= bone then return parent end
		i = i + 1
	end

	return nil
end

do
	local PhysCache, PhysIDs = { }, { }

	function TOOL:CachePhys(ent)
	local RTable = {}
	
	RTable[0] = {}
	RTable[0].pos = ent:GetPhysicsObjectNum(0):GetPos()
	RTable[0].ang = ent:GetPhysicsObjectNum(0):GetAngles()
	RTable[0].moving = ent:GetPhysicsObjectNum(0):IsMoveable()
	
	for i=1,ent:GetBoneCount()-1 do
		local pb = BoneToPhysBone(ent,i)
		local parent = GetPhysBoneParent(ent,pb)
		if pb and pb != 0 and parent and !RTable[pb] then
			local obj1 = ent:GetPhysicsObjectNum(pb)
			debugoverlay.Text( obj1:GetPos(), pb, 5)
			local obj2 = ent:GetPhysicsObjectNum(parent)
			local pos1,ang1 = obj1:GetPos(),obj1:GetAngles()
			local pos2,ang2 = obj2:GetPos(),obj2:GetAngles()
			local pos3,ang3 = WorldToLocal(pos1,ang1,pos2,ang2)
			local mov = obj1:IsMoveable()
			RTable[pb] = {pos = pos3,ang = ang3,moving = mov,parent = parent}
		end
	end
		self.PhysBoneOffsetsKeys = RTable
	end
end

do
	function TOOL:Think()
		local E = self.TargetEntity

		if E then
			if not E:IsValid() then
				self:SetOperation(0)
				self.TargetEntity = nil
				self.TargetBone = nil

				return
			else
				self:CacheBone(E)
			end
		end

		if self.Pressed then
			local op = self:GetOperation()

			--[[ 			if op == 1 then

			else--]]
			if op == 2 then
				self:RotateThink(self.TargetEntity)
				-- elseif op == 3 then
			end
		end
	end
end

function TOOL:Deploy()
	self.RefreshCache = true
end
--[[
if self:GetOwner():KeyDown(IN_SPEED) then
	local Sang = self.RotationStartGrabAng
	local SangS = self.RotationStartGrabAngSnapped
	if ang[1] ~= Sang[1] then
		ang[1] = math.NormalizeAngle(SangS[1] + ceiloor(ang[1] * 0.2) * 5)
	end
	if ang[2] ~= Sang[2] then
		ang[2] = math.NormalizeAngle(SangS[2] + ceiloor(ang[2] * 0.2) * 5)
	end
	if ang[3] ~= Sang[3] then
		ang[3] = math.NormalizeAngle(SangS[3] + ceiloor(ang[3] * 0.2) * 5)
	end
end
]]