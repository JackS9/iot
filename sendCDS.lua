function sendCDS()
    conn = nil
    conn=net.createConnection(net.TCP, 0) 
    conn:on("receive", function(conn, payload) 
         print(payload) 
    end) 
    conn:on("connection", function(conn, payload) 
        conn:send("GET /iot/AddReading.php?"
        .."username=jacks9@suddenlink.net&password=jeffrey7&"
        .."json=[{\"bin_id\":1,\"sensor_id\":1,\"key\":\"CDS\",\"value\":"..adc.read(0).."}]"
        .." HTTP/1.1\r\n" 
        .."Host: wvresearch.org\r\n"
        .."Connection: close\r\n"
        .."Accept: */*\r\n" 
        .."User-Agent: Mozilla/4.0 (compatible; esp8266 Lua; Windows NT 5.1)\r\n" 
        .."\r\n")
    end)
    conn:connect(80,'wvresearch.org') 
end

old_cds = adc.read(0)

tmr.alarm(0,2000,1,function() 
    count = count + 1
    gpio.write(12,gpio.LOW)
    cds = adc.read(0)
    print("CDS: "..cds)
    if cds ~= old_cds then
        gpio.write(12,gpio.HIGH)
        print("Send it.")
        sendCDS()
        old_cds = cds
    end
end)