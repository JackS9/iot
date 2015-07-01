-- choose the strongest open AP available and connect to it
-- http://benlo.com/esp8266/esp8266Projects.html#thebutton
-- tested with NodeMcu 0.9.2 build 20150123

gpio.write(red,gpio.HIGH)
Tstart  = tmr.now()

ConnStatus = nil
function ConnStatus(n)
   status = wifi.sta.status()
   uart.write(0,' '..status)
   local x = n+1
   if (x < 50) and ( status < 5 ) then
      tmr.alarm(0,100,0,function() ConnStatus(x) end)
      if gpio.read(red) > 0 then gpio.write(red,gpio.LOW)
      else gpio.write(red,gpio.HIGH)
      end
   else
      if status == 5 then
         print('\nConnected as '..wifi.sta.getip())
         dofile('httpget.lua')
      else
         print("\nConnection failed")
         dofile('reconnect.lua')
      end
   end
end
   
best_ssid = nil
function best_ssid(ap_db)
   local min = 100
   ssid = nil
   for k,v in pairs(ap_db) do
       if tonumber(v) < min then 
          min = tonumber(v)
          ssid = k
          end
       end
    return min
end


connect = nil
function connect(aplist)
   print("\nAvailable Open Access Points:\n")
   for k,v in pairs(aplist) do print(k..' '..v) end
   
   ap_db = {}
   if next(aplist) then
      for k,v in pairs(aplist) do 
         if '0' == string.sub(v,1,1) then 
            ap_db[k] = string.match(v, '-(%d+),') 
            end 
          end
      signal = -best_ssid(ap_db)
      end
   if ssid then
      print("\nBest SSID: ".. ssid)
      wifi.sta.config(ssid,"")
      print("\nConnecting to "..ssid)
      ConnStatus(0)
   else
      print("\nNo available open APs")
      ssid = ''
      gpio.write(red,gpio.LOW)
      gpio.write(green,gpio.LOW)
      gpio.write(blue,gpio.LOW)
      end
end
    

wifi.setmode(wifi.STATION)
wifi.sta.getap(function(aplist) connect(aplist)  end)
