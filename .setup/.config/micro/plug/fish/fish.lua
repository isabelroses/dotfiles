VERSION = "0.2.0"

local micro = import("micro")
local config = import("micro/config")
local shell = import("micro/shell")

function init()
    config.RegisterCommonOption("fish", "fmt", true)
    config.MakeCommand("fishfmt", fishfmt, config.NoComplete)
    config.AddRuntimeFile("fish", config.RTHelp, "help/fish-plugin.md")
end

function onSave(bp)
    if bp.Buf:FileType() == "fish" then
        if bp.Buf.Settings["fish.fmt"] then
            fishfmt(bp)
        end
    end
end

function fishfmt(bp)
    bp:Save()
    local _, err = shell.RunCommand("fish_indent -w " .. bp.Buf.Path)
    if err ~= nil then
        micro.InfoBar():Error(err)
        return
    end

    bp.Buf:ReOpen()
end
