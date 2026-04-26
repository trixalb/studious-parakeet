m_id = 0
m = peripheral.wrap("monitor_"..m_id)
r = peripheral.wrap("bottom")

function map(x,in_min,in_max,out_min,out_max)
	return (x - in_min) * (out_max - out_min) / (in_max - in_min)
end

while true do
	m.clear()
	m.setCursorPos(1,1)
	m.setTextScale(2)
	m.write("TANQUE: "..math.floor(map(r.getAnalogInput("front"),0,15,0,255)).."%")
	sleep(1)
end
