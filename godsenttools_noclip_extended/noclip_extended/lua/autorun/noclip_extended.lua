do
	local FrameTime = FrameTime

	hook.Add("Move", "NoclipExtended", function(ply, mv)
		if ply:GetMoveType() ~= 8 then return end -- MOVETYPE_NOCLIP

		ply:ViewPunchReset()

		local factor = 20

		if mv:KeyDown(131072) then -- IN_SPEED
			factor = 10000 / 1500
		elseif mv:KeyDown(4) then -- IN_DUCK
			factor = 200
		end

		local MA = mv:GetMoveAngles()
		local result, R = MA:Forward(), MA:Right()

		result:Normalize()
		R:Normalize()

		result:Mul(mv:GetForwardSpeed() / factor)
		R:Mul(mv:GetSideSpeed() / factor)

		result:Add(R)

		if mv:KeyDown(2) then -- IN_JUMP
			result[3] = result[3] + (mv:KeyDown(262144) and -1 or 1) * 10000 / factor -- IN_WALK
		end

		mv:SetVelocity(result)

		result:Mul(FrameTime())

		do
			local o = mv:GetOrigin()

			o:Add(result)
			mv:SetOrigin(o)
		end

		return true
	end)
end