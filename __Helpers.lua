local Ctlg = require("__Catalouge")
local Helper = {}

function Helper.serializeTable(val, name, skipnewlines, depth)
	skipnewlines = skipnewlines or false
	depth = depth or 0

	local tmp = string.rep(" ", depth)

	if name then tmp = tmp .. name .. " = " end

	if type(val) == "table" then
		tmp = tmp .. "{" .. (not skipnewlines and "\n" or "")

		for k, v in pairs(val) do
			if (k ~= "wrapped") then
				tmp =  tmp .. Helper.serializeTable(v, k, skipnewlines, depth + 1) .. "," .. (not skipnewlines and "\n" or "")
			end
		end

		tmp = tmp .. string.rep(" ", depth) .. "}"
	elseif type(val) == "number" then
		tmp = tmp .. tostring(val)
	elseif type(val) == "string" then
		tmp = tmp .. string.format("%q", val)
	elseif type(val) == "boolean" then
		tmp = tmp .. (val and "true" or "false")
	else
		tmp = tmp .. "\"[" .. type(val) .. "]\""
	end

	return tmp
end

function Helper.printPretty(content)
	local str
	if (type(content) == "table") then
		str = Helper.serializeTable(content)
	elseif type(content) == "string" then
		str = content
	else 
		str = tostring(content)
	end
	local x, y = term.getSize()
	print(string.rep("-", x))
	textutils.pagedPrint(str, y - 15)
	print(string.rep("-", x))
end

function Helper.concatListInPlace(list, ...)
	for _, v in ipairs(table.pack(...)) do
		list[#list + 1] = v
	end
end

function Helper.round(a)
	return math.floor(a + 0.5)
end

function Helper.tickFrom(cur)
	return Helper.round((os.clock() - cur) * 20)
end

function Helper.printRowOf(widthRatios, backColors, textColors, contents, monitor)
	local x, y = monitor.getCursorPos()
	local xx, yy = monitor.getSize()
	local widths = {}
	for _, r in ipairs(widthRatios) do
		widths[#widths + 1] = math.floor((xx - x) * r)
	end
	local lastTextCol, lastBackCol
	for idx, wid in ipairs(widths) do
		wid = wid - 1
		local c = tostring(contents[idx]) or ""
		local contWid = math.min(#c, wid)
		local spaceWid = wid - #c
		local textCol = textColors[idx] or lastTextCol
		local backCol = backColors[idx] or lastBackCol
		monitor.setTextColor(textCol)
		monitor.setBackgroundColor(backCol)
		monitor.write(" ")
		monitor.write(string.sub(c, 1, contWid))
		monitor.write(string.rep(" ", spaceWid))
		monitor.setTextColor(colors.white)
		monitor.setBackgroundColor(colors.black)
		-- if idx == 1 then
		-- 	monitor.write("|")
		-- end
		lastTextCol = textCol
		lastBackCol = backCol
	end
	monitor.setCursorPos(x, y + 1)
end

function Helper.dispNameMaker(id)
	local colonPos, _ = string.find(id, ':')
	local unColoned
	
	if colonPos then
		unColoned = string.sub(id, colonPos + 1, #id)
	else
		unColoned = id
	end

	return string.gsub('_' .. unColoned, "_(.)", function(c) return ' ' .. string.upper(c) end):sub(2)
end

function Helper.makeMultipliedIO(io, factor)
	local ret = {}
	ret.item = {}
	ret.fluid = {}
	for id, amt in pairs(io.item or {}) do
		ret.item[id] = amt * factor
	end
	for id, amt in pairs(io.fluid or {}) do
		ret.fluid[id] = amt * factor
	end
	return ret
end

function Helper.getIdOf(material, template, itemIdIndex)
	return itemIdIndex[string.gsub(template, "%%m", material)]
end

--- Create long, flatten list of ItemIDs, by combination of "materials" and "templates".
---@param materials table material list
---@param templates table template list (mark place to substitute with material name by '%m')
---@param itemIdIndex table full ItemID table.
---@return table 
--- The length of returning table(list) is always same: #materials * #templates (no nil value).
--- If there is no item, then the place is marked with "false".
function Helper.makeIDListOver(materials, templates, itemIdIndex)
	local ret = {}
	for _, m in ipairs(materials) do
		for _, t in ipairs(templates) do
			-- Give boolean "false" if item ID is not exist
			ret[#ret + 1] = Helper.getIdOf(m, t, itemIdIndex) or false
		end
	end
	return ret
end


function Helper.IO2Catalogue(IO)
	local ret = Ctlg:new()
	for itemID, count in pairs(IO.item or {}) do
		ret[itemID] = count
	end
	for fluidID, amt in pairs(IO.fluid or {}) do
		ret[fluidID] = amt
	end
	return ret
end

return Helper