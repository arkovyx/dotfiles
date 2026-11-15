terminal = "foot"
browser = "librewolf"
mainMod = "SUPER"

local hs = require("hyprsplit")

-- -----------------------------------------------------
-- Path to home
-- -----------------------------------------------------
HOME = os.getenv("HOME")


-- Theme (pywal)
local _ok, _m3 = pcall(dofile, HOME .. "/.cache/wal/hyprland-colors.lua")
if _ok then
    m3 = _m3
else
    m3 = {
        primary         = "rgba(d71921ff)",
        tertiary        = "rgba(d71921ff)",
        surface_lowest  = "rgba(000000ff)",
    }
end

-- -----------------------------------------------------
-- Autostart
-- -----------------------------------------------------
hl.on("hyprland.start", function()
    hl.exec_cmd("wl-paste --type text --watch cliphist store")
    hl.exec_cmd("wl-paste --type image --watch cliphist store")
    hl.exec_cmd("kanshi")
    -- TZEUK: Custom Quickshell shell
    hl.exec_cmd("qs -c ~/.config/quickshell/tzeuk")
    hl.exec_cmd("hypridle")
    hl.exec_cmd(os.getenv("HOME") .. "/.local/bin/wall-restore &")
    hl.exec_cmd("systemctl --user start hyprpolkitagent")
end)

-- -----------------------------------------------------
-- hyprsplit
-- -----------------------------------------------------
hs.config({
    num_workspaces = 10,
    persistent_workspaces = true,
})

-- -----------------------------------------------------
-- SOURCE FILES
-- -----------------------------------------------------
require("source.environment_variables")
require("source.permissions")
require("source.appearance")
require("source.input")
require("source.keybinds")
require("source.window_rules")
