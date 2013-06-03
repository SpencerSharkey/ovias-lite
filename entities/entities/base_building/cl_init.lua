--[[
	Ovias
	Copyright © Slidefuse LLC - 2012
]]--

include("shared.lua")

function ENT:Initialize()

	self.foundationMatrix = Matrix()
	self:CalculateFoundation()

	self.modelMins, self.modelMaxs = self:OBBMins(), self:OBBMaxs()
	self.isBuilding = false
	self.isBuilt = false

	self:SharedInit()
end

local mFoundation = CreateMaterial("ovFoundation1", "VertexLitGeneric", {
	["$basetexture"] = "nature/dirtwall001a",
	["$model"] = 1
})

local mWire = Material("models/wireframe")

function ENT:Draw()

	--Draw foundation
	render.SetMaterial(mFoundation)

	self.foundationMatrix:SetAngles(self:GetAngles())
	self.foundationMatrix:SetTranslation(self:GetPos())

	render.SuppressEngineLighting(true)
	cam.PushModelMatrix(self.foundationMatrix)
		self.foundationMesh:Draw()
	cam.PopModelMatrix()
	render.SuppressEngineLighting(false)
	--

	--Building Rendering
	if (self.isBuilding) then
		local buildProgress = self.buildProgress
		local height = self.modelMaxs.z
		local clipHeight = (buildProgress/100)*height

		local clipNormal = Vector(0, 0, -1)
		local distance = clipNormal:Dot(Vector(0, 0, self:GetPos().z + clipHeight))
		render.MaterialOverride("")
		render.EnableClipping(true)
			render.PushCustomClipPlane(clipNormal, distance)
			self:DrawModel()
			render.PopCustomClipPlane()
		render.EnableClipping(false)

		render.MaterialOverride(mWire)

		local clipNormal = Vector(0, 0, 1)
		local distance = clipNormal:Dot(Vector(0, 0, self:GetPos().z + clipHeight))
		render.MaterialOverride(mWire)
		render.EnableClipping(true)
			render.PushCustomClipPlane(clipNormal, distance)
			self:DrawModel()
			render.PopCustomClipPlane()
		render.EnableClipping(false)
		render.MaterialOverride(false)
	else
		self:DrawModel()
	end

end

function ENT:Think()

	if (self.isBuilding) then
		self.buildProgress = 100-(((self.endBuildTime - CurTime())/self:GetBuildTime())*100)
		if (CurTime() >= self.endBuildTime) then
			self.isBuilding = false
			self.isBuilt = true
		end
	end

end

netstream.Hook("ovB_StartBuild", function(data)
	local ent = data.ent
	ent.startBuildTime = CurTime()
	ent.endBuildTime = CurTime() + ent:GetBuildTime()
	ent.isBuilding = true
end)

netstream.Hook("ovB_PauseBuild", function(data)
	local ent = data.ent
	ent.isBuilding = false
	ent.buildTimeLeft = ent.endBuildTime - CurTime()
end)

netstream.Hook("ovB_UnPauseBuild", function(data)
	local ent = data.ent
	ent.isBuilding = true
	ent.endBuildTime = CurTime() + ent.buildTimeLeft
	ent.buildTimeLeft = nil
end)