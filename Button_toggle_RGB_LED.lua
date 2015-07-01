gpio.mode(3,gpio.INT)
function toggleLED()
level=gpio.read(3)
ws2812.writergb(4,string.char(100*level,100*level,100*level))
end
gpio.trig(3,"both",toggleLED)
gpio.write(3,gpio.LOW)