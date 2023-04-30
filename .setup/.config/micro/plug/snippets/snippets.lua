VERSION = "0.2.0"

local micro = import("micro")
local buffer = import("micro/buffer")
local config = import("micro/config")
local util = import("micro/util")

local debugflag = true
local curFileType = ""
local snippets = {}
local currentSnippet = nil
local RTSnippets = config.NewRTFiletype()

local Location = {}
Location.__index = Location

local Snippet = {}
Snippet.__index = Snippet

-- Snippets
--      --> Snippet
--                --> Location

function Location.new(idx, ph, snippet)
	debug1("Location.new(idx, ph, snip) idx = " , idx)
	--debugt("Location.new(idx, ph, snip) ph = ", ph)
	--debugt("Location.new(idx, ph, snippet) snippet = ", snippet)	

	local self = setmetatable({}, Location)
	self.idx = idx
	self.ph = ph
	self.snippet = snippet
	return self
end

-- offset of the location relative to the snippet start
function Location.offset(self)
	debug("Location.offset(self)")
	local add = 0
	for i = 1, #self.snippet.locations do
		local loc = self.snippet.locations[i]
		debug1("loc = ",loc)
		if loc == self then
			break
		end

		local val = loc.ph.value
        micro.Log("VAL", val)
		if val then
			add = add + val:len()
		end
	end
	return self.idx+add
end

function Location.startPos(self)
	--debugt("Location.startPos(self) = ",self)
	local loc = self.snippet.startPos
	return loc:Move(self:offset(), self.snippet.view.buf)
end

-- returns the length of the location (but at least 1)
function Location.len(self)
	debug("Location.len(self)")
	local len = 0
	if self.ph.value then
		len = self.ph.value:len()
	end
	if len <= 0 then
		len = 1
	end
	return len
end

function Location.endPos(self)
	debug("Location.endPos(self)")
	local start = self:startPos()
    micro.Log("ENDPOS", self.ph.value)
	return start:Move(self:len(), self.snippet.view.buf)
end

-- check if the given loc is within the location
function Location.isWithin(self, loc)
	debug("Location.isWithin(self, loc)")
	return loc:GreaterEqual(self:startPos()) and loc:LessEqual(self:endPos())
end

function Location.focus(self)
	debug("Location.focus(self)")
	local view = self.snippet.view
	local startP = self:startPos():Move(-1, view.Buf)
	local endP = self:endPos():Move(-1, view.Buf)
    micro.Log(startP, endP)

    if view.Cursor:LessThan(startP) then
        while view.Cursor:LessThan(startP) do
            view.Cursor:Right()
        end
    elseif view.Cursor:GreaterEqual(endP) then
        while view.Cursor:GreaterEqual(endP) do
            view.Cursor:Left()
        end
    end

	if self.ph.value:len() > 0 then
		view.Cursor:SetSelectionStart(startP)
		view.Cursor:SetSelectionEnd(endP)
	else
		view.Cursor:ResetSelection()
	end
end

function Location.handleInput(self, ev)
	debug("Location.handleInput(self, ev)")
	if ev.EventType == 1 then
		-- TextInput
		if util.String(ev.Deltas[1].Text) == "\n" then
			Accept()
			return false
		else
			local offset = 1
			local sp = self:startPos()
			while sp:LessEqual(-ev.Deltas[1].Start) do
				sp = sp:Move(1, self.snippet.view.Buf)
				offset = offset + 1
			end

			self.snippet:remove()
			local v = self.ph.value
			if v == nil then
				v = ""
			end

			self.ph.value = v:sub(0, offset-1) .. util.String(ev.Deltas[1].Text) .. v:sub(offset)
			self.snippet:insert()
			return true
		end
	elseif ev.EventType == -1 then
		-- TextRemove
		local offset = 1
		local sp = self:startPos()
		while sp:LessEqual(-ev.Deltas[1].Start) do
			sp = sp:Move(1, self.snippet.view.Buf)
			offset = offset + 1
		end

		if ev.Deltas[1].Start.Y ~= ev.Deltas[1].End.Y then
			return false
		end

		self.snippet:remove()

		local v = self.ph.value
		if v == nil then
			v = ""
		end

		local len = ev.Deltas[1].End.X - ev.Deltas[1].Start.X

		self.ph.value = v:sub(0, offset-1) .. v:sub(offset+len)
		self.snippet:insert()
		return true
	end

	return false
