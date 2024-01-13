local Ctlg = require("__Catalouge")

local RecipeObjects = {}
------------------------------------------------------------
-- Mini class Recipe
RecipeObjects.Recipe = {
	PRIO_ULTIMATE = 100,
	PRIO_HIGH = 90,
	PRIO_NORMAL = 80,
	PRIO_LOW = 70,
	PRIO_RELUCTANT = 60,
	PADDING_GOAL = "GOAL",
	PADDING_HALF_GOAL = "HALF_GOAL",
}

local recipeMt = {
	__index = RecipeObjects.Recipe
}

function RecipeObjects.Recipe:new(o)
	assert(o ~= nil)
	setmetatable(o, recipeMt)
	return o
end

function RecipeObjects.Recipe:setPriority(prio)
	self.priority = prio
	return self
end

--- Only materials in idList will counted as output, and used when calculating required crafting
function RecipeObjects.Recipe:filterEffOutput(...)
	local ps = table.pack(...)
	local srcCtlg = self.effUnitOutputCtlg
	local newCtlg = Ctlg:new()
	for _, v in ipairs(ps) do
		newCtlg[v] = srcCtlg[v]
	end
	self.effUnitOutputCtlg = newCtlg
	return self
end

function RecipeObjects.Recipe:setAlwaysProc()
	self.alwaysProc = true
	return self
end

function RecipeObjects.Recipe:setOpportunistic(...)
	self.opportunistic = true
	local ps = table.pack(...)
	for _, mat in ipairs(ps) do
		self.paddingCtlg[mat] = RecipeObjects.Recipe.PADDING_GOAL
	end
	return self
end

function RecipeObjects.Recipe:setPaddings(...)
	local ps = table.pack(...)
	for idx = 1, #ps, 2 do
		assert(type(ps[idx]) == "string", debug.traceback())
		self.paddingCtlg[ps[idx]] = ps[idx + 1]
	end
	return self
end

function RecipeObjects.Recipe:setMaxCount(...)
	local ps = table.pack(...)
	for idx = 1, #ps, 2 do
		assert(type(ps[idx]) == "string", debug.traceback())
		self.maxCount[ps[idx]] = ps[idx + 1]
	end
	return self
end

function RecipeObjects.Recipe:setChainHead(otherChainInputCtlg)
	self.effUnitInputCtlg:inPlaceAdd(otherChainInputCtlg, Ctlg.ALLOW_KEY_CREATION)
	return self
end
------------------------------------------------------------
-- Mini class RecipeList (multiple recipes)
RecipeObjects.RecipeList = { }

local recipeListMt = {
	__index = RecipeObjects.RecipeList
}

function RecipeObjects.RecipeList:new(o)
	assert(o ~= nil)
	assert(table.foreach(o, function(idx, rec) if getmetatable(rec) ~= recipeMt then return false end end) == nil)
	setmetatable(o, recipeListMt)
	return o
end

function RecipeObjects.RecipeList:append(recipe)
	assert(getmetatable(recipe) == recipeMt)
	self[#self + 1] = recipe
end

function RecipeObjects.RecipeList:setPriority(prio)
	for _, r in ipairs(self) do
		r:setPriority(prio)
	end
	return self
end

--- Only materials in idList will counted as output, and used when calculating required crafting
function RecipeObjects.RecipeList:filterEffOutput(...)
	for _, r in ipairs(self) do
		r:filterEffOutput(...)
	end
	return self
end

function RecipeObjects.RecipeList:setAlwaysProc()
	for _, r in ipairs(self) do
		r:setAlwaysProc()
	end
	return self
end

function RecipeObjects.RecipeList:setOpportunistic(...)
	for _, r in ipairs(self) do
		r:setOpportunistic(...)
	end
	return self
end

function RecipeObjects.RecipeList:setPaddings(...)
	for _, r in ipairs(self) do
		r:setPaddings(...)
	end
	return self
end

function RecipeObjects.RecipeList:setMaxCount(...)
	for _, r in ipairs(self) do
		r:setMaxCount(...)
	end
	return self
end

function RecipeObjects.RecipeList:setChainHead(otherChainInputCtlg)
	for _, r in ipairs(self) do
		r:setChainHead(otherChainInputCtlg)
	end
	return self
end
------------------------------------------------------------
return RecipeObjects