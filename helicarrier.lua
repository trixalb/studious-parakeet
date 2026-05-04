-- =========================
-- HELICARRIER FLIGHT CONTROLLER (PID VERSION)
-- ComputerCraft
-- =========================

-- ========= PERIPHERALS =========
local h = peripheral.wrap("top")
local a = peripheral.wrap("right")

rednet.open("left")

local r2 = peripheral.wrap("redstone_relay_0")
local r1 = peripheral.wrap("redstone_relay_1")
local l2 = peripheral.wrap("redstone_relay_2")
local l1 = peripheral.wrap("redstone_relay_3")

-- ========= CONFIG =========
local setHeight = 200
local base_power = 7
local target_pitch = 0

-- PID CONFIG
local pitch_kp = 0.8
local pitch_ki = 0.03
local pitch_kd = 0.4

local pitch_integral = 0
local last_pitch = 0
local integral_limit = 50

-- Turbine powers
local r2p, r1p, l2p, l1p = 0, 0, 0, 0

-- ========= UTILITIES =========
local function clamp(value, minVal, maxVal)
    if value < minVal then return minVal end
    if value > maxVal then return maxVal end
    return value
end

local function round(num, decimals)
    local mult = 10 ^ (decimals or 0)
    return math.floor(num * mult + 0.5) / mult
end

local function setTurbine(relay, power)
    power = clamp(power, 0, 15)
    relay.setAnalogOutput("back", 15 - power)
end

local function updatePower()
    setTurbine(r2, r2p)
    setTurbine(r1, r1p)
    setTurbine(l2, l2p)
    setTurbine(l1, l1p)
end

local function resetAll()
    r2p, r1p, l2p, l1p = 0, 0, 0, 0
    updatePower()
end

-- ========= SELF TEST =========
resetAll()

print("All turbines set to 0")
print("Self test in progress")
print("Carrier may move during this process")

sleep(3)

local turbines = {r2, r1, l2, l1}

for _, turbine in ipairs(turbines) do
    setTurbine(turbine, 1)
    sleep(1)
end

sleep(2)

for _, turbine in ipairs(turbines) do
    setTurbine(turbine, 15)
    sleep(2)
end

sleep(1)
resetAll()

sleep(3)

print("Self test complete, starting normal operation...")
sleep(2)

term.clear()
term.setCursorPos(1, 1)
print("--- HELI CARRIER ---")

-- ========= MAIN LOOP =========
while true do
    -- Receber comandos
    local id, message, protocol = rednet.receive("helicarrier", 0.05)

    -- ========= SENSOR DATA =========
    local angles = a.getAngles()
    local roll = round(tonumber(angles[1]) or 0, 3)
    local pitch = round(tonumber(angles[2]) or 0, 3)

    -- ========= PID CONTROL =========
    local pitch_error = target_pitch - pitch

    -- Integral
    pitch_integral = pitch_integral + pitch_error
    pitch_integral = clamp(
        pitch_integral,
        -integral_limit,
        integral_limit
    )

    -- Derivative
    local pitch_derivative = pitch - last_pitch
    last_pitch = pitch

    -- PID Output
    local pitch_adjust =
        (pitch_error * pitch_kp) +
        (pitch_integral * pitch_ki) -
        (pitch_derivative * pitch_kd)

    -- ========= POWER DISTRIBUTION =========
    -- Rear turbines respond stronger
    r2p = clamp(base_power + pitch_adjust, 0, 15)
    l2p = clamp(base_power + pitch_adjust, 0, 15)

    -- Front turbines counterbalance
    r1p = clamp(base_power - (pitch_adjust * 0.5), 0, 15)
    l1p = clamp(base_power - (pitch_adjust * 0.5), 0, 15)

    -- ========= REDNET COMMANDS =========
    if message ~= nil and type(message) == "string" then

        -- Shutdown
        if message == "shutdown" then
            print("Shutdown received.")
            resetAll()
            break

        -- Power Up
        elseif message == "up" then
            base_power = clamp(base_power + 1, 0, 15)

        -- Power Down
        elseif message == "down" then
            base_power = clamp(base_power - 1, 0, 15)

        -- Set Target Pitch
        elseif string.sub(message, 1, 6) == "pitch:" then
            local newPitch = tonumber(string.sub(message, 7))
            if newPitch then
                target_pitch = newPitch
            end

        -- Set KP
        elseif string.sub(message, 1, 3) == "KP:" then
            local newKP = tonumber(string.sub(message, 4))
            if newKP then
                pitch_kp = newKP
            end

        -- Set KI
        elseif string.sub(message, 1, 3) == "KI:" then
            local newKI = tonumber(string.sub(message, 4))
            if newKI then
                pitch_ki = newKI
            end

        -- Set KD
        elseif string.sub(message, 1, 3) == "KD:" then
            local newKD = tonumber(string.sub(message, 4))
            if newKD then
                pitch_kd = newKD
            end
        end
    end

    -- ========= APPLY POWER =========
    updatePower()

    -- ========= DISPLAY =========
    term.setCursorPos(1, 3)
    term.clearLine()
    print("Roll: " .. roll)

    term.setCursorPos(1, 4)
    term.clearLine()
    print("Pitch: " .. pitch)

    term.setCursorPos(1, 5)
    term.clearLine()
    print("Target Pitch: " .. target_pitch)

    term.setCursorPos(1, 6)
    term.clearLine()
    print("Base Power: " .. base_power)

    term.setCursorPos(1, 7)
    term.clearLine()
    print("KP: " .. round(pitch_kp, 3))

    term.setCursorPos(1, 8)
    term.clearLine()
    print("KI: " .. round(pitch_ki, 3))

    term.setCursorPos(1, 9)
    term.clearLine()
    print("KD: " .. round(pitch_kd, 3))

    term.setCursorPos(1, 10)
    term.clearLine()
    print("Err: " .. round(pitch_error, 3))

    term.setCursorPos(1, 11)
    term.clearLine()
    print("Int: " .. round(pitch_integral, 3))

    term.setCursorPos(1, 12)
    term.clearLine()
    print(
        "R2:" .. round(r2p, 1) ..
        " R1:" .. round(r1p, 1) ..
        " L2:" .. round(l2p, 1) ..
        " L1:" .. round(l1p, 1)
    )

    sleep(0.05)
end
