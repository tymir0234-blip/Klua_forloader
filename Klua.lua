-- @author Kayzee
-- @version 6.2

(function()
local V = "6.2"

local cfg = {}
local dirty = false
local _DB = "KLua_menu_cfg"

local function StoreB(k, d) if cfg[k] == nil then cfg[k] = d or false end return cfg[k] end
local function StoreI(k, d) if cfg[k] == nil then cfg[k] = d or 0 end return math.floor(cfg[k]) end
local function StoreF(k, d) if cfg[k] == nil then cfg[k] = d or 0 end return cfg[k] end
local function StoreS(k, d) if cfg[k] == nil then cfg[k] = d or "" end return cfg[k] end
local function StoreC(k, r, g, b)
    if cfg[k] == nil then cfg[k] = {r or 255, g or 255, b or 255, 255} end
    return cfg[k]
end

local SAVE_KEYS = {
    "res_enable", "res_offset", "min_hit", "adapt", "log_miss",
    "hb_head", "hb_chest", "hb_stomach",
    "fast_acc", "revolver_fix",
    "sa_enable", "sa_fov", "sa_smooth", "sa_visible", "sa_shoot_only", "sa_rcomp", "sa_hitboxes",
    "dmg_enable", "dmg_life", "dmg_size", "dmg_rise", "dmg_drift", "dmg_dist", "dmg_head", "dmg_kill",
    "dmg_col_norm", "dmg_col_head", "dmg_col_kill",
    "aim_vis", "aim_vis_col",
    "hit_fx", "hit_fx_size", "hit_fx_life", "hit_fx_ring", "hit_fx_col",
    "kill_fx", "kill_fx_size", "kill_fx_life", "kill_fx_col",
    "remove_smoke",
    "wm_enable", "wm_show_nick", "wm_show_fps", "wm_show_ghz", "wm_show_gpu", "wm_show_ping",
    "wm_opacity", "wm_pos", "wm_accent", "info_panel",
    "menu_accent",
    "nc_enable", "nc_tag", "nc_mode", "nc_cursor", "nc_speed", "nc_nick",
    "cf_enable"
}

local function serialize()
    local out = { "KLMENU_1" }
    for _, k in ipairs(SAVE_KEYS) do
        local v = cfg[k]
        if type(v) == "boolean" then
            out[#out+1] = k .. "|b|" .. (v and "1" or "0")
        elseif type(v) == "table" then
            out[#out+1] = k .. "|t|" .. v[1] .. "," .. v[2] .. "," .. v[3] .. "," .. (v[4] or 255)
        elseif type(v) == "string" then
            out[#out+1] = k .. "|s|" .. v
        elseif v ~= nil then
            out[#out+1] = k .. "|n|" .. tostring(v)
        end
    end
    return table.concat(out, "\n")
end

local function parse(str)
    if type(str) ~= "string" then return nil end
    local d, header = {}, false
    for line in str:gmatch("[^\r\n]+") do
        if not header then
            if line ~= "KLMENU_1" then return nil end
            header = true
        else
            local k, t, v = line:match("^([%w_]+)|([nbst])|(.+)$")
            if k then
                if t == "b" then d[k] = (v == "1")
                elseif t == "t" then
                    local r,g,b,a = v:match("(%d+),(%d+),(%d+),?(%d*)")
                    if r then d[k] = {tonumber(r), tonumber(g), tonumber(b), (a ~= "" and tonumber(a)) or 255} end
                elseif t == "s" then
                    d[k] = v
                else d[k] = tonumber(v) end
            end
        end
    end
    if not header then return nil end
    return d
end

local function cfgsave()
    dirty = false
    database.save(_DB, serialize())
end

local function cfgload()
    if database.exists(_DB) then
        local d = parse(database.load(_DB))
        if d then
            for k, v in pairs(d) do
                if cfg[k] ~= nil and type(v) == type(cfg[k]) then cfg[k] = v end
            end
        end
    end
end

StoreB("res_enable", true) StoreI("res_offset", 58) StoreI("min_hit", 45)
StoreB("adapt", true) StoreB("log_miss", false)
StoreB("hb_head", true) StoreB("hb_chest", true) StoreB("hb_stomach", true)
StoreB("fast_acc", false) StoreB("revolver_fix", true)
StoreB("sa_enable", false) StoreF("sa_fov", 15.0) StoreI("sa_smooth", 0) StoreB("sa_visible", false) StoreB("sa_shoot_only", false) StoreB("sa_rcomp", true) StoreI("sa_hitboxes", 63)
StoreB("dmg_enable", true) StoreI("dmg_life", 1300) StoreI("dmg_size", 22) StoreI("dmg_rise", 60) StoreI("dmg_drift", 28) StoreB("dmg_dist", true) StoreB("dmg_head", true) StoreB("dmg_kill", true)
StoreC("dmg_col_norm", 255, 255, 255) StoreC("dmg_col_head", 255, 210, 60) StoreC("dmg_col_kill", 255, 70, 70)
StoreB("aim_vis", true) StoreC("aim_vis_col", 255, 0, 255)
StoreB("hit_fx", true) StoreI("hit_fx_size", 10) StoreI("hit_fx_life", 450) StoreB("hit_fx_ring", true) StoreC("hit_fx_col", 173, 241, 117)
StoreB("kill_fx", true) StoreI("kill_fx_size", 64) StoreI("kill_fx_life", 950) StoreC("kill_fx_col", 173, 241, 117)
StoreB("remove_smoke", true)
StoreB("wm_enable", true) StoreB("wm_show_nick", true) StoreB("wm_show_fps", true) StoreB("wm_show_ghz", true) StoreB("wm_show_gpu", true) StoreB("wm_show_ping", true)
StoreF("wm_opacity", 0.55) StoreI("wm_pos", 2) StoreC("wm_accent", 70, 130, 255) StoreB("info_panel", false)
StoreC("menu_accent", 173, 241, 117)
StoreB("nc_enable", false) StoreI("nc_tag", 0) StoreI("nc_mode", 1) StoreI("nc_cursor", 0) StoreF("nc_speed", 0.5) StoreS("nc_nick", "bars1k")
StoreB("cf_enable", true)

cfgload()

-- ==========================================
-- CONSOLE FILTER
-- ==========================================
local CF_PREFIX = "[K/M]"
local cf_saved = false
local cf_orig_enable = "0"
local cf_orig_text = ""
local cf_last_state = nil

local function cf_save_original()
    if cf_saved then return end
    cf_saved = true
    local ok, val = pcall(cvar.get_string, "con_filter_enable")
    if ok and val then cf_orig_enable = val end
    ok, val = pcall(cvar.get_string, "con_filter_text")
    if ok and val then cf_orig_text = val end
end

local function cf_apply()
    local want = StoreB("cf_enable", false)
    if want then
        cf_save_original()
        pcall(function()
            engine.exec('con_filter_enable 1')
            engine.exec(string.format('con_filter_text "%s"', CF_PREFIX))
        end)
    elseif cf_saved then
        pcall(function()
            engine.exec(string.format("con_filter_enable %s", cf_orig_enable or "0"))
            engine.exec(string.format('con_filter_text "%s"', cf_orig_text or ""))
        end)
    end
end

local function cf_tick()
    local want = StoreB("cf_enable", false)
    if cf_last_state == want then return end
    cf_last_state = want
    cf_apply()
end

local function log_kill(msg)
    pcall(function() client.log(CF_PREFIX .. " KILL " .. msg) end)
end

local function log_miss(msg)
    pcall(function() client.log(CF_PREFIX .. " MISS " .. msg) end)
end

-- Miss tracking for silent aim (resolver logs its own cycles)
local miss_last_hit = 0
local miss_last_log = 0

local g_scale = 1.0
local T = {
    Dark = {12,12,16,255}, Light = {22,22,29,255}, Mid = {16,16,21,255},
    Outline = {9,8,11,255}, Accent = {173,241,117,255}, White = {226,230,248,255},
    TextDim = {62,62,70,255}, TextHov = {110,110,122,255}, TreeDim = {52,56,52,255},
    Shadow = {0,0,0,160},
    W=600, H=420, HeadH=30, SideX=10, SideY=34, SideW=145,
    ProfH=43, TabH=22, SubH=18,
}
local C_TEXT_ON = {190,192,206,255}
local C_BOX_OFF = {33,33,41,255}
local C_ACCENT_DARK = {88,128,58,255}

local function S(v) return math.floor(v * g_scale + 0.5) end
local function clrLerp(a, b, t)
    return { math.floor(a[1]+(b[1]-a[1])*t), math.floor(a[2]+(b[2]-a[2])*t), math.floor(a[3]+(b[3]-a[3])*t), math.floor((a[4] or 255)+((b[4] or 255)-(a[4] or 255))*t) }
end
local function clrA(c, a) return {c[1], c[2], c[3], math.floor((c[4] or 255)*a)} end
local anim_v = {}
local function anim(id, target, speed)
    speed = speed or 14
    if anim_v[id] == nil then anim_v[id] = target end
    local dt = globals.frametime()
    if dt <= 0 or dt > 0.2 then dt = 0.016 end
    anim_v[id] = anim_v[id] + (target - anim_v[id]) * math.min(1, dt*speed)
    return anim_v[id]
end
local function txt(x, y, c, s)
    x, y = math.floor(x), math.floor(y)
    local sh = clrA(T.Shadow, (c[4] or 255)/255)
    imgui.dl_add_text(x+1, y+1, sh[1], sh[2], sh[3], sh[4], s)
    imgui.dl_add_text(x, y, c[1], c[2], c[3], c[4] or 255, s)
end
local function frame(mx, my, Mx, My, borders, fill)
    if fill then imgui.dl_add_rect_filled(mx, my, Mx, My, fill[1], fill[2], fill[3], fill[4] or 255, 0) end
    local o = 0
    for _, c in ipairs(borders) do
        imgui.dl_add_rect(mx+o, my+o, Mx-o, My-o, c[1], c[2], c[3], c[4] or 255, 0, 1)
        o = o + 1
    end
end
local function ttop(y, h) return math.floor(y + (h - imgui.get_font_size()) * 0.5) end

local function hsv(h, s, v)
    local i = math.floor(h*6) local f = h*6 - i
    local p, q, t = v*(1-s), v*(1-f*s), v*(1-(1-f)*s)
    local r, g, b
    i = i % 6
    if i==0 then r,g,b=v,t,p elseif i==1 then r,g,b=q,v,p
    elseif i==2 then r,g,b=p,v,t elseif i==3 then r,g,b=p,q,v
    elseif i==4 then r,g,b=t,p,v else r,g,b=v,p,q end
    return math.floor(r*255+.5), math.floor(g*255+.5), math.floor(b*255+.5)
end
local function rgb2hsv(r, g, b)
    r, g, b = r/255, g/255, b/255
    local mx = math.max(r,g,b) local mn = math.min(r,g,b) local d = mx - mn
    local h, s, v = 0, mx==0 and 0 or d/mx, mx
    if d ~= 0 then
        if mx==r then h=((g-b)/d)%6 elseif mx==g then h=(b-r)/d+2 else h=(r-g)/d+4 end
        h = h/6
    end
    return h, s, v
end

local KR=18 local KL=13 local KLG=2 local KG=5 local KI=15
local KB=10 local KBO=9 local KBT=12 local KCB=18

local function cp_size() return S(6)+S(100)+S(6)+S(10)+S(6), S(6)+S(100)+S(6)+S(8)+S(6) end
local function cp_body(col)
    local pad, sv, bar, ab = S(6), S(100), S(10), S(8)
    local wx, wy = imgui.get_window_pos() local sx, sy = cp_size() local mxp, myp = imgui.get_mouse_pos()
    frame(wx, wy, wx+sx, wy+sy, {T.Outline, T.Mid}, T.Light)
    local h, s, v = rgb2hsv(col[1], col[2], col[3])
    local ax, ay = wx+pad, wy+pad
    local bx, by = ax+sv, ay+sv
    local hr, hg, hb = hsv(h, 1, 1)
    imgui.dl_add_rect_filled_multicolor(ax, ay, bx, by, {255,255,255,255}, {hr,hg,hb,255}, {hr,hg,hb,255}, {255,255,255,255})
    imgui.dl_add_rect_filled_multicolor(ax, ay, bx, by, {0,0,0,0}, {0,0,0,0}, {0,0,0,255}, {0,0,0,255})
    imgui.dl_add_rect(ax-1, ay-1, bx+1, by+1, T.Outline[1], T.Outline[2], T.Outline[3], 255, 0, 1)
    imgui.set_cursor_screen_pos(ax, ay) imgui.invisible_button("##sv", sv, sv)
    if imgui.is_item_active() then s = math.max(0, math.min(1, (mxp-ax)/sv)) v = 1 - math.max(0, math.min(1, (myp-ay)/sv)) local r2,g2,b2 = hsv(h,s,v) col[1],col[2],col[3] = r2,g2,b2 end
    local cx, cy = math.floor(ax+s*sv), math.floor(ay+(1-v)*sv)
    imgui.dl_add_rect(cx-3, cy-3, cx+4, cy+4, T.Outline[1], T.Outline[2], T.Outline[3], 255, 0, 1)
    imgui.dl_add_rect(cx-2, cy-2, cx+3, cy+3, 255,255,255,255, 0, 1)
    local hx = bx+pad
    for i = 0, 5 do
        local c0r,c0g,c0b = hsv(i/6,1,1) local c1r,c1g,c1b = hsv((i+1)/6,1,1)
        imgui.dl_add_rect_filled_multicolor(hx, math.floor(ay+sv*i/6), hx+bar, math.floor(ay+sv*(i+1)/6), {c0r,c0g,c0b,255}, {c0r,c0g,c0b,255}, {c1r,c1g,c1b,255}, {c1r,c1g,c1b,255})
    end
    imgui.dl_add_rect(hx-1, ay-1, hx+bar+1, by+1, T.Outline[1], T.Outline[2], T.Outline[3], 255, 0, 1)
    imgui.set_cursor_screen_pos(hx, ay) imgui.invisible_button("##hue", bar, sv)
    if imgui.is_item_active() then h = math.max(0, math.min(1, (myp-ay)/sv))*0.9999 local r2,g2,b2 = hsv(h,s,v) col[1],col[2],col[3] = r2,g2,b2 end
    local hy = math.floor(ay+h*sv)
    imgui.dl_add_rect(hx-1, hy-1, hx+bar+1, hy+2, 255,255,255,255, 0, 1)
    local aw = (hx+bar) - ax local a2x, a2y = ax, by+pad local b2x, b2y = ax+aw, a2y+ab
    local cr, cg, cb = hsv(h,s,v)
    imgui.dl_add_rect_filled(a2x, a2y, b2x, b2y, T.Dark[1], T.Dark[2], T.Dark[3], 255, 0)
    imgui.dl_add_rect_filled_multicolor(a2x, a2y, b2x, b2y, {cr,cg,cb,0}, {cr,cg,cb,255}, {cr,cg,cb,255}, {cr,cg,cb,0})
    imgui.dl_add_rect(a2x-1, a2y-1, b2x+1, b2y+1, T.Outline[1], T.Outline[2], T.Outline[3], 255, 0, 1)
    imgui.set_cursor_screen_pos(a2x, a2y) imgui.invisible_button("##alpha", aw, ab)
    if imgui.is_item_active() then col[4] = math.floor(255 * math.max(0, math.min(1, (mxp-a2x)/aw))) end
    local axp = math.floor(a2x + (col[4]/255)*aw)
    imgui.dl_add_rect(axp-1, a2y-1, axp+2, b2y+1, 255,255,255,255, 0, 1)
end
local function color_btn(rx, ry, w, h, col)
    imgui.set_cursor_screen_pos(rx, ry) local clicked = imgui.invisible_button("##col", w, h)
    local hov = imgui.is_item_hovered() local id = imgui.get_item_id() local open = imgui.is_popup_open("##cp")
    anim(id, (hov or open) and 1 or 0)
    frame(rx+S(2), ry+S(2), rx+w-S(2), ry+h-S(2), {T.Outline}, col)
    if clicked then imgui.open_popup("##cp") end
    local px, py = cp_size()
    imgui.set_next_window_pos(rx+w-px, ry+h+S(2)) imgui.set_next_window_size(px, py)
    imgui.push_style_var(imgui.StyleVar_WindowPadding, 0, 0) imgui.push_style_var(imgui.StyleVar_WindowBorderSize, 0)
    local ok = imgui.begin_popup("##cp", imgui.WindowFlags_NoTitleBar + imgui.WindowFlags_NoResize + imgui.WindowFlags_NoMove + imgui.WindowFlags_NoSavedSettings + imgui.WindowFlags_NoBackground)
    imgui.pop_style_var(2)
    if ok then cp_body(col) imgui.end_popup() end
end

local KEY_N = {[1]="M1",[2]="M2",[3]="M3",[4]="M4",[5]="M5",[8]="BK",[9]="TAB",[13]="ENT",[16]="SH",[17]="CT",[18]="AL",[27]="ESC",[32]="SP"}
for i=65,90 do KEY_N[i] = string.char(i) end
for i=48,57 do KEY_N[i] = string.char(i) end
local listen = {}
local function key_btn(rx, ry, w, h, kref, mref)
    imgui.set_cursor_screen_pos(rx, ry)
    local c1 = imgui.invisible_button("##kb", w, h)
    local c2 = imgui.is_item_clicked(1) local hov = imgui.is_item_hovered()
    local id = imgui.get_item_id() local il = listen[id] or false
    if c2 then imgui.open_popup("##kbmode") end
    if c1 then il = true listen[id] = true end
    if il and not imgui.is_mouse_down(0) then
        local nk = 0
        if input.is_key_down(27) then il=false listen[id]=false
        else
            if input.is_mouse_down(3) then nk = 4 elseif input.is_mouse_down(4) then nk = 5
            elseif input.is_mouse_down(0) then nk = 1 elseif input.is_mouse_down(1) then nk = 2
            elseif input.is_mouse_down(2) then nk = 3 end
            if nk == 0 then for vk = 8, 254 do if vk ~= 1 and vk ~= 2 and vk ~= 4 and vk ~= 5 and vk ~= 6 then if input.is_key_down(vk) then nk = vk break end end end end
            if nk ~= 0 then kref[1] = nk il=false listen[id]=false end
        end
    end
    anim(id, (hov or il) and 1 or 0)
    frame(rx, ry, rx+w, ry+h, {T.Outline}, il and T.Accent or C_BOX_OFF)
    local nm = (kref[1]==0) and "-" or (KEY_N[kref[1]] or string.format("K%d", kref[1]))
    local tw = imgui.calc_text_size(nm)
    txt(math.floor(rx+(w-tw)*0.5), ttop(ry,h), {225,228,240,255}, nm)
    imgui.set_next_window_pos(rx, ry+h+S(2)) imgui.set_next_window_size(w, S(54))
    imgui.push_style_var(imgui.StyleVar_WindowPadding, 0, 0) imgui.push_style_var(imgui.StyleVar_WindowBorderSize, 0)
    local ok = imgui.begin_popup("##kbmode", imgui.WindowFlags_NoTitleBar + imgui.WindowFlags_NoResize + imgui.WindowFlags_NoMove + imgui.WindowFlags_NoSavedSettings + imgui.WindowFlags_NoBackground)
    imgui.pop_style_var(2)
    if ok then
        frame(rx, ry+h+S(2), rx+w, ry+h+S(2)+S(54), {T.Outline, T.Mid}, T.Light)
        local modes = {"hold", "toggle", "always"}
        for i = 0, 2 do
            imgui.set_cursor_screen_pos(rx+S(4), ry+h+S(2)+i*S(16))
            if imgui.selectable(modes[i+1], mref[1]==i, w-S(8), S(14)) then mref[1] = i imgui.close_current_popup() end
        end
        imgui.end_popup()
    end
end

local g_start_x, g_start_y, g_max_x, g_title
local function bg(t)
    imgui.dummy(0, S(10))
    g_title = t
    g_start_x, g_start_y = imgui.get_cursor_screen_pos()
    g_max_x = g_start_x + imgui.get_content_region_avail()
    imgui.indent(S(10))
    imgui.dummy(0, S(5))
end
local function eg()
    imgui.dummy(0, S(5))
    imgui.unindent(S(10))
    local _, cy = imgui.get_cursor_screen_pos()
    local rmin_x, rmax_x = g_start_x - S(10), g_max_x
    local rmin_y, rmax_y = g_start_y, cy
    frame(rmin_x, rmin_y, rmax_x, rmax_y, {T.Outline, T.Mid}, nil)
    local ts = imgui.calc_text_size(g_title) local tx = rmin_x + S(8)
    imgui.dl_add_rect_filled(tx, rmin_y, tx+ts+S(6), rmin_y+2, T.Light[1], T.Light[2], T.Light[3], 255, 0)
    txt(tx+S(3), rmin_y - math.floor(imgui.get_font_size()*0.5), {150,152,166,255}, g_title)
    imgui.dummy(0, S(8))
end

local function chk(label, key, def, wkb, wclr, r, g, b)
    imgui.push_id(label)
    local px, py = imgui.get_cursor_screen_pos() local w = g_max_x - px local h = S(KR)
    local cw = wclr and S(KCB) or 0 local kw = wkb and S(22) or 0 local gap = (wkb and wclr) and S(2) or 0
    imgui.set_cursor_screen_pos(px, py) local clicked = imgui.invisible_button("##cb", w - kw - gap - cw, h)
    local hov = imgui.is_item_hovered() local id = imgui.get_item_id()
    local cur = StoreB(key, def) if clicked then cfg[key] = not cur cur = not cur dirty = true end
    local st = anim(id, cur and 1 or 0) local ht = anim(id+1, hov and 1 or 0)
    local bs = S(KBO) local by = math.floor(py + (h-bs)*0.5)
    local fill = clrLerp(clrLerp(C_BOX_OFF, {46,46,58,255}, ht), T.Accent, st)
    frame(px, by, px+bs, by+bs, {T.Outline}, fill)
    local col = clrLerp(clrLerp(T.TextDim, T.TextHov, ht), C_TEXT_ON, st)
    txt(px+S(KI), ttop(py, h), col, label)
    if wkb then
        local kx = px + w - kw - (wclr and (gap+cw) or 0)
        local kref = {StoreI(key..".key", 0)} local mref = {StoreI(key..".mode", 0)}
        key_btn(kx, py, kw, h, kref, mref)
        cfg[key..".key"] = kref[1] cfg[key..".mode"] = mref[1]
    end
    if wclr then local cd = StoreC(key..".col", r or 173, g or 241, b or 117) color_btn(px+w-cw, py, cw, h, cd) end
    imgui.set_cursor_screen_pos(px, py) imgui.dummy(w, h+S(KG))
    imgui.pop_id()
end

local function color_row(label, key, r, g, b)
    imgui.push_id(label)
    local px, py = imgui.get_cursor_screen_pos() local w = g_max_x - px local h = S(KR) local cw = S(KCB)
    txt(px+S(KI), ttop(py, h), T.TextHov, label)
    local cd = StoreC(key, r or 255, g or 255, b or 255) color_btn(px+w-cw, py, cw, h, cd)
    imgui.set_cursor_screen_pos(px, py) imgui.dummy(w, h+S(KG))
    imgui.pop_id()
end

local function combo(label, key, def, items)
    imgui.push_id(label)
    local px, py = imgui.get_cursor_screen_pos() local w = g_max_x - px
    local tx = px+S(KI) local bw = px+w-tx local bh = S(KR) local by = py+S(KL)+S(KLG)
    txt(tx, py, T.TextHov, label)
    imgui.set_cursor_screen_pos(tx, by) if imgui.invisible_button("##combo", bw, bh) then imgui.open_popup("##pop") end
    local hov = imgui.is_item_hovered() local id = imgui.get_item_id() local open = imgui.is_popup_open("##pop")
    local ht = anim(id, hov and 1 or 0) local ot = anim(id+1, open and 1 or 0)
    local cur = StoreI(key, def)
    frame(tx, by, tx+bw, by+bh, {T.Outline}, clrLerp(T.Mid, {26,26,34,255}, ht))
    txt(tx+S(6), ttop(by,bh), clrLerp(T.TextHov, C_TEXT_ON, ot), items[cur+1] or "?")
    local ax = math.floor(tx+bw-S(10)) local ay = math.floor(by+bh*0.5)
    local ac = clrLerp(clrLerp(T.TextDim, T.TextHov, ht), T.Accent, ot) local hw, hh = S(3), S(2)
    if open then imgui.dl_add_triangle_filled(ax-hw, ay+hh, ax+hw+1, ay+hh, ax+0.5, ay-hh, ac[1],ac[2],ac[3],ac[4])
    else imgui.dl_add_triangle_filled(ax-hw, ay-hh, ax+hw+1, ay-hh, ax+0.5, ay+hh, ac[1],ac[2],ac[3],ac[4]) end
    local ih = S(16)
    imgui.set_next_window_pos(tx, by+bh+S(1)) imgui.set_next_window_size(bw, ih*#items+2)
    imgui.push_style_var(imgui.StyleVar_WindowPadding, 0, 0) imgui.push_style_var(imgui.StyleVar_WindowBorderSize, 0)
    local ok = imgui.begin_popup("##pop", imgui.WindowFlags_NoTitleBar + imgui.WindowFlags_NoResize + imgui.WindowFlags_NoMove + imgui.WindowFlags_NoSavedSettings + imgui.WindowFlags_NoBackground)
    imgui.pop_style_var(2)
    if ok then
        local wx, wy = imgui.get_window_pos() frame(wx, wy, wx+bw, wy+ih*#items+2, {T.Outline, T.Mid}, T.Light)
        for i = 1, #items do
            imgui.push_id(i) local ix, iy = wx+1, wy+1+ih*(i-1)
            imgui.set_cursor_screen_pos(ix, iy) if imgui.invisible_button("##it", bw-2, ih) then cfg[key] = i-1 dirty = true imgui.close_current_popup() end
            local it = anim(imgui.get_item_id(), imgui.is_item_hovered() and 1 or 0) local sel = (cur == i-1) and 1 or 0
            local bg = clrA(T.Accent, 0.07*it) imgui.dl_add_rect_filled(ix, iy, ix+bw-2, iy+ih, bg[1],bg[2],bg[3],bg[4], 0)
            local tc = clrLerp(clrLerp(T.TextDim, T.TextHov, it), T.Accent, sel) txt(ix+S(5), ttop(iy,ih), tc, items[i])
            imgui.pop_id()
        end
        imgui.end_popup()
    end
    imgui.set_cursor_screen_pos(px, py) imgui.dummy(w, S(KL)+S(KLG)+bh+S(KG))
    imgui.pop_id()
end

local function slider(label, key, def, mn, mx, step, fmt, is_int)
    step = step or 1 fmt = fmt or "%.0f"
    imgui.push_id(label)
    local px, py = imgui.get_cursor_screen_pos() local w = g_max_x - px
    local tx = px+S(KI) local by = py+S(KL)+S(KLG) local bh = S(KB)
    txt(tx, py, T.TextHov, label)
    local cur = is_int and StoreI(key, def) or StoreF(key, def)
    local x0 = tx+S(KBT+2) local x1 = px+w-S(KBT+2) local btnY = by-S(2) local btnH = bh+S(4)
    local frac = anim(imgui.get_id("sl_anim"..key), math.max(0, math.min(1, (cur-mn)/(mx-mn))), 22)
    frame(x0, by, x1, by+bh, {T.Outline}, T.Dark)
    local fw = math.floor((x1-x0-2)*frac)
    if fw > 0 then imgui.dl_add_rect_filled_multicolor(x0+1, by+1, x0+1+fw, by+bh-1, {C_ACCENT_DARK[1],C_ACCENT_DARK[2],C_ACCENT_DARK[3],255}, {T.Accent[1],T.Accent[2],T.Accent[3],255}, {T.Accent[1],T.Accent[2],T.Accent[3],255}, {C_ACCENT_DARK[1],C_ACCENT_DARK[2],C_ACCENT_DARK[3],255}) end
    local buf = string.format(fmt, cur) local tw = imgui.calc_text_size(buf)
    txt(math.floor((x0+x1-tw)*0.5), ttop(by,bh), {225,228,240,255}, buf)
    imgui.set_cursor_screen_pos(x0, by) imgui.invisible_button("##bar", x1-x0, bh)
    if imgui.is_item_active() then
        local mxp = imgui.get_mouse_pos() local t = math.max(0, math.min(1, (mxp-x0)/(x1-x0)))
        local nv = mn + t*(mx-mn) nv = math.floor((nv-mn)/step + 0.5)*step + mn
        if nv < mn then nv = mn end if nv > mx then nv = mx end
        cur = nv cfg[key] = is_int and math.floor(cur) or cur dirty = true
    end
    local function sb(sid, bx, plus)
        imgui.set_cursor_screen_pos(bx, btnY) imgui.invisible_button(sid, S(KBT), btnH)
        local hov = imgui.is_item_hovered()
        if hov and imgui.is_mouse_clicked(0) then
            local nv = cur + (plus and step or -step) if nv < mn then nv = mn end if nv > mx then nv = mx end
            cur = nv cfg[key] = is_int and math.floor(cur) or cur dirty = true
        end
        local t = anim(imgui.get_item_id(), hov and 1 or 0) local bxc = bx+S(KBT)*0.5 local byc = by+bh*0.5-1
        local ac = clrLerp(T.TextDim, {255,255,255,255}, t) local arm = S(3)
        imgui.dl_add_rect_filled(math.floor(bxc-arm), math.floor(byc), math.floor(bxc+arm+1), math.floor(byc+1), ac[1],ac[2],ac[3],255,0)
        if plus then imgui.dl_add_rect_filled(math.floor(bxc), math.floor(byc-arm), math.floor(bxc+1), math.floor(byc+arm+1), ac[1],ac[2],ac[3],255,0) end
    end
    sb("##minus", tx, false) sb("##plus", px+w-S(KBT), true)
    imgui.set_cursor_screen_pos(px, py) imgui.dummy(w, S(KL)+S(KLG)+bh+S(KG))
    imgui.pop_id()
end
local function Sld(l, k, mn, mx, d) slider(l, k, d, mn, mx, 1, "%.0f", true) end
local function SldF(l, k, mn, mx, d, st) slider(l, k, d, mn, mx, st or 0.1, "%.1f", false) end
local function Chk(l, k, d, kb) chk(l, k, d, kb or false, false) end
local function ChkC(l, k, d, r, g, b) chk(l, k, d, false, true, r, g, b) end
local function Clr(l, k, r, g, b) color_row(l, k, r, g, b) end
local function Cmb(l, k, items, def) combo(l, k, def or 0, items) end

local function pick_buttons(pick)
    local ret = pick
    local ar, ag, ab = T.Accent[1], T.Accent[2], T.Accent[3]
    local lbls = {"Head", "Neck", "Chest", "Stomach", "Arms", "Legs"}
    for bi = 1, 6 do
        local on = math.floor(pick / 2 ^ (bi - 1)) % 2 == 1
        if on then
            imgui.push_style_color(imgui.Col_Button, ar/255, ag/255, ab/255, 0.8)
            imgui.push_style_color(imgui.Col_Text, 0.04, 0.04, 0.04, 1.0)
        else
            imgui.push_style_color(imgui.Col_Button, 0.14, 0.14, 0.17, 1.0)
            imgui.push_style_color(imgui.Col_Text, 0.8, 0.8, 0.8, 1.0)
        end
        if imgui.button(lbls[bi] .. "##sa_p" .. bi, 0, 0) then
            local bit = 2 ^ (bi - 1)
            if on then ret = ret - bit else ret = ret + bit end
            dirty = true
        end
        imgui.pop_style_color(2)
        imgui.same_line()
    end
    return ret
end

local hitbox = hitbox
local buttons = buttons

-- NAME CHANGER
local ffi_mod = rawget(_G, "ffi")
if not ffi_mod then pcall(function() ffi_mod = require("ffi") end) end
local kernel32 = nil
if ffi_mod then
    pcall(function() ffi_mod.cdef[[
        typedef unsigned char np_u8;
        typedef unsigned int np_u32;
        typedef unsigned long long np_u64;
        typedef void* np_handle;
        np_handle GetModuleHandleA(const char* name);
        int VirtualProtect(void* addr, np_u64 size, unsigned long prot, unsigned long* old);
    ]] end)
    local ok, lib = pcall(ffi_mod.load, "kernel32")
    if ok then kernel32 = lib end

    if kernel32 then
        local function u16(p) return ffi_mod.cast("uint16_t*", p)[0] end
        local function i32(p) return ffi_mod.cast("int32_t*", p)[0] end
        local function u32(p) return ffi_mod.cast("uint32_t*", p)[0] end
        local function to_ptr(addr) return ffi_mod.cast("uint8_t*", ffi_mod.cast("np_u64", addr)) end
        local function text_section(mod_name)
            local base = ffi_mod.cast("uint8_t*", kernel32.GetModuleHandleA(mod_name))
            if base == nil then return nil end
            local nt = base + i32(base + 0x3C)
            if u32(nt) ~= 0x00004550 then return nil end
            local num_sections = u16(nt + 0x06)
            local opt_size     = u16(nt + 0x14)
            local sect         = nt + 0x18 + opt_size
            for i = 0, num_sections - 1 do
                local hdr = sect + i * 40
                if ffi_mod.string(hdr, 5) == ".text" then
                    return base + u32(hdr + 0x0C), u32(hdr + 0x08)
                end
            end
            return nil
        end
        local function pat(str)
            local t = {}
            for tok in str:gmatch("%S+") do
                if tok == "?" or tok == "??" then t[#t + 1] = false
                else t[#t + 1] = tonumber(tok, 16) end
            end
            return t
        end
        local function find_pattern(start, size, bytes)
            local n = #bytes
            for off = 0, size - n do
                local q = start + off
                local hit = true
                for k = 1, n do
                    local w = bytes[k]
                    if w ~= false and q[k - 1] ~= w then hit = false; break end
                end
                if hit then return q, off end
            end
            return nil
        end
        local SIG_NAME_GATE = pat("48 C1 E8 ? A8 01 ? 15")
        local function unlock_name_convar()
            local start, size = text_section("engine2.dll")
            if not start then return end
            local patched = false
            local from = 0
            while true do
                local q, off = find_pattern(start + from, size - from, SIG_NAME_GATE)
                if not q then break end
                local target = q + 6
                if target[0] == 0xEB then patched = true break end
                if target[0] == 0x75 then
                    local old = ffi_mod.new("unsigned long[1]")
                    if kernel32.VirtualProtect(target, 1, 0x40, old) ~= 0 then
                        target[0] = 0xEB
                        kernel32.VirtualProtect(target, 1, old[0], old)
                        patched = true
                    end
                    break
                end
                from = from + off + 1
            end
        end
        unlock_name_convar()

        local OFF_NAME = 0x6FC
        local OFF_SANITIZED = 0x878
        local OFF_DIRTY = 0x974
        local function write_name_to_controller(text)
            local ctrl = entitylist.get_local_controller()
            if not ctrl or not ctrl:is_valid() then return false end
            local ok = pcall(function()
                local addr = ctrl:get_address()
                if not addr or addr == 0 then return end
                local base = to_ptr(addr)
                local n = #text
                if n > 127 then n = 127 end
                local namep = base + OFF_NAME
                for i = 0, n - 1 do namep[i] = text:byte(i + 1) end
                namep[n] = 0
                (base + OFF_DIRTY)[0] = 1
                local sp = ffi_mod.cast("char**", base + OFF_SANITIZED)[0]
                if sp ~= nil then
                    local cap = #ffi_mod.string(sp)
                    local m = n < cap and n or cap
                    for i = 0, m - 1 do sp[i] = text:byte(i + 1) end
                    sp[m] = 0
                end
            end)
            return ok
        end
        cfg._write_name = write_name_to_controller
    end
end

local TAG_LIST = {
    "[None]", "aimware.net", "crack aw.net",
    "enigma v1.5 legit", "ev0lve.xyz",
    "fatality.win", "crack fat.win", "gamesense.pub",
    "crack huiONE", "legendware.pw",
    "neverlose.cc", "nl.cc", "crack nl.cc", "nixware.cc",
    "onetap.su", "primordial.gg", "sharkhack",
    "skeet.cc", "crack skeet.cc", "spirthack.me", "weave.su"
}
local LOOKALIKE = {e="3",i="1",s="$",g="9",a="@",o="0",t="7",l="|",b="8",z="2"}
local nc_cache = {}
local nc_was_enabled, nc_frame_idx, nc_next_at, nc_last_tag, nc_last_mode, nc_last_applied, nc_last_exec = false, 1, 0, nil, nil, "", ""

local function build_typing(text)
    local frames = {"|", ""}
    for i = 1, #text do
        local p = text:sub(1, i)
        table.insert(frames, p .. "|")
        if i == 2 or i == 4 or i == 5 or i == 7 or i == 8 then table.insert(frames, p) table.insert(frames, p .. "|") end
    end
    table.insert(frames, text) table.insert(frames, text .. "|") table.insert(frames, text)
    for i = #text - 1, 1, -1 do
        local p = text:sub(1, i)
        table.insert(frames, p) table.insert(frames, p .. "|")
        if i == 4 or i == 2 then table.insert(frames, p) table.insert(frames, p .. "|") end
    end
    table.insert(frames, "") table.insert(frames, "|")
    return frames
end
local function build_jitter(text)
    local frames = {text}
    for _ = 1, 6 do
        local chars = {}
        for i = 1, #text do chars[i] = text:sub(i, i) end
        for _ = 1, math.min(2, #text) do
            local pos = math.random(1, #text)
            local repl = LOOKALIKE[chars[pos]]
            if repl then chars[pos] = repl end
        end
        frames[#frames + 1] = table.concat(chars)
        frames[#frames + 1] = text
    end
    return frames
end
local function build_sliding(text)
    local frames = {}
    local padded = text .. "    " .. text
    for i = 1, #padded - 4 do
        local f = padded:sub(i, i+4)
        table.insert(frames, f) table.insert(frames, f)
    end
    return frames
end
local function get_frames(tag_name, mode_idx)
    local key = tag_name .. "|" .. mode_idx
    if nc_cache[key] then return nc_cache[key] end
    local frames
    if mode_idx == 1 then frames = build_typing(tag_name)
    elseif mode_idx == 2 then frames = build_jitter(tag_name)
    elseif mode_idx == 3 then frames = build_sliding(tag_name)
    else frames = {tag_name} end
    nc_cache[key] = frames
    return frames
end

local function apply_name(text)
    text = tostring(text or ""):gsub("[\"\\;]", "")
    if #text > 127 then text = text:sub(1, 127) end
    if text == "" then return end
    if text ~= nc_last_exec then
        nc_last_exec = text
        pcall(function() engine.exec(string.format("name \"%s\"", text)) end)
    end
    if cfg._write_name then cfg._write_name(text) end
end

local function tick_nc()
    if not StoreB("nc_enable", false) then
        if nc_was_enabled then
            local orig = StoreS("nc_nick", "bars1k")
            if orig and orig ~= "" then apply_name(orig) end
            nc_was_enabled = false nc_last_applied = "" nc_last_exec = ""
        end
        return
    end
    nc_was_enabled = true
    if not engine.is_in_game() then return end

    local now = globals.realtime()
    local tag_name = TAG_LIST[StoreI("nc_tag", 0) + 1] or TAG_LIST[1]
    local mode_idx = StoreI("nc_mode", 1)

    if tag_name ~= nc_last_tag or mode_idx ~= nc_last_mode then
        nc_last_tag, nc_last_mode = tag_name, mode_idx
        nc_frame_idx, nc_next_at, nc_last_applied, nc_last_exec = 1, 0, "", ""
    end
    if now < nc_next_at then return end

    local frame
    if tag_name == TAG_LIST[1] then frame = ""
    elseif mode_idx == 0 then frame = tag_name
    else
        local frames = get_frames(tag_name, mode_idx)
        if not frames or #frames == 0 then return end
        frame = frames[nc_frame_idx]
        nc_frame_idx = nc_frame_idx % #frames + 1
    end

    if mode_idx == 1 and frame ~= "" then
        local cursor = ({"|", "/", "\\"})[StoreI("nc_cursor", 0) + 1] or "|"
        frame = frame:gsub("|", cursor)
    end

    local nick = StoreS("nc_nick", "bars1k")
    if not nick or nick == "" then nick = "bars1k" cfg["nc_nick"] = nick end
    local combined = (frame == "") and nick or (frame .. " " .. nick)
    if #combined > 127 then combined = combined:sub(1, 127) end

    local speed = StoreF("nc_speed", 0.5)
    local delay = 0.01 + (1.0 - speed) * 0.29
    if combined == nc_last_applied then
        local wait = delay
        if mode_idx ~= 0 and nc_frame_idx == 1 then wait = 1.5 end
        nc_next_at = now + wait
        return
    end
    apply_name(combined)
    nc_last_applied = combined
    if mode_idx ~= 0 and nc_frame_idx == 1 then nc_next_at = now + 1.5 else nc_next_at = now + delay end
end

-- DAMAGE / FX
local dmg_marks = {}
local function dmg_add(x, y, z, dmg, kind)
    local ok, _, yaw = pcall(engine.get_view_angles) if not ok or not yaw then yaw = 0 end
    local r = math.rad(yaw)
    dmg_marks[#dmg_marks+1] = {x=x, y=y, z=z, rx=math.sin(r), ry=-math.cos(r), side=(math.random()>0.5 and 1 or -1)*(0.25+math.random()), dmg=dmg, kind=kind, born=globals.realtime()}
    if #dmg_marks > 40 then table.remove(dmg_marks, 1) end
end
local function draw_dmg()
    if #dmg_marks == 0 then return end
    local now = globals.realtime() local life = StoreI("dmg_life", 1300)/1000
    local lp = StoreB("dmg_dist", true) and entitylist.get_local_player() or nil
    local eye = lp and lp:get_eye_position() or nil
    for i = #dmg_marks, 1, -1 do
        local m = dmg_marks[i] local age = now - m.born
        if age >= life then table.remove(dmg_marks, i)
        else
            local t = age/life local e = 1 - (1-t)^3
            local wx, wy, wz = m.x + m.rx*StoreI("dmg_drift",28)*m.side*e, m.y + m.ry*StoreI("dmg_drift",28)*m.side*e, m.z + StoreI("dmg_rise",60)*e
            local sx, sy = render.w2s(wx, wy, wz)
            if sx and sy then
                local size = StoreI("dmg_size", 22)
                if m.kind == 1 then size = size * 1.2 elseif m.kind == 2 then size = size * 1.4 end
                if eye then
                    local dx, dy, dz = m.x - eye.x, m.y - eye.y, m.z - eye.z
                    local dist = math.sqrt(dx*dx + dy*dy + dz*dz)
                    local scale = math.max(0.35, math.min(1.5, 200 / math.max(50, dist)))
                    size = size * scale
                end
                local alpha = 255 if t > 0.55 then alpha = math.floor(255 * (1 - (t - 0.55) / 0.45)) end
                local c = StoreC("dmg_col_norm", 255, 255, 255)
                if m.kind == 1 then c = StoreC("dmg_col_head", 255, 210, 60)
                elseif m.kind == 2 then c = StoreC("dmg_col_kill", 255, 70, 70) end
                local label = m.kind == 2 and "KILL" or tostring(m.dmg)
                render.text(sx, sy - size*0.5, label, c[1], c[2], c[3], alpha, true, nil, size)
            end
        end
    end
end

local hit_fx, kill_fx = {}, {}
local function spawn_hit(x,y,z) hit_fx[#hit_fx+1] = {x=x,y=y,z=z,born=globals.curtime()} if #hit_fx>32 then table.remove(hit_fx,1) end end
local function spawn_kill(x,y,z) kill_fx[#kill_fx+1] = {x=x,y=y,z=z,born=globals.curtime()} if #kill_fx>16 then table.remove(kill_fx,1) end end
local function draw_fx()
    local now = globals.curtime()
    local hc = StoreC("hit_fx_col", 173, 241, 117)
    local kc = StoreC("kill_fx_col", 173, 241, 117)
    for i = #hit_fx, 1, -1 do
        local fx = hit_fx[i] local t = (now-fx.born)/(StoreI("hit_fx_life",450)/1000)
        if t >= 1 then table.remove(hit_fx, i) else
            local r = StoreI("hit_fx_size",10)*(0.45+(1-(1-t)^3)*0.85) local a = math.floor(235*(1-t)^1.5) local d = r*0.7071
            render.line_3d(fx.x-d, fx.y-d, fx.z, fx.x+d, fx.y+d, fx.z, hc[1], hc[2], hc[3], a, 1.8)
            render.line_3d(fx.x-d, fx.y+d, fx.z, fx.x+d, fx.y-d, fx.z, hc[1], hc[2], hc[3], a, 1.8)
            if StoreB("hit_fx_ring",true) then render.circle_3d(fx.x, fx.y, fx.z, r*1.4, hc[1], hc[2], hc[3], math.floor(a*0.6), 16, 1.2) end
        end
    end
    local br, bg2, bb = math.min(255,kc[1]+70), math.min(255,kc[2]+70), math.min(255,kc[3]+70)
    for i = #kill_fx, 1, -1 do
        local fx = kill_fx[i] local t = (now-fx.born)/(StoreI("kill_fx_life",950)/1000)
        if t >= 1 then table.remove(kill_fx, i) else
            local ease = 1 - (1-t)^3 local a = math.floor(215*(1-t)^2) local rr = 8 + StoreI("kill_fx_size",64)*ease
            render.circle_3d(fx.x, fx.y, fx.z+2, rr, kc[1], kc[2], kc[3], a, 24, 1.8)
            render.circle_3d(fx.x, fx.y, fx.z+2, rr*0.55, br, bg2, bb, math.floor(a*0.6), 20, 1.2)
            render.line_3d(fx.x, fx.y, fx.z+2, fx.x, fx.y, fx.z+42*(1-ease), br, bg2, bb, math.floor(a*0.45), 1.4)
        end
    end
end

local function draw_aim_vis()
    if not cmd.is_valid() then return end
    local lp = entitylist.get_local_player()
    if not lp or not lp:is_alive() then return end
    local eye = lp:get_eye_position()
    if not eye then return end
    local vp, vy, vr = cmd.get_view_angles()
    local best, bf = nil, StoreF("sa_fov", 15.0) + 1
    entitylist.for_each_enemy(function(e)
        if e:is_dormant() or not e:is_alive() then return end
        local p = e:get_hitbox_position(hitbox.head)
        if not p then return end
        local ap, ay = utils.calc_angle(eye.x, eye.y, eye.z, p.x, p.y, p.z)
        local f = utils.get_fov(vp, vy, vr, ap, ay, 0)
        if f < bf then bf, best = f, p end
    end)
    if not best then return end
    local sx, sy = render.w2s(best.x, best.y, best.z)
    local sw, sh = render.get_screen_size()
    if not sx or not sy or not sw or not sh then return end
    local c = StoreC("aim_vis_col", 255, 0, 255)
    render.line(sw * 0.5, sh * 0.5, sx, sy, c[1], c[2], c[3], 180, 1.0)
    render.filled_circle(sx, sy, 3, c[1], c[2], c[3], 220, 8)
end

-- RESOLVER CORE
local RESOLVE_SIDES = { -1, 0, 1 }
local resolver_data = {}
local current_target_idx = nil
local fire_started_at = nil
local last_fire_target = nil

local function get_resolver(ent_idx)
    local d = resolver_data[ent_idx]
    if not d then d = { side_idx = 2, misses = 0 } resolver_data[ent_idx] = d end
    return d
end
local function get_offset_deg(ent_idx)
    if not StoreB("adapt", true) then return 0 end
    local d = get_resolver(ent_idx)
    local max_off = StoreF("res_offset", 58)
    return RESOLVE_SIDES[d.side_idx] * max_off
end
local function cycle_resolver(ent_idx)
    local d = get_resolver(ent_idx)
    d.side_idx = (d.side_idx % #RESOLVE_SIDES) + 1
end
local function reset_resolver(ent_idx)
    local d = get_resolver(ent_idx)
    d.side_idx = 2
    d.misses = 0
end
local function rotate_around(x, y, z, ox, oy, oz, offset_deg)
    if not offset_deg or offset_deg == 0 then return x, y, z end
    local rad = math.rad(offset_deg)
    local dx, dy = x - ox, y - oy
    local cos_a, sin_a = math.cos(rad), math.sin(rad)
    return ox + dx*cos_a - dy*sin_a,
           oy + dx*sin_a + dy*cos_a,
           z
end

-- WATERMARK
local wm_style = {
    height = 26, rounding = 6, pad_x = 10, gap = 14, icon_gap = 6,
    icon_size = 12, font_size = 13,
    bg     = {12, 14, 20}, text   = {225, 228, 235, 255},
}
local wm_icons = {}
function wm_icons.nick(x, y, s, r, g, b, a)
    render.filled_circle(x + s * 0.5, y + s * 0.28, s * 0.24, r, g, b, a, 12)
    render.filled_rect(x + s * 0.12, y + s * 0.58, s * 0.76, s * 0.42, r, g, b, a, 3)
end
function wm_icons.fps(x, y, s, r, g, b, a)
    local w = s * 0.24
    render.filled_rect(x,            y + s * 0.55, w, s * 0.45, r, g, b, a, 1)
    render.filled_rect(x + s * 0.38, y + s * 0.30, w, s * 0.70, r, g, b, a, 1)
    render.filled_rect(x + s * 0.76, y,            w, s,        r, g, b, a, 1)
end
function wm_icons.ghz(x, y, s, r, g, b, a)
    render.filled_rect(x + s * 0.2, y + s * 0.2, s * 0.6, s * 0.6, r, g, b, a, 2)
    for i = 0, 2 do
        local p = s * (0.3 + i * 0.2)
        render.line(x + p, y,         x + p, y + s * 0.2, r, g, b, a, 1)
        render.line(x + p, y + s * 0.8, x + p, y + s,       r, g, b, a, 1)
        render.line(x,         y + p, x + s * 0.2, y + p,   r, g, b, a, 1)
        render.line(x + s * 0.8, y + p, x + s,     y + p,   r, g, b, a, 1)
    end
end
function wm_icons.gpu(x, y, s, r, g, b, a)
    render.filled_rect(x, y, s, s * 0.68, r, g, b, a, 2)
    render.filled_rect(x + s * 0.4, y + s * 0.72, s * 0.2, s * 0.14, r, g, b, a, 0)
    render.filled_rect(x + s * 0.2, y + s * 0.88, s * 0.6, s * 0.12, r, g, b, a, 1)
end
function wm_icons.ping(x, y, s, r, g, b, a)
    local cx, cy = x + s * 0.5, y + s * 0.5
    render.filled_circle(cx, cy, s * 0.5, r, g, b, a, 16)
    local d_r, d_g, d_b, d_a = wm_style.bg[1], wm_style.bg[2], wm_style.bg[3], 255
    render.line(cx, cy, cx, cy - s * 0.3, d_r, d_g, d_b, d_a, 1.5)
    render.line(cx, cy, cx + s * 0.22, cy, d_r, d_g, d_b, d_a, 1.5)
end

local function build_wm_items()
    local items = {}
    local ctrl = entitylist.get_local_controller()
    local nick = (ctrl and ctrl:get_name()) or "user"
    local fps = math.floor((globals.framerate() or 0) + 0.5)
    local ping = (ctrl and ctrl:get_ping()) or 0
    local ghz = 4.72 + math.random(0, 9) / 100
    local gpu = math.random(15, 30)
    local var = math.random(1, 5)
    local function add(icon_func, text) items[#items + 1] = { icon = icon_func, text = text } end
    if StoreB("wm_show_nick", true) then add(wm_icons.nick, tostring(nick)) end
    if StoreB("wm_show_fps", true) then add(wm_icons.fps, string.format("%d FPS", fps)) end
    if StoreB("wm_show_ghz", true) then add(wm_icons.ghz, string.format("%.2f GHz", ghz)) end
    if StoreB("wm_show_gpu", true) then add(wm_icons.gpu, string.format("%d%% GPU", gpu)) end
    if StoreB("wm_show_ping", true) then add(wm_icons.ping, string.format("VAR \194\177%d MS", var)) end
    return items
end

local function draw_watermark()
    local items = build_wm_items()
    if #items == 0 then return end
    local sw, sh = render.get_screen_size()
    if not sw or not sh then return end
    local col = StoreC("wm_accent", 70, 130, 255)
    local ar, ag, ab, aa = col[1], col[2], col[3], col[4]
    local current_opacity = StoreF("wm_opacity", 0.55)
    local total = wm_style.pad_x * 2
    local widths = {}
    for i, it in ipairs(items) do
        local tw = render.get_text_size(it.text, nil, wm_style.font_size) or (#it.text * 7)
        widths[i] = tw
        total = total + wm_style.icon_size + wm_style.icon_gap + tw
        if i < #items then total = total + wm_style.gap end
    end
    local pad = 10
    local pos = StoreI("wm_pos", 2)
    local x, y
    if pos == 0 then x, y = pad, pad
    elseif pos == 1 then x, y = pad, sh - wm_style.height - pad
    elseif pos == 2 then x, y = sw - total - pad, pad
    elseif pos == 3 then x, y = sw - total - pad, sh - wm_style.height - pad
    elseif pos == 4 then x, y = math.floor((sw - total) / 2), pad
    elseif pos == 5 then x, y = math.floor((sw - total) / 2), sh - wm_style.height - pad
    elseif pos == 6 then x, y = math.floor((sw - total) / 2), math.floor((sh - wm_style.height) / 2)
    end
    local bg_a = math.floor(255 * current_opacity)
    render.filled_rect(x, y, total, wm_style.height, wm_style.bg[1], wm_style.bg[2], wm_style.bg[3], bg_a, wm_style.rounding)
    local cx = x + wm_style.pad_x
    for i, it in ipairs(items) do
        local _, th = render.get_text_size(it.text, nil, wm_style.font_size)
        th = th or wm_style.font_size
        local iy = y + math.floor((wm_style.height - wm_style.icon_size) / 2)
        it.icon(cx, iy, wm_style.icon_size, ar, ag, ab, aa)
        cx = cx + wm_style.icon_size + wm_style.icon_gap
        local ty = y + math.floor((wm_style.height - th) / 2)
        render.text(cx, ty, it.text, wm_style.text[1], wm_style.text[2], wm_style.text[3], wm_style.text[4], false, nil, wm_style.font_size)
        cx = cx + widths[i] + wm_style.gap
    end
end

-- REVOLVER FIX
local plausible_key = nil
local plausible_state = false

local function find_plausible_key()
    if plausible_key then return plausible_key end
    local candidates = settings.find("aim")
    for _, k in ipairs(candidates) do
        local low = k:lower()
        if low:find("plausible") then
            local info = settings.info(k)
            if info and (info.writable == nil or info.writable) then
                plausible_key = k
                return k
            end
        end
    end
    for _, k in ipairs(settings.find("")) do
        local low = k:lower()
        if low:find("plausible") then
            local info = settings.info(k)
            if info and (info.writable == nil or info.writable) then
                plausible_key = k
                return k
            end
        end
    end
    return nil
end

client.add_event_callback("player_hurt", function(ev)
    local me = entitylist.get_local_player()
    local vic = ev:get_pawn("userid")
    if not me or not vic or vic == me or ev:get_pawn("attacker") ~= me then return end
    miss_last_hit = globals.realtime()
    local ok_idx, idx = pcall(function() return vic:get_index() end)
    if ok_idx and idx then reset_resolver(idx) end
    local dmg = ev:get_int("dmg_health") local hg = ev:get_int("hitgroup")
    if not dmg or dmg <= 0 then return end
    local pos = vic:get_hitbox_position(hg == 1 and hitbox.head or hitbox.chest)
    if not pos then return end
    if StoreB("hit_fx",true) then spawn_hit(pos.x,pos.y,pos.z) end
    if StoreB("dmg_enable",true) then dmg_add(pos.x,pos.y,pos.z,dmg, (StoreB("dmg_head",true) and hg==1) and 1 or 0) end
end)

client.add_event_callback("player_death", function(ev)
    local me = entitylist.get_local_player()
    local vic = ev:get_pawn("userid")
    if not me or not vic or ev:get_pawn("attacker") ~= me then return end
    local name = "?"
    pcall(function() name = vic:get_name() or "?" end)
    local o = vic:get_origin()
    if StoreB("kill_fx",true) and o then spawn_kill(o.x,o.y,o.z) end
    if StoreB("dmg_enable",true) and StoreB("dmg_kill",true) and o then
        dmg_add(o.x, o.y, o.z, 0, 2)
    end
    log_kill(name)
end)

-- SILENT AIM
local sa_st = { active = false, fov = 0 }
local function run_saim()
    if not StoreB("sa_enable", false) then sa_st.active = false return end
    if StoreB("sa_shoot_only", false) and not cmd.is_button_down(buttons.attack) then
        sa_st.active = false return
    end
    if not cmd.is_valid() then return end
    local lp = entitylist.get_local_player() if not lp or not lp:is_alive() then return end
    local hold = entitylist.get_local_weapon()
    if hold then local c = hold:get_class_name():lower() if c:find("grenade") or c:find("flash") then return end end
    local eye = lp:get_eye_position() if not eye then return end
    local vp, vy, vr = cmd.get_view_angles()

    local lim = StoreF("sa_fov", 15.0)
    local best_f, best_p, best_y = lim + 0.01, nil, nil
    local targets = {}
    local pick = StoreI("sa_hitboxes", 63)
    local zones = {hitbox.head, hitbox.neck, {hitbox.upper_chest,hitbox.chest,hitbox.lower_chest}, {hitbox.stomach,hitbox.pelvis}, {hitbox.left_upper_arm,hitbox.right_upper_arm,hitbox.left_forearm,hitbox.right_forearm,hitbox.left_hand,hitbox.right_hand}, {hitbox.left_thigh,hitbox.right_thigh,hitbox.left_calf,hitbox.right_calf,hitbox.left_foot,hitbox.right_foot}}
    for bi=1,6 do if math.floor(pick / 2^(bi-1)) % 2 == 1 then local z = zones[bi] if type(z)=="table" then for _,id in ipairs(z) do targets[#targets+1]=id end else targets[#targets+1]=z end end end
    if #targets == 0 then targets = {hitbox.head} end

    entitylist.for_each_enemy(function(e)
        if e:is_dormant() or not e:is_alive() then return end
        local o = e:get_origin()
        local idx = e:get_index()
        local off = (o and StoreB("res_enable", true) and StoreB("adapt", true)) and get_offset_deg(idx) or 0
        for _, id in ipairs(targets) do
            local p = e:get_hitbox_position(id)
            if p and p:is_valid() then
                local rx, ry, rz = p.x, p.y, p.z
                if o and off ~= 0 then rx, ry, rz = rotate_around(p.x, p.y, p.z, o.x, o.y, o.z, off) end
                local ap, ay = utils.calc_angle(eye.x, eye.y, eye.z, rx, ry, rz)
                local f = utils.get_fov(vp, vy, vr, ap, ay, 0)
                if f < best_f then
                    if StoreB("sa_visible", false) then
                        if not trace.visible(eye.x, eye.y, eye.z, rx, ry, rz, lp, e) then return end
                    end
                    best_f, best_p, best_y = f, ap, ay
                end
            end
        end
    end)
    if not best_p then sa_st.active = false return end
    local smooth = StoreI("sa_smooth", 0)/100
    if smooth > 0 then best_p = vp + (best_p - vp)*(1-smooth) best_y = vy + ((best_y - vy + 540)%360 - 180)*(1-smooth) end
    if StoreB("sa_rcomp", true) then
        local punch = nil
        for _, fn_name in ipairs({"get_punch_angle", "get_aim_punch", "get_view_punch", "get_punch"}) do
            local ok, val = pcall(function() return lp[fn_name](lp) end)
            if ok and val then punch = val break end
        end
        if punch then
            best_p = best_p - (punch.x or 0)
            best_y = best_y - (punch.y or 0)
        end
    end
    cmd.set_subtick_angles(best_p, best_y, 0)
    cmd.set_view_angles(best_p, best_y, 0, true)
    cmd.rotate_movement(vy)
    sa_st.active = true sa_st.fov = best_f
end

-- RESOLVER AIMBOT
local function run_resolver()
    current_target_idx = nil
    if not StoreB("res_enable", true) then return end
    if not cmd.is_valid() or not cmd.is_button_down(buttons.attack) then return end
    local lp = entitylist.get_local_player() if not lp or not lp:is_alive() then return end
    local eye = lp:get_eye_position() if not eye then return end
    local vp, vy, vr = cmd.get_view_angles()

    local max_fov = StoreF("min_hit", 45)
    local best, bf, best_idx, best_aim = nil, max_fov + 1, nil, nil

    local hbs = {}
    if StoreB("hb_head", true) then hbs[#hbs+1] = hitbox.head end
    if StoreB("hb_chest", true) then hbs[#hbs+1] = hitbox.chest end
    if StoreB("hb_stomach", true) then hbs[#hbs+1] = hitbox.stomach end
    if #hbs == 0 then hbs = {hitbox.head} end

    entitylist.for_each_enemy(function(e)
        if e:is_dormant() or not e:is_alive() then return end
        local idx = e:get_index()
        local o = e:get_origin()
        if not o then return end
        local off = get_offset_deg(idx)
        for _, hb in ipairs(hbs) do
            local p = e:get_hitbox_position(hb)
            if p then
                local rx, ry, rz = rotate_around(p.x, p.y, p.z, o.x, o.y, o.z, off)
                local ap, ay = utils.calc_angle(eye.x, eye.y, eye.z, rx, ry, rz)
                local f = utils.get_fov(vp, vy, vr, ap, ay, 0)
                if f < bf then
                    bf = f
                    best = e
                    best_idx = idx
                    best_aim = { ap = ap, ay = ay }
                end
            end
        end
    end)

    if not best or not best_aim then return end
    current_target_idx = best_idx
    cmd.set_subtick_angles(best_aim.ap, best_aim.ay, 0)
    cmd.set_view_angles(best_aim.ap, best_aim.ay, 0, true)
end

local function run_exploits()
    if StoreB("fast_acc", false) then
        local ok, f = pcall(require, "ffi")
        if ok and f then
            pcall(function() f.cdef[[typedef unsigned long long uintptr_t;]] end)
            local w = entitylist.get_local_weapon()
            if w and w:is_valid() then
                local ok2, addr = pcall(w.get_address, w)
                if ok2 and addr and addr ~= 0 then
                    pcall(function()
                        local ptr = f.cast("float*", addr + 0x1020)
                        if ptr then ptr[0] = 0.0 end
                    end)
                end
            end
        end
    end

    if not StoreB("revolver_fix", true) then
        if plausible_state and plausible_key then
            settings.set(plausible_key, false)
            plausible_state = false
        end
        return
    end

    local key = find_plausible_key()
    if not key then return end
    local weapon = entitylist.get_local_weapon()
    local is_revolver = false
    if weapon and weapon:is_valid() then
        local class = weapon:get_class_name()
        local def_idx = weapon:get_definition_index()
        if class == "weapon_revolver" or def_idx == 64 then is_revolver = true end
    end
    local current_val = settings.get(key)
    if is_revolver then
        if not current_val then
            local ok, err = settings.set(key, true)
            if ok then plausible_state = true end
        end
    else
        if current_val and plausible_state then
            local ok, err = settings.set(key, false)
            if ok then plausible_state = false end
        end
    end
end

client.set_callback("on_createmove_end", function()
    run_resolver() run_saim() run_exploits()

    if not cmd.is_valid() then return end
    local now = globals.realtime()
    local att = cmd.is_button_down(buttons.attack)

    -- Resolver miss cycle
    if att and current_target_idx and StoreB("adapt", true) then
        if last_fire_target ~= current_target_idx then
            fire_started_at = now
            last_fire_target = current_target_idx
        elseif now - fire_started_at >= 0.5 then
            cycle_resolver(current_target_idx)
            local d = get_resolver(current_target_idx)
            log_miss(string.format("target %d cycle side %d", current_target_idx, d.side_idx))
            fire_started_at = now
        end
    else
        fire_started_at = nil
        last_fire_target = nil
    end

    -- Silent aim miss timeout (only if resolver not providing target)
    if StoreB("sa_enable", false) and not StoreB("res_enable", true) then
        if att then
            if miss_last_hit == 0 then miss_last_hit = now end
            if now - miss_last_hit >= 1.0 and now - miss_last_log >= 1.0 then
                log_miss(string.format("silent aim — %.1fs no hit", now - miss_last_hit))
                miss_last_log = now
            end
        else
            miss_last_hit = 0
        end
    end
end)

local smoke_pending = 0
client.set_callback("on_paint", function()
    cf_tick()
    tick_nc()
    if StoreB("remove_smoke", true) then
        local list = entitylist.get_grenades()
        for _, e in ipairs(list) do
            local ok, t = pcall(e.get_grenade_type, e)
            if ok and t == 2 then
                local keys = settings.find("smoke")
                for _, k in ipairs(keys) do
                    if settings.get(k) == true then
                        settings.set(k, false)
                        smoke_pending = globals.realtime()
                    end
                end
            end
        end
        if smoke_pending > 0 then
            if globals.realtime() - smoke_pending > 0.1 then
                local keys = settings.find("smoke")
                for _, k in ipairs(keys) do settings.set(k, true) end
                smoke_pending = 0
            end
        end
    end
    if StoreB("dmg_enable", true) then draw_dmg() end
    if StoreB("hit_fx", true) or StoreB("kill_fx", true) then draw_fx() end
    if StoreB("aim_vis", true) then draw_aim_vis() end
    if StoreB("wm_enable", true) then draw_watermark() end
end)

local TABS = {
    { name = "combat",        subs = {"resolver","silent"} },
    { name = "visuals",       subs = {"world","effects"} },
    { name = "miscellaneous", subs = {"main","config"} },
}
local g_tab = 0
local g_sub = {0, 0, 0}

local lua_grp = ui.create("KLua Window")
local lua_show = lua_grp:checkbox("Show Window", true)
local lua_key = lua_grp:key_bind("Toggle Key")
if lua_key:get() == 0 then lua_key:set(input.INSERT) end

local win_x, win_y = 200, 200
local win_init = false
local last_menu_state = false
local dragging = false
local drag_start_x, drag_start_y = 0, 0
local win_start_x, win_start_y = 0, 0

local function Page(tab, sub, col)
    local id = tab*10+sub
    if id == 0 then
        if col == 0 then
            bg("Resolver")
            Chk("Enable", "res_enable", true)
            Sld("Max FOV", "min_hit", 1, 180, 45)
            Sld("Offset (deg)", "res_offset", 0, 90, 58)
            Chk("Adapt on Miss", "adapt", true)
            eg()
        else
            bg("Hitboxes")
            Chk("Head", "hb_head", true)
            Chk("Chest", "hb_chest", true)
            Chk("Stomach", "hb_stomach", true)
            eg()
            bg("Exploits")
            Chk("Fast Accuracy Recover", "fast_acc", false)
            Chk("Revolver -> Only Plausible Hits", "revolver_fix", true)
            eg()
        end
    elseif id == 1 then
        if col == 0 then
            bg("Silent Aim")
            Chk("Enable", "sa_enable", false)
            SldF("Field of View", "sa_fov", 1.0, 40.0, 15.0, 0.1)
            Sld("Smoothing", "sa_smooth", 0, 95, 0)
            Chk("Visible Targets Only", "sa_visible", false)
            Chk("Only While Firing", "sa_shoot_only", false)
            Chk("Recoil Compensation", "sa_rcomp", true)
            eg()
        else
            bg("Hitboxes")
            local pick = pick_buttons(StoreI("sa_hitboxes", 63))
            if pick ~= StoreI("sa_hitboxes", 63) then cfg["sa_hitboxes"] = pick dirty = true end
            eg()
        end
    elseif id == 10 then
        if col == 0 then
            bg("Damage Numbers")
            Chk("Enable", "dmg_enable", true)
            Sld("Lifetime (ms)", "dmg_life", 500, 3000, 1300)
            Sld("Size", "dmg_size", 12, 44, 22)
            Sld("Rise", "dmg_rise", 10, 150, 60)
            Sld("Spread", "dmg_drift", 0, 80, 28)
            Chk("Scale with Distance", "dmg_dist", true)
            Chk("Highlight Headshots", "dmg_head", true)
            Chk("Highlight Kills", "dmg_kill", true)
            eg()
            bg("Damage Colors")
            Clr("Normal", "dmg_col_norm", 255, 255, 255)
            Clr("Headshot", "dmg_col_head", 255, 210, 60)
            Clr("Kill", "dmg_col_kill", 255, 70, 70)
            eg()
        else
            bg("Aim Visualizer")
            Chk("Enable Predictor", "aim_vis", true)
            Clr("Color", "aim_vis_col", 255, 0, 255)
            eg()
        end
    elseif id == 11 then
        if col == 0 then
            bg("Hit Effects")
            Chk("Enable", "hit_fx", true)
            Sld("Size", "hit_fx_size", 4, 24, 10)
            Sld("Lifetime (ms)", "hit_fx_life", 200, 900, 450)
            Chk("Expanding Ring", "hit_fx_ring", true)
            Clr("Color", "hit_fx_col", 173, 241, 117)
            eg()
        else
            bg("Kill Effects")
            Chk("Enable", "kill_fx", true)
            Sld("Size", "kill_fx_size", 20, 140, 64)
            Sld("Lifetime (ms)", "kill_fx_life", 400, 2000, 950)
            Clr("Color", "kill_fx_col", 173, 241, 117)
            eg()
            bg("Fixes")
            Chk("Remove Smoke", "remove_smoke", true)
            eg()
        end
    elseif id == 20 then
        if col == 0 then
            bg("Name Changer")
            Chk("Enable", "nc_enable", false)
            Cmb("Tag", "nc_tag", TAG_LIST, 0)
            Cmb("Mode", "nc_mode", {"Static", "Typing", "Jitter", "Sliding"}, 1)
            if StoreI("nc_mode", 1) == 1 then
                Cmb("Cursor", "nc_cursor", {"|", "/", "\\"}, 0)
            end
            SldF("Speed", "nc_speed", 0.0, 1.0, 0.5, 0.1)
            imgui.spacing()
            imgui.text_colored(0.7, 0.7, 0.7, 1.0, "Nickname")
            imgui.set_next_item_width(g_max_x - imgui.get_cursor_screen_pos())
            local nick = StoreS("nc_nick", "bars1k")
            local ok, new_nick = pcall(imgui.input_text, "##ncnick", nick, 64)
            if ok and new_nick ~= nick then cfg["nc_nick"] = new_nick dirty = true end
            imgui.spacing()
            if imgui.button("Restore from Steam", g_max_x - imgui.get_cursor_screen_pos(), 25) then
                local raw = cvar.get_string("name")
                if raw and raw ~= "" then
                    raw = raw:gsub("^[%w%.%$]+%s+", ""):gsub("^[/|\\\\]%s*", "")
                    if raw ~= "" then cfg["nc_nick"] = raw dirty = true end
                end
            end
            eg()
        else
            bg("Watermark")
            Chk("Enable Watermark", "wm_enable", true)
            Cmb("Position", "wm_pos", {"Left Top", "Left Bottom", "Right Top", "Right Bottom", "Center Top", "Center Bottom", "Center"}, 2)
            Chk("Show Nickname", "wm_show_nick", true)
            Chk("Show FPS", "wm_show_fps", true)
            Chk("Show GHz", "wm_show_ghz", true)
            Chk("Show GPU", "wm_show_gpu", true)
            Chk("Show Ping", "wm_show_ping", true)
            SldF("Opacity", "wm_opacity", 0.0, 1.0, 0.55, 0.05)
            Clr("Accent Color", "wm_accent", 70, 130, 255)
            eg()
        end
    elseif id == 21 then
        if col == 0 then
            bg("Console Filter")
            Chk("Only Kills / Misses", "cf_enable", true)
            if imgui.button("Re-apply Filter", 200, 25) then
                cf_apply()
            end
            eg()
            bg("Configuration")
            if imgui.button("Save Config", 200, 25) then cfgsave() end
            if imgui.button("Load Config", 200, 25) then cfgload() end
            if imgui.button("Reset to Defaults", 200, 25) then
                for k in pairs(cfg) do cfg[k] = nil end
                if database.exists(_DB) then database.save(_DB, "") end
                client.log("[Menu] Settings wiped. Restart script.")
            end
            eg()
        else
            bg("About")
            imgui.text_colored(1, 1, 1, 1.0, "KLua on fluencelua menu")
            imgui.text_colored(0.6, 0.6, 0.6, 1.0, "v" .. V)
            eg()
        end
    end
end

local function PagesRender(tab, sub, ox, oy, sw, sh)
    local gap = S(8)
    local colW = math.floor((sw - gap) * 0.5)
    for col = 0, 1 do
        imgui.set_cursor_screen_pos(ox + col*(colW+gap), oy)
        imgui.push_style_var(imgui.StyleVar_WindowPadding, S(10), S(7))
        imgui.begin_child("##col"..tab.."_"..sub.."_"..col, colW, sh, false, imgui.WindowFlags_NoBackground + imgui.WindowFlags_NoScrollbar)
        Page(tab, sub, col)
        imgui.end_child()
        imgui.pop_style_var(1)
    end
end

-- INTRO
local intro_start = nil
local intro_done = false
local INTRO_DUR = 3.5
local intro_particles = {}
for i = 1, 40 do
    table.insert(intro_particles, {
        x = math.random(), y = math.random(),
        vx = (math.random() - 0.5) * 0.5,
        vy = (math.random() - 0.5) * 0.5,
        s = math.random(1, 3),
        a = math.random(30, 100) / 255
    })
end

local function draw_intro()
    if not intro_start then intro_start = globals.realtime() end
    local elapsed = globals.realtime() - intro_start
    if elapsed >= INTRO_DUR then intro_done = true return end
    local sw, sh = render.get_screen_size()
    if not sw or not sh or sw <= 0 or sh <= 0 then return end
    local uiscale = math.min(sw / 1920, sh / 1080)
    if uiscale < 0.5 then uiscale = 0.5 end
    if uiscale > 3.0 then uiscale = 3.0 end
    local cx, cy = sw * 0.5, sh * 0.5
    local ft = globals.frametime()
    if ft <= 0 or ft > 0.1 then ft = 0.016 end
    local c = StoreC("menu_accent", 173, 241, 117)
    local ar, ag, ab = c[1], c[2], c[3]
    local alpha = 1.0
    if elapsed < 0.5 then alpha = elapsed / 0.5
    elseif elapsed > INTRO_DUR - 0.5 then alpha = (INTRO_DUR - elapsed) / 0.5 end
    local ia = math.floor(255 * alpha)
    imgui.set_next_window_pos(0, 0, imgui.Cond_Always)
    imgui.set_next_window_size(sw, sh, imgui.Cond_Always)
    imgui.set_next_window_bg_alpha(0)
    local flags = imgui.WindowFlags_NoTitleBar + imgui.WindowFlags_NoResize + imgui.WindowFlags_NoMove
                + imgui.WindowFlags_NoScrollbar + imgui.WindowFlags_NoCollapse + imgui.WindowFlags_NoBackground
                + imgui.WindowFlags_NoSavedSettings + imgui.WindowFlags_NoInputs
    if imgui.begin("##kl_intro_overlay", flags) then
        imgui.dl_add_rect_filled(0, 0, sw, sh, T.Dark[1], T.Dark[2], T.Dark[3], ia, 0)
        for _, p in ipairs(intro_particles) do
            p.x = p.x + p.vx * ft * 0.2
            p.y = p.y + p.vy * ft * 0.2
            if p.x < 0 then p.x = 1 elseif p.x > 1 then p.x = 0 end
            if p.y < 0 then p.y = 1 elseif p.y > 1 then p.y = 0 end
            local ps = math.max(1.0, p.s * uiscale)
            imgui.dl_add_circle_filled(p.x * sw, p.y * sh, ps, ar, ag, ab, math.floor(p.a * 255 * alpha), 8)
        end
        imgui.set_window_font_scale(3.0 * uiscale)
        local brand = "KLua"
        local bw, bh = imgui.calc_text_size(brand)
        bw = bw or (100 * uiscale)
        bh = bh or (40 * uiscale)
        local bx = math.floor(cx - bw * 0.5)
        local by = math.floor(cy - bh * 0.5 - 30 * uiscale)
        local sh_off = math.max(1, math.floor(2 * uiscale))
        imgui.dl_add_text(bx + sh_off, by + sh_off, 0, 0, 0, ia, brand)
        imgui.dl_add_text(bx, by, ar, ag, ab, ia, brand)
        imgui.set_window_font_scale(1.0)
        imgui.set_window_font_scale(1.0 * uiscale)
        local sub = "initializing..."
        local sw_txt = imgui.calc_text_size(sub)
        sw_txt = sw_txt or (80 * uiscale)
        local sub_y = by + bh + math.floor(10 * uiscale)
        imgui.dl_add_text(math.floor(cx - sw_txt * 0.5), sub_y, T.TextHov[1], T.TextHov[2], T.TextHov[3], ia, sub)
        imgui.set_window_font_scale(1.0)
        local pw = 240 * uiscale
        local ph = math.max(3, math.floor(4 * uiscale))
        local px = math.floor(cx - pw * 0.5)
        local py = math.floor(cy + 40 * uiscale)
        imgui.dl_add_rect_filled(px, py, px + pw, py + ph, T.Mid[1], T.Mid[2], T.Mid[3], ia, 0)
        local prog = math.min(1.0, elapsed / (INTRO_DUR - 0.6))
        if prog > 0 then
            imgui.dl_add_rect_filled(px, py, px + pw * prog, py + ph, ar, ag, ab, ia, 0)
        end
        imgui.dl_add_rect(px - 1, py - 1, px + pw + 1, py + ph + 1, T.Outline[1], T.Outline[2], T.Outline[3], ia, 0, 1)
    end
    imgui.end_window()
end

local function draw_menu()
    local k = lua_key:get()
    if k ~= 0 and input.is_button_pressed(k) then
        lua_show:set(not lua_show:get())
    end
    if not lua_show:get() then
        if last_menu_state and menu.is_open() then menu.set_open(false) end
        last_menu_state = false
        return
    end
    if not menu.is_open() then menu.set_open(true) end
    last_menu_state = true
    local ds_w, ds_h = render.get_screen_size()
    if not ds_w or ds_w <= 0 then return end
    if not win_init then
        win_x = ds_w * 0.5 - S(T.W) * 0.5
        win_y = ds_h * 0.5 - S(T.H) * 0.5
        win_init = true
    end
    local c = StoreC("menu_accent", 173, 241, 117)
    T.Accent[1], T.Accent[2], T.Accent[3] = c[1], c[2], c[3]
    C_ACCENT_DARK[1], C_ACCENT_DARK[2], C_ACCENT_DARK[3] = math.floor(c[1]*0.5), math.floor(c[2]*0.5), math.floor(c[3]*0.5)
    local W, H = S(T.W), S(T.H)
    imgui.set_next_window_size(W, H, imgui.Cond_Always)
    imgui.set_next_window_pos(win_x, win_y, imgui.Cond_Always)
    imgui.push_style_var(imgui.StyleVar_WindowPadding, 0, 0)
    imgui.push_style_var(imgui.StyleVar_WindowBorderSize, 0)
    local flags = imgui.WindowFlags_NoTitleBar + imgui.WindowFlags_NoResize + imgui.WindowFlags_NoScrollbar + imgui.WindowFlags_NoScrollWithMouse + imgui.WindowFlags_NoCollapse + imgui.WindowFlags_NoBackground + imgui.WindowFlags_NoSavedSettings
    if imgui.begin("##kl_menu", flags) then
        local px, py = imgui.get_window_pos()
        px, py = math.floor(px), math.floor(py)
        local mx, my = imgui.get_mouse_pos()
        local hovered = mx >= px and mx <= px + W and my >= py and my <= py + H
        if imgui.is_mouse_clicked(0) and hovered and not imgui.is_any_item_active() then
            dragging = true
            drag_start_x, drag_start_y = mx, my
            win_start_x, win_start_y = win_x, win_y
        end
        if not imgui.is_mouse_down(0) then dragging = false end
        if dragging then
            win_x = win_start_x + (mx - drag_start_x)
            win_y = win_start_y + (my - drag_start_y)
        end
        frame(px, py, px+W, py+H, {T.Outline, T.Light}, T.Dark)
        frame(px+S(5), py+S(T.HeadH), px+W-S(5), py+H-S(5), {T.Outline, T.Mid}, T.Light)
        local a, b = "KLua", "  .dev"
        local sa = imgui.calc_text_size(a)
        local sb = imgui.calc_text_size(b)
        local hx = math.floor(px + (W - (sa+sb))*0.5)
        local hy = math.floor(py + (S(T.HeadH) - imgui.get_font_size())*0.5)
        txt(hx, hy, T.Accent, a)
        txt(hx+sa, hy, T.White, b)
        local fs = imgui.get_font_size()
        local sbx, sby = px+S(T.SideX), py+S(T.SideY)
        local sbw = S(T.SideW)
        local pfMaxY = sby+S(T.ProfH)
        frame(sbx, sby, sbx+sbw, pfMaxY, {T.Outline, T.Mid}, T.Light)
        txt(sbx+S(6), sby+S(7), T.White, "Kayzee")
        txt(sbx+S(6), sby+S(25), T.TextDim, "Owner")
        local mnMinY = pfMaxY+S(3)
        local mnMaxY = py+S(T.H)-S(13)
        frame(sbx, mnMinY, sbx+sbw, mnMaxY, {T.Outline, T.Mid}, T.Light)
        imgui.dl_push_clip_rect(sbx, mnMinY, sbx+sbw, mnMaxY)
        local y = mnMinY+S(5)
        for i = 1, #TABS do
            local tab = TABS[i]
            local sel = (g_tab == i-1)
            local rMinX, rMinY = sbx+S(3), y
            local rMaxX, rMaxY = sbx+sbw-S(3), y+S(T.TabH)
            imgui.push_id(i)
            imgui.set_cursor_screen_pos(rMinX, rMinY)
            if imgui.invisible_button("tab", rMaxX-rMinX, rMaxY-rMinY) then g_tab = i-1 end
            local hov = imgui.is_item_hovered()
            local id = imgui.get_item_id()
            imgui.pop_id()
            local st = anim(id, sel and 1 or 0)
            local ht = anim(id+1, hov and 1 or 0)
            local col = clrLerp(clrLerp(T.TextDim, T.TextHov, ht), T.Accent, st)
            if st > 0.01 then
                local c0 = clrA(T.Accent, 0.07*st)
                imgui.dl_add_rect_filled_multicolor(rMinX, rMinY, rMinX+S(120), rMaxY,
                    {c0[1],c0[2],c0[3],c0[4]}, {c0[1],c0[2],c0[3],0}, {c0[1],c0[2],c0[3],0}, {c0[1],c0[2],c0[3],c0[4]})
                local ac = clrA(T.Accent, st)
                imgui.dl_add_rect_filled(sbx+S(5), y+S(1), sbx+S(5)+S(2), y+S(T.TabH)-S(1), ac[1],ac[2],ac[3],ac[4], 0)
            end
            txt(sbx+S(14), y+(S(T.TabH)-fs)*0.5, col, tab.name)
            y = y + S(T.TabH)
            if sel then
                y = y + S(2)
                local ns = #tab.subs local subH = S(T.SubH)
                local lineX = math.floor(sbx+S(15))
                local lastC = math.floor(y + subH*(ns-0.5))
                imgui.dl_add_rect_filled_multicolor(lineX, y, lineX+1, lastC+1,
                    {T.Accent[1],T.Accent[2],T.Accent[3],255}, {T.Accent[1],T.Accent[2],T.Accent[3],255},
                    {T.TreeDim[1],T.TreeDim[2],T.TreeDim[3],255}, {T.TreeDim[1],T.TreeDim[2],T.TreeDim[3],255})
                for s = 1, ns do
                    local ssel = (g_sub[i] == s-1)
                    local cy = math.floor(y + subH*(s-0.5))
                    imgui.push_id(i*100+s+1)
                    imgui.set_cursor_screen_pos(lineX, y+subH*(s-1))
                    if imgui.invisible_button("sub", rMaxX-lineX, subH) then g_sub[i] = s-1 end
                    local shov = imgui.is_item_hovered()
                    local sid = imgui.get_item_id()
                    imgui.pop_id()
                    local sst = anim(sid, ssel and 1 or 0)
                    local sht = anim(sid+1, shov and 1 or 0)
                    local scol = clrLerp(clrLerp(T.TextDim, T.TextHov, sht), T.Accent, sst)
                    local tick = clrLerp(T.TreeDim, T.Accent, sst)
                    imgui.dl_add_rect_filled(lineX, cy, math.floor(sbx+S(21)), cy+1, tick[1],tick[2],tick[3],tick[4], 0)
                    txt(sbx+S(23), cy-fs*0.5, scol, tab.subs[s])
                end
                y = y + subH*ns
            end
        end
        imgui.dl_pop_clip_rect()
        local cx = px + S(T.SideX + T.SideW + 8)
        local cy2 = py + S(T.SideY)
        local cw = W - S(T.SideX + T.SideW + 16)
        local ch = H - S(T.SideY) - S(8)
        PagesRender(g_tab, g_sub[g_tab+1], cx, cy2, cw, ch)
    end
    imgui.end_window()
    imgui.pop_style_var(2)
end

client.set_callback("on_imgui", function()
    cf_tick()
    if not intro_done then
        if menu.is_open() then menu.set_open(false) end
        draw_intro()
        return
    end
    local ok, err = pcall(draw_menu)
    if not ok then client.log("[menu] error: " .. tostring(err)) end
end)

client.set_callback("on_unload", function()
    if dirty then cfgsave() end
    if menu.is_open() then menu.set_open(false) end
    if plausible_state and plausible_key then
        settings.set(plausible_key, false)
    end
    if nc_was_enabled then
        local orig = StoreS("nc_nick", "bars1k")
        if orig and orig ~= "" then
            pcall(function() engine.exec(string.format('name "%s"', orig)) end)
        end
    end
    if cf_saved then
        pcall(function()
            engine.exec(string.format("con_filter_enable %s", cf_orig_enable or "0"))
            engine.exec(string.format('con_filter_text "%s"', cf_orig_text or ""))
        end)
    end
end)

client.log("[KLua] v" .. V .. " loaded")

-- Apply console filter on startup
cf_last_state = StoreB("cf_enable", false)
if cf_last_state then cf_apply() end

end)()
