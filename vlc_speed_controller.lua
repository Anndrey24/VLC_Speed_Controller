--[[----------------------------------------
This program is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation; either version 3 of the License, or (at your option) any later version.
This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.
You should have received a copy of the GNU General Public License along with this program. If not, see https://www.gnu.org/licenses/.
--------------------------------------------
"vlc_speed_controller.lua" > Put this VLC Extension Lua script file in \lua\extensions\ folder
--------------------------------------------
INSTALLATION directory:
* Windows (all users): %ProgramFiles%\VideoLAN\VLC\lua\extensions\
* Windows (current user): %APPDATA%\VLC\lua\extensions\
* Linux (all users): /usr/lib/vlc/lua/extensions/
* Linux (current user): ~/.local/share/vlc/lua/extensions/
* Mac OS X (all users): /Applications/VLC.app/Contents/MacOS/share/lua/extensions/
* Mac OS X (current user): /Users/%your_name%/Library/Application Support/org.videolan.vlc/lua/extensions/
--------------------------------------------
To use extension: View > VLC Speed Controller
--]]----------------------------------------


DEFAULT_CONFIG = {
    toggle = 1.5,
    decr = 0.1,
    incr = 0.1,
    rewind = 5,
    advance = 5,
    keep_speed = 0,
    custom_speed_1 = 0.75,
    custom_speed_2 = 1.00,
    custom_speed_3 = 1.25,
    custom_speed_4 = 1.50,
    custom_speed_5 = 1.75,
    custom_speed_6 = 2.00,
    custom_speed_7 = 2.50,
    custom_speed_8 = 3.00
}

last_speed = 1.0

---------------- Standard VLC extension functions that must/can be implemented ---------------------


