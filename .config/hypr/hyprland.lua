terminal = "foot"
menu = "fuzzel"
browser = "librewolf"
mainMod = "SUPER"

local hs = require("hyprsplit")

HOME = os.getenv("HOME")

-- Theme (matugen) with safe fallback — never crash on missing cache
local _ok, _m3 = pcall(dofile, HOME .. "/.cache/matugen/hyprland-colors.lua")
if _ok then
    m3 = _m3
else
    m3 = {
        primary         = "rgba(d3bbfcff)",
        on_primary      = "rgba(39255cff)",
        container       = "rgba(503c74ff)",
        secondary       = "rgba(cdc2dbff)",
        tertiary        = "rgba(f1b7c4ff)",
        surface         = "rgba(151218ff)",
        surface_lowest  = "rgba(0f0d13ff)",
        surface_high    = "rgba(2c292fff)",
        on_surface      = "rgba(e7e0e8ff)",
        outline         = "rgba(948f99ff)",
        outline_variant = "rgba(49454eff)",
        error           = "rgba(ffb4abff)",
    }
end

hl.on("hyprland.start", function()
    hl.exec_cmd("wl-paste --type text --watch cliphist store")
    hl.exec_cmd("wl-paste --type image --watch cliphist store")
    hl.exec_cmd("kanshi")
    hl.exec_cmd("qs -p " .. HOME .. "/.config/quickshell/tzeuk")
    hl.exec_cmd("hypridle")
    hl.exec_cmd(HOME .. "/.local/bin/wall-restore &")
    hl.exec_cmd("systemctl --user start hyprpolkitagent")
end)

hs.config({
    num_workspaces = 10,
    persistent_workspaces = true,
})

require("source.environment_variables")
require("source.permissions")
require("source.appearance")
require("source.input")
require("source.keybinds")
require("source.window_rules")
