DEFAULT_CONFIG = {
    target = 1.5,
    toggle = 1.5,
    decr = 0.1,
    incr = 0.1,
    rewind = 5,
    advance = 5
}
cfg=DEFAULT_CONFIG
---------------- Standard VLC extension functions that must/can be implemented ---------------------


function descriptor()
    return {
        title = "VLC Speed Controller";
        version = "1.0";
        author = "Andrei Hutu";
        url = "https://github.com/Anndrey24/VLC_Speed_Controller";
        description = [[
VLC Speed Controller
This extension allows you to quickly switch between normal speed and a target playback speed, while also providing a GUI for playback customization.
]];
        capabilities = {"menu"}
    }
end


function activate()
    cfg = load_config()
    create_dialog_controller()
end


function deactivate()
    save_config(cfg)
end


function close()
    on_click_cancel()
end


function menu()
    return {"Speed Controller","Settings"}
end


function trigger_menu(id)
    if id == 1 then
        on_click_cancel()
        create_dialog_controller()
    elseif id == 2 then
        on_click_cancel()
        create_dialog_settings()
    end
end


---------------------------- Functions specific to this extension ----------------------------------


function create_dialog_controller()
    local input = vlc.object.input()
    cfg = load_config()

    dlg = vlc.dialog(descriptor().title .. " > Speed Controller")

    -- SPEED
    speed_widget = dlg:add_label("Speed: " .. round2(vlc.var.get(input,"rate"),2), 1, 1, 1, 1)
    dlg:add_button("-", decr_speed, 3, 1, 1, 1)
    dlg:add_button("+", incr_speed, 4, 1, 1, 1)
    dlg:add_button("Preferred", pref_speed, 1, 2, 2, 1)
    dlg:add_button("TOGGLE", toggle_speed, 1, 3, 3, 1)

    -- SEEK
    dlg:add_button("<< Backwards", rewind, 3, 2, 1, 1)
    dlg:add_button("Forwards >>", advance, 4, 2, 1, 1)
    dlg:add_button("Next Frame", next_frame, 4, 3, 1, 1)

    -- PLAY / PAUSE
    dlg:add_button("Play / Pause", function() vlc.playlist.pause() end, 3,4,1,1)
end


function create_dialog_settings()
    dlg = vlc.dialog(descriptor().title .. " > Settings")

    -- DECREASE SPEED
    dlg:add_label("Decrease speed: ", 1, 1, 1, 1)
    dd_decr = dlg:add_text_input(cfg.decr, 2, 1, 2, 1)
   
    -- INCREASE SPEED
    dlg:add_label("Increase speed: ", 1, 2, 1, 1)
    dd_incr = dlg:add_text_input(cfg.incr, 2, 2, 2, 1)
   
    -- REWIND
    dlg:add_label("Rewind (in sec): ", 1, 3, 1, 1)
    dd_rewind = dlg:add_text_input(cfg.rewind, 2, 3, 2, 1)
   
    -- ADVANCE
    dlg:add_label("Advance (in sec): ", 1, 4, 1, 1)
    dd_advance = dlg:add_text_input(cfg.advance, 2, 4, 2, 1)

    -- TARGET
    dlg:add_label("Preferred speed: ", 1, 5, 1, 1)
    dd_target = dlg:add_text_input(cfg.target, 2, 5, 2, 1)
   
    -- SAVE / CANCEL

    dlg:add_button("Save", on_click_save, 2, 6, 1, 1)
    dlg:add_button("Cancel", on_click_cancel , 3, 6, 1, 1)
end


function on_click_cancel()
    if dlg then
        dlg:delete()
        dlg = nil
    end
end


function on_click_save()
    cfg.target = tonumber(dd_target:get_text()) and tonumber(dd_target:get_text()) or DEFAULT_CONFIG.target
    cfg.target = math.min(31.25, math.max(0.03,cfg.target))
    cfg.toggle = cfg.target
    cfg.decr = tonumber(dd_decr:get_text()) and tonumber(dd_decr:get_text()) or DEFAULT_CONFIG.decr
    cfg.incr = tonumber(dd_incr:get_text()) and tonumber(dd_incr:get_text()) or DEFAULT_CONFIG.incr
    cfg.rewind = tonumber(dd_rewind:get_text()) and tonumber(dd_rewind:get_text()) or DEFAULT_CONFIG.rewind
    cfg.advance = tonumber(dd_advance:get_text()) and tonumber(dd_advance:get_text()) or DEFAULT_CONFIG.advance
    save_config(cfg)
    dlg:hide()
end

function decr_speed()
    local input = vlc.object.input()
    vlc.var.set(input, "rate", math.min(math.max(0.03, vlc.var.get(input,"rate") - cfg.decr),31.25))
    local curr_speed = vlc.var.get(input,"rate")
    if curr_speed ~= 1 then
        cfg.toggle = curr_speed
    end
    speed_widget:set_text("Speed: " .. round2(curr_speed,2))
end


function incr_speed()
    local input = vlc.object.input()
    vlc.var.set(input, "rate", math.max(math.min(31.25, vlc.var.get(input,"rate") + cfg.incr),0.03))
    local curr_speed = vlc.var.get(input,"rate")
    if curr_speed ~= 1 then
        cfg.toggle = curr_speed
    end
    speed_widget:set_text("Speed: " .. round2(curr_speed,2))
end


function toggle_speed()
    local input = vlc.object.input()
    local curr_speed = vlc.var.get(input,"rate")
    if curr_speed ~= 1 then
        vlc.var.set(input, "rate", 1)
        speed_widget:set_text("Speed: " .. 1.00)
    else
        vlc.var.set(input, "rate", cfg.toggle)
        speed_widget:set_text("Speed: " .. round2(cfg.toggle,2))
    end
end

function pref_speed()
    local input = vlc.object.input()
    vlc.var.set(input, "rate", cfg.target)
    cfg.toggle = cfg.target
    speed_widget:set_text("Speed: " .. round2(cfg.target,2))
end

function rewind()
    local input = vlc.object.input()
    vlc.var.set(input, "time-offset",cfg.rewind*-1000000)
end


function advance()
    local input = vlc.object.input()
    vlc.var.set(input, "time-offset",cfg.advance*1000000)
end


function next_frame()
    local input = vlc.object.input()
    for k0,v0 in pairs(vlc.input.item():info()) do
        for k1,v1 in pairs(v0) do
            if tonumber(v1) then vlc.var.set(input, "time-offset",(1/v1)*1000000) return end
        end
    end
end


function round2(num, numDecimalPlaces)
    return tonumber(string.format("%." .. numDecimalPlaces .. "f", num))
end


---------------------------- Config management functions -------------------------------------------


--- Returns a table containing all the data from the INI file.
--@param fileName The name of the INI file to parse. [string]
--@return The table containing all data from the INI file. [table]
function load_config()
    local file_name = vlc.config.configdir() .. "vlcsc"
    assert(type(file_name) == 'string', 'Variable "file_name" must be a string.');
    local file = io.open(file_name, 'r')
    if not file then
        local cfg = DEFAULT_CONFIG;
        save_config(cfg)
        return cfg
    end
    local cfg = {};
    local section;
    for line in file:lines() do
        local param, value = line:match('^([%w|_]+)%s-=%s-(.+)$');
        if(param and value ~= nil)then
            if(tonumber(value))then
                value = tonumber(value);
            elseif(value == 'true')then
                value = true;
            elseif(value == 'false')then
                value = false;
            end
            if(tonumber(param))then
                param = tonumber(param);
            end
            cfg[param] = value;
        end
    end
    file:close();
    return cfg;
end


--- Saves all the data from a table to an INI file.
--@param fileName The name of the INI file to fill. [string]
--@param data The table containing all the data to store. [table]
function save_config(cfg)
    file_name = vlc.config.configdir() .. "vlcsc"
    vlc.msg.warn(file_name)
    assert(type(file_name) == 'string', 'Variable "file_name" must be a string.');
    assert(type(cfg) == 'table', 'Parameter "cfg" must be a table.');
    local file = assert(io.open(file_name, 'w+b'), 'Error loading file :' .. file_name);
    local contents = '';
    for key, value in pairs(cfg) do
        contents = contents .. ('%s=%s\n'):format(key, tostring(value));
    end
    file:write(contents);
    file:close();
end