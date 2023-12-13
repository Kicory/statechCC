
TH = {}

--- Check all in parallel
---@param predicate function return boolean, argument is following (each)
function TH.checkPredicate(predicate, ...)
    local functions = {}
    local results = {}
    for k, toCheck in ipairs(table.pack(...)) do
        functions[k] = function() results[k] = predicate(toCheck) end
    end
    parallel.waitForAll(table.unpack(functions))
    return results
end

function TH.checkAll(...)
    local functions = {}
    local results = {}
    for k, toCheck in ipairs(table.pack(...)) do
        functions[k] = function() results[k] = toCheck() end
    end
    parallel.waitForAll(table.unpack(functions))
    return results
end

function TH.allAnd(...)
    local result = true
    for _, v in ipairs(...) do
        result = v and result
    end
    return result
end

function TH.allOr(...)
    local result = false
    for _, v in ipairs(...) do
        result = v or result
    end
    return result
end

function TH.allMax(...)
    local result = nil
    for _, v in ipairs(...) do
        result = math.max(result or v, v)
    end
    return result
end
function TH.allMin(...)
    local result = nil
    for _, v in ipairs(...) do
        result = math.min(result or v, v)
    end
    return result
end


function TH.doMany(toRepeat, repeatCount)
    local functions = {}
    for i = 1, repeatCount do
        functions[#functions + 1] = toRepeat
    end
    parallel.waitForAll(table.unpack(functions))
end