function descriptor()
    return {
        title = "VLC Speed Controller";
        version = "1.2";
        author = "Andrei Hutu";
        url = "https://github.com/Anndrey24/VLC_Speed_Controller";
        description = [[
VLC Speed Controller
This extension allows you to quickly switch between 1.0x speed and a user configurable target speed, while also providing a GUI for playback control.
]];
        capabilities = {"menu","input-listener"};
        icon = icon_string ;
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

function input_changed()
    if cfg.keep_speed == 1 then
        local input = vlc.object.input()
        vlc.var.set(input, "rate", last_speed)
        if last_speed ~= 1 then
            cfg.toggle = last_speed
        end
    end
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


--- Creates Speed Controller Window.
function create_dialog_controller()
    local input = vlc.object.input()
    cfg = load_config()

    dlg = vlc.dialog("Speed Controller")

    -- SPEED
    dlg:add_label("Playback Speed: ", 1, 1, 2, 1)
    dlg:add_button("-", decr_speed, 3, 1, 1, 1)
    dlg:add_button("+", incr_speed, 4, 1, 1, 1)
    speed_widget = dlg:add_text_input(round2(vlc.var.get(input,"rate"),2), 5, 1, 2, 1)
    last_speed = tonumber(speed_widget:get_text())
    dlg:add_button("Set", set_speed, 7, 1, 2, 1)
    dlg:add_button(round2(cfg.custom_speed_1,2), function() change_speed(round1(cfg.custom_speed_1,2)) end, 1, 2, 1, 1)
    dlg:add_button(round2(cfg.custom_speed_2,2), function() change_speed(round1(cfg.custom_speed_2,2)) end, 2, 2, 1, 1)
    dlg:add_button(round2(cfg.custom_speed_3,2), function() change_speed(round1(cfg.custom_speed_3,2)) end, 3, 2, 1, 1)
    dlg:add_button(round2(cfg.custom_speed_4,2), function() change_speed(round1(cfg.custom_speed_4,2)) end, 4, 2, 1, 1)
    dlg:add_button(round2(cfg.custom_speed_5,2), function() change_speed(round1(cfg.custom_speed_5,2)) end, 5, 2, 1, 1)
    dlg:add_button(round2(cfg.custom_speed_6,2), function() change_speed(round1(cfg.custom_speed_6,2)) end, 6, 2, 1, 1)
    dlg:add_button(round2(cfg.custom_speed_7,2), function() change_speed(round1(cfg.custom_speed_7,2)) end, 7, 2, 1, 1)
    dlg:add_button(round2(cfg.custom_speed_8,2), function() change_speed(round1(cfg.custom_speed_8,2)) end, 8, 2, 1, 1)
    dlg:add_button("TOGGLE", toggle_speed, 1, 3, 2, 1)

    -- SEEK
    dlg:add_label("", 1, 1, 2, 1)
    dlg:add_button("<< Backwards", rewind, 3, 3, 2, 1)
    dlg:add_button("Forwards >>", advance, 5, 3, 2, 1)
    dlg:add_button("Next Frame", next_frame, 7, 3, 2, 1)

    -- PLAY / PAUSE
    dlg:add_button("Play / Pause", function() vlc.playlist.pause() end, 3,4,4,1)

    -- SETTINGS
    dlg:add_button("Settings", function() on_click_cancel(); create_dialog_settings(); end, 7,4,2,1)
end


--- Creates Settings Window.
function create_dialog_settings()
    dlg = vlc.dialog("Speed Settings")

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

    -- KEEP SPEED
    dlg:add_label("Maintain speed between tracks: ", 1, 6, 1, 1)
    if cfg.keep_speed == 1 then
        dd_keep = dlg:add_check_box("",true, 2, 6, 2, 1)
    else
        dd_keep = dlg:add_check_box("",false, 2, 6, 2, 1)
    end

    -- CUSTOM SPEED
    dlg:add_label("Custom Speed 1: ", 1, 7, 1, 1)
    dd_c1 = dlg:add_text_input(cfg.custom_speed_1, 2, 7, 2, 1)
    dlg:add_label("Custom Speed 2: ", 1, 8, 1, 1)
    dd_c2 = dlg:add_text_input(cfg.custom_speed_2, 2, 8, 2, 1)
    dlg:add_label("Custom Speed 3: ", 1, 9, 1, 1)
    dd_c3 = dlg:add_text_input(cfg.custom_speed_3, 2, 9, 2, 1)
    dlg:add_label("Custom Speed 4: ", 1, 10, 1, 1)
    dd_c4 = dlg:add_text_input(cfg.custom_speed_4, 2, 10, 2, 1)
    dlg:add_label("Custom Speed 5: ", 1, 11, 1, 1)
    dd_c5 = dlg:add_text_input(cfg.custom_speed_5, 2, 11, 2, 1)
    dlg:add_label("Custom Speed 6: ", 1, 12, 1, 1)
    dd_c6 = dlg:add_text_input(cfg.custom_speed_6, 2, 12, 2, 1)
    dlg:add_label("Custom Speed 7: ", 1, 13, 1, 1)
    dd_c7 = dlg:add_text_input(cfg.custom_speed_7, 2, 13, 2, 1)
    dlg:add_label("Custom Speed 8: ", 1, 14, 1, 1)
    dd_c8 = dlg:add_text_input(cfg.custom_speed_8, 2, 14, 2, 1)

    -- SAVE / CANCEL
    dlg:add_button("Save", on_click_save, 2, 15, 1, 1)
    dlg:add_button("Cancel", on_click_cancel , 3, 15, 1, 1)
end


--- Deletes current window.
function on_click_cancel()
    if dlg then
        dlg:delete()
        dlg = nil
    end
end


--- Saves settings.
function on_click_save()
    cfg.decr = tonumber(dd_decr:get_text()) or DEFAULT_CONFIG.decr
    cfg.incr = tonumber(dd_incr:get_text()) or DEFAULT_CONFIG.incr
    cfg.rewind = tonumber(dd_rewind:get_text()) or DEFAULT_CONFIG.rewind
    cfg.advance = tonumber(dd_advance:get_text()) or DEFAULT_CONFIG.advance
    if dd_keep:get_checked() == true then
        cfg.keep_speed = 1
    else
        cfg.keep_speed = 0
    end
    cfg.custom_speed_1 = bound(tonumber(dd_c1:get_text()) or DEFAULT_CONFIG.custom_speed_1)
    cfg.custom_speed_2 = bound(tonumber(dd_c2:get_text()) or DEFAULT_CONFIG.custom_speed_2)
    cfg.custom_speed_3 = bound(tonumber(dd_c3:get_text()) or DEFAULT_CONFIG.custom_speed_3)
    cfg.custom_speed_4 = bound(tonumber(dd_c4:get_text()) or DEFAULT_CONFIG.custom_speed_4)
    cfg.custom_speed_5 = bound(tonumber(dd_c5:get_text()) or DEFAULT_CONFIG.custom_speed_5)
    cfg.custom_speed_6 = bound(tonumber(dd_c6:get_text()) or DEFAULT_CONFIG.custom_speed_6)
    cfg.custom_speed_7 = bound(tonumber(dd_c7:get_text()) or DEFAULT_CONFIG.custom_speed_7)
    cfg.custom_speed_8 = bound(tonumber(dd_c8:get_text()) or DEFAULT_CONFIG.custom_speed_8)
    save_config(cfg)
    dlg:delete()
    create_dialog_controller()
end


--- Sets playback speed to a specific value from text input.
function set_speed()
    local input = vlc.object.input()
    local new_speed = tonumber(speed_widget:get_text()) and tonumber(speed_widget:get_text()) or 1
    vlc.var.set(input, "rate", new_speed)
    if new_speed ~= 1 then
        cfg.toggle = new_speed
    end
    speed_widget:set_text(round2(new_speed,2))
    last_speed = tonumber(speed_widget:get_text())
end

--- Sets playback speed to a specific value from parameter.
function change_speed(new_speed)
    local input = vlc.object.input()
    vlc.var.set(input, "rate", new_speed)
    if new_speed ~= 1 then
        cfg.toggle = new_speed
    end
    speed_widget:set_text(round2(new_speed,2))
    last_speed = tonumber(speed_widget:get_text())
end

--- Decreases playback speed by an increment.
function decr_speed()
    local input = vlc.object.input()
    local curr_speed = round1(vlc.var.get(input,"rate"),2)
    local diff = round1(cfg.decr,2)
    local new_speed = round1(curr_speed - diff,2)
    vlc.var.set(input, "rate", math.min(math.max(0.03,  new_speed),31.25))
    if new_speed ~= 1 then
        cfg.toggle = new_speed
    end
    speed_widget:set_text(round2(new_speed,2))
    last_speed = tonumber(speed_widget:get_text())
end


--- Increases playback speed by an increment.
function incr_speed()
    local input = vlc.object.input()
    local curr_speed = round1(vlc.var.get(input,"rate"),2)
    local diff = round1(cfg.incr,2)
    local new_speed = round1(curr_speed + diff,2)
    vlc.var.set(input, "rate", math.max(math.min(31.25, new_speed),0.03))
    if new_speed ~= 1 then
        cfg.toggle = new_speed
    end
    speed_widget:set_text(round2(new_speed,2))
    last_speed = tonumber(speed_widget:get_text())
end


--- Switches between normal speed to target speed.
function toggle_speed()
    local input = vlc.object.input()
    local curr_speed = round1(vlc.var.get(input,"rate"),2)
    if curr_speed ~= 1 then
        vlc.var.set(input, "rate", 1)
        speed_widget:set_text("1.00")
        last_speed = 1.00
    else
        vlc.var.set(input, "rate", cfg.toggle)
        speed_widget:set_text(round2(cfg.toggle,2))
        last_speed = tonumber(speed_widget:get_text())
    end
end

--- Jumps back by a specific time.
function rewind()
    local input = vlc.object.input()
    vlc.var.set(input, "time-offset",cfg.rewind*-1000000)
end


--- Jumps forward by a specific time.
function advance()
    local input = vlc.object.input()
    vlc.var.set(input, "time-offset",cfg.advance*1000000)
end


--- Jumps to the next frame.
function next_frame()
    local input = vlc.object.input()
    for k0,v0 in pairs(vlc.input.item():info()) do
        for k1,v1 in pairs(v0) do
            if tonumber(v1) then 
                vlc.msg.info(tonumber(v1) .. " " .. 1000000/tonumber(v1))
                vlc.var.set(input, "time-offset",math.floor(1000000/tonumber(v1))) return end
        end
    end
end


function round1(num, nr_decimals)
    local mult = 10^(nr_decimals or 0)
    return math.floor(num * mult + 0.5) / mult
end


function round2(num, nr_decimals)
    return string.format("%3." .. nr_decimals .. "f", num)
end

function bound(speed)
    return math.min(31.25, math.max(0.03,speed))
end
---------------------------- Config management functions -------------------------------------------


--- Returns a table containing all the data from the cofig file.
function load_config()
    -- Find config file
    local file_name = vlc.config.configdir() .. "/vlcsc"
    assert(type(file_name) == 'string', 'Variable "file_name" must be a string.');
    local file = io.open(file_name, 'r')
    -- File not found
    if not file then
        -- Load default config
        local cfg = DEFAULT_CONFIG;
        save_config(cfg)
        return cfg
    end
    local cfg = DEFAULT_CONFIG;
    for line in file:lines() do
        -- Match "[key] = [value]" pairs (eg. target = 1.5, incr=0.1) 
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
            -- Store pair in config table
            cfg[param] = value;
        end
    end
    file:close();
    return cfg;
end


--- Saves all the data from a table to a config file.
function save_config(cfg)
    file_name = vlc.config.configdir() .. "/vlcsc"
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

icon_string = "\137\80\78\71\13\10\26\10\0\0\0\13\73\72\68\82\0\0\0\64\0\0\0\64\8\0\0\0\0\143\2\46\2\0\0\0\4\103\65\77\65\0\0\177\143\11\252\97\5\0\0\0\32\99\72\82\77\0\0\122\38\0\0\128\132\0\0\250\0\0\0\128\232\0\0\117\48\0\0\234\96\0\0\58\152\0\0\23\112\156\186\81\60\0\0\0\2\98\75\71\68\0\255\135\143\204\191\0\0\0\9\112\72\89\115\0\0\18\116\0\0\18\116\1\222\102\31\120\0\0\0\7\116\73\77\69\7\229\8\10\13\19\11\43\117\128\125\0\0\7\223\73\68\65\84\88\195\157\87\107\140\85\213\21\254\214\222\231\156\123\239\220\25\102\144\135\3\202\136\32\85\112\20\49\98\161\81\139\66\65\209\90\41\88\107\20\107\227\187\20\43\137\177\10\218\104\99\171\77\170\166\181\41\90\53\66\213\216\152\88\109\21\149\164\62\64\91\171\1\138\60\44\165\60\134\135\142\51\4\102\238\220\123\30\247\156\179\247\215\31\247\14\76\185\3\163\236\31\39\103\157\189\214\183\215\123\237\35\33\142\182\40\36\33\34\148\35\112\56\71\23\71\234\100\5\54\50\26\71\128\144\240\104\242\86\101\195\237\157\234\196\209\78\0\213\63\194\145\0\8\64\140\151\46\95\182\53\68\227\25\55\93\89\182\253\35\244\15\64\177\22\64\174\253\250\183\179\89\5\19\36\55\254\70\27\245\165\53\160\24\207\37\176\255\210\143\135\27\11\64\169\125\215\46\139\129\126\84\112\250\151\175\251\98\197\158\145\87\45\249\248\248\178\0\128\177\195\159\159\178\160\212\31\115\191\26\152\252\59\55\180\9\199\246\36\189\71\82\69\39\255\61\107\229\75\1\144\94\199\55\190\104\178\136\156\67\225\167\46\188\124\185\175\106\17\106\29\67\88\231\165\221\77\177\73\61\71\57\90\107\165\133\16\73\183\192\8\7\246\1\133\6\157\176\66\177\69\91\249\150\115\41\192\126\120\70\215\132\210\169\149\199\160\237\219\60\82\136\233\77\198\42\161\90\215\238\89\211\180\188\227\129\150\160\6\161\198\7\20\253\203\71\147\156\21\213\125\229\139\86\132\176\122\245\108\15\20\118\143\123\109\92\116\184\205\135\209\164\205\222\117\191\174\179\2\49\35\81\12\87\7\137\159\14\203\89\8\229\248\237\55\197\138\60\42\128\216\252\155\191\29\42\70\0\136\129\212\253\226\226\146\167\44\5\16\148\135\124\240\106\214\12\160\1\176\92\208\39\222\13\19\92\139\234\161\66\121\107\192\40\184\221\27\123\243\133\26\78\244\200\40\147\42\175\90\203\116\219\82\61\0\128\148\163\234\241\244\54\119\43\14\47\40\58\107\130\92\175\229\53\137\112\56\128\169\111\106\175\190\229\63\56\167\222\82\32\216\227\146\2\64\210\19\220\88\29\29\32\173\63\119\93\125\34\0\132\153\142\207\43\218\120\149\232\83\153\105\53\42\28\150\7\180\249\127\93\160\50\105\117\243\255\245\118\187\191\182\58\111\14\171\233\195\243\66\251\147\158\140\187\8\17\145\131\156\21\194\238\27\244\228\224\68\6\200\68\138\201\191\251\224\134\200\214\196\75\229\167\222\63\209\31\48\149\41\48\57\179\227\64\63\0\199\143\102\84\91\76\181\181\0\49\146\173\109\160\20\19\161\86\190\223\134\34\100\109\221\227\8\227\197\169\158\202\94\231\18\32\164\255\33\66\84\216\216\39\70\14\40\180\4\20\132\82\125\135\168\62\4\148\34\132\149\42\210\32\132\182\151\7\144\64\200\172\162\216\176\34\148\17\2\18\89\85\37\132\146\38\2\106\143\0\36\54\2\186\14\1\73\202\90\40\18\18\217\53\111\119\53\207\104\141\32\20\179\162\71\19\39\77\117\19\69\225\27\93\14\37\154\248\245\72\220\47\86\42\0\118\86\115\194\236\71\27\50\214\61\97\226\144\16\66\4\126\122\175\100\71\228\212\146\52\8\130\114\215\201\240\92\7\231\239\78\253\32\244\91\161\197\197\34\22\75\92\5\37\162\176\138\165\34\23\193\21\65\243\227\105\16\4\40\242\117\92\221\94\216\59\31\191\99\49\136\122\198\78\219\245\233\127\159\194\60\150\130\48\60\235\140\205\27\55\174\223\93\14\74\252\16\139\219\214\111\252\228\64\20\20\185\56\243\183\45\235\94\158\130\7\88\10\80\228\93\178\133\61\236\252\246\31\232\7\81\79\203\44\166\9\111\206\238\74\253\48\108\157\100\173\177\73\16\150\248\79\60\198\216\216\40\8\139\188\219\105\99\202\210\121\206\38\91\82\64\35\255\141\124\57\247\234\13\161\2\32\38\45\245\96\76\84\208\4\64\90\107\18\169\134\208\50\177\149\209\80\54\97\33\255\211\244\117\161\82\230\251\39\93\117\235\187\97\189\241\133\0\232\56\245\131\177\234\184\230\68\0\73\119\238\216\209\86\237\105\93\29\59\183\237\83\213\28\80\202\77\91\243\107\33\8\125\179\245\198\33\24\254\131\79\172\31\6\81\97\236\153\207\46\125\114\14\22\179\20\132\254\100\207\115\49\188\61\246\75\124\63\159\215\25\92\195\98\80\228\221\206\86\235\7\229\3\35\103\208\119\168\252\150\167\30\254\232\207\47\188\242\202\69\190\130\205\110\253\17\57\120\201\226\72\1\146\52\223\97\108\93\214\10\161\131\185\211\130\184\213\30\170\127\137\203\89\208\1\234\81\108\184\120\246\205\211\30\188\80\0\237\79\121\209\87\199\53\70\20\66\210\161\139\64\148\173\0\138\23\44\72\92\83\174\218\64\152\220\174\253\167\130\14\212\99\219\31\181\61\234\220\137\29\161\54\128\245\154\83\149\250\170\226\44\227\91\192\17\2\68\8\95\43\125\176\187\122\88\134\153\16\199\230\214\188\120\218\66\87\111\222\112\65\157\175\0\45\136\84\165\22\0\229\212\145\42\77\5\16\100\81\231\32\134\0\162\93\229\22\151\46\189\228\162\80\57\146\62\210\118\251\115\103\23\87\120\247\2\16\148\74\80\34\149\90\163\217\52\217\234\174\91\239\44\9\98\252\250\249\68\149\159\157\236\3\81\249\10\39\222\211\61\253\41\80\57\42\30\182\226\217\191\188\151\249\222\29\227\3\77\202\101\35\15\53\35\206\60\133\212\13\141\16\97\211\92\198\34\177\71\1\206\188\212\75\156\169\51\46\115\98\69\9\196\234\12\83\173\210\178\64\32\25\27\11\33\36\32\226\41\10\37\141\41\162\50\4\32\101\163\64\215\161\16\18\80\83\42\115\129\73\66\186\25\134\194\208\5\29\137\93\151\82\182\70\217\80\64\207\179\145\245\197\73\64\207\75\4\150\18\199\146\173\75\18\69\9\152\45\124\52\108\82\98\188\240\195\134\201\41\146\206\19\81\72\70\124\214\214\80\154\208\176\119\79\211\132\212\102\187\62\30\62\169\172\194\238\17\86\23\226\97\169\179\127\87\212\210\18\238\232\62\101\68\164\244\61\117\155\110\43\172\92\53\61\183\253\150\206\85\239\204\114\123\206\27\63\254\133\15\166\109\120\250\233\242\25\67\111\95\243\254\222\243\245\250\5\61\43\214\205\116\55\60\250\221\176\238\213\149\51\252\252\227\207\28\168\31\191\237\198\112\249\132\81\9\74\156\247\26\147\199\182\241\186\231\201\91\126\207\29\23\94\97\158\249\57\205\222\107\25\112\254\150\142\217\145\157\179\146\188\234\37\254\227\122\22\248\220\18\118\241\222\63\50\224\218\249\252\213\195\44\42\175\221\126\179\24\254\164\165\16\206\44\98\206\38\132\167\95\246\80\163\69\226\167\101\3\60\184\96\110\102\183\115\126\23\102\175\175\182\91\128\200\61\113\219\127\224\237\88\184\246\59\86\41\51\40\233\106\104\216\214\61\200\116\54\96\103\35\156\3\55\116\252\117\48\68\107\45\112\175\48\223\98\83\212\61\24\187\142\131\184\240\128\44\28\36\243\30\26\141\228\244\179\135\156\22\40\149\230\47\89\176\250\137\133\101\153\115\231\219\207\253\233\58\32\192\157\175\4\16\91\2\80\60\235\154\197\210\56\253\199\239\63\177\250\106\232\157\111\109\129\93\255\94\59\162\61\91\62\131\233\254\97\199\203\245\70\223\151\76\201\189\94\186\175\197\63\103\208\27\251\239\153\16\75\253\152\161\227\71\143\73\81\127\42\149\62\113\242\129\81\238\20\251\102\249\103\163\226\76\225\211\161\227\156\206\173\99\71\58\187\62\29\54\54\105\104\29\183\175\53\149\0\204\9\146\68\217\172\66\26\43\184\137\205\48\129\184\177\208\75\109\38\38\178\144\36\17\149\65\26\59\30\146\196\115\144\38\202\141\28\29\139\4\128\33\180\162\24\66\41\208\106\24\81\160\213\20\163\96\149\208\86\118\12\148\178\182\247\65\171\45\53\37\56\216\31\8\64\64\84\230\28\171\68\117\163\151\56\196\89\237\109\125\175\56\210\251\144\190\196\193\139\138\212\50\162\191\219\250\87\92\135\0\40\60\22\128\62\38\16\95\29\65\232\0\21\127\29\235\114\0\247\216\165\153\136\163\194\203\63\247\142\201\122\168\210\212\101\161\67\105\22\247\24\1\130\161\132\4\200\30\249\215\124\0\3\196\150\197\1\252\190\31\191\34\148\230\255\0\173\118\74\170\112\109\6\74\0\0\0\37\116\69\88\116\100\97\116\101\58\99\114\101\97\116\101\0\50\48\50\49\45\48\56\45\49\48\84\49\51\58\49\57\58\48\52\43\48\48\58\48\48\124\162\137\85\0\0\0\37\116\69\88\116\100\97\116\101\58\109\111\100\105\102\121\0\50\48\50\49\45\48\56\45\49\48\84\49\51\58\49\57\58\48\52\43\48\48\58\48\48\13\255\49\233\0\0\0\0\73\69\78\68\174\66\96\130"