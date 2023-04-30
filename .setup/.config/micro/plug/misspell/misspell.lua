VERSION = "0.2.0"

local config = import("micro/config")

function init()
    -- uses the default linter plugin
    -- matches any filetype
    linter.makeLinter("misspell", "", "misspell", {"%f"}, "%f:%l:%c: %m", {}, false, true)
end