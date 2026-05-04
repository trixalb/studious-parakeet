-- Helicarrier Flight Controller (ComputerCraft)
-- Corrigido e otimizado para melhor estabilidade de inclinação (pitch)

-- =========================
-- Peripheral Setup
-- =========================
local h = peripheral.wrap("top")
local a = peripheral.wrap("right")

rednet.open("left")

local r2 = peripheral.wrap("redstone_relay_0")
local r1 = peripheral.wrap("redstone_relay_1")
local l2 = peripheral.wrap("redstone_relay_2")
local l1 = peripheral.wrap("redstone_relay_3")

-- =========================
-- Configurações
-- =========================
local setHeight = 200
local base_power = 7
local target_pitch = 0

-- PID simplificado para pitch
local pitch_kp = 0.8
local pitch_kd = 0.4

-- Potência atual
local r2p, r1p, l2p, l1p = 0, 0, 0, 0

-- Estado anterior
local last_pitch = 0

-- =========================
-- Funções utilitárias
-- =========================
local function clamp(value, min, max)
    if value < min then return min end
    if value > max then return max end
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

-- =========================
-- Self Test
-- =========================
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

sleep(3)

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
term.setCursorPos(1,1)
print("--- HELI CARRIER ---")

-- =========================
-- Main Control Loop
-- =========================
while true do
    local id, message, protocol = rednet.receive("helicarrier", 0.05)

    -- Leitura de sensores
    local angles = a.getAngles()
    local roll = round(tonumber(angles[1]) or 0, 3)
    local pitch = round(tonumber(angles[2]) or 0, 3)

    -- =========================
    -- Controle de Pitch (PD)
    -- =========================
    local pitch_error = target_pitch - pitch
    local pitch_rate = pitch - last_pitch
    last_pitch = pitch

    local pitch_adjust =
        (pitch_error * pitch_kp) -
        (pitch_rate * pitch_kd)

    -- Turbinas traseiras corrigem pitch
    r2p = clamp(base_power + pitch_adjust, 0, 15)
    l2p = clamp(base_power + pitch_adjust, 0, 15)

    -- Turbinas dianteiras estabilizam
    r1p = clamp(base_power - (pitch_adjust * 0.5), 0, 15)
    l1p = clamp(base_power - (pitch_adjust * 0.5), 0, 15)

    -- =========================
    -- Comandos remotos
    -- =========================
    if message ~= nil then
        if type(message) == "string" then
            if message == "shutdown" then
                print("Shutdown received.")
                resetAll()
                break

            elseif message == "up" then
                base_power = clamp(base_power + 1, 0, 15)

            elseif message == "down" then
                base_power = clamp(base_power - 1, 0, 15)

            elseif tonumber(message) then
                target_pitch = tonumber(message)
            end
        end
    end

    -- =========================
    -- Atualizar saída
    -- =========================
    updatePower()

    -- =========================
    -- Display
    -- =========================
    term.setCursorPos(1,3)
    term.clearLine()
    print("Roll: " .. roll)

    term.setCursorPos(1,4)
    term.clearLine()
    print("Pitch: " .. pitch)

    term.setCursorPos(1,5)
    term.clearLine()
    print("Base Power: " .. base_power)

    term.setCursorPos(1,6)
    term.clearLine()
    print("Target Pitch: " .. target_pitch)

    term.setCursorPos(1,7)
    term.clearLine()
    print(
        "R2:" .. round(r2p,1) ..
        " R1:" .. round(r1p,1) ..
        " L2:" .. round(l2p,1) ..
        " L1:" .. round(l1p,1)
    )

    sleep(0.05)
end
