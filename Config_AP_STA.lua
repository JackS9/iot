neopixel=4
red=string.char(0,255,0)
green=string.char(255,0,0)
blue=string.char(0,0,255)
white=string.char(50,50,50)
ws2812.writergb(neopixel, red)
-- put module in STATION AP mode
wifi.setmode(wifi.STATIONAP)
print("ESP8266 mode is: " .. wifi.getmode())
-- Uncomment the following to use non-default SSID (and no password)
--cfg={}
-- Set the SSID and password for the ESP8266 in AP mode
--cfg.ssid="ESP_STATION"
--cfg.pwd="it"
--wifi.ap.config(cfg)
-- Now you should see an SSID wireless router named ESP_xxxxxx when you scan for available WIFI networks
-- Lets connect to the module from a computer or mobile device. So, find the SSID and connect using the password selected
print("Look for a WiFi AP named ESP_xxxxxx, where xxxxxx are the last 6 digits in its MAC ID: " .. wifi.ap.getmac())
print("Then go to 192.168.4.1 and provide the SSID and password for a WiFi AP on your local WAN")
-- create a server on port 80 and wait for a connection, when a connection is coming in function c will be executed
sv=nil
sv=net.createServer(net.TCP,120)
sv:listen(80,"192.168.4.1",function(c)
    c:on("receive", function(c, pl)
        -- print the payload pl received from the connection
        print(pl)
        print(string.len(pl))
        -- parse the response (payload) for the SSID and password
        print(string.match(pl,"GET"))
        ssid_start,ssid_end=string.find(pl,"SSID=")
        if ssid_start and ssid_end then
            amper1_start, amper1_end =string.find(pl,"&", ssid_end+1)
            if amper1_start and amper1_end then
                http_start, http_end =string.find(pl,"HTTP/1.1", ssid_end+1)
                if http_start and http_end then
                    ssid=string.sub(pl,ssid_end+1, amper1_start-1)
                    password=string.sub(pl,amper1_end+10, http_start-2)
                    if ssid and password then
                        print("ESP8266 connecting to SSID: " .. ssid .. " with PASSWORD: " .. password)
                        -- set the module to STATIONAP mode
                        --wifi.setmode(wifi.STATIONAP)
                        --print("ESP8266 mode now is: " .. wifi.getmode())
                        -- configure the module so it can connect to the network using the received SSID and password
                        wifi.sta.config(ssid,password)
                        --wifi.sta.connect()
                        print("Setting up ESP8266 for STATION mode.  Please wait for IP address.")
                        ws2812.writergb(neopixel, blue)
                        count=0
                        status=0
                        repeat
                            ws2812.writergb(neopixel, white)
                            tmr.delay(1000000)
                            ws2812.writergb(neopixel, blue)
                            status=wifi.sta.status()
                            count=count+1
                        until status==5 or count>=60
                        if status==5 then
                            sta_ip=wifi.sta.getip()
                            print("ESP8266 STATION IP now is: " .. sta_ip)
                            ws2812.writergb(neopixel, green)
                           -- Let user know the MAC and IP addresses of the module
                            c:send("<!DOCTYPE html> ")
                            c:send("<html><body>")
                            c:send("<h1>ESP8266 Wireless control setup</h1>")
                            mac_mess = "The module MAC address is: " .. wifi.sta.getmac
                            ip_mess = "The module IP address is: " .. sta_ip
                            c:send("<h2>" .. mac_mess .. "</h2>")
                            c:send("<h2>" .. ip_mess .. "</h2>")
                            c:send("<p>Reconnect to the " .. ssid .. " AP and go to " .. sta_ip .. ".</p>")
                            c:send("</body></html>")
                            -- now the module is configured and connected to the WAN network so lets start the app
                            -- close the AP server and set to STATION mode
                            print("Closing AP server and switching ESP8266 to STATION mode.")
                            sv:close()
                            --wifi.setmode(wifi.STATION)
                            --wifi.sta.connect()
                            -- start web service
                            dofile("Web_toggle_RGB_LED.lua")
                        else
                            print("Could not get IP address for " .. ssid .. " after " .. count .. " seconds")
                            c:send("<!DOCTYPE html> ")
                            c:send("<html><body>")
                            c:send("<h1>Could not get IP address for " .. ssid .. " after " .. count .. " seconds</h1>")
                            c:send("</body></html>")
                            sv:close()
                        end
                    end
                end
            end
        end
        -- this is the web page that requests the SSID and password from the user
        c:send("<!DOCTYPE html>")
        c:send("<html><body>")
        c:send("<h1>ESP8266 Wireless control setup</h1>")
        c:send("<h2>Enter SSID and Password for your WIFI router</h2>")
        c:send("<form action='' method='get'>")
        c:send("SSID: ")
        c:send("<input type='text' name='SSID' value='' maxlength='100'/>")
        c:send("<br/>")
        c:send("Password: ")
        c:send("<input type='text' name='Password' value='' maxlength='100'/>")
        c:send("<br/>")
        c:send("<input type='submit' value='Submit' />")
        c:send("</form></body></html>")
    end)
end)
