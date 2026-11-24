local function read_shader_path()
    local home = os.getenv("HOME")
    if not home then return "" end

    local f = io.open(home .. "/.cache/tzeuk/shader", "r")
    if not f then return "" end

    local state = (f:read("*a") or ""):gsub("%s+", "")
    f:close()

    if state == "" or state == "none" then
        return ""
    elseif state == "dots" then
        return home .. "/.config/quickshell/tzeuk/shaders/hyprland/screen-dots.frag"
    elseif state == "wall" then
        return ""
    else
        local shader_file = home .. "/.config/hypr/shaders/" .. state .. ".glsl"
        local tf = io.open(shader_file, "r")
        if tf then
            tf:close()
            return shader_file
        end
        return ""
    end
end

hl.config({
    general = {
        gaps_in = 2,
        gaps_out = 2,
        border_size = 2,
        resize_on_border = false,
        allow_tearing = false,
        layout = "dwindle",
        ["col.active_border"] = {
            colors = { m3.primary, m3.tertiary },
            angle = 45,
        },
        ["col.inactive_border"] = {
            colors = { m3.surface_lowest, m3.surface_lowest },
            angle = 45,
        },
    },

    decoration = {
        blur = {
            enabled = true,
            size = 3,
            passes = 3,
            new_optimizations = true,
            vibrancy = 0.1696,
            ignore_opacity = true,
        },
        screen_shader = read_shader_path(),
    },

    animations = {
        enabled = false,
        bezier = {
            {
                name = "myBezier",
                points = { 1.05, 2.3, 1.5, 2.05 },
            },
        },
        animation = {
            { "windows", 1, 2, "myBezier" },
            { "windowsOut", 1, 2, "default", "popin 80%" },
            { "border", 1, 10, "default" },
            { "borderangle", 1, 8, "default" },
            { "fade", 1, 7, "default" },
            { "workspaces", 1, 1, "default" },
        },
    },

    dwindle = {
        preserve_split = true,
    },

    master = {
        new_status = "master",
        new_on_top = true,
    },

    misc = {
        force_default_wallpaper = -1,
        disable_hyprland_logo = true,
        disable_splash_rendering = true,
        mouse_move_enables_dpms = true,
        key_press_enables_dpms = true,
        vrr = 0,
    },
})
