VERSION = "1.2.1"

local micro = import("micro")
local config = import("micro/config")
local util = import("micro/util")
local utf8 = import("unicode/utf8")

function init()
    config.MakeCommand("wc", wordCount, config.NoComplete)
    config.AddRuntimeFile("wc", config.RTHelp, "help/wc.md")
    config.TryBindKey("F5", "lua:wc.wordCount", false)
end

function wordCount(bp)
	-- Buffer of selection/whole document
	local buffer
	--Get active cursor (to get selection)
	local cursor = bp.Buf:GetActiveCursor()
	--If cursor exists and there is selection, convert selection byte[] to string
	if cursor and cursor:HasSelection() then
		buffer = util.String(cursor:GetSelection())
	else
	--no selection, convert whole buffer byte[] to string
    	buffer = util.String(bp.Buf:Bytes())
    end
    --length of the buffer/selection (string), utf8 friendly
	charCount = utf8.RuneCountInString(buffer)
	--Get word/line count using gsub's number of substitutions
	-- number of substitutions, pattern: %S+ (more than one non-whitespace characters)
	local _ , wordCount = buffer:gsub("%S+","")
	-- number of substitutions, pattern: \n (number of newline characters)
	local _, lineCount = buffer:gsub("\n", "")
	--add one to line count (since we're counting separators not lines above)
	lineCount = lineCount + 1
	--display the message
	micro.InfoBar():Message("Lines:" .. lineCount .. "  Words:"..wordCount.."  Characters:"..charCount)
end