end

-- new snippet 
function Snippet.new()
	debug("Snippet.new()")
	local self = setmetatable({}, Snippet)
	self.code = ""
	return self
end

-- add line of code to snippet
function Snippet.AddCodeLine(self, line)
	--debugt("Snippet.AddCodeLine(self,line) self = " , self)
	debug1("Snippet.AddCodeLine(self, line) line = " , line)
	if self.code ~= "" then
		self.code = self.code .. "\n"
	end
	self.code = self.code .. line
end

function Snippet.Prepare(self)
	debug("Snippet.Prepare(self)")
	if not self.placeholders then
		self.placeholders = {}
		self.locations = {}
		local count = 0
		local pattern = "${(%d+):?([^}]*)}"
		while true do
			local num, value = self.code:match(pattern)
			if not num then
				break
			end
			count = count+1
			num = tonumber(num)
			local idx = self.code:find(pattern)
			self.code = self.code:gsub(pattern, "", 1)
            micro.Log("IDX", idx, self.code)

			local placeHolders = self.placeholders[num]
			if not placeHolders then
				placeHolders = {num = num}
				self.placeholders[#self.placeholders+1] = placeHolders
			end
			self.locations[#self.locations+1] = Location.new(idx, placeHolders, self)
			debug1("location total = ",#self.locations)
			if value then
				placeHolders.value = value
			end
		end
	end
end

function Snippet.clone(self)
	debug("Snippet.clone(self)")
	local result = Snippet.new()
	result:AddCodeLine(self.code)
	result:Prepare()
	return result
end

function Snippet.str(self)
	debug("Snippet.str(self)")
	local res = self.code
	for i = #self.locations, 1, -1 do
		local loc = self.locations[i]
		res = res:sub(0, loc.idx-1) .. loc.ph.value .. res:sub(loc.idx)
	end
	return res
end

function Snippet.findLocation(self, loc)
	debug1("Snippet.findLocation(self, loc) loc = ",loc)
	for i = 1, #self.locations do
		if self.locations[i]:isWithin(loc) then
			return self.locations[i]
		end
	end
	return nil
end

function Snippet.remove(self)
	debug("Snippet.remove(self)")
	local endPos = self.startPos:Move(self:str():len(), self.view.Buf)
	self.modText = true
	self.view.Cursor:SetSelectionStart(self.startPos)
	self.view.Cursor:SetSelectionEnd(endPos)
	self.view.Cursor:DeleteSelection()
	self.view.Cursor:ResetSelection()
	self.modText = false
end

function Snippet.insert(self)
	debug("Snippet.insert(self)")
	self.modText = true
	self.view.Buf:insert(self.startPos, self:str())
	self.modText = false
end

function Snippet.focusNext(self)
	debug("Snippet.focusNext(self)")
	if self.focused == nil then
		self.focused = 0
	else
		self.focused = (self.focused + 1) % #self.placeholders
	end

	local ph = self.placeholders[self.focused+1]

	for i = 1, #self.locations do
		if self.locations[i].ph == ph then
			self.locations[i]:focus()
			return
		end
	end
end

local function CursorWord(bp)
	debug1("CursorWord(bp)",bp)
	local c = bp.Cursor
	local x = c.X-1 -- start one rune before the cursor
	local result = ""
	while x >= 0 do
		local r = util.RuneStr(c:RuneUnder(x))
		if (r == " ") then    -- IsWordChar(r) then
			break
		else
			result = r .. result
		end
		x = x-1
	end

	return result
end

local function ReadSnippets(filetype)
	debug1("ReadSnippets(filetype)",filetype)
	local snippets = {}
	local allSnippetFiles = config.ListRuntimeFiles(RTSnippets)
	local exists = false

	for i = 1, #allSnippetFiles do
		if allSnippetFiles[i] == filetype then
			exists = true
			break
		end
	end

	if not exists then
		micro.InfoBar():Error("No snippets file for \""..filetype.."\"")
		return snippets
	end

	local snippetFile = config.ReadRuntimeFile(RTSnippets, filetype)

	local curSnip = nil
	local lineNo = 0
	for line in string.gmatch(snippetFile, "(.-)\r?\n") do
		lineNo = lineNo + 1
		if string.match(line,"^#") then
			-- comment
		elseif line:match("^snippet") then
			curSnip = Snippet.new()
			for snipName in line:gmatch("%s(.+)") do  -- %s space  .+ one or more non-empty sequence 
				snippets[snipName] = curSnip
			end
		else
			local codeLine = line:match("^\t(.*)$")
			if codeLine ~= nil then
				curSnip:AddCodeLine(codeLine)
			elseif line ~= "" then
				micro.InfoBar():Error("Invalid snippets file (Line #"..tostring(lineNo)..")")
			end
		end
	end
	debugt("ReadSnippets(filetype) snippets = ",snippets)
	return snippets
end

-- Check filetype and load snippets
-- Return true is snippets loaded for filetype
-- Return false if no snippets loaded
local function EnsureSnippets(bp)
	debug("EnsureSnippets()")
	local filetype = bp.Buf.Settings["filetype"]
	if curFileType ~= filetype then
		snippets = ReadSnippets(filetype)
		curFileType = filetype
	end
	if next(snippets) == nil then
		return false
	end
	return true
end

function onBeforeTextEvent(sb, ev)
	debug1("onBeforeTextEvent(ev)",ev)
	if currentSnippet ~= nil and currentSnippet.view.Buf.SharedBuffer == sb then
		if currentSnippet.modText then
			-- text event from the snippet. simply ignore it...
			return true
		end

		local locStart = nil
		local locEnd = nil

		if ev.Deltas[1].Start ~= nil and currentSnippet ~= nil then
			locStart = currentSnippet:findLocation(ev.Deltas[1].Start:Move(1, currentSnippet.view.Buf))
			locEnd = currentSnippet:findLocation(ev.Deltas[1].End)
		end
		if locStart ~= nil and ((locStart == locEnd) or (ev.Deltas[1].End.Y==0 and ev.Deltas[1].End.X==0))  then
			if locStart:handleInput(ev) then
				currentSnippet.view.Cursor:Goto(-ev.C)
				return false
			end
		end
		Accept()
	end

	return true

end

-- Insert snippet if found.
-- Pass in the name of the snippet to be inserted by command mode
-- No name passed in then it will check the text left of the cursor
function Insert(bp, args)
    local snippetName = nil
    if args ~= nil and #args > 0 then
        snippetName = args[1]
    end
	debug1("Insert(snippetName)",snippetName)

	local c = bp.Cursor
	local buf = bp.Buf
	local xy = buffer.Loc(c.X, c.Y)
	-- check if a snippet name was passed in
	local noArg = false
	if not snippetName then
		snippetName = CursorWord(bp)
		noArg = true
	end
	-- check filetype and load snippets
	local result = EnsureSnippets(bp)
	-- if no snippets return early
	if (result == false) then return end

	-- curSn cloned into currentSnippet if snippet found
	local curSn = snippets[snippetName]
	if curSn then
		currentSnippet = curSn:clone()
		currentSnippet.view = bp
		-- remove snippet keyword from micro buffer before inserting snippet
		if noArg then
			currentSnippet.startPos = xy:Move(-snippetName:len(), buf)

			currentSnippet.modText = true

			c:SetSelectionStart(currentSnippet.startPos)
			c:SetSelectionEnd(xy)
			c:DeleteSelection()
			c:ResetSelection()

			currentSnippet.modText = false
		else
			-- no need to remove snippet keyword from buffer as run from command mode
			currentSnippet.startPos = xy
		end
		-- insert snippet to micro buffer
		currentSnippet:insert()
		micro.InfoBar():Message("Snippet Inserted \""..snippetName.."\"")

		-- Placeholders
		if #currentSnippet.placeholders == 0 then
			local pos = currentSnippet.startPos:Move(currentSnippet:str():len(), bp.Buf)
			while bp.Cursor:LessThan(pos) do
				bp.Cursor:Right()
			end
			while bp.Cursor:GreaterThan(pos) do
				bp.Cursor:Left()
			end
		else
			currentSnippet:focusNext()
		end
	else
		-- Snippet not found
		micro.InfoBar():Message("Unknown snippet \""..snippetName.."\"")
	end
end

function Next()
	debug("Next()")
	if currentSnippet then
		currentSnippet:focusNext()
	end
end

function Accept()
	debug("Accept()")
	currentSnippet = nil
end

function Cancel()
	debug("Cancel()")
	if currentSnippet then
		currentSnippet:remove()
		Accept()
	end
end


local function StartsWith(String,Start)
	debug1("StartsWith(String,Start) String ",String)
	debug1("StartsWith(String,Start) start ",start)
	String = String:upper()
	Start = Start:upper()
	return string.sub(String,1,string.len(Start))==Start
end

-- Used for auto complete in the command prompt
function findSnippet(input)
	debug1("findSnippet(input)",input)
	local result = {}
    -- TODO: pass bp
	EnsureSnippets()

	for name,v in pairs(snippets) do
		if StartsWith(name, input) then
			table.insert(result, name)
		end
	end
	return result
end

-- Debug functions below
-- debug1 is for logging functionName and 1 argument passed
function debug1(functionName, argument)
	if debugflag == false then return end
	if argument == nil then
		micro.Log("snippets-plugin -> function " .. functionName .. " = nil")
	elseif argument == "" then
	micro.Log("snippets-plugin -> function " .. functionName .. " = empty string")
	else micro.Log("snippets-plugin -> function " .. functionName .. " = " .. tostring(argument))
	end
end

-- debug is for logging functionName only
function debug(functionName)
	if debugflag == false then return end
	micro.Log("snippets-plugin -> function " .. functionName)
end

-- debug is for logging functionName and table
function debugt(functionName,tablepassed)
	if debugflag == false then return end
	micro.Log("snippets-plugin -> function " .. functionName )
		tprint(tablepassed)
--	if (tablepassed == nil) then return end
--	for key,value in pairs(tablepassed) do 
--		micro.Log("key - " .. tostring(key) .. "value = " .. tostring(value[1]) )
--	end
end

-- dump table
function dump(o)
	if type(o) == 'table' then
	   local s = '{ '
	   for k,v in pairs(o) do
		  if type(k) ~= 'number' then k = '"'..k..'"' end
		  s = s .. '['..k..'] = ' .. dump(v) .. ','
	   end
	   return s .. '} '
	else
	   return tostring(o)
	end
 end

 function tprint (tbl, indent)
	if not indent then indent = 0 end
	for k, v in pairs(tbl) do
	  formatting = string.rep("  ", indent) .. k .. ": "
	  if type(v) == "table" then
		micro.Log(formatting .. "Table ->")
		tprint(v, indent+1)
	  elseif type(v) == nil then 
		micro.Log(formatting .. " nil")
	else
		micro.Log(formatting .. tostring(v))
	  end
	end
  end

  function checkTableisEmpty(myTable)
	if next(myTable) == nil then
		-- myTable is empty
	 end
end

function tablePrint(tbl)
	for index = 1, #tbl do
		micro.Log(tostring(index) .. " = " .. tostring(tbl[index]))
    end
end

function init()
    -- Insert a snippet
    config.MakeCommand("snippetinsert", Insert, config.NoComplete)
    -- Mark next placeholder
    config.MakeCommand("snippetnext", Next, config.NoComplete)
    -- Cancel current snippet (removes the text)
    config.MakeCommand("snippetcancel", Cancel, config.NoComplete)
    -- Acceptes snipped editing
    config.MakeCommand("snippetaccept", Accept, config.NoComplete)

    config.AddRuntimeFile("snippets", config.RTHelp, "help/snippets.md")
    config.AddRuntimeFilesFromDirectory("snippets", RTSnippets, "snippets", "*.snippets")

    config.TryBindKey("Alt-w", "lua:snippets.Next", false)
    config.TryBindKey("Alt-a", "lua:snippets.Accept", false)
    config.TryBindKey("Alt-s", "lua:snippets.Insert", false)
    config.TryBindKey("Alt-d", "lua:snippets.Cancel", false)
end
