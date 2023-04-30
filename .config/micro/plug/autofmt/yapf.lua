VERSION = "1.0.0"

local config = import("micro/config")

function init()
    config.MakeCommand("yapf", yapf, config.NoComplete)
    config.AddRuntimeFile("yapf", config.RTHelp, "help/yapf.md")
end

function onSave(bp)
    if bp.Buf:FileType() == "python" then
        yapf(bp)
    end
end

function yapf(bp)
    bp:Save()
    local handle = io.popen("yapf -i " .. bp.Buf.Path)
    local result = handle:read("*a")
    handle:close()
    bp.Buf:ReOpen()
end