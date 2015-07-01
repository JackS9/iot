neopixel=4
conn = nil
conn=net.createConnection(net.TCP, 0) 

conn:on("receive", function(conn, payload) 
     print(payload) 
     if string.match(payload, 'color received', 0) then   
        ws2812.writergb(neopixel, string.char(255,0,0))
     end
end) 

conn:on("connection", function(conn, payload) 
    print('\nConnected') 
    ws2812.writergb(neopixel, string.char(0,255,0))
    conn:send("GET /esp8266/test.php?"
      .."ID="..node.chipid().."&red=255&green=0&blue=0"
      .." HTTP/1.1\r\n" 
      .."Host: wvresearch.org\r\n"
	  .."Connection: close\r\n"
      .."Accept: */*\r\n" 
      .."User-Agent: Mozilla/4.0 (compatible; esp8266 Lua; Windows NT 5.1)\r\n" 
      .."\r\n")
end) 
                                             
conn:connect(80,'wvresearch.org')                       