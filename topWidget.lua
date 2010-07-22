--Download

kgetpixmap       = widget({ type = "imagebox", align = "right" })
kgetpixmap.image = image("/home/lepagee/icons/download.png")

kgetwidget = widget({
    type = 'textbox',
    name = 'volumewidget'
})

kgetwidget.text = "KGet: 1 |"

local kgetInfo
function downloadInfo() 
  local percent = ""
  local source = ""
  local destination = ""
  local size = ""
  local downloaded = ""
  local downloadTable = {}
  local count = 0
  
  local f = io.popen('/home/lepagee/Scripts/kgetInfo.sh')
  if (f:read("*line") == "ready") then
    while true do
      percent = f:read("*line")
      
      if percent == "END" or nil then
	break
      end
      
      source = f:read("*line")
      destination = f:read("*line")
      size = f:read("*line")
      downloaded = f:read("*line")
      local aLine = f:read("*line")
      
      local kgetdown1 = widget({
	type = 'textbox',
	name = 'volumewidget'
      })
      
      local kgetdownpercent = widget({
	type = 'textbox',
	name = 'volumewidget'
      })
      
      local kgetdowndescription = widget({
	type = 'textbox',
	name = 'volumewidget'
      })
      
      local kgetdownprogress = widget({
	type = 'textbox',
	name = 'volumewidget'
      })
      
      kgetdownpercent.text = " ("..percent.."%)"
      kgetdownpercent.width = 40
      
      size = string.format("%.2f", tonumber(size) / 1024 /1024)
      downloaded = string.format("%.2f", tonumber(downloaded) / 1024 /1024)
      
      local path = explode("/",source)
      local fileName = path[# path]:gsub("\"","")
      
      local dpath = explode("/",destination:gsub("\"",""))
      destination = ""
      for i = 1, (# dpath) -1 do
	destination = destination .. dpath[i] .. "/"
      end

      kgetdown1.text = " <b>File: </b>".. fileName
      
      kgetdowndescription.text = " <b>Destination: </b>"  .. destination
      
      kgetdownprogress.text = " <b>Progress: </b>" .. downloaded .. "mb / " .. size .. "mb (" .. percent .. "%)"
      
      local downbar = awful.widget.progressbar({ layout = awful.widget.layout.horizontal.rightleft })
      downbar:set_width(320)
      downbar:set_height(18)
      downbar:set_vertical(false)
      downbar:set_background_color(beautiful.bg_normal)
      downbar:set_border_color(beautiful.fg_normal)
      downbar:set_color(beautiful.fg_normal)
      downbar:set_value(tonumber(percent)/100)
      
      table.insert(downloadTable, kgetdown1)
      table.insert(downloadTable, kgetdowndescription)
      table.insert(downloadTable, kgetdownprogress)
--       table.insert(downloadTable, downbar)
--       table.insert(downloadTable, kgetdownpercent)
--       table.insert(downloadTable, { downbar,
-- 				    kgetdownpercent,
-- 				    layout = awful.widget.layout.horizontal.leftright
--       })
      
      count = count + 1
      
      if count > 0 then
	local kgetdowntmp = widget({
	  type = 'textbox',
	  name = 'volumewidget'
	})
	kgetdowntmp.text = " "
	table.insert(downloadTable, kgetdowntmp)
      end
      
    end
  end 
  f:close()
  
  local toRemove = 0
  
  if count > 0 then
    table.remove(downloadTable, # downloadTable)
  end
  
  if count == 1 then
    toRemove = 1
  end

  local text2 = ""
  
  for i =0, (count * 4) -1 - toRemove do
    text2 = text2 .. "\n"
  end
  
  kgetInfo = naughty.notify({
		  text = text2,
		  timeout = 0, hover_timeout = 0.5,
		  width = 360, screen = mouse.screen
	      })
	      
  downloadTable['layout'] = awful.widget.layout.vertical.flex
  kgetInfo.box.widgets = downloadTable
end

function currentDownload() 
  local f = io.open('/tmp/kgetDwn.txt','r')
  local text2 = f:read("*all")
  f:close()
  local count = tonumber(text2) or 0
  if count > 0 then
     kgetwidget.visible = true
     kgetpixmap.visible = true
  else
     kgetwidget.visible = false
     kgetpixmap.visible = false
  end
  return {count}
end

vicious.register(kgetwidget, currentDownload, 'KGet: $1 | ',5)


kgetwidget:add_signal("mouse::enter", function ()
    downloadInfo()
end)

kgetwidget:add_signal("mouse::leave", function ()
   naughty.destroy(kgetInfo)
end)

kgetpixmap:add_signal("mouse::enter", function ()
    downloadInfo()
end)

kgetpixmap:add_signal("mouse::leave", function ()
   naughty.destroy(kgetInfo)
end)

--Sound

local alsaInfo = {}
function soundInfo() 
  local f = io.popen('/home/lepagee/Scripts/alsaInfo.sh')
  local text2 = f:read("*all")
  f:close()
  alsaInfo = { month, year, 
	      naughty.notify({
		  text = text2,
		  timeout = 0, hover_timeout = 0.5,
		  width = 140, screen = mouse.screen
	      })
	    }
end

volumewidget = widget({
    type = 'textbox',
    name = 'volumewidget',
    align='right'
})

--volumewidget.mouse_enter = function () soundInfo() end

volumewidget:add_signal("mouse::enter", function ()
    soundInfo()
end)

volumewidget:add_signal("mouse::leave", function ()
   naughty.destroy(alsaInfo[3])
end)

--volumewidget.mouse_leave = function () naughty.destroy(alsaInfo[3]) end

volumewidget:buttons( awful.util.table.join(
    awful.button({ }, 1, function()
        mywibox3.visible = not mywibox3.visible
	musicBarVisibility = true
	volumepixmap.visible = not volumepixmap.visible 
	volumewidget.visible = not volumewidget.visible 
    end),
    awful.button({ }, 4, function()
        awful.util.spawn("amixer -c0 sset Master 2dB+ >/dev/null") 
    end),
    awful.button({ }, 5, function()
        awful.util.spawn("amixer -c0 sset Master 2dB- >/dev/null") 
    end)
))


volumepixmap       = widget({ type = "imagebox", align = "right" })
volumepixmap.image = image("/home/lepagee/Icon/vol.png")
volumepixmap:buttons( awful.util.table.join(
    awful.button({ }, 1, function()
        mywibox3.visible = not mywibox3.visible
	volumepixmap.visible = not volumepixmap.visible 
	volumewidget.visible = not volumewidget.visible 
    end),
    awful.button({ }, 4, function()
        awful.util.spawn("amixer -c0 sset Master 2dB+ >/dev/null") 
    end),
    awful.button({ }, 5, function()
        awful.util.spawn("amixer -c0 sset Master 2dB- >/dev/null") 
    end)
))

-- volumepixmap.mouse_enter = function () soundInfo() end
-- volumepixmap.mouse_leave = function () naughty.destroy(alsaInfo[3]) end

volumepixmap:add_signal("mouse::enter", function ()
    soundInfo()
end)

volumepixmap:add_signal("mouse::leave", function ()
   naughty.destroy(alsaInfo[3])
end)


vicious.register(volumewidget, amixer_volume_int, '$1%  | ')

local screenWidth = 1280

spacer3 = widget({ type = "textbox", align = "right" })
spacer3.text = "| "
--spacer3.x = screenWidth - 400

--CPU

local memInfo = {}
function memStat() 
  local f = io.open('/tmp/memStatus.txt','r')
  local text2 = f:read("*all")
  f:close()

  memInfo = { month, year, 
	      naughty.notify({
		  text = text2,
		  timeout = 0, hover_timeout = 0.5,
		  width = 210, screen = mouse.screen
	      })
	    }
end

local cpuInfo = {}
function cpuStat() 
  local f = io.open('/tmp/cpuStatus.txt','r')
  local text2 = f:read("*all")
  f:close()
  cpuInfo = { month, year, 
	      naughty.notify({
		  text = text2,
		  timeout = 0, hover_timeout = 0.5,
		  width = 210, screen = mouse.screen
	      })
	    }
end

function toggleSensorBar()
    if mywibox4.visible ==  false then
      mywibox4.visible = true
    else
      mywibox4.visible = false
    end
end


cpulogo       = widget({ type = "imagebox", align = "right" })
cpulogo.image = image("/home/lepagee/Icon/brain.png")
cpulogo:buttons( awful.util.table.join(
  awful.button({ }, 1, function()
    toggleSensorBar()
  end)
))

-- cpulogo.mouse_enter = function () cpuStat() end
-- cpulogo.mouse_leave = function () naughty.destroy(cpuInfo[3]) end

cpulogo:add_signal("mouse::enter", function ()
    cpuStat()
end)

cpulogo:add_signal("mouse::leave", function ()
   naughty.destroy(cpuInfo[3])
end)

cpuwidget = widget({
      type = 'textbox',
          name = 'cpuwidget',
	   align = "right"
        })
cpuwidget.width = 27
cpuwidget:buttons( awful.util.table.join(
  awful.button({ }, 1, function()
    toggleSensorBar()
  end)
))
 
vicious.register(cpuwidget, vicious.widgets.cpu,'$1%')

-- cpuwidget.mouse_enter = function () cpuStat() end
-- cpuwidget.mouse_leave = function () naughty.destroy(cpuInfo[3]) end

cpuwidget:add_signal("mouse::enter", function ()
    cpuStat()
end)

cpuwidget:add_signal("mouse::leave", function ()
   naughty.destroy(cpuInfo[3])
end)
	    
cpugraphwidget = awful.widget.graph({ layout = awful.widget.layout.horizontal.rightleft })
 --[[widget({
    type = 'graph',
    name = 'cpugraphwidget',
     align = "right"
})]]
-- cpugraphwidget:buttons({
--   button({ }, 1, function()
--     toggleSensorBar()
--   end)
-- })
 
cpugraphwidget.height = 0.6
cpugraphwidget.width = 45
cpugraphwidget.grow = 'right'

cpugraphwidget:set_width(40)
cpugraphwidget:set_height(18)
cpugraphwidget:set_offset(1)
--membarwidget:set_gap(1)
cpugraphwidget:set_height(14)
--cpugraphwidget:set_min_value(0)
--cpugraphwidget:set_max_value(100)
--cpugraphwidget:set_scale(false)
--cpugraphwidget:set_min_value(0)
cpugraphwidget:set_background_color(beautiful.bg_normal)
cpugraphwidget:set_border_color(beautiful.fg_normal)
cpugraphwidget:set_color(beautiful.fg_normal)
--awful.widget.layout.margins[cpugraphwidget] = { top = 4}


-- cpugraphwidget:plot_properties_set('cpu', {
--                                         fg = beautiful.fg_normal,
-- 					fg_center = beautiful.fg_normal,
-- 					--fg_end = '#CC0000',
--                                         vertical_gradient = true
-- })
 
vicious.register(cpugraphwidget, vicious.widgets.cpu, '$1', 1)

-- cpugraphwidget.mouse_enter = function () cpuStat() end
-- cpugraphwidget.mouse_leave = function () naughty.destroy(cpuInfo[3]) end

-- cpugraphwidget:add_signal("mouse::enter", function ()
--     cpuStat()
-- end)
-- 
-- cpugraphwidget:add_signal("mouse::leave", function ()
--    cpuStat()
-- end)

spacer2 = widget({ type = "textbox", align = "right" })
spacer2.text = "  |"

--RAM

ramlogo       = widget({ type = "imagebox", align = "right" })
ramlogo.image = image("/home/lepagee/Icon/cpu.png")
ramlogo:buttons( awful.util.table.join(
  awful.button({ }, 1, function()
    toggleSensorBar()
  end)
))

-- ramlogo.mouse_enter = function () memStat() end
-- ramlogo.mouse_leave = function () naughty.destroy(memInfo[3]) end

ramlogo:add_signal("mouse::enter", function ()
    memStat()
end)

ramlogo:add_signal("mouse::leave", function ()
   naughty.destroy(memInfo[3])
end)

memwidget = widget({
    type = 'textbox',
    name = 'memwidget',
     align = "right"
})
memwidget:buttons( awful.util.table.join(
  awful.button({ }, 1, function()
    toggleSensorBar()
  end)
))


vicious.register(memwidget, vicious.widgets.mem, '$1%')
-- memwidget.mouse_enter = function () memStat() end
-- memwidget.mouse_leave = function () naughty.destroy(memInfo[3]) end

memwidget:add_signal("mouse::enter", function ()
    memStat()
end)

memwidget:add_signal("mouse::leave", function ()
   naughty.destroy(memInfo[3])
end)

-- membarwidget = widget({
--     type = 'progressbar',
--     name = 'membarwidget',
--     align = 'right'
-- })
membarwidget = awful.widget.progressbar({ layout = awful.widget.layout.horizontal.rightleft })
-- membarwidget:buttons({
--   button({ }, 1, function()
--     toggleSensorBar()
--   end)
-- })

-- membarwidget.width = 40
-- membarwidget.height = 0.65
-- membarwidget.gap = 0
-- membarwidget.border_padding = 1
-- membarwidget.border_width = 1
-- membarwidget.ticks_count = 0
-- membarwidget.ticks_gap = 0
-- membarwidget.vertical = false

membarwidget:set_width(40)
membarwidget:set_height(18)
membarwidget:set_offset(1)
membarwidget:set_margin({top=2,bottom=2})
membarwidget:set_vertical(false)
membarwidget:set_background_color(beautiful.bg_normal)
membarwidget:set_border_color(beautiful.fg_normal)
membarwidget:set_color(beautiful.fg_normal)
membarwidget:set_gradient_colors({
  beautiful.fg_normal,
  beautiful.fg_normal,
  '#CC0000'
})
membarwidget.offset =  2
--awful.widget.layout.margins[membarwidget] = { top = 2, bottom = 2 }

-- membarwidget.mouse_enter = function () memStat() end
-- membarwidget.mouse_leave = function () naughty.destroy(memInfo[3]) end

-- membarwidget:add_signal("mouse::enter", function ()
--     memStat()
-- end)
-- 
-- membarwidget:add_signal("mouse::leave", function ()
--    naughty.destroy(memInfo[3])
-- end)

vicious.register(membarwidget, vicious.widgets.mem, '$1', 1, 'mem')

spacer1 = widget({ type = "textbox", align = "right" })
spacer1.text = "  |"

--NET

  
  
--   vicious.register(netUpGraph, vicious.widgets.net, '${eth0 up_kb}',1)
--   vicious.register(netDownGraph, vicious.widgets.net, '${eth0 down_kb}',1)
  
local netWorkWibox
local netInfo = {}

function netStat () 
  local f = io.popen('ifconfig | grep -e "inet addr:[0-9.]*" -o |  grep -e "[0-9.]*" -o')
  local text2 = "<b><u>IP Addresses:</u></b>\n"
  text2 = text2 .. "<i><b>  v4: </b>" .. f:read() .. "</i>"
  f:close()
  f = io.popen('ifconfig | grep -e "inet6 addr: [0-9.A-Fa-f;:]*" -o | cut -f3 -d " "')
  text2 =  text2 .. "\n<i><b>  v6: </b>" .. f:read() .. "</i>\n\n"
  f:close()
  f = io.open('/tmp/localNetLookup','r')
  text2 = text2 .. "<b><u>Local Network:</u></b>\n"
  text2 = text2 .. f:read("*all")
  f:close()
  f = io.open('/tmp/connectedHost','r')
  text2 = text2 .. "<b><u>Open Connections:</u></b>\n"
  text2 = text2 .. f:read("*all")
  f:close()
   netWorkWibox = naughty.notify({
		  text = text2,
		  timeout = 0, hover_timeout = 0.5,
		  width = 240, screen = mouse.screen
	      })
	      
  local uploadImg = widget({ type = "imagebox"})
  uploadImg.image = image("/home/lepagee/Icon/arrowUp.png")
  uploadImg.resize = false
  
  local downloadImg = widget({ type = "imagebox"})
  downloadImg.image = image("/home/lepagee/Icon/arrowDown.png")
  downloadImg.resize = false
  
  local netUsageUp = widget({ type = "textbox" })
  netUsageUp.text = "<b>Up: </b>"
  
  local netSpacer1 = widget({ type = "textbox" })
  netSpacer1.text = " "
  netSpacer1.width = 10
  
  local netUsageDown = widget({ type = "textbox" })
  netUsageDown.text = "<b>Down: </b>"
  
  
  local netSpacer3 = widget({ type = "textbox" })
  netSpacer3.text = "  "
  

  
 
  
  local netSpacer2 = widget({ type = "textbox" })
  netSpacer2.text = " "
  netSpacer2.width = 10
  

  local netUpGraph = awful.widget.graph()
  netUpGraph:set_width(60)
  netUpGraph:set_height(25)
  netUpGraph:set_scale(true)
  netUpGraph:set_background_color(beautiful.bg_normal)
  netUpGraph:set_border_color(beautiful.fg_normal)
  netUpGraph:set_color(beautiful.fg_normal)
  
  local netDownGraph = awful.widget.graph()
  netDownGraph:set_width(60)
  netDownGraph:set_height(25)
  netDownGraph:set_scale(true)
  netDownGraph:set_background_color(beautiful.bg_normal)
  netDownGraph:set_border_color(beautiful.fg_normal)
  netDownGraph:set_color(beautiful.fg_normal)
  
  
  netWorkWibox.box.widgets = {
	netWorkWibox.box.widgets[2],
	{
	  downloadImg,
	  netUsageDown,
	  netDownGraph,
	  netSpacer2,
	  uploadImg,
	  netUsageUp,
	  netUpGraph,
	  layout = awful.widget.layout.horizontal.leftright
	},
	
	layout = awful.widget.layout.vertical.topbottom
  }
  
  netWorkWibox.box.height = netWorkWibox.box.height + 25
  
  netInfo = { month, year, 
               netWorkWibox
              }
end

downlogo       = widget({ type = "imagebox", align = "right" })
downlogo.image = image("/home/lepagee/Icon/arrowDown.png")

-- downlogo.mouse_enter = function () netStat() end
-- downlogo.mouse_leave = function () naughty.destroy(netInfo[3]) end

downlogo:add_signal("mouse::enter", function ()
    netStat()
end)

downlogo:add_signal("mouse::leave", function ()
   naughty.destroy(netInfo[3])
end)

netDownWidget = widget({
    type = 'textbox',
    name = 'netwidget',
    align = "right"
})

netDownWidget.width = 55

vicious.register(netDownWidget, vicious.widgets.net, '${eth0 down_kb}KBs',1) --Interval, ?, decimal

-- netDownWidget.mouse_enter = function () netStat() end
-- netDownWidget.mouse_leave = function () naughty.destroy(netInfo[3]) end

netDownWidget:add_signal("mouse::enter", function ()
    netStat()
end)

netDownWidget:add_signal("mouse::leave", function ()
   naughty.destroy(netInfo[3])
end)

uplogo       = widget({ type = "imagebox", align = "right" })
uplogo.image = image("/home/lepagee/Icon/arrowUp.png")

-- uplogo.mouse_enter = function () netStat() end
-- uplogo.mouse_leave = function () naughty.destroy(netInfo[3]) end

uplogo:add_signal("mouse::enter", function ()
    netStat()
end)

uplogo:add_signal("mouse::leave", function ()
   naughty.destroy(netInfo[3])
end)

netUpWidget = widget({
    type = 'textbox',
    name = 'netwidget',
    align = "right"
})
netUpWidget.width = 55

vicious.register(netUpWidget, vicious.widgets.net, '${eth0 up_kb}KBs',1)

-- netUpWidget.mouse_enter = function () netStat() end
-- netUpWidget.mouse_leave = function () naughty.destroy(netInfo[3]) end

netUpWidget:add_signal("mouse::enter", function ()
    netStat()
end)

netUpWidget:add_signal("mouse::leave", function ()
   naughty.destroy(netInfo[3])
end)

spacer4 = widget({ type = "textbox", align = "right" })
spacer4.text = "|"

--The clock

local calendar = {}

-- mytextbox = widget({ type = "textbox", align = "right" })
-- mytextbox.text = "<b><small>----CLOCK----</small></b>"
local calPopup
 function testFunc()
     local dateInfo = ""
    dateInfo = dateInfo .. "<b><u>Europe:</u></b>"
    dateInfo = dateInfo .. "\n<b>  <span size=\"x-large\">⌚</span> UTC: </b><i>" ..  getHour(os.date('%H') + 5) .. ":" .. os.date('%M').. ":" .. os.date('%S') .. "</i>"
    dateInfo = dateInfo .. "\n<b>  <span size=\"x-large\">⌚</span> CET: </b><i>" ..  getHour(os.date('%H') + 6) .. ":" .. os.date('%M').. ":" .. os.date('%S') .. "</i>"
    dateInfo = dateInfo .. "\n<b>  <span size=\"x-large\">⌚</span> EET: </b><i>" ..  getHour(os.date('%H') + 7) .. ":" .. os.date('%M').. ":" .. os.date('%S') .. "</i>"
    dateInfo = dateInfo .. "\n\n<b><u>America:</u></b>"
    dateInfo = dateInfo .. "\n<b>  <span size=\"x-large\">⌚</span> EST: </b><i>" ..  getHour(os.date('%H') + 0) .. ":" .. os.date('%M').. ":" .. os.date('%S') .. "</i>"
    dateInfo = dateInfo .. "\n<b>  <span size=\"x-large\">⌚</span> PST: </b><i>" ..  getHour(os.date('%H') - 3) .. ":" .. os.date('%M').. ":" .. os.date('%S') .. "</i>"
    dateInfo = dateInfo .. "\n<b>  <span size=\"x-large\">⌚</span> CST: </b><i>" ..  getHour(os.date('%H') - 1) .. ":" .. os.date('%M').. ":" .. os.date('%S') .. "</i>"
    dateInfo = dateInfo .. "\n\n<b><u>Japan:</u></b>"
    dateInfo = dateInfo .. "\n<b>  <span size=\"x-large\">⌚</span> JST: </b><i>" ..  getHour(os.date('%H') + 13) .. ":" .. os.date('%M').. ":" .. os.date('%S') .. "</i>\n\n"
    calPopup.box.height = 915
    return dateInfo
     
end

mytextclock:add_signal("mouse::enter", function ()

    local f = io.popen('cal | sed -r -e "s/(^| )(`date +\\"%d\\"`)($| )/\\1<b><span background=\\"#1577D3\\" foreground=\\"#0A1535\\">\\2<\\/span><\\/b>\\3/"',"r")
    local someText2 = "<tt><b><i>" .. f:read() .. "</i></b><u>" .. "\n" .. f:read() .. '</u>\n' .. f:read("*all") .. "</tt>"
    f:close()
    
    local month = os.date('%m')
    local year = os.date('%Y')
    
    --Display the next month
    if month == '12' then
     month = 1
     year = year + 1
    else
     month = month + 1
    end
    
    f = io.popen('cal ' .. month .. ' ' .. year ,"r")
    someText2 = someText2 .. "<tt><b><i>" .. f:read() .. "</i></b><u>" .. "\n" .. f:read() .. '</u>\n' .. f:read("*all") .. "</tt>"
    f:close()
    
    
    local dateInfo = ""
    dateInfo = dateInfo .. "<b><u>Europe:</u></b>"
    dateInfo = dateInfo .. "\n<b>  <span size=\"x-large\">⌚</span> UTC: </b><i>" ..  getHour(os.date('%H') + 5) .. ":" .. os.date('%M').. ":" .. os.date('%S') .. "</i>"
    dateInfo = dateInfo .. "\n<b>  <span size=\"x-large\">⌚</span> CET: </b><i>" ..  getHour(os.date('%H') + 6) .. ":" .. os.date('%M').. ":" .. os.date('%S') .. "</i>"
    dateInfo = dateInfo .. "\n<b>  <span size=\"x-large\">⌚</span> EET: </b><i>" ..  getHour(os.date('%H') + 7) .. ":" .. os.date('%M').. ":" .. os.date('%S') .. "</i>"
    dateInfo = dateInfo .. "\n\n<b><u>America:</u></b>"
    dateInfo = dateInfo .. "\n<b>  <span size=\"x-large\">⌚</span> EST: </b><i>" ..  getHour(os.date('%H') + 0) .. ":" .. os.date('%M').. ":" .. os.date('%S') .. "</i>"
    dateInfo = dateInfo .. "\n<b>  <span size=\"x-large\">⌚</span> PST: </b><i>" ..  getHour(os.date('%H') - 3) .. ":" .. os.date('%M').. ":" .. os.date('%S') .. "</i>"
    dateInfo = dateInfo .. "\n<b>  <span size=\"x-large\">⌚</span> CST: </b><i>" ..  getHour(os.date('%H') - 1) .. ":" .. os.date('%M').. ":" .. os.date('%S') .. "</i>"
    dateInfo = dateInfo .. "\n\n<b><u>Japan:</u></b>"
    dateInfo = dateInfo .. "\n<b>  <span size=\"x-large\">⌚</span> JST: </b><i>" ..  getHour(os.date('%H') + 13) .. ":" .. os.date('%M').. ":" .. os.date('%S') .. "</i>\n"

    local weatherInfo = ""
    f = io.open('/tmp/weather.txt',"r")
    weatherInfo = weatherInfo .. "\n" .. f:read("*all")
    f:close()
    
    weatherInfo = string.gsub(weatherInfo, "@cloud", "☁")
    weatherInfo = string.gsub(weatherInfo, "@sun", "✸")
    weatherInfo = string.gsub(weatherInfo, "@moon", "☪")
    weatherInfo = string.gsub(weatherInfo, "@rain", "☔")--☂
    weatherInfo = string.gsub(weatherInfo, "@snow", "❄")
    weatherInfo = string.gsub(weatherInfo, "deg", "°")
    
    calPopup = naughty.notify({
                   text = someText2,
                   timeout = 0, hover_timeout = 0.5,
                   width = 150, screen = mouse.screen
               })


      local timeInfo = widget({ type = 'textbox', })
      timeInfo.text = dateInfo
      
      local weatherInfo2 = widget({ type = 'textbox', })
      weatherInfo2.text = weatherInfo
      
      local calInfo = widget({ type = 'textbox', })
      calInfo.text = someText2
      
      awful.widget.layout.margins[calInfo] = {bottom = 0, left =5}
      

     --testImage2       = widget({ type = "imagebox"})
     --testImage2.image = image("/tmp/1600.jpg")
     --awful.widget.layout.margins[testImage2] = {left = 5, right = 5}
     
     testImage3       = widget({ type = "imagebox"})
     testImage3.image = image("/tmp/flower_crop.jpg")
     awful.widget.layout.margins[testImage3] = {left = 10, right = 25, top = 10}
     
     vicious.register(timeInfo,  testFunc, '$1',1)

     

     calPopup.box.widgets = {
	calInfo,
	timeInfo,
	--testImage2,
	testImage3,
	weatherInfo2,
     }
    calPopup.box.widgets["layout"] = awful.widget.layout.vertical.topbottom

    calPopup.box.height = 915

   calendar = { month, year, 
               calPopup
              }
end)

mytextclock:add_signal("mouse::leave", function ()
   naughty.destroy(calendar[3])
end)
