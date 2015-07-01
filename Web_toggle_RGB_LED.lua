neopixel=4
red=string.char(0,255,0)
green=string.char(255,0,0)
blue=string.char(0,0,255)
white=string.char(50,50,50)
srv=nil
srv=net.createServer(net.TCP) 
srv:listen(80,function(conn) 
    conn:on("receive", function(client,request)
        local buf = "";
        local _, _, method, path, vars = string.find(request, "([A-Z]+) (.+)?(.+) HTTP");
        if(method == nil)then 
            _, _, method, path = string.find(request, "([A-Z]+) (.+) HTTP"); 
        end
        local _GET = {}
        if (vars ~= nil)then 
            for k, v in string.gmatch(vars, "(%w+)=(%w+)&*") do 
                _GET[k] = v 
            end 
        end
        buf = buf.."<h1> Hello, Jack.</h1><form src=\"/\">Turn NeoPixel <select name=\"pin\" onchange=\"form.submit()\">";
        local _red,_green,_blue,_white,_off = "","","","",""
        if(_GET.pin == "RED")then
              _red = " selected=true";
              ws2812.writergb(neopixel, red);
        elseif(_GET.pin == "GREEN")then
              _green = " selected=\"true\"";
              ws2812.writergb(neopixel, green);
        elseif(_GET.pin == "BLUE")then
              _blue = " selected=\"true\"";
              ws2812.writergb(neopixel, blue);
        elseif(_GET.pin == "WHITE")then
              _white = " selected=\"true\"";
              ws2812.writergb(neopixel, white);
        elseif(_GET.pin == "OFF")then
              _off = " selected=\"true\"";
              ws2812.writergb(neopixel, string.char(0,0,0));
        end
        buf = buf.."<option".._red..">RED</opton><option".._green..">GREEN</opton><option".._blue..">BLUE</opton><option".._white..">WHITE</opton><option".._off..">OFF</option></select></form>";
        client:send(buf);
        client:close();
        dofile("Post_to_IoT_Dashboard.lua");
        collectgarbage();
    end)
end)