function sendTemp()
    conn = nil
    conn=net.createConnection(net.TCP, 0) 
    conn:on("receive", function(conn, payload) 
         print(payload) 
    end) 
    conn:on("connection", function(conn, payload) 
        conn:send("GET /iot/AddReading.php?"
        .."username=jacks9@suddenlink.net&password=jeffrey7&"
        .."json=[{\"bin_id\":1,\"sensor_id\":1,\"key\":\"Temp\",\"value\":25}]"
        .." HTTP/1.1\r\n" 
        .."Host: wvresearch.org\r\n"
        .."Connection: close\r\n"
        .."Accept: */*\r\n" 
        .."User-Agent: Mozilla/4.0 (compatible; esp8266 Lua; Windows NT 5.1)\r\n" 
        .."\r\n")
    end)
    conn:connect(80,'wvresearch.org') 
end

button=3
gpio.mode(button,gpio.INT)
gpio.write(button,gpio.LOW)
gpio.trig(button,"high",sendTemp)
