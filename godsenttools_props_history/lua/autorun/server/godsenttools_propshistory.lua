util.AddNetworkString("GodSentToolsPropsHistory")

local function AddPropHistory(ply, model, ent)
	net.Start("GodSentToolsPropsHistory")
	net.WriteString(model)
	net.WriteUInt(ent:GetSkin(), 8)

	for i = 0, 8 do
		net.WriteUInt(ent:GetBodygroup(i) or 0, 4)
	end

	net.Send(ply)
end

hook.Add("PlayerSpawnedProp", "GodSentToolsPropsHistory", AddPropHistory)
hook.Add("PlayerSpawnedRagdoll", "GodSentToolsPropsHistory", AddPropHistory)