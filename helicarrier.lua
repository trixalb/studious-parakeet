System64
system64_ofc
•
🌲 I love rm -rf /

You missed a call from 
Pitu
 that lasted a few seconds. — 5/2/2026 10:32 PM
Pitu — Yesterday at 2:38 PM
Confira este TikTok que eu encontrei!  ▶️Assistir ao vídeo na íntegra agora!  https://vt.tiktok.com/ZS9xfHt1L/
TikTok
TikTok · Metrópoles Oficial
114.4K gostos, 2617 comentários, "🌈👀 Viral que desafia a #visão! Um teste de #daltonismo simples e interativo conquistou a web com mais de 3 milhões de visualizações. Gravado na tela de #celular ou TV, o vídeo mostra imagens que colocam à prova a percepção de cores, mas atenção: a qualidade da tela pode interferir no resultado! ...

Cainã
System64 — Yesterday at 2:38 PM
k
oi
Pitu — Yesterday at 2:38 PM
Faz esses teste aí kkkk
System64 — Yesterday at 2:38 PM
tá
Pitu — Yesterday at 2:42 PM
Fez?
Acertou quantos?
System64 — Yesterday at 2:42 PM
cara
eu n vi nada no primeiro
ele falou que se ver nd tá bom
Pitu — Yesterday at 2:42 PM
De acordo com o vídeo minha visão tá 100 %
Pitu — Yesterday at 2:42 PM
E os outros
System64 — Yesterday at 2:42 PM
pera
to vendo aq
tava atendendo tikcet
Pitu — Yesterday at 2:42 PM
Foda
System64 — Yesterday at 2:42 PM
o segundo tbm nada
o terceiro to vendo 42
Pitu — Yesterday at 2:45 PM
Não errou nenhum então?
System64 — Yesterday at 2:45 PM
o último to vendo cor em vermelho
Pitu — Yesterday at 2:45 PM
Mas a guitarra do Bonnie kkkkkk
System64 — Yesterday at 2:45 PM
q guitarra do bonie?
Pitu — Yesterday at 2:46 PM
Daquele jogo que tinha 2 imagens e tem que escolher a certa
A gente jogou no início de 2025 se pá
Faz um tempo
A guitarra do bonnie tava marrom
E era vermelha
E você disse que tinha 0 diferença kk
System64 — Yesterday at 2:47 PM
eu vi guitarra do bonnie nenhuma
Pitu — Yesterday at 2:47 PM
Eu tinha rido muito kkkk
Enfim, depois vamos terminar o helicarrier?
System64 — Yesterday at 2:48 PM
sim 
System64
 started a call that lasted a few seconds. — Yesterday at 7:37 PM
Pitu
 started a call. — 3:46 PM
Pitu — 3:58 PM
Image
System64 — 4:25 PM
Image
System64 — 4:37 PM
Image
Pitu 2 — 7:02 PM
h = peripheral.wrap("top")
a = peripheral.wrap("right")
rednet.open("left")

r2 = peripheral.wrap("redstone_relay_0")
r1 = peripheral.wrap("redstone_relay_1")

helicarrier.lua
3 KB
﻿
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
