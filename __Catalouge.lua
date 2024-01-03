local Ctlg = {
	ALLOW_KEY_CREATION = 0,
	ERROR_ON_NEW_KEY = 1,
	IGNORE_NEW_KEY = 2
}

local function calcCtlg(ctlg1, ctlg2, func, defaultVal)
	local keyDict = {}
	local resultCtlg = Ctlg:new()
	for k, _ in pairs(ctlg1) do
		keyDict[k] = true
	end
	for k, _ in pairs(ctlg2) do
		keyDict[k] = true
	end
	for k, _ in pairs(keyDict) do
		resultCtlg[k] = func(ctlg1[k] or defaultVal, ctlg2[k] or defaultVal)
	end
	
	return resultCtlg
end

local mt = {
	__index = Ctlg,
	__add = function(ctlg1, ctlg2)
		return calcCtlg(ctlg1, ctlg2, function(a, b) return a + b end, 0)
	end,
	__sub = function(ctlg1, ctlg2)
		return calcCtlg(ctlg1, ctlg2, function(a, b) return a - b end, 0)
	end,
	__mul = function(ctlg1, amt)
		assert(type(amt) == "number")
		local ret = Ctlg:new()
		for k, v in pairs(ctlg1) do
			ret[k] = v * amt
		end
		return ret
	end,
	__div = function(ctlg, other)
		if type(ctlg) == "table" and type(other) == "number" then
			local ret = Ctlg:new()
			for k, v in pairs(ctlg) do
				ret[k] = math.floor(v / other)
			end
			return ret
		elseif type(ctlg) == "table" and type(other) == "table" then
			return ctlg:divWithOffset(other)
		end
		error("Only support division with other ctlg or number " .. debug.traceback())
	end,
	__unm = function(ctlg)
		local ret = ctlg:copy()
		for k, v in pairs(ret) do
			ret[k] = -v
		end
		return ret
	end,
	__eq = function(ctlg, other)
		for k, v in pairs(ctlg) do
			if other[k] == nil or other[k] ~= v then
				return false
			end
		end
		for k, v in pairs(other) do
			if ctlg[k] == nil or ctlg[k] ~= v then
				return false
			end
		end
		return true
	end,
}

function Ctlg:new(o)
	local ret = o or {}
	setmetatable(ret, mt)
	return ret
end

function Ctlg:copy()
	local ret = Ctlg:new()
	for k, v in pairs(self) do
		ret[k] = v
	end
	return ret
end

function Ctlg:map(func)
	for k, v in pairs(self) do
		self[k] = func(k, v)
	end
	return self
end

function Ctlg:divWithOffset(otherCtlg, offset)
	return self:divGeneric(otherCtlg, offset, math.floor)
end

function Ctlg:divGeneric(otherCtlg, offset, roundingFunc)
	local ret = nil
	offset = offset or Ctlg:new()
	for id, amt in pairs(otherCtlg) do
		assert(type(amt) == "number" and amt ~= 0, debug.traceback())
		local singleResult = roundingFunc(((self[id] or 0) + (offset[id] or 0)) / amt)
		ret = math.min(ret or singleResult, singleResult)
	end
	ret = ret or 0
	return ret
end

function Ctlg:filter(pred)
	for k, v in pairs(self) do
		if not pred(k, v) then
			self[k] = nil
		end
	end
	return self
end

function Ctlg:getKeys()
	local keys = {}
	for k in pairs(self) do
		keys[#keys + 1] = k
	end
	return keys
end

function Ctlg:inPlaceFunc(otherCtlg, func, newKeyMode, defaultVal)
	for k, v in pairs(otherCtlg) do
		if self[k] then
			self[k] = func(self[k], v)
		elseif newKeyMode == Ctlg.ALLOW_KEY_CREATION then
			self[k] = func(defaultVal or 0, v)
		elseif newKeyMode == Ctlg.ERROR_ON_NEW_KEY then
			error("New key: " .. k .. " is not allowed.")
		elseif newKeyMode == Ctlg.IGNORE_NEW_KEY then
			-- nothing happens
		else
			error("New key mode error: " .. newKeyMode .. " is not defined mode.")
		end
	end
	return self
end

function Ctlg:inPlaceAdd(otherCtlg, newKeyMode)
	return self:inPlaceFunc(otherCtlg, function(a, b) return a + b end, newKeyMode, 0)
end

function Ctlg:inPlaceSub(otherCtlg, newKeyMode)
	return self:inPlaceFunc(otherCtlg, function(a, b) return a - b end, newKeyMode, 0)
end

return Ctlg