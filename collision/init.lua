local capi = {root=root,client=client,mouse=mouse,
               screen = screen, keygrabber = keygrabber}
local util         = require( "awful.util"     )
local awful        = require( "awful"          )
local glib         = require( "lgi"            ).GLib
local col_utils    = require( "collision.util" )
local module = {
  _focus  = require( "collision.focus" ),
  _resize = require( "collision.resize"),
  _max    = require( "collision.max"   ),
  _screen = require( "collision.screen"),
  settings= col_utils.settings          ,
}

local current_mode = "focus"

local event_callback = {
  focus  = module._focus._global_bydirection_key,
  move   = module._focus._global_bydirection_key,
  resize = module._resize.resize                ,
  max    = module._max.change_focus             ,
  tag    = module._max.change_tag               ,
  screen = module._screen.reload                ,
}

local start_callback = {
  focus  = module._focus.display      ,
  move   = module._focus.display      ,
  resize = module._resize.display     ,
  max    = module._max.display_clients,
  tag    = module._max.display_tags   ,
  screen = module._screen.display     ,
}

local exit_callback = {
  focus  = module._focus._quit ,
  move   = module._focus._quit ,
  resize = module._resize.hide ,
  max    = module._max.hide    ,
  tag    = module._max.hide    ,
  screen = module._screen.hide ,
}

local keys = {--Normal  Xephyr        G510 alt         G510
  up    = {"Up"    --[[, "&"        , "XF86AudioPause" , "F15"]] },
  down  = {"Down"  --[[, "KP_Enter" , "XF86WebCam"     , "F14"]] },
  left  = {"Left"  --[[, "#"        , "Cancel"         , "F13"]] },
  right = {"Right" --[[, "\""       , "XF86Paste"      , "F17"]] },
}

local function exit_loop()
  exit_callback[current_mode]()
  capi.keygrabber.stop()
  return false
end

-- Event loop
local function start_loop(is_swap,is_max)
  capi.keygrabber.run(function(mod, key, event)
    -- Detect the direction
    for k,v in pairs(keys) do
      if util.table.hasitem(v,key) then
        if event == "press" then
          if not event_callback[current_mode](mod,key,event,k,is_swap,is_max) then
            return exit_loop()
          end
          return
        end
        return #mod > 0
      end
    end

    if key == "Shift_L" or key == "Shift_R" then
      is_swap = event == "press"
      return #mod > 0
    elseif key == "Control_L" or key == "Control_R" then
      is_max = event == "press"
      return #mod > 0 and awful.util.table.hasitem(mod,"Mod4") or exit_loop()
    elseif key == "Alt_L" or key == "Alt_R" then
      exit_callback[current_mode]()
      current_mode = event == "press" and "resize" or "focus"
      start_callback[current_mode](mod,key,event,k,is_swap,is_max)
      return #mod > 0 and awful.util.table.hasitem(mod,"Mod4") or exit_loop()
    end

    return exit_loop()
  end)
end

function module.focus(direction,c,max)
  local screen = (c or ((capi.client.focus and capi.client.focus.focusable) and capi.client.focus or capi.mouse)).screen
  -- Useless when there is only 1 client tiled, incompatible with the "max_out" mode (in this case, focus floating mode)
  if awful.layout.get(screen) == awful.layout.suit.max and #awful.client.tiled(screen) > 1 and not max then
    current_mode = "max"
    module._max.display_clients(screen,direction)
  else
    current_mode = "focus"
    module._focus.global_bydirection(direction,c,false,max)
  end
  start_loop(false,max)
end

function module.move(direction,c,max)
  current_mode = "move"
  module._focus.global_bydirection(direction,c,true,max)
  start_loop(true,max)
end

function module.resize(direction,c,max)
  current_mode = "resize"
  start_loop(false,max)
  module._resize.display(c)
end

function module.tag(direction,swap,max)
  current_mode = "tag"
  local c = capi.client.focus
  module._max.display_tags((c) and c.screen or capi.mouse.screen,direction,c,swap,max)
  start_loop(swap,max)
end

function module.screen(direction, move)
  current_mode = "screen"
  module._screen.display(nil,direction,move)
  start_loop(false,max)
end

local function new(k)
  -- Replace the keys array. The new one has to have a valid mapping
  keys = k or keys
  local aw = {}

  -- This have to be executer after rc.lua
  glib.idle_add(glib.PRIORITY_DEFAULT_IDLE, function()
    for k,v in pairs(keys) do
      for _,key_nane in ipairs(v) do
        aw[#aw+1] = awful.key({ "Mod4",                              }, key_nane, function () module.focus (k          ) end)
        aw[#aw+1] = awful.key({ "Mod4", "Mod1"                       }, key_nane, function () module.resize(k          ) end)
        aw[#aw+1] = awful.key({ "Mod4", "Shift"                      }, key_nane, function () module.move  (k          ) end)
        aw[#aw+1] = awful.key({ "Mod4", "Shift",   "Control"         }, key_nane, function () module.move  (k,nil ,true) end)
        aw[#aw+1] = awful.key({ "Mod4",            "Control"         }, key_nane, function () module.focus (k,nil ,true) end)
        aw[#aw+1] = awful.key({ "Mod4", "Mod1" ,   "Control"         }, key_nane, function () module.screen(k          ) end)
          aw[#aw+1] = awful.key({ "Mod1", "Shift", "Control", "Mod4" }, key_nane, function () module.screen(k,true     ) end)
        if k == "left" or k =="right" then -- Conflict with my text editor, so I say no
          aw[#aw+1] = awful.key({ "Mod1",          "Control"         }, key_nane, function () module.tag   (k,nil ,true) end)
          aw[#aw+1] = awful.key({ "Mod1", "Shift", "Control"         }, key_nane, function () module.tag   (k,true,true) end)
        end
      end
    end
    capi.root.keys(awful.util.table.join(capi.root.keys(),unpack(aw)))
  end)
end

return setmetatable(module, { __call = function(_, ...) return new(...) end })
-- kate: space-indent on; indent-width 2; replace-tabs on;
