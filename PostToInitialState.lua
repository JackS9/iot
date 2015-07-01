function sendTemp()
    conn = nil
    conn=net.createConnection(net.TCP, 0) 
    conn:on("receive", function(conn, payload) 
         print(payload) 
    end) 
    conn:on("connection", function(conn, payload) 
        conn:send("POST /api/events"
        .." HTTP/1.1\r\n" 
        .."Host: groker.initialstate.com\r\n"
        .."Content-Type: application/json\r\n"
        .."Connection: close\r\n"
        .."Accept: */*\r\n" 
        .."Accept-Version: 0.0.1\r\n" 
        .."User-Agent: Mozilla/4.0 (compatible; esp8266 Lua; Windows NT 5.1)\r\n" 
        .."data-binary=[{\"key\":\"Temp\",\"value\":25.0}]"
        .."\r\n")
    end)
    conn:connect(80,'groker.initialstate.com') 
end

button=3
gpio.mode(button,gpio.INT)
gpio.write(button,gpio.LOW)
gpio.trig(button,"high",sendTemp)