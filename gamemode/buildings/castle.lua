-- A function to grab the name
function ENT:GetOviasName()
	return "Kingdom Castle"
end

-- A function to get a table of general info
function ENT:GetInfo()
	return {
		["desc"] = "The central hub of your your territory."
	}
end

-- A function to return a requirements object
function ENT:SetupRequirements(req)
	req:AddFunction(function(faction, trace, ghost)
		if (table.Count(faction:GetBuildings()) <= 0) then
			return false, "Already have a castle"
		end
	end)
end

-- A function to grab the model the building uses
function ENT:GetOviasModel()
	return "models/roller.mdl"
end

-- A function to grab the time it takes to build the building in seconds
function ENT:GetBuildTime()
	return 10
end

-- Called before a building starts being built
function ENT:PreBuild()
end

-- Called per-tick during the build stage
function ENT:Build()
end

-- Called after the building has been completed
function ENT:PostBuild()
	self.territory = SF.Territory:Create(self:GetFaction(), self:GetPos(), 240)
end

-- Called before the building is demolished
function ENT:PreDestruction()
end

-- Called after the building has been demolished
function ENT:PostDestruction()
	self.territory:Remove()
end