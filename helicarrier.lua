h = peripheral.wrap("top")
a = peripheral.wrap("right")
rednet.open("left")

r2 = peripheral.wrap("redstone_relay_0")
r1 = peripheral.wrap("redstone_relay_1")
l2 = peripheral.wrap("redstone_relay_2")
l1 = peripheral.wrap("redstone_relay_3")

function setTurbine(relay, power)
    if power < 0 or power > 15 then
        error("Not in range")
    end
    relay.setAnalogOutput("back",15-power)
end

function isInt(str)
    if type(str) ~= "string" then
        return false
    end
    return string.match(str,"^[-+]?%d+$") ~= nil
end

setTurbine(r2,0)
setTurbine(r1,0)
setTurbine(l2,0)
setTurbine(l1,0)


print("All set to 0")
print("Self test in progress")
print("Carrier may move in this process")

sleep(3)

setTurbine(r2,1)
sleep(1)
setTurbine(r1,1)
sleep(1)
setTurbine(l2,1)
sleep(1)
setTurbine(l1,1)
sleep(3)
setTurbine(r2,15)
sleep(3)
setTurbine(r1,15)
sleep(3)
setTurbine(l2,15)
sleep(3)
setTurbine(l1,15)

sleep(.5)
setTurbine(r2,0)
setTurbine(r1,0)
setTurbine(l2,0)
setTurbine(l1,0)
setTurbine(r2,0)
setTurbine(l2,0)
setTurbine(l1,0)

sleep(4)

print("Self test complete, starting normal operation..")

setHeight = 200
base_power = 7
target_pitch = 0
r2p = 0
r1p = 0
l2p = 0
l1p = 0

function updatePower()
    setTurbine(r2,r2p)
    setTurbine(r1,r1p)
    setTurbine(l2,l2p)
    setTurbine(l1,l1p)
end
function round(num,decimals)
    mult = 10^(decimals or 0)
    return math.floor(num * mult + 0.5) / mult
end

sleep(1)
term.clear()
term.setCursorPos(1,1)
print("---HELI CARRIER---")

while true do
    id,message,protocol = rednet.receive("helicarrier",.5)
    if message == nil then
        if r2p > 15 then
            r2p = 15
        end
        if l2p > 15 then
            l2p = 15
        end
        if l1p > 15 then
            l1p = 15
        end
        if r1p > 15 then
            r1p = 15
        end
        if r2p < 0 then
            r2p = 0
        end
        if l2p < 0 then
            l2p = 0
        end
        if l1p < 0 then
            l1p = 0
        end
        if r1p < 0 then
            r1p = 0
        end
        updatePower()
        roll = round(tonumber(a.getAngles()[1]),4)
        pitch = round(tonumber(a.getAngles()[2]),4)
        print(roll..", "..pitch)
        r2p = math.ceil(base_power + (target_pitch - pitch * 1.25))
        l2p = r2p
        l1p = base_power
        r1p = base_power
    end
end
