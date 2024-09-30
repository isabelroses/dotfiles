local wezterm = require("wezterm")
local M = {}

M.is_windows = function()
  return wezterm.target_triple:find("windows") ~= nil
end

---@return boolean
M.is_linux = function()
  return wezterm.target_triple:find("linux") ~= nil
end

---@return boolean
M.is_darwin = function()
  return wezterm.target_triple:find("darwin") ~= nil
end

return M
