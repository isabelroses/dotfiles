VERSION = "1.0.0"

local micro = import("micro")
local microBuffer = import("micro/buffer")
local config = import("micro/config")
local shell = import("micro/shell")

local function errlog(msg, bufpane)
    microBuffer.Log(("editorconfig error: %s\n"):format(msg))
    bufpane:OpenLogBuf()
end

-- for debugging; use micro -debug, and then inspect log.txt
local function log(msg)
    micro.Log(("editorconfig log: %s"):format(msg))
end

local function setSafely(key, value, bufpane)
    if value == nil then
        log(("Ignore nil for %s"):format(key))
    else
        buffer = bufpane.Buf
        local oldValue = config.GetGlobalOption(key)
        if oldValue ~= value then
            log(("Set %s = %s (was %s)"):format(key, value, oldValue))
            buffer:SetOptionNative(key, value)
        else
            log(("Unchanged %s = %s"):format(key, oldValue))
        end
    end
end

local function setIndentation(properties, bufpane)
    local indent_size_str = properties["indent_size"]
    local tab_width_str = properties["tab_width"]
    local indent_style = properties["indent_style"]

    local indent_size = tonumber(indent_size_str, 10)
    local tab_width = tonumber(tab_width_str, 10)

    if indent_size_str == "tab" then
        indent_size = tab_width
    elseif tab_width == nil then
        tab_width = indent_size
    end

    if indent_style == "space" then
        setSafely("tabstospaces", true, bufpane)
        setSafely("tabsize", indent_size, bufpane)
    elseif indent_style == "tab" then
        setSafely("tabstospaces", false, bufpane)
        setSafely("tabsize", tab_width, bufpane)
    elseif indent_style ~= nil then
        errlog(("Unknown value for editorconfig property indent_style: %s"):format(indent_style or "nil"), bufpane)
    end
end

local function setEndOfLine(properties, bufpane)
    local end_of_line = properties["end_of_line"]
    if end_of_line == "lf" then
        setSafely("fileformat", "unix", bufpane)
    elseif end_of_line == "crlf" then
        setSafely("fileformat", "dos", bufpane)
    elseif end_of_line == "cr" then
        -- See https://github.com/zyedidia/micro/blob/master/runtime/help/options.md for supported runtime options.
        errlog(("Value %s for editorconfig property end_of_line is not currently supported by micro."):format(end_of_line), bufpane)
    elseif end_of_line ~= nil then
        errlog(("Unknown value for editorconfig property end_of_line: %s"):format(end_of_line), bufpane)
    end
end

local function setCharset(properties, bufpane)
    local charset = properties["charset"]
    if charset ~= "utf-8" and charset ~= nil then
        -- TODO: I believe micro 2.0 added support for more charsets, so this is gonna have to be updated accordingly.
        -- Also now we need to actually set the charset since it isn't just utf-8.
        errlog(("Value %s for editorconfig property charset is not currently supported by micro."):format(charset), bufpane)
    end
end

local function setTrimTrailingWhitespace(properties, bufpane)
    local val = properties["trim_trailing_whitespace"]
    if val == "true" then
        setSafely("rmtrailingws", true, bufpane)
    elseif val == "false" then
        setSafely("rmtrailingws", false, bufpane)
    elseif val ~= nil then
        errlog(("Unknown value for editorconfig property trim_trailing_whitespace: %s"):format(val), bufpane)
    end
end

local function setInsertFinalNewline(properties, bufpane)
    local val = properties["insert_final_newline"]
    if val == "true" then
        setSafely("eofnewline", true, bufpane)
    elseif val == "false" then
        setSafely("eofnewline", false, bufpane)
    elseif val ~= nil then
        errlog(("Unknown value for editorconfig property insert_final_newline: %s"):format(val), bufpane)
    end
end

local function applyProperties(properties, bufpane)
    setIndentation(properties, bufpane)
    setEndOfLine(properties, bufpane)
    setCharset(properties, bufpane)
    setTrimTrailingWhitespace(properties, bufpane)
    setInsertFinalNewline(properties, bufpane)
end

function onEditorConfigExit(output, args)
    log(("editorconfig core output: \n%s"):format(output))
    local properties = {}
    for line in output:gmatch('([^\n]+)') do
        local key, value = line:match('([^=]*)=(.*)')
        if key == nil or value == nil then
            errlog(("Failed to parse editorconfig output: %s"):format(line))
            return
        end
        key = key:gsub('^%s(.-)%s*$', '%1')
        value = value:gsub('^%s(.-)%s*$', '%1')
        properties[key] = value
    end

    local bufpane = args[1]
    applyProperties(properties, bufpane)
    log("Done.")
end

function getApplyProperties(bufpane)
    if (bufpane.Buf.Path or "") == "" then
        -- Current buffer does not visit any file
        return
    end

    local fullpath = bufpane.Buf.AbsPath
    if fullpath == nil then
        messenger:Message("editorconfig: AbsPath is empty")
        return
    end

    log(("Running on file %s"):format(fullpath))
    shell.JobSpawn("editorconfig", {fullpath}, nil, nil, onEditorConfigExit, bufpane)
end

function onBufPaneOpen(bufpane)
    getApplyProperties(bufpane)
end

function onSave(bufpane)
    getApplyProperties(bufpane)
    return true
end

function init()
    config.AddRuntimeFile("editorconfig", config.RTHelp, "help/editorconfig.md")
end
