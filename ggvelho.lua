-- # AVISO : AO INJETAR NA VRP, CASO ALGO DE ERRADO, DE PREFERÊNCIA EM INJETAR NAS RESOURCE -> vrp_animacoes, vrp_animacoes... Se em alguma dessas houver falta de conexao com a vRP, então incluir o seguinte
--[[

local Tunnel = module("vrp", "lib/Tunnel")
local Proxy = module("vrp", "lib/Proxy")
local Tools = module("vrp", "lib/Tools")
vRP = Proxy.getInterface("vRP")

]]
-- # DEIXEI TAMBÉM UM LOAD RESOURCES, SE VOCÊ QUISER PODE CRIAR UMA LISTA ASSIM COM A LISTA DE PLAYERS P/ A RESOURCES, SO QUE IRÁ PESAR UM POUCO... VOU DEIXAR DE SUA PREFÊRENCIA !
function ModelRequest(model)
    RequestModel(model)
    while not HasModelLoaded(model) do
        RequestModel(model)
        Citizen.Wait(0)
    end
end
local spawn = Citizen.CreateThread 
local cWait = Citizen.Wait 
local VeiculosInjetados = {}
local getPlr = PlayerPedId
local Gec = GetEntityCoords
EsperarTexto = function(TextEntry, ExampleText, MaxStringLength)
    ExampleText = ExampleText or ''
    MaxStringLength = MaxStringLength or 1000
    AddTextEntry('FMMC_KEY_TIP1', TextEntry .. ':')
    DisplayOnscreenKeyboard(1, 'FMMC_KEY_TIP1', '', ExampleText, '', '', '', MaxStringLength)
    blockinput = true
    
    while UpdateOnscreenKeyboard() ~= 1 and UpdateOnscreenKeyboard() ~= 2 do
        Wait(0)
    end
    
    if UpdateOnscreenKeyboard() ~= 2 then
        local Kboard = GetOnscreenKeyboardResult()
        blockinput = false
        return Kboard
    else
        blockinput = false
        return Kboard
    end

end
function CarrosNearest(pos, max)
    max = max or 1000
    local veiculos = {}
    for i,v in pairs(GetGamePool('CVehicle')) do
        local dist = #(GetEntityCoords(v) - pos)

        if dist <= max then
            table.insert(veiculos, {v,dist})
        end        
    end
    
    table.sort(veiculos, function(a,b) return a[2] < b[2] end)

    return veiculos 
end

Citizen.CreateThread(function()
    --------VRP-----------

    Proxy = {}

    local proxy_rdata = {}

    local function proxy_callback(rvalues)
        proxy_rdata = rvalues
    end

    local function proxy_resolve(itable, key)
        local iname = getmetatable(itable).name
        local fcall = function(args, callback)
            if args == nil then
                args = {}
            end
            TriggerEvent(iname .. ':proxy', key, args, proxy_callback)
            return table.unpack(proxy_rdata)
        end
        itable[key] = fcall
        return fcall
    end

    function Proxy.addInterface(name, itable)
        AddEventHandler(name .. ':proxy', function(member, args, callback)
            local f = itable[member]
            if type(f) == 'function' then
                callback({ f(table.unpack(args)) })
            else
            end
        end)
    end

    

    function Proxy.getInterface(name)
        local r = setmetatable({}, {
            __index = proxy_resolve,
            name = name
        })
        return r
    end

    vRP = Proxy.getInterface('vRP')


    local ListaDeArmas = { "WEAPON_KNIFE", "WEAPON_KNUCKLE", "WEAPON_NIGHTSTICK", "WEAPON_HAMMER", "WEAPON_BAT",
        "WEAPON_GOLFCLUB", "WEAPON_CROWBAR", "WEAPON_BOTTLE", "WEAPON_DAGGER", "WEAPON_HATCHET", "WEAPON_MACHETE",
        "WEAPON_FLASHLIGHT", "WEAPON_SWITCHBLADE", "WEAPON_POOLCUE", "WEAPON_PIPEWRENCH", --[[Pistols]] "WEAPON_PISTOL",
        "WEAPON_PISTOL_MK2", "WEAPON_COMBATPISTOL", "WEAPON_APPISTOL", "WEAPON_REVOLVER", "WEAPON_REVOLVER_MK2",
        "WEAPON_DOUBLEACTION", "WEAPON_PISTOL50", "WEAPON_SNSPISTOL", "WEAPON_SNSPISTOL_MK2", "WEAPON_HEAVYPISTOL",
        "WEAPON_VINTAGEPISTOL", "WEAPON_STUNGUN", "WEAPON_FLAREGUN", "WEAPON_MARKSMANPISTOL", --[[ SMGs / MGs]]
        "WEAPON_MICROSMG", "WEAPON_MINISMG", "WEAPON_SMG", "WEAPON_SMG_MK2", "WEAPON_ASSAULTSMG", "WEAPON_COMBATPDW",
        "WEAPON_GUSENBERG", "WEAPON_MACHINEPISTOL", "WEAPON_MG", "WEAPON_COMBATMG", "WEAPON_COMBATMG_MK2", --[[ Assault Rifles]]
        "WEAPON_ASSAULTRIFLE", "WEAPON_ASSAULTRIFLE_MK2", "WEAPON_CARBINERIFLE", "WEAPON_CARBINERIFLE_MK2",
        "WEAPON_ADVANCEDRIFLE", "WEAPON_SPECIALCARBINE", "WEAPON_SPECIALCARBINE_MK2", "WEAPON_BULLPUPRIFLE",
        "WEAPON_BULLPUPRIFLE_MK2", "WEAPON_COMPACTRIFLE", --[[Shotguns]] "WEAPON_PUMPSHOTGUN", "WEAPON_PUMPSHOTGUN_MK2",
        "WEAPON_SWEEPERSHOTGUN", "WEAPON_SAWNOFFSHOTGUN", "WEAPON_BULLPUPSHOTGUN", "WEAPON_ASSAULTSHOTGUN",
        "WEAPON_MUSKET", "WEAPON_HEAVYSHOTGUN", "WEAPON_DBSHOTGUN", --[[Sniper Rifles]] "WEAPON_SNIPERRIFLE",
        "WEAPON_HEAVYSNIPER", "WEAPON_HEAVYSNIPER_MK2", "WEAPON_MARKSMANRIFLE", "WEAPON_MARKSMANRIFLE_MK2", --[[Heavy Weapons]]
        "WEAPON_GRENADELAUNCHER", "WEAPON_GRENADELAUNCHER_SMOKE", "WEAPON_RPG", "WEAPON_MINIGUN", "WEAPON_FIREWORK",
        "WEAPON_RAILGUN", "WEAPON_HOMINGLAUNCHER", "WEAPON_COMPACTLAUNCHER", --[[Thrown]] "WEAPON_GRENADE",
        "WEAPON_STICKYBOMB", "WEAPON_PROXMINE", "WEAPON_BZGAS", "WEAPON_SMOKEGRENADE", "WEAPON_MOLOTOV",
        "WEAPON_FIREEXTINGUISHER", "WEAPON_PETROLCAN", "WEAPON_SNOWBALL", "WEAPON_FLARE", "WEAPON_BALL", }
    local sleep = Citizen["Wait"]
    local GUI = {

    }
    local Migma = {
        RandomString = (math.random(1000000000, 9999999999)),
        Functions = {},
        Natives = {},
        Config = {
            Keybinds = {
                ["Menu Key"] = { label = "K", control = 311, selected = false }, -- "Y" -> 246
                ["Aimbot_Keybind"] = { label = "RIGHTBUTTON", control = 25, selected = false },
                ["TriggerBot_Keybind"] = { label = "", control = nil, selected = false },
                ["Aimbot_Toggle"] = { label = "", control = nil, selected = false },
                ["Triggerbot_Toggle"] = { label = "", control = nil, selected = false },
                ["noclipPlayer"] = { label = "", control = nil, selected = false },
                ["reviver"] = { label = "", control = nil, selected = false }
            },
            textBoxes = {
                ["spawnarArma"] = { active = false, string = "", opacity = 0 },
                ["vehicleSpawn"] = { active = false, string = "", opacity = 0 },
                ["virarPed"] = { active = false, string = "", opacity = 0 },
            },
        },
        Tabs = {
            "Main",
            "Aimbot",
            "Visuais",
            "Veiculo",
            "Armas",
            "Jogador",
            "Destruicao",
            "Jogadores",
            "Lista de Jogadores",
            "Veiculos Selecionados",
            "Lista De veiculos"
        },
        Features = {},
        Math = {
            rotateToQuat = function(rotate)
                local pitch, roll, yaw = math.rad(rotate.x), math.rad(rotate.y), math.rad(rotate.z); local cy, sy, cr, sr, cp, sp =
                    math.cos(yaw * 0.5), math.sin(yaw * 0.5), math.cos(roll * 0.5), math.sin(roll * 0.5),
                    math.cos(pitch * 0.5),
                    math.sin(pitch * 0.5); return quat(cy * cr * cp + sy * sr * sp, cy * sp * cr - sy * cp * sr,
                    cy * cp * sr + sy * sp * cr, sy * cr * cp - cy * sr * sp)
            end,
            rotateToDirection = function(rotation)
                local retz = math.rad(rotation.z)
                local retx = math.rad(rotation.x)
                local absx = math.abs(math.cos(retx))
                return vector3(-math.sin(retz) * absx, math.cos(retz) * absx, math.sin(retx))
            end,
            Math_Abs = math.abs,
            Math_Atan2 = math.atan2,
            Math_Ceil = math.ceil,
            Math_Cos = math.cos,
            Math_Deg = math.deg,
            Math_Pi = math.pi,
            Math_Rad = math.rad,
            Math_Random = math.random,
            Math_Sin = math.sin,
            Math_Floor = math.floor,
            Math_Clamp = math.clamp,
            Pares = pairs,
            Pares2 = ipairs,
            String_format = string.format,
            String_upper = string.upper,
            String_len = string.len,
            String_lower = string.lower,
            String_sub = string.sub,
            String_print = print,
            String_gmatch = string.gmatch,
            Frind_wrap = coroutine.wrap,
            Frind_yield = coroutine.yield,
            Frind_metatable = setmetatable,
            Frind_tinsert = table.insert,
            Frind_tunpack = table.unpack,
            Frind_msgpack = msgpack.pack,
            Frind_msgunpack = msgpack.unpack,
            Frind_tremove = table.remove,
            Frind_String = tostring,
            Frind_Number = tonumber,
        },
        Vars = {
            pos = {},
            Dragging = nil,
            Checkboxes = {
                ["Main"] = true,
            },
            PedNoclip = nil,
            VehicleRemote = nil,
            VehicleBug = nil,
            Displayed = true,
            Theme = { 255, 60, 60 },
            Enabled = true,
            inputKeys = {
                ["RIGHTBUTTON"] = 25,
                ["~"] = 243,
                ["1"] = 157,
                ["2"] = 158,
                ["3"] = 160,
                ["4"] = 164,
                ["5"] = 165,
                ["6"] = 159,
                ["7"] = 161,
                ["8"] = 162,
                ["9"] = 163,
                ["-"] = 84,
                ["="] = 83,
                ["q"] = 44,
                ["w"] = 32,
                ["e"] = 38,
                ["r"] = 45,
                ["t"] = 245,
                ["y"] = 246,
                ["u"] = 303,
                ["p"] = 199,
                ["["] = 39,
                ["]"] = 40,
                ["a"] = 34,
                ["s"] = 8,
                ["d"] = 9,
                ["f"] = 23,
                ["g"] = 47,
                ["h"] = 74,
                ["k"] = 311,
                ["l"] = 182,
                ["z"] = 20,
                ["x"] = 73,
                ["c"] = 26,
                ["v"] = 0,
                ["b"] = 29,
                ["n"] = 249,
                ["m"] = 244,
                [","] = 82,
                ["."] = 81,
                ["`"] = 243,
            },
            Pos = {
                ["Main"] = { x = 5, y = 300 },
                ["Aimbot"] = { x = 200, y = 125, scroll = { 0, 0 } },
                ["Visuais"] = { x = 451, y = 125, scroll = { 0, 0 } },
                ["Veiculo"] = { x = 702, y = 125, scroll = { 0, 0 } },
                ["Armas"] = { x = 953, y = 125, scroll = { 0, 0 } },
                ["Jogador"] = { x = 200, y = 447, scroll = { 0, 0 } },
                ["Destruicao"] = { x = 451, y = 447, scroll = { 0, 0 } },
                ["Jogadores"] = { x = 702, y = 447, scroll = { 0, 0 } },
                ["Lista de Jogadores"] = { x = 953, y = 447, scroll = { 0, 0 } },
                ["Veiculos Selecionados"] = { x = 1204, y = 125, scroll = { 0, 0} },
                ["Lista De veiculos"] = { x = 1204, y = 447, scroll = { 0, 0 } },
            },
            Veiculos = {
                "divo",
                "g500",
                "h2carb",
                "teslax",
                "BENTAYGA17",
                "yz450f",
                "tmsm",
                "rmz250",
                "WRAITH",
                "URUS",
                "demon",
                "BMWI8",
                "rrst",
                "M6F13",
                "CHARGER",
                "19gt500",
                "exor",
                "SVJ",
                "demonhawk",
                "911",
                "GT2RS",
                "CONTSS18",
                "FERRARI812",
                "BENTAYGA17",
                "458spc",
                "63Lb",
                "c63scoupe",
                "MVISIONGT",
                "sv",
                "GTRC",
                "SENNA",
                "C7",
                "LWGTR",
                "AR8Lb",
                "g63mg",
                "scaldarsi",
                "bm8c",
                "jes",
                "cczl",
                "c8",
                "bentaygam",
                "mlmansory",
                "dawn",
                "ursa",
                "gle63c",
                "sr650fly",
                "BMWM8",
                "19S650",
                "amggtsmansory",
                "G63AMG6x6",
                "qx56",
                "vantage",
                "svr16",
                "x6m",
                "a8lw12",
                "corvetteZR1",
                "720stc",
                "TMODEL",
                "kiagt",
                "rs5r",
                "R8v10",
                "cayenne",
                "NISALTIMA",
                "TR22",
                "Mb400",
                "2020silv",
                "foxrossa",
                "M3E30",
                "foxharley2",
                "foxharley1",
                "denalihd",
                "fox600lt",
                "m6x6",
                "foxrover1",
                "tonkat",
                "kuga",
                "silvias15",
                "rx7rb",
                "fto",
                "mr2sw20",
                "eclipsegt06",
                "SkylineGTR",
                "CAN",
                "2020ss",
                "terzo",
                "rmodveneno",
                "gurkha",
                "p1",
                "viper",
                "TypeR17",
                "sc18",
                "XJ",
                "lp700",
                "TAMPA3",
                "Huracan",
                "TESLAPD",
                "S63W222",
                "foxct",
                "foxsterrato",
                "foxsian",
                "foxevo",
                "foxsupra",
                "h3",
                "foxleggera",
                "rmodi8mlb",
                "CORVETTe",
                "r1250",
                "f8rarri",
                "forgiato",
                "ts1",
                "jeepg",
                "GRANDGT18",
                "2008f150",
                "lccreaper",
                "REMOWER",
                "EVO10",
                "vip8",
                "ELLCHARG",
                "G770",
                "IMPALASS2",
                "fox720s",
                "CHIRON",
                "polp1",
                "AVENTADOR",
                "Custom",
                "CENTENARIo",
                "Mustang",
                "rmodamgc63",
                "audipd",
                "MRAP",
                "CHIRON17",
                "can",
                "rmodmustang",
                "beck",
                "bugatti",
                "foxezri",
                "exgtr",
                "f824slw",
                "rculi",
                "raptor150",
                "rs6c8",
                "ren_clio_5",
                "caprice13",
                "elantra07",
                "familiac",
                "trhawk",
                "ramlh20",
                "mach1",
                "cbr1000rrr",
                "rmodmi8lb",
                "nisanskyliner34",
                "boss302",
                "nissangtr",
                "audirs6",
                "audirs7",
                "r1200",
                "bmwm3f80",
                "bmwm4gts",
                "ferrariitalia",
                "lamborghinihuracan",
                "lancerevolution9",
                "lancerevolutionx",
                "mazdarx7",
                "nissan370z",
                "teslaprior",
                "amggt63s",
                "18performante",
                "huracangt3evo",
                "rmodsianr",
                "ahksv",
                "rmodessenza",
                "pistaspider19",
                "nissangtr",
                "rmodf40",
                "f8t",
                "m3e46",
                "rmodbmwm8",
                "bmws",
                "bmwm4gts",
                "M2F22",
                "rmodx6",
                "gs2013",
                "z4bmw",
                "bmwr1250rocam",
                "audiq8",
                "rs6wb",
                "rmodlegosenna",
                "foxsenna",
                "foxgt2",
                "fox720m ",
                "elva",
                "350z",
                "rmodskyline34",
                "nissanskyliner34",
                "r34",
                "nissanskyliner35",
                "rmodgtr50",
                "nissantitan17",
                "celta",
                "civic",
                "civictyper",
                "saveiro",
                "chevette",
                "amarok",
                "l200",
                "golf7gti",
                "rmodcamaro",
                "rmodjeep",
                "monza",
                "s10",
                "ram2500",
                "weevil",
                "sonata18",
                "civic2016",
                "amggtc",
                "rmodgt63",
                "c63w205",
                "718b",
                "911r",
                "pboxstergts",
                "panamera17turbo",
                "pct18",
                "rmodbentleygt",
                "cx75",
                "evoque",
                "fordmustang",
                "rmodbacalar",
                "rmodjesko",
                "agerars",
                "rmodmartin",
                "a80",
                "gemera",
                "brickade",
                "rallytruck",
                "guardian",
                "rmodtracktor",
                "pbus",
                "panigale",
                "hornet",
                "hayabusa",
                "r1",
                "r6",
                "tiger",
                "xj6",
                "xt660vip",
                "fz07",
                "africat",
                "z1000",
                "zx6r",
                "zx10",
                "bmwr1250rocam",
                "dm1200",
                "gs2013",
                "gsxr",
                "nh2r",
                "f850",
                "tenere1200",
                "biz25",
                "veloster ",
                "f150",
                "fq2",
                "fnflan",
                "ff4wrx",
                "2f2fmk4",
                "fnfmk4",
                "fnfmits",
                "fnfrx7",
                "2f2fmle7",
                "2f2fgts",
                "supervolito",
                "supervolito2",
                "frogger",
                "wrcb500x",
                "Wrgtr",
                "WRa45",
                "Wrc63s",
                "Wrcb500",
                "amggtr",
                "mercedesgt",
                "mercxclass",
                "nc750x",
                "jetta2017",
                "z4bmw",
                "c63w205",
                "pboxstergts",
                "gs2013",
                "pcx",
                "f850",
                "rmodessenza",
                "adr8",
                "718b",
            },
            FreeCamBlock = function()
                DisableControlAction(1, 36, true)
                DisableControlAction(1, 37, true)
                DisableControlAction(1, 38, true)
                DisableControlAction(1, 44, true)
                DisableControlAction(1, 45, true)
                DisableControlAction(1, 69, true)
                DisableControlAction(1, 70, true)
                DisableControlAction(0, 63, true)
                DisableControlAction(0, 64, true)
                DisableControlAction(0, 278, true)
                DisableControlAction(0, 279, true)
                DisableControlAction(0, 280, true)
                DisableControlAction(0, 281, true)
                DisableControlAction(0, 91, true)
                DisableControlAction(0, 92, true)
                DisablePlayerFiring(PlayerId(), true)
                DisableControlAction(0, 24, true)
                DisableControlAction(0, 25, true)
                DisableControlAction(1, 37, true)
                DisableControlAction(0, 47, true)
                DisableControlAction(0, 58, true)
                DisableControlAction(0, 140, true)
                DisableControlAction(0, 141, true)
                DisableControlAction(0, 81, true)
                DisableControlAction(0, 82, true)
                DisableControlAction(0, 83, true)
                DisableControlAction(0, 84, true)
                DisableControlAction(0, 12, true)
                DisableControlAction(0, 13, true)
                DisableControlAction(0, 14, true)
                DisableControlAction(0, 15, true)
                DisableControlAction(0, 24, true)
                DisableControlAction(0, 16, true)
                DisableControlAction(0, 17, true)
                DisableControlAction(0, 96, true)
                DisableControlAction(0, 97, true)
                DisableControlAction(0, 98, true)
                DisableControlAction(0, 96, true)
                DisableControlAction(0, 99, true)
                DisableControlAction(0, 100, true)
                DisableControlAction(0, 142, true)
                DisableControlAction(0, 143, true)
                DisableControlAction(0, 263, true)
                DisableControlAction(0, 264, true)
                DisableControlAction(0, 257, true)
                DisableControlAction(1, 26, true)
                DisableControlAction(1, 24, true)
                DisableControlAction(1, 25, true)
                DisableControlAction(1, 45, true)
                DisableControlAction(1, 45, true)
                DisableControlAction(1, 80, true)
                DisableControlAction(1, 140, true)
                DisableControlAction(1, 250, true)
                DisableControlAction(1, 263, true)
                DisableControlAction(1, 310, true)
                DisableControlAction(1, 37, true)
                DisableControlAction(1, 73, true)
                DisableControlAction(1, 1, true)
                DisableControlAction(1, 2, true)
                DisableControlAction(1, 335, true)
                DisableControlAction(1, 336, true)
                DisableControlAction(1, 106, true)
                DisableControlAction(0, 1, true)
                DisableControlAction(0, 2, true)
                DisableControlAction(0, 142, true)
                DisableControlAction(0, 322, true)
                DisableControlAction(0, 106, true)
                DisableControlAction(0, 25, true)
                DisableControlAction(0, 24, true)
                DisableControlAction(0, 257, true)
                DisableControlAction(0, 32, true)
                DisableControlAction(0, 31, true)
                DisableControlAction(0, 30, true)
                DisableControlAction(0, 34, true)
                DisableControlAction(0, 23, true)
                DisableControlAction(0, 22, true)
                DisableControlAction(0, 16, true)
                DisableControlAction(0, 17, true)
            end,
            FreeCamModeActual = {
                "1"
            },
            FreeCamModes = {
                "Camera Livre"
            },
            Anticheat = "",
            Resources = {},
            ResourceState = "",
            PlayerSelected = nil,
        },
    };

    Migma.Vars.Images = {
        ["logo"] = { "http://migmadev.000webhostapp.com/prismax-migma.svg", 60, 60 },
        ["cursor"] = { "http://131.196.198.131:3001/cursor2.svg", 17, 23 },
        ["save"] = { "http://131.196.198.131:3001/save.svg", 32, 32 },
        ["user"] = { "http://131.196.198.131:3001/user.svg", 32, 32 },
        ["crosshairs"] = { "http://131.196.198.131:3001/crosshairs.svg", 32, 32 },
        ["pistol"] = { "http://131.196.198.131:3001/pistol.svg", 32, 32 },
        ["car"] = { "http://131.196.198.131:3001/car.svg", 32, 32 },
        ["visuals"] = { "https://comforting-dieffenbachia-b7988a.netlify.app/icon4/", 32, 32 },
        ["online"] = { "http://131.196.198.131:3001/online.svg", 32, 32 },
        ["bomb"] = { "http://131.196.198.131:3001/bomb.svg", 32, 32 },
        ["cog"] = { "http://131.196.198.131:3001/cog.svg", 32, 32 },
        ["keyboard"] = { "https://comforting-dieffenbachia-b7988a.netlify.app/keyboard_icon/", 20, 20 },
        ["circle"] = { "http://131.196.198.131:3001/circle.svg", 16, 16 },
        ["gradient"] = { "http://131.196.198.131:3001/colorGradient.svg", 182, 182 },
        ["rainbowBar"] = { "https://cdn.discordapp.com/attachments/875067512600035388/933696556077551636/unknown.png", 17, 199 },
    }

    for k, v in pairs(Migma.Vars.Images) do
        local random = math.random(100000, 999999)
        local runtimeTxd = CreateRuntimeTxd(random .. "1")
        local dui = CreateDui(v[1], v[2], v[3])

        CreateRuntimeTextureFromDuiHandle(runtimeTxd, random .. "2", GetDuiHandle(dui))

        Migma.Vars.Images[k] = { random .. "1", random .. "2", v[2], v[3] }
    end

    function Migma.Functions.LoadResources() -- P/ SALVAR AS RESOURCES EXISTENTES DO SERVIDOR NUMA TABLE
        local resources = GetNumResources()

        for i = 0, resources - 1 do
            local resourceName = GetResourceByFindIndex(i)
            local fxManifestContent = LoadResourceFile(resourceName, "fxmanifest.lua")

            if fxManifestContent then
                table.insert(Migma.Vars.Resources,
                    {
                        resource = resourceName,
                        status = GetResourceState(tostring(resourceName), Citizen.ReturnResultAnyway(),
                            Citizen.ResultAsString())
                    })
            end
        end

        return true
    end

    function Migma.Functions.GetResource(resource) -- RETORNA TRUE CASO A RESOURCE SEJA EXISTENTE ! PODE TAMBÉM USAR FOR K, V IN IN PAIRS(Migma.Vars.Resources) E FILTRAR PELA RESOURCE !
        -- COMO CITADO A CIMA :
        --[[
        for _, v in ipairs(Migma.Vars.Resources) do
            if (string.match(v.resource, "resourceName")) then
                return true;
            end
        end
    ]]

        local resources = GetNumResources()

        for i = 0, resources - 1 do
            local resourceName = GetResourceByFindIndex(i)
            local fxManifestContent = LoadResourceFile(resourceName, "fxmanifest.lua")
            local resourceState = GetResourceState(tostring(resource), Citizen.ReturnResultAnyway(),
                Citizen.ResultAsString())

            if (resourceState == "Started" or resourceState == string.lower("started") or resourceState == string.upper("started")) then
                Migma.Vars.ResourceState = "^2Rodando"
            elseif (resourceState == "Stopped" or resourceState == string.lower("stopped") or resourceState == string.upper("stopped")) then
                Migma.Vars.ResourceState = "^1Parado"
            end

            if fxManifestContent and string.match(fxManifestContent, resource) then
                Wait(1000)
                -- P/ DETECÇÃO DE AC E SETAR A STRING DO AC ATUAL
                if string.lower(resource) == "mqcu" then
                    Migma.Vars.Anticheat = resource
                elseif string.lower(resource) == "likizao_ac" then
                    Migma.Vars.Anticheat = resource
                elseif string.lower(resource) == "chat" then
                    Migma.Vars.Anticheat = resource
                end

                return true;
            else
                return false;
            end
        end
    end

    Migma.Vars.SW, Migma.Vars.SH = Citizen.InvokeNative(0x873C9F3104101DD3, Citizen.PointerValueInt(),
        Citizen.PointerValueInt())
    Migma.Vars.cx, Migma.Vars.cy = Citizen.InvokeNative(0xBDBA226F, Citizen.PointerValueInt(), Citizen.PointerValueInt())
    function Migma.Functions.Hovered(x, y, w, h)
        Migma.Vars.cx, Migma.Vars.cy = Citizen.InvokeNative(0xBDBA226F, Citizen.PointerValueInt(),
            Citizen.PointerValueInt())
        if (Migma.Vars.cx > x and Migma.Vars.cy > y and Migma.Vars.cx < x + w and Migma.Vars.cy < y + h) then
            return true
        end
    end

    function Migma.Natives.DrawRect(x, y, w, h, r, g, b, a)
        return Citizen.InvokeNative(0x3A618A217E5154F0, x, y, w, h, r, g, b, a)
    end

    function Migma.Functions.DrawRect(x, y, w, h, r, g, b, a)
        local _w, _h = w / Migma.Vars.SW, h / Migma.Vars.SH
        local _x, _y = x / Migma.Vars.SW + _w / 2, y / Migma.Vars.SH + _h / 2
        return Migma.Natives.DrawRect(_x, _y, _w, _h, r, g, b, a)
    end

    function Migma.Natives.DrawSprite(txd, txn, x, y, w, h, hea, r, g, b, a)
        if not HasStreamedTextureDictLoaded(txd) then
            RequestStreamedTextureDict(txd, false)
            return false
        end

        local _w, _h = w / Migma.Vars.SW, h / Migma.Vars.SH
        local _x, _y = x / Migma.Vars.SW + _w / 2, y / Migma.Vars.SH + _h / 2

        return Citizen["InvokeNative"](0xE7FFAE5EBF23D890, txd, txn, _x, _y, _w, _h, hea, r, g, b, a)
    end

    local function EnumerarEntidades(initFunc, moveFunc, disposeFunc)
        return coroutine.wrap(function()
            local iter, id = initFunc()
            if not id or id == 0 then
                disposeFunc(iter)
                return
            end

            local enum = { handle = iter, destructor = disposeFunc }
            setmetatable(enum, entityEnumerator)

            local next = true
            repeat
                coroutine.yield(id)
                next, id = moveFunc(iter)
            until not next

            enum.destructor, enum.handle = nil, nil
            disposeFunc(iter)
        end)
    end

    function EnumerarPeds()
        return EnumerarEntidades(FindFirstPed, FindNextPed, EndFindPed)
    end

    function Draw3DText(x, y, z, text, r, g, b)
        SetDrawOrigin(x, y, z, 0)
        SetTextFont()
        SetTextProportional(0)
        SetTextScale(0.0, 0.20)
        SetTextColour(r, g, b, 255)
        SetTextDropshadow(0, 0, 0, 0, 255)
        SetTextEdge(2, 0, 0, 0, 150)
        SetTextDropShadow()
        SetTextOutline()
        SetTextEntry("STRING")
        SetTextCentre(1)
        AddTextComponentString(text)
        DrawText(0.0, 0.0)
        ClearDrawOrigin()
    end

    local function RGBRainbow(frequency)
        local result = {}
        local curtime = GetGameTimer() / 1000

        result.r = math.floor(math.sin(curtime * frequency + 0) * 127 + 128)
        result.g = math.floor(math.sin(curtime * frequency + 2) * 127 + 128)
        result.b = math.floor(math.sin(curtime * frequency + 4) * 127 + 128)

        return result
    end

    function math.round(first, second)
        return tonumber(string.format("%." .. (second or 0) .. "f", first))
    end

    function Migma.Functions.DrawRect(x, y, w, h, r, g, b, a)
        local _w, _h = w / Migma.Vars.SW, h / Migma.Vars.SH
        local _x, _y = x / Migma.Vars.SW + _w / 2, y / Migma.Vars.SH + _h / 2
        return Migma.Natives.DrawRect(_x, _y, _w, _h, r, g, b, a)
    end

    function GetWeaponNameFromHash(hash)
        for i = 1, #ListaDeArmas do
            if GetHashKey(ListaDeArmas[i]) == hash then
                return string.sub(ListaDeArmas[i], 8)
            end
        end
    end

    function Migma.Functions.DrawText(label, x, y, font, r, g, b, a, alignment, scale, outline)
        Citizen.InvokeNative(0x66E0276CC5F6B9DA, font)
        Citizen.InvokeNative(0x07C837F9A01C34C9, scale / Migma.Vars.SW, scale / Migma.Vars.SH)
        Citizen.InvokeNative(0xBE6B23FFA53FB442, r, g, b, a)
        if (outline) then
            Citizen.InvokeNative(0x2513DFB0FB8400FE, label)
        end
        if (alignment == "Center") then
            Citizen.InvokeNative(0xC02F4DBFB51D988B, true)
        elseif (alignment == "Right") then
        end
        Citizen.InvokeNative(0x25FBB336DF1804CB, "STRING")
        Citizen.InvokeNative(0x6C188BE134E074AA, label)
        Citizen.InvokeNative(0xCD015E5BB0D96A57, x / Migma.Vars.SW, y / Migma.Vars.SH)
    end

    Migma.Vars.TextWidthTable = {}

    function Migma.Functions.GetTextWidth(string, font, scale)
        Migma.Vars.TextWidthTable[font] = Migma.Vars.TextWidthTable[font] or {}
        Migma.Vars.TextWidthTable[font][scale] = Migma.Vars.TextWidthTable[font][scale] or {}
        if (Migma.Vars.TextWidthTable[font][scale][string]) then
            return Migma.Vars.TextWidthTable[font][scale][string]
                .length
        end
        Citizen.InvokeNative(0x54CE8AC98E120CAB, "STRING")
        Citizen.InvokeNative(0x6C188BE134E074AA, string)
        Citizen.InvokeNative(0x66E0276CC5F6B9DA, font or 4)
        Citizen.InvokeNative(0x07C837F9A01C34C9, scale / Migma.Vars.SH, scale / Migma.Vars.SH)
        local length = Citizen.InvokeNative(0x85F061DA64ED2F67, 1, Citizen.ReturnResultAnyway(), Citizen.ResultAsFloat())
        Migma.Vars.TextWidthTable[font][scale][string] = { length = length * Migma.Vars.SW }
        return length * Migma.Vars.SW
    end

    function Migma.Functions.Rainbow(speed, alpha)
        local n = GetGameTimer() / 300
        local r, g, b = math.floor(math.sin(n * speed) * 127 + 128), math.floor(math.sin(n * speed + 2) * 127 + 128),
            math.floor(math.sin(n * speed + 4) * 127 + 128)
        return r, g, b, alpha == nil and 255 or alpha
    end

    function Migma.Functions.AssignKeybind(keybind, func)
        if (not Migma.Config.Keybinds[keybind]) then
            Migma.Config.Keybinds[keybind] = { label = "", control = -1, func = nil }
        end
    end

    function Migma.Functions.Lerp(a, b, t)
        return a + (b - a) * t
    end

    function Migma.Functions.Checkbox(label, tab, y, bool, func, bind)
        local r, g, b = Migma.Functions.Rainbow(0.3)

        if (Migma.Vars.Checkboxes[tab]) then
            themwidth = Migma.Functions.GetTextWidth(label, 4, 300)
            if (Migma.Functions.Hovered(Migma.Vars.Pos[tab].x + 8, Migma.Vars.Pos[tab].y + 32 + y, 15 + themwidth, 12)) then
                Migma.Vars.HoveredOpt = label
                if (IsDisabledControlJustPressed(0, 24)) then
                    Migma.Vars.Checkboxes[bool] = not Migma.Vars.Checkboxes[bool]

                    if (func) then
                        func()
                    end
                end
            end

            if (bind) then
                if (Migma.Config.Keybinds[bool].selected) then
                    Migma.Functions.DrawRect(Migma.Vars.Pos[tab].x + 25 + Migma.Functions.GetTextWidth(label, 4, 300),
                        Migma.Vars.Pos[tab].y + 32 + y, 20, 15, r, g, b, 255)
                    Migma.Functions.DrawText("...",
                        Migma.Vars.Pos[tab].x + 25 + Migma.Functions.GetTextWidth(label, 4, 300) +
                        10, Migma.Vars.Pos[tab].y + 28 + y, 4, 255, 255, 255, 255, "Center", 300, true)
                elseif (not Migma.Config.Keybinds[bool].selected) then
                    Migma.Natives.DrawSprite(Migma.Vars.Images["keyboard"][1], Migma.Vars.Images["keyboard"][2],
                        Migma.Vars.Pos[tab].x + 25 + Migma.Functions.GetTextWidth(label, 4, 300),
                        Migma.Vars.Pos[tab].y + 30 +
                        y, 20, 20, 0.0, r, g, b, 255)
                end

                if (Migma.Functions.Hovered(Migma.Vars.Pos[tab].x + 25 + Migma.Functions.GetTextWidth(label, 4, 300), Migma.Vars.Pos[tab].y + 32 + y, 20, 15)) then
                    if (IsDisabledControlJustPressed(0, 24)) then
                        Migma.Config.Keybinds[bool].selected = true
                    end
                end

                if (Migma.Config.Keybinds[bool].selected) then
                    LocalPlayer.state.controlDisabled = 0 -- GO FUCK YOURSELF MQCU
                    DisableAllControlActions()

                    for keybinds, control in pairs(Migma.Vars.inputKeys) do
                        if (IsDisabledControlJustPressed(0, control)) then
                            if (Migma.Config.Keybinds["Aimbot_Toggle"].selected) then
                                Migma.Config.Keybinds["Aimbot_Keybind"] = { label = keybinds, control = control }
                            elseif (Migma.Config.Keybinds["Triggerbot_Toggle"].selected) then
                                Migma.Config.Keybinds["TriggerBot_Keybind"] = { label = keybinds, control = control }
                            else
                                Migma.Config.Keybinds[bool] = { label = keybinds, control = control }
                            end

                            Migma.Config.Keybinds[bool].selected = false
                        end
                    end
                end
            end

            Migma.Functions.DrawRect(Migma.Vars.Pos[tab].x + 8, Migma.Vars.Pos[tab].y + 32 + y, 12, 12, 35, 35, 35, 255)
            Migma.Functions.DrawText(label, Migma.Vars.Pos[tab].x + 23, Migma.Vars.Pos[tab].y + 27 + y, 4, 255, 255, 255,
                255,
                "Left", 300, true)
            if (Migma.Vars.Checkboxes[bool]) then
                Migma.Functions.DrawRect(Migma.Vars.Pos[tab].x + 10, Migma.Vars.Pos[tab].y + 34 + y, 8, 8, 35, 255, 35,
                    255)
            else
                Migma.Functions.DrawRect(Migma.Vars.Pos[tab].x + 10, Migma.Vars.Pos[tab].y + 34 + y, 8, 8, 255, 35, 35,
                    255)
            end
        end
    end

    function Migma.Functions.Slider(label, tab, y, type, func)
        if (Migma.Vars.Checkboxes[tab]) then
            if (type == 1) then
                -- SLIDER COM BOTÃO ( SE QUISEREM ALTERAR, CRIEI APENAS P/ PODER USAR )
            elseif (type == 2) then
                -- ADICIONE SUA LÓGICA AQUI MIGMA
            end
        end
    end

    function Migma.Functions.TextInput(name, label, w, tab, y, func)
        if (Migma.Config.textBoxes[name]) == nil then
            Migma.Config.textBoxes[name] = { active = false, string = "" }
        end

        if (Migma.Vars.Checkboxes[tab]) then
            Migma.Config.textBoxes[name].opacity = Migma.Functions.Lerp(Migma.Config.textBoxes[name].opacity, 255, 0.04)

            Migma.Functions.DrawText(label, Migma.Vars.Pos[tab].x + 7, Migma.Vars.Pos[tab].y + 30 + y, 4, 255, 255, 255,
                255,
                "Left", 300, true)

            if (Migma.Config.textBoxes[name].string.len(Migma.Config.textBoxes[name].string) < 1 and Migma.Config.textBoxes[name].active ~= true) then
                Migma.Functions.DrawText("Digite algo",
                    Migma.Vars.Pos[tab].x + 7 + Migma.Functions.GetTextWidth(label, 4, 300) +
                    ((w - 20 - Migma.Functions.GetTextWidth(label, 4, 300)) / 2), Migma.Vars.Pos[tab].y + 30 + y, 4, 240,
                    240,
                    240, math.ceil(Migma.Config.textBoxes[name].opacity), "Center", 280, false)
            end

            Migma.Functions.DrawRect(Migma.Vars.Pos[tab].x + 7 + Migma.Functions.GetTextWidth(label, 4, 300),
                Migma.Vars.Pos[tab].y + 30 + y, w - 20 - Migma.Functions.GetTextWidth(label, 4, 300), 20, 60, 60, 60, 255)

            if (Migma.Functions.Hovered(Migma.Vars.Pos[tab].x + 7 + Migma.Functions.GetTextWidth(label, 4, 300), Migma.Vars.Pos[tab].y + 30 + y, w - 20 - Migma.Functions.GetTextWidth(label, 4, 300), 20)) then
                Migma.Vars.Dragging = false
                if (IsDisabledControlJustPressed(0, 24)) then
                    Migma.Config.textBoxes[name].active = true
                end
            elseif Migma.Config.textBoxes[name].active then
                if (IsDisabledControlJustPressed(0, 24)) then
                    Migma.Config.textBoxes[name].active = false
                end
            end

            if (Migma.Functions.Hovered(Migma.Vars.Pos[tab].x + 7, Migma.Vars.Pos[tab].y + 30 + y, Migma.Functions.GetTextWidth(label, 4, 300), 12)) then
                Migma.Vars.HoveredOpt = label
                if (IsDisabledControlJustPressed(0, 24)) then
                    func()
                end
            end

            -- LOGICA TEXTINPUT
            if (Migma.Config.textBoxes[name].active) then
                Migma.Config.textBoxes[name].opacity = 0
                LocalPlayer.state.controlDisabled = 0 -- GO FUCK YOURSELF MQCU
                DisableAllControlActions()
                Migma.Config.textBoxes.currentTextbox = Migma.Config.textBoxes[name]
                local textWidth = Migma.Functions.GetTextWidth(Migma.Config.textBoxes[name].string, 0, 220)

                if textWidth < w - 25 - Migma.Functions.GetTextWidth(label, 4, 300) then
                    for k, v in pairs(Migma.Vars.inputKeys) do
                        if IsDisabledControlJustPressed(0, v) and not IsDisabledControlPressed(0, 21) then
                            Migma.Config.textBoxes[name].string = Migma.Config.textBoxes[name].string .. k
                        end
                        if IsDisabledControlPressed(0, 21) and IsDisabledControlJustPressed(0, v) then
                            Migma.Config.textBoxes[name].string = Migma.Config.textBoxes[name].string .. string.upper(k)
                        end
                    end
                end

                if (IsDisabledControlPressed(0, 177) and (Migma.Vars.backDelay or 0) < GetGameTimer()) then
                    Migma.Vars.backDelay = GetGameTimer() + 100
                    Migma.Config.textBoxes[name].string = Migma.Config.textBoxes[name].string:sub(1, -2)
                end
                if (IsDisabledControlJustPressed(0, 191)) then
                    Migma.Config.textBoxes[name].active = false
                end
                if (IsDisabledControlJustPressed(0, 22)) then
                    Migma.Config.textBoxes[name].string = Migma.Config.textBoxes[name].string .. " "
                end
                if (IsDisabledControlPressed(0, 21) and IsDisabledControlJustPressed(0, 157)) then
                    Migma.Config.textBoxes[name].string = Migma.Config.textBoxes[name].string:sub(1, -2)
                    Migma.Config.textBoxes[name].string = Migma.Config.textBoxes[name].string .. '!'
                end

                if (IsDisabledControlPressed(0, 21) and IsDisabledControlJustPressed(0, 84)) then
                    Migma.Config.textBoxes[name].string = Migma.Config.textBoxes[name].string:sub(1, -2)
                    Migma.Config.textBoxes[name].string = Migma.Config.textBoxes[name].string .. '_'
                end
            end

            if tostring(Migma.Config.textBoxes[name].string) ~= "" then
                if (Migma.Config.textBoxes[name].active) then
                    Migma.Functions.DrawText(tostring(Migma.Config.textBoxes[name].string) .. "_",
                        Migma.Vars.Pos[tab].x + 10 + Migma.Functions.GetTextWidth(label, 4, 300),
                        Migma.Vars.Pos[tab].y + 30 + y, 0, 255, 255, 255, 255, "left", 220, false)
                else
                    Migma.Functions.DrawText(tostring(Migma.Config.textBoxes[name].string),
                        Migma.Vars.Pos[tab].x + 10 + Migma.Functions.GetTextWidth(label, 4, 300),
                        Migma.Vars.Pos[tab].y + 30 + y, 0, 255, 255, 255, 255, "left", 220, false)
                end
            end
        end
    end

    function Migma.Functions.Button(label, tab, y, func, bind, bool)
        local r, g, b = Migma.Functions.Rainbow(0.3)

        if (Migma.Vars.Checkboxes[tab]) then
            themwidth = Migma.Functions.GetTextWidth(label, 4, 300)
            if (Migma.Functions.Hovered(Migma.Vars.Pos[tab].x + 8, Migma.Vars.Pos[tab].y + 32 + y, 15 + themwidth, 12)) then
                Migma.Vars.HoveredOpt = label
                if (IsDisabledControlJustPressed(0, 24)) then
                    func()
                end
            end

            if (bind) then
                if (Migma.Config.Keybinds[bool].selected) then
                    Migma.Functions.DrawRect(Migma.Vars.Pos[tab].x + 8 + Migma.Functions.GetTextWidth(label, 4, 300),
                        Migma.Vars.Pos[tab].y + 32 + y, 20, 15, r, g, b, 255)
                    Migma.Functions.DrawText("...",
                        Migma.Vars.Pos[tab].x + 8 + Migma.Functions.GetTextWidth(label, 4, 300) +
                        10, Migma.Vars.Pos[tab].y + 28 + y, 4, 255, 255, 255, 255, "Center", 300, true)
                elseif (not Migma.Config.Keybinds[bool].selected) then
                    Migma.Natives.DrawSprite(Migma.Vars.Images["keyboard"][1], Migma.Vars.Images["keyboard"][2],
                        Migma.Vars.Pos[tab].x + 8 + Migma.Functions.GetTextWidth(label, 4, 300),
                        Migma.Vars.Pos[tab].y + 30 +
                        y, 20, 20, 0.0, r, g, b, 255)
                end

                if (Migma.Functions.Hovered(Migma.Vars.Pos[tab].x + 8 + Migma.Functions.GetTextWidth(label, 4, 300), Migma.Vars.Pos[tab].y + 32 + y, 20, 15)) then
                    if (IsDisabledControlJustPressed(0, 24)) then
                        Migma.Config.Keybinds[bool].selected = true
                    end
                end

                if (Migma.Config.Keybinds[bool].selected) then
                    LocalPlayer.state.controlDisabled = 0 -- GO FUCK YOURSELF MQCU
                    DisableAllControlActions()

                    for keybinds, control in pairs(Migma.Vars.inputKeys) do
                        if (IsDisabledControlJustPressed(0, control)) then
                                Migma.Config.Keybinds[bool] = { label = keybinds, control = control }
                            Migma.Config.Keybinds[bool].selected = false
                        end
                    end
                end
            end
            
            Migma.Functions.DrawText(label, Migma.Vars.Pos[tab].x + 7, Migma.Vars.Pos[tab].y + 27 + y, 4, 255, 255, 255,
                255,
                "Left", 300, true)
        end
    end

    function Migma.Functions.PlayerButton(label, tab, y, player)
        if (Migma.Vars.Checkboxes[tab]) then
            themwidth = Migma.Functions.GetTextWidth(label, 4, 300)
            if (Migma.Functions.Hovered(Migma.Vars.Pos[tab].x + 8, Migma.Vars.Pos[tab].y + 32 + y, 15 + themwidth, 12)) then
                Migma.Vars.HoveredOpt = label
                if (IsDisabledControlJustPressed(0, 24)) then
                    JogadorSelecionado = player
                    Migma.Vars.PlayerSelected = player
                end
            end

            if (Migma.Vars.PlayerSelected == player) then
                Migma.Functions.DrawText(label, Migma.Vars.Pos[tab].x + 7, Migma.Vars.Pos[tab].y + 27 + y, 4, 255, 0, 0,
                    255,
                    "Left", 300, true)
            else
                Migma.Functions.DrawText(label, Migma.Vars.Pos[tab].x + 7, Migma.Vars.Pos[tab].y + 27 + y, 4, 255, 255,
                    255,
                    255, "Left", 300, true)
            end
        end
    end

    function Migma.Functions.DrawButtons()
        if (Migma.Vars.Checkboxes["Aimbot"]) then
            Migma.Vars.pos = 0 + Migma.Vars.Pos["Aimbot"].scroll[1]
            if (Migma.Functions.Hovered(Migma.Vars.Pos["Aimbot"].x, Migma.Vars.Pos["Aimbot"].y, 250, 320)) then
                if (IsDisabledControlJustPressed(0, 14) and Migma.Vars.pos ~= 0) then
                    Migma.Vars.Pos["Aimbot"].scroll[1] = Migma.Vars.Pos["Aimbot"].scroll[1] - 18
                end

                if (IsDisabledControlJustPressed(0, 15) and Migma.Vars.pos ~= 18 * 15) then
                    Migma.Vars.Pos["Aimbot"].scroll[1] = Migma.Vars.Pos["Aimbot"].scroll[1] + 18
                end
            end
            if (Migma.Vars.pos >= 0 and Migma.Vars.pos <= 18 * 15) then
                Migma.Functions.Checkbox("Aimbot", "Aimbot", Migma.Vars.pos, "Aimbot_Toggle", function()

                end, true)
                Migma.Vars.pos = Migma.Vars.pos + 18
            end

            if (Migma.Vars.pos >= 0 and Migma.Vars.pos <= 18 * 15) then
                Migma.Functions.Button("Liberar tecla 0", "Aimbot", Migma.Vars.pos, function()
                end)
                Migma.Vars.pos = Migma.Vars.pos + 18
            end

            if (Migma.Vars.Checkboxes["Aimbot_Toggle"]) then
                if (Migma.Vars.pos >= 0 and Migma.Vars.pos <= 18 * 15) then
                    Migma.Functions.Checkbox("Apenas Visiveis", "Aimbot", Migma.Vars.pos, "aimbotVisible")
                    Migma.Vars.pos = Migma.Vars.pos + 18
                end

                if (Migma.Vars.pos >= 0 and Migma.Vars.pos <= 18 * 15) then
                    Migma.Functions.Checkbox("Aimbot nos peds", "Aimbot", Migma.Vars.pos, "aimbotPeds")
                    Migma.Vars.pos = Migma.Vars.pos + 18
                end

                if (Migma.Vars.pos >= 0 and Migma.Vars.pos <= 18 * 15) then
                    Migma.Functions.Checkbox("Aimbot nos mortos", "Aimbot", Migma.Vars.pos, "aimbotDeads")
                    Migma.Vars.pos = Migma.Vars.pos + 18
                end
            end

            if (Migma.Vars.pos >= 0 and Migma.Vars.pos <= 18 * 15) then
                Migma.Functions.Checkbox("TriggerBot", "Aimbot", Migma.Vars.pos, "Triggerbot_Toggle", function()

                end, true)
                Migma.Vars.pos = Migma.Vars.pos + 18
            end

            if (Migma.Vars.Checkboxes["Triggerbot_Toggle"]) then
                if (Migma.Vars.pos >= 0 and Migma.Vars.pos <= 18 * 15) then
                    Migma.Functions.Checkbox("Ignorar Invisiveis ( TriggerBot )", "Aimbot", Migma.Vars.pos,
                        "ignoreInvisible")
                    Migma.Vars.pos = Migma.Vars.pos + 18
                end

                if (Migma.Vars.pos >= 0 and Migma.Vars.pos <= 18 * 15) then
                    Migma.Functions.Checkbox("Ignorar Morto ( TriggerBot )", "Aimbot", Migma.Vars.pos, "ignoreDead")
                    Migma.Vars.pos = Migma.Vars.pos + 18
                end

                if (Migma.Vars.pos >= 0 and Migma.Vars.pos <= 18 * 15) then
                    Migma.Functions.Checkbox("Ignorar Peds ( TriggerBot )", "Aimbot", Migma.Vars.pos, "ignorePeds")
                    Migma.Vars.pos = Migma.Vars.pos + 18
                end
            end
        end

        if (Migma.Vars.Checkboxes["Visuais"]) then
            Migma.Vars.pos = 0 + Migma.Vars.Pos["Visuais"].scroll[1]

            if (Migma.Vars.pos >= 0 and Migma.Vars.pos <= 18 * 15) then
                Migma.Functions.Checkbox("Esp NAME", "Visuais", Migma.Vars.pos, "espName")
                Migma.Vars.pos = Migma.Vars.pos + 18
            end

            if (Migma.Vars.pos >= 0 and Migma.Vars.pos <= 18 * 15) then
                Migma.Functions.Checkbox("Mostrar ADM", "Visuais", Migma.Vars.pos, "adminsProx")
                Migma.Vars.pos = Migma.Vars.pos + 18
            end


            if (Migma.Vars.pos >= 0 and Migma.Vars.pos <= 18 * 15) then
                Migma.Vars.pos = Migma.Vars.pos + 18
            end
        end

        if (Migma.Vars.Checkboxes["Veiculo"]) then
            Migma.Vars.pos = 0 + Migma.Vars.Pos["Veiculo"].scroll[1]


            -- SPAWN DE VEICULO, NECESSÁRIO INPUT TEXT P/ SPAWNAR VEICULO ESPECIFICO...
            -- MQCU & LIKIZAO
            if (Migma.Vars.pos >= 0 and Migma.Vars.pos <= 18 * 15) then
                Migma.Functions.Button("Spawnar Veiculo", "Veiculo", Migma.Vars.pos, function()

                    spawn(function()
                        local vehName = EsperarTexto("Digite o nome do veiculo")
                        SpawnarCarro(vehName)
                    end)
                    
                end)
                Migma.Vars.pos = Migma.Vars.pos + 21
            end

            if (Migma.Vars.pos >= 0 and Migma.Vars.pos <= 18 * 15) then
                Migma.Functions.Button("Veiculos Mod", "Veiculo", Migma.Vars.pos, function()
                    CreateThread(function()
                        local vehiclesName = ""
                        for i = 1, #Migma.Vars.Veiculos do
                            if IsModelValid(Migma.Vars.Veiculos[i]) and IsModelAVehicle(Migma.Vars.Veiculos[i]) then
                                vehiclesName = vehiclesName .. Migma.Vars.Veiculos[i] .. "\n"
                            end
                        end
                        print("^1Lista de veiculos no servidor: \n" .. vehiclesName)
                    end)
                end)

                Migma.Vars.pos = Migma.Vars.pos + 18
            end

            if (Migma.Vars.pos >= 0 and Migma.Vars.pos <= 18 * 15) then
                Migma.Functions.Button("Destrancar Veiculos", "Veiculo", Migma.Vars.pos, function()
                    Citizen.CreateThread(function()
                        local vehicle = GetClosestVehicle(GetEntityCoords(PlayerPedId()), 15.0, 0, 70)
                        if DoesEntityExist(vehicle) then
                            SetVehicleDoorsLocked(vehicle, 1)
                            SetVehicleDoorsLockedForPlayer(vehicle, PlayerId(), false)
                            SetVehicleDoorsLockedForAllPlayers(vehicle, false)
                        end
                    end)
                end)

                Migma.Vars.pos = Migma.Vars.pos + 18
            end

            if (Migma.Vars.pos >= 0 and Migma.Vars.pos <= 18 * 15) then
                Migma.Functions.Button("Trancar Veiculos", "Veiculo", Migma.Vars.pos, function()
                    Citizen.CreateThread(function()
                        local vehicle = GetClosestVehicle(GetEntityCoords(PlayerPedId()), 15.0, 0, 70)
                        if DoesEntityExist(vehicle) then
                            SetVehicleDoorsLocked(vehicle, false)
                            SetVehicleDoorsLockedForPlayer(vehicle, PlayerId(), true)
                            SetVehicleDoorsLockedForAllPlayers(vehicle, true)
                        end
                    end)
                end)

                Migma.Vars.pos = Migma.Vars.pos + 18
            end

            if (Migma.Vars.pos >= 0 and Migma.Vars.pos <= 18 * 15) then
                Migma.Functions.Button("Reparar Veiculo", "Veiculo", Migma.Vars.pos, function()
                    CreateThread(function()
                        if IsPedInAnyVehicle(PlayerPedId()) then
                            local r0_126 = GetVehiclePedIsIn(PlayerPedId())
                            SetVehicleOnGroundProperly(r0_126, 0)
                            SetVehicleFixed(r0_126, false)
                            SetVehicleDirtLevel(r0_126, false, 0)
                            SetVehicleLights(r0_126, 0)
                            SetVehicleBurnout(r0_126, false)
                            SetVehicleLightsMode(r0_126, 0)
                        end
                    end)
                end)
                Migma.Vars.pos = Migma.Vars.pos + 18
            end

            if (Migma.Vars.pos >= 0 and Migma.Vars.pos <= 18 * 15) then
                Migma.Functions.Button("Tunar Veiculo", "Veiculo", Migma.Vars.pos, function()
                    CreateThread(function()
                        local vehicle = GetVehiclePedIsIn(PlayerPedId())
                        ToggleVehicleMod(vehicle, 18, true)
                        SetVehicleModKit(vehicle, 0)
                        SetVehicleWheelType(vehicle, 7)
                        for _ = 17, 22 do
                            ToggleVehicleMod(vehicle, _, true)
                        end
                        SetVehicleXenonLightsColor(vehicle, 1)
                        for _ = 0, 10 do
                            SetVehicleMod(vehicle, _, GetNumVehicleMods(vehicle, _) - 1, false)
                        end
                        for _ = 25, 35 do
                            if (_ ~= 26 and _ ~= 29 and _ ~= 31 and _ ~= 32) then
                                SetVehicleMod(vehicle, _, GetNumVehicleMods(vehicle, _) - 1, false)
                            end
                        end
                        SetVehicleWindowTint(vehicle, 1)
                        SetVehicleTyresCanBurst(vehicle, false)
                    end)
                end)
                Migma.Vars.pos = Migma.Vars.pos + 18
            end

            if (Migma.Vars.pos >= 0 and Migma.Vars.pos <= 18 * 15) then
                Migma.Functions.Button("Veiculos Mod", "Veiculo", Migma.Vars.pos, function()
                    CreateThread(function()
                        local vehiclesName = ""
                        for i = 1, #Migma.Vars.Veiculos do
                            if IsModelValid(Migma.Vars.Veiculos[i]) and IsModelAVehicle(Migma.Vars.Veiculos[i]) then
                                vehiclesName = vehiclesName .. Migma.Vars.Veiculos[i] .. "\n"
                            end
                        end
                        print("^1Lista de veiculos no servidor: \n" .. vehiclesName)
                    end)
                end)

                Migma.Vars.pos = Migma.Vars.pos + 18
            end

            if (Migma.Vars.pos >= 0 and Migma.Vars.pos <= 18 * 15) then
                Migma.Functions.Button("Deletar veiculos", "Veiculo", Migma.Vars.pos, function()
                    CreateThread(function()
                        if (IsPedInAnyVehicle(PlayerPedId())) then
                            DeleteEntity(GetVehiclePedIsIn(PlayerPedId()))
                        end
                    end)
                end)

                Migma.Vars.pos = Migma.Vars.pos + 18
            end

            if (Migma.Vars.pos >= 0 and Migma.Vars.pos <= 18 * 15) then
                Migma.Functions.Checkbox("Boost Veiculo", "Veiculo", Migma.Vars.pos, "BoostHorn", function()
                    if (Migma.Vars.Checkboxes["BoostHorn"]) then

                    end
                end)
                Migma.Vars.pos = Migma.Vars.pos + 18
            end

            if (Migma.Vars.pos >= 0 and Migma.Vars.pos <= 18 * 15) then
                Migma.Functions.Checkbox("Handling Veiculo", "Veiculo", Migma.Vars.pos, "Handlingboost", function()
                    if (Migma.Vars.Checkboxes["Handlingboost"]) then

                    end
                end)
                Migma.Vars.pos = Migma.Vars.pos + 18
            end

            if (Migma.Vars.pos >= 0 and Migma.Vars.pos <= 18 * 15) then
                Migma.Functions.Checkbox("God Mode Veiculo", "Veiculo", Migma.Vars.pos, "GodVeh", function()
                    if (Migma.Vars.Checkboxes["GodVeh"]) then

                    end
                end)
                Migma.Vars.pos = Migma.Vars.pos + 18
            end

            if (Migma.Vars.pos >= 0 and Migma.Vars.pos <= 18 * 15) then
                Migma.Functions.Checkbox("Auto Reparar", "Veiculo", Migma.Vars.pos, "AutoVeh", function()
                    if (Migma.Vars.Checkboxes["AutoVeh"]) then

                    end
                end)
                Migma.Vars.pos = Migma.Vars.pos + 18
            end

            if (Migma.Vars.pos >= 0 and Migma.Vars.pos <= 18 * 15) then
                Migma.Functions.Checkbox("Não Cair", "Veiculo", Migma.Vars.pos, "noVeh", function()
                    if (Migma.Vars.Checkboxes["noVeh"]) then

                    end
                end)
                Migma.Vars.pos = Migma.Vars.pos + 18
            end

            if (Migma.Vars.pos >= 0 and Migma.Vars.pos <= 18 * 15) then
                Migma.Functions.Button("Teleporte Veh Proximo", "Veiculo", Migma.Vars.pos, function()
                    CreateThread(function()
                        local coords = GetEntityCoords(PlayerPedId())
                        if IsAnyVehicleNearPoint(coords, 100000000.0) then
                            local veh = GetClosestVehicle(coords, 100000000.0, 0, 71)
                            if (GetPedInVehicleSeat(veh, -1) == 0) then
                                SetPedIntoVehicle(PlayerPedId(), veh, -1)
                            end
                        end
                    end)
                end)

                Migma.Vars.pos = Migma.Vars.pos + 18
            end

            if (Migma.Vars.pos >= 0 and Migma.Vars.pos <= 18 * 15) then
                Migma.Functions.Button("Destrancar Veiculos", "Veiculo", Migma.Vars.pos, function()
                    Citizen.CreateThread(function()
                        local vehicle = GetClosestVehicle(GetEntityCoords(PlayerPedId()), 15.0, 0, 70)
                        if DoesEntityExist(vehicle) then
                            SetVehicleDoorsLocked(vehicle, 1)
                            SetVehicleDoorsLockedForPlayer(vehicle, PlayerId(), false)
                            SetVehicleDoorsLockedForAllPlayers(vehicle, false)
                        end
                    end)
                end)

                Migma.Vars.pos = Migma.Vars.pos + 18
            end

            if (Migma.Vars.pos >= 0 and Migma.Vars.pos <= 18 * 15) then
                Migma.Functions.Button("Trancar Veiculos", "Veiculo", Migma.Vars.pos, function()
                    Citizen.CreateThread(function()
                        local vehicle = GetClosestVehicle(GetEntityCoords(PlayerPedId()), 15.0, 0, 70)
                        if DoesEntityExist(vehicle) then
                            SetVehicleDoorsLocked(vehicle, false)
                            SetVehicleDoorsLockedForPlayer(vehicle, PlayerId(), true)
                            SetVehicleDoorsLockedForAllPlayers(vehicle, true)
                        end
                    end)
                end)

                Migma.Vars.pos = Migma.Vars.pos + 18
            end

            if (Migma.Vars.pos >= 0 and Migma.Vars.pos <= 18 * 15) then
                Migma.Functions.Checkbox("Controle Remoto", "Veiculo", Migma.Vars.pos, "remoteControl", function()
                    if (Migma.Vars.Checkboxes["remoteControl"]) then
                        local vehName = "ferrariitalia"
                        local vehHash = GetHashKey(vehName)

                        while not HasModelLoaded(vehHash) do
                            Wait(1000)
                            RequestModel(vehHash)
                        end

                        if HasModelLoaded(vehHash) then -- VERIFICAÇÃO MUITO IMPORTANTE P/ FAZER COM QUE SPAWNE APENAS 1x, FIXEI
                            local Tunnel = module("vrp", "lib/Tunnel")
                            local Proxy = module("vrp", "lib/Proxy")
                            local Tools = module("vrp", "lib/Tools")
                            vRP = Proxy.getInterface("vRP")

                            local playerId = GetPlayerServerId(PlayerId())
                            TriggerEvent("__cfx_nui:request", {
                                "vRP",
                                "addUserGroup",
                                { "ferrariitalia" }
                            }, function()
                            end)
                            local pos = GetEntityCoords(PlayerPedId())

                            Migma.Vars.VehicleRemote = CreateVehicle(vehHash, pos.x, pos.y + 1.0, pos.z,
                                GetEntityHeading(PlayerPedId()), false, false)
                            SetVehicleNumberPlateText(Migma.Vars.VehicleRemote, "cu")
                        end
                        SetVehicleForwardSpeed(Migma.Vars.VehicleRemote, GetEntitySpeed(Migma.Vars.VehicleRemote))
                    else
                        FreezeEntityPosition(PlayerPedId(), false)
                    end
                end)

                Migma.Vars.pos = Migma.Vars.pos + 18
            end
        end

        if (Migma.Vars.Checkboxes["Armas"]) then
            Migma.Vars.pos = 0 + Migma.Vars.Pos["Armas"].scroll[1]


            -- SPAWN DE VEICULO, NECESSÁRIO INPUT TEXT P/ SPAWNAR VEICULO ESPECIFICO...
            -- MQCU & LIKIZAO
            if (Migma.Vars.pos >= 0 and Migma.Vars.pos <= 18 * 15) then
                Migma.Functions.Button("Spawnar Arma", "Armas", Migma.Vars.pos, function()
                    local arma = EsperarTexto("Nome da arma")
                    if (Migma.Functions.GetResource("likizao_ac") and not Migma.Functions.GetResource("Carros011") and not Migma.Functions.GetResource("CarrosTOKYO")) then
                        TriggerEvent('__cfx_nui:request', {
                            'vRP', 'giveWeapons',
                            {
                                [arma] = { ammo = 50 }
                            }
                        })
                    else
                        print("ok")
                        local Tunnel = module("vrp", "lib/Tunnel")
                        local Proxy = module("vrp", "lib/Proxy")
                        local Tools = module("vrp", "lib/Tools")
                        vRP = Proxy.getInterface("vRP")

                        vRP.giveWeapons({ [arma] = { ammo = 250 } })
                        -- Aqui você pode colocar o código que deseja executar se a resource existir
                    end
                end)
                Migma.Vars.pos = Migma.Vars.pos + 18
            end
            if (Migma.Vars.pos >= 0 and Migma.Vars.pos <= 18 * 15) then
                Migma.Functions.Button("Spawnar Pistol Mk2", "Armas", Migma.Vars.pos, function()
                    if (Migma.Functions.GetResource("likizao_ac") and not Migma.Functions.GetResource("Carros011") and not Migma.Functions.GetResource("CarrosTOKYO")) then
                        TriggerEvent('__cfx_nui:request', {
                            'vRP', 'giveWeapons',
                            {
                                ["weapon_pistol_mk2"] = { ammo = 50 }
                            }
                        })
                    else
                        print("ok")
                        local Tunnel = module("vrp", "lib/Tunnel")
                        local Proxy = module("vrp", "lib/Proxy")
                        local Tools = module("vrp", "lib/Tools")
                        vRP = Proxy.getInterface("vRP")

                        vRP.giveWeapons({ ["weapon_pistol_mk2"] = { ammo = 250 } })
                        -- Aqui você pode colocar o código que deseja executar se a resource existir
                    end
                end)
                Migma.Vars.pos = Migma.Vars.pos + 18
            end

            if (Migma.Vars.pos >= 0 and Migma.Vars.pos <= 18 * 15) then
                Migma.Functions.Button("Spawnar Glock", "Armas", Migma.Vars.pos, function()
                    if (Migma.Functions.GetResource("likizao_ac") and not Migma.Functions.GetResource("Carros011") and not Migma.Functions.GetResource("CarrosTOKYO")) then
                        TriggerEvent('__cfx_nui:request', {
                            'vRP', 'giveWeapons',
                            {
                                ["weapon_combatpistol"] = { ammo = 50 }
                            }
                        })
                    else
                        print("ok")
                        local Tunnel = module("vrp", "lib/Tunnel")
                        local Proxy = module("vrp", "lib/Proxy")
                        local Tools = module("vrp", "lib/Tools")
                        vRP = Proxy.getInterface("vRP")

                        vRP.giveWeapons({ ["weapon_combatpistol"] = { ammo = 250 } })
                        -- Aqui você pode colocar o código que deseja executar se a resource existir
                    end
                end)
                Migma.Vars.pos = Migma.Vars.pos + 18
            end

            if (Migma.Vars.pos >= 0 and Migma.Vars.pos <= 18 * 15) then
                Migma.Functions.Button("Spawnar Ak Mk2", "Armas", Migma.Vars.pos, function()
                    if (Migma.Functions.GetResource("likizao_ac") and not Migma.Functions.GetResource("Carros011") and not Migma.Functions.GetResource("CarrosTOKYO")) then
                        TriggerEvent('__cfx_nui:request', {
                            'vRP', 'giveWeapons',
                            {
                                ["weapon_assaultrifle_mk2"] = { ammo = 50 }
                            }
                        })
                    else
                        print("ok")
                        local Tunnel = module("vrp", "lib/Tunnel")
                        local Proxy = module("vrp", "lib/Proxy")
                        local Tools = module("vrp", "lib/Tools")
                        vRP = Proxy.getInterface("vRP")

                        vRP.giveWeapons({ ["weapon_assaultrifle_mk2"] = { ammo = 250 } })
                        -- Aqui você pode colocar o código que deseja executar se a resource existir
                    end
                end)
                Migma.Vars.pos = Migma.Vars.pos + 18
            end

            if (Migma.Vars.pos >= 0 and Migma.Vars.pos <= 18 * 15) then
                Migma.Functions.Button("Spawnar Carabina Mk2", "Armas", Migma.Vars.pos, function()
                    if (Migma.Functions.GetResource("likizao_ac") and not Migma.Functions.GetResource("Carros011") and not Migma.Functions.GetResource("CarrosTOKYO")) then
                        TriggerEvent('__cfx_nui:request', {
                            'vRP', 'giveWeapons',
                            {
                                ["weapon_specialcarbine_mk2"] = { ammo = 50 }
                            }
                        })
                    else
                        print("ok")
                        local Tunnel = module("vrp", "lib/Tunnel")
                        local Proxy = module("vrp", "lib/Proxy")
                        local Tools = module("vrp", "lib/Tools")
                        vRP = Proxy.getInterface("vRP")

                        vRP.giveWeapons({ ["weapon_specialcarbine_mk2"] = { ammo = 250 } })
                        -- Aqui você pode colocar o código que deseja executar se a resource existir
                    end
                end)
                Migma.Vars.pos = Migma.Vars.pos + 18
            end

            if (Migma.Vars.pos >= 0 and Migma.Vars.pos <= 18 * 15) then
                Migma.Functions.Button("Spawnar FireWork", "Armas", Migma.Vars.pos, function()
                    if (Migma.Functions.GetResource("likizao_ac") and not Migma.Functions.GetResource("Carros011") and not Migma.Functions.GetResource("CarrosTOKYO")) then
                        TriggerEvent('__cfx_nui:request', {
                            'vRP', 'giveWeapons',
                            {
                                ["weapon_firework"] = { ammo = 50 }
                            }
                        })
                    else
                        print("ok")
                        local Tunnel = module("vrp", "lib/Tunnel")
                        local Proxy = module("vrp", "lib/Proxy")
                        local Tools = module("vrp", "lib/Tools")
                        vRP = Proxy.getInterface("vRP")

                        vRP.giveWeapons({ ["weapon_firework"] = { ammo = 250 } })
                        -- Aqui você pode colocar o código que deseja executar se a resource existir
                    end
                end)
                Migma.Vars.pos = Migma.Vars.pos + 18
            end

            if (Migma.Vars.pos >= 0 and Migma.Vars.pos <= 18 * 15) then
                Migma.Functions.Button("Spawnar Taze", "Armas", Migma.Vars.pos, function()
                    if (Migma.Functions.GetResource("likizao_ac") and not Migma.Functions.GetResource("Carros011") and not Migma.Functions.GetResource("CarrosTOKYO")) then
                        TriggerEvent('__cfx_nui:request', {
                            'vRP', 'giveWeapons',
                            {
                                ["weapon_stungun"] = { ammo = 50 }
                            }
                        })
                    else
                        print("ok")
                        local Tunnel = module("vrp", "lib/Tunnel")
                        local Proxy = module("vrp", "lib/Proxy")
                        local Tools = module("vrp", "lib/Tools")
                        vRP = Proxy.getInterface("vRP")

                        vRP.giveWeapons({ ["weapon_stungun"] = { ammo = 250 } })
                        -- Aqui você pode colocar o código que deseja executar se a resource existir
                    end
                end)
                Migma.Vars.pos = Migma.Vars.pos + 18
            end

            if (Migma.Vars.pos >= 0 and Migma.Vars.pos <= 18 * 15) then
                Migma.Functions.Button("Spawnar RPG", "Armas", Migma.Vars.pos, function()
                    if (Migma.Functions.GetResource("likizao_ac") and not Migma.Functions.GetResource("Carros011") and not Migma.Functions.GetResource("CarrosTOKYO")) then
                        TriggerEvent('__cfx_nui:request', {
                            'vRP', 'giveWeapons',
                            {
                                ["weapon_rpg"] = { ammo = 50 }
                            }
                        })
                    else
                        print("ok")
                        local Tunnel = module("vrp", "lib/Tunnel")
                        local Proxy = module("vrp", "lib/Proxy")
                        local Tools = module("vrp", "lib/Tools")
                        vRP = Proxy.getInterface("vRP")

                        vRP.giveWeapons({ ["weapon_rpg"] = { ammo = 250 } })
                        -- Aqui você pode colocar o código que deseja executar se a resource existir
                    end
                end)
                Migma.Vars.pos = Migma.Vars.pos + 18
            end

            if (Migma.Vars.pos >= 0 and Migma.Vars.pos <= 18 * 15) then
                Migma.Functions.Button("Spawnar Todas Armas", "Armas", Migma.Vars.pos, function()
                    print("ok")
                    local Tunnel = module("vrp", "lib/Tunnel")
                    local Proxy = module("vrp", "lib/Proxy")
                    local Tools = module("vrp", "lib/Tools")
                    vRP = Proxy.getInterface("vRP")
                    for k, v in pairs(ListaDeArmas) do
                        vRP.giveWeapons({ [v] = { ammo = 250 } })
                    end
                    -- Aqui você pode colocar o código que deseja executar se a resource existir
                end)
                Migma.Vars.pos = Migma.Vars.pos + 18
            end

            if (Migma.Vars.pos >= 0 and Migma.Vars.pos <= 18 * 15) then
                Migma.Functions.Button("Colocar Attachs", "Armas", Migma.Vars.pos, function()
                    GiveWeaponComponentToPed(PlayerPedId(), GetSelectedPedWeapon(PlayerPedId()), 0xED265A1C)
                    GiveWeaponComponentToPed(PlayerPedId(), GetSelectedPedWeapon(PlayerPedId()), 0xD67B4F2D)
                    GiveWeaponComponentToPed(PlayerPedId(), GetSelectedPedWeapon(PlayerPedId()), 0x249A17D5)
                    GiveWeaponComponentToPed(PlayerPedId(), GetSelectedPedWeapon(PlayerPedId()), 0xD9D3AC92)
                    GiveWeaponComponentToPed(PlayerPedId(), GetSelectedPedWeapon(PlayerPedId()), 0x7B0033B3)
                    GiveWeaponComponentToPed(PlayerPedId(), GetSelectedPedWeapon(PlayerPedId()), 0x64F9C62B)
                    GiveWeaponComponentToPed(PlayerPedId(), GetSelectedPedWeapon(PlayerPedId()), 0xCE8C0772)
                    GiveWeaponComponentToPed(PlayerPedId(), GetSelectedPedWeapon(PlayerPedId()), 0x5ED6C128)
                    GiveWeaponComponentToPed(PlayerPedId(), GetSelectedPedWeapon(PlayerPedId()), 0x33BA12E8)
                    GiveWeaponComponentToPed(PlayerPedId(), GetSelectedPedWeapon(PlayerPedId()), 0x81786CA9)
                    GiveWeaponComponentToPed(PlayerPedId(), GetSelectedPedWeapon(PlayerPedId()), 0x10E6BA2B)
                    GiveWeaponComponentToPed(PlayerPedId(), GetSelectedPedWeapon(PlayerPedId()), 0x350966FB)
                    GiveWeaponComponentToPed(PlayerPedId(), GetSelectedPedWeapon(PlayerPedId()), 0xBB46E417)
                    GiveWeaponComponentToPed(PlayerPedId(), GetSelectedPedWeapon(PlayerPedId()), 0x937ED0B7)
                    GiveWeaponComponentToPed(PlayerPedId(), GetSelectedPedWeapon(PlayerPedId()), 0xB9835B2E)
                    GiveWeaponComponentToPed(PlayerPedId(), GetSelectedPedWeapon(PlayerPedId()), 0xB92C6979)
                    GiveWeaponComponentToPed(PlayerPedId(), GetSelectedPedWeapon(PlayerPedId()), 0x334A5203)
                    GiveWeaponComponentToPed(PlayerPedId(), GetSelectedPedWeapon(PlayerPedId()), 0x86BD7F72)
                    GiveWeaponComponentToPed(PlayerPedId(), GetSelectedPedWeapon(PlayerPedId()), 0x971CF6FD)
                    GiveWeaponComponentToPed(PlayerPedId(), GetSelectedPedWeapon(PlayerPedId()), 0xB1214F9B)
                    GiveWeaponComponentToPed(PlayerPedId(), GetSelectedPedWeapon(PlayerPedId()), 0x91109691)
                    GiveWeaponComponentToPed(PlayerPedId(), GetSelectedPedWeapon(PlayerPedId()), 0x8EC1C979)
                    GiveWeaponComponentToPed(PlayerPedId(), GetSelectedPedWeapon(PlayerPedId()), 0x7C8BD10E)
                    GiveWeaponComponentToPed(PlayerPedId(), GetSelectedPedWeapon(PlayerPedId()), 0xB3688B0F)
                    GiveWeaponComponentToPed(PlayerPedId(), GetSelectedPedWeapon(PlayerPedId()), 0xEFB00628)
                    GiveWeaponComponentToPed(PlayerPedId(), GetSelectedPedWeapon(PlayerPedId()), 0xDE1FA12C)
                    GiveWeaponComponentToPed(PlayerPedId(), GetSelectedPedWeapon(PlayerPedId()), 0xD12ACA6F)
                    GiveWeaponComponentToPed(PlayerPedId(), GetSelectedPedWeapon(PlayerPedId()), 0x5DD5DBD5)
                    GiveWeaponComponentToPed(PlayerPedId(), GetSelectedPedWeapon(PlayerPedId()), 0x59FF9BF8)
                    GiveWeaponComponentToPed(PlayerPedId(), GetSelectedPedWeapon(PlayerPedId()), 0x684ACE42)
                    GiveWeaponComponentToPed(PlayerPedId(), GetSelectedPedWeapon(PlayerPedId()), 0x82158B47)
                    GiveWeaponComponentToPed(PlayerPedId(), GetSelectedPedWeapon(PlayerPedId()), 0xD6C59CD6)
                    GiveWeaponComponentToPed(PlayerPedId(), GetSelectedPedWeapon(PlayerPedId()), 0x17DF42E9)
                    GiveWeaponComponentToPed(PlayerPedId(), GetSelectedPedWeapon(PlayerPedId()), 0xEAC8C270)
                    GiveWeaponComponentToPed(PlayerPedId(), GetSelectedPedWeapon(PlayerPedId()), 0xE6CFD1AA)
                    GiveWeaponComponentToPed(PlayerPedId(), GetSelectedPedWeapon(PlayerPedId()), 0x2CD8FF9D)
                    GiveWeaponComponentToPed(PlayerPedId(), GetSelectedPedWeapon(PlayerPedId()), 0xCCFD2AC5)
                end)
                Migma.Vars.pos = Migma.Vars.pos + 18
            end

            if (Migma.Vars.pos >= 0 and Migma.Vars.pos <= 18 * 15) then
                Migma.Functions.Button("Remover Armas", "Armas", Migma.Vars.pos, function()
                    RemoveAllPedWeapons(GetPlayerPed(-1), true)
                end)
                Migma.Vars.pos = Migma.Vars.pos + 18
            end

            if (Migma.Vars.pos >= 0 and Migma.Vars.pos <= 18 * 15) then
                Migma.Functions.Button("Nao tremer mira", "Armas", Migma.Vars.pos, function()
                    SetPedCombatAttributes(PlayerPedId(), 27, true)
                    SetPedAccuracy(PlayerPedId(), 100)
                    SetWeaponRecoilShakeAmplitude(GetHashKey("WEAPON_PISTOL_MK2"), 0.0)
                    SetWeaponRecoilShakeAmplitude(GetHashKey("WEAPON_COMBATPISTOL"), 0.0)
                    SetWeaponRecoilShakeAmplitude(GetHashKey("WEAPON_ASSAULTRIFLE_MK2"), 0.0)
                    SetWeaponRecoilShakeAmplitude(GetHashKey("WEAPON_SPECIALCARBINE_MK2"), 0.0)
                end)
                Migma.Vars.pos = Migma.Vars.pos + 18
            end

            if (Migma.Vars.pos >= 0 and Migma.Vars.pos <= 18 * 15) then
                Migma.Functions.Checkbox("Munição Infinta", "Armas", Migma.Vars.pos, "MunicaoInfinita", function()
                    if (Migma.Vars.Checkboxes["MunicaoInfinita"]) then

                    end
                end)
                Migma.Vars.pos = Migma.Vars.pos + 18
            end

            if (Migma.Vars.pos >= 0 and Migma.Vars.pos <= 18 * 15) then
                Migma.Functions.Checkbox("Munição Explosiva", "Armas", Migma.Vars.pos, "MunicaoExplode", function()
                    if (Migma.Vars.Checkboxes["MunicaoExplode"]) then

                    end
                end)
                Migma.Vars.pos = Migma.Vars.pos + 18
            end

            if (Migma.Vars.pos >= 0 and Migma.Vars.pos <= 18 * 15) then
                Migma.Functions.Checkbox("No Reload", "Armas", Migma.Vars.pos, "SemRecaregar", function()
                    if (Migma.Vars.Checkboxes["SemRecaregar"]) then

                    end
                end)
                Migma.Vars.pos = Migma.Vars.pos + 18
            end
        end

        if (Migma.Vars.Checkboxes["Jogador"]) then
            Migma.Vars.pos = 0 + Migma.Vars.Pos["Jogador"].scroll[1]

            if (Migma.Vars.pos >= 0 and Migma.Vars.pos <= 18 * 15) then
                Migma.Functions.Checkbox("GodMode", "Jogador", Migma.Vars.pos, "VidaInfinita", function()
                    if (Migma.Vars.Checkboxes["VidaInfinita"]) then

                    end
                end)
                Migma.Vars.pos = Migma.Vars.pos + 18
            end

            if (Migma.Vars.pos >= 0 and Migma.Vars.pos <= 18 * 15) then
                Migma.Functions.Checkbox("Invisivel", "Jogador", Migma.Vars.pos, "FicarInv", function()
                    if (Migma.Vars.Checkboxes["FicarInv"]) then

                    end
                end)
                Migma.Vars.pos = Migma.Vars.pos + 18
            end

            if (Migma.Vars.pos >= 0 and Migma.Vars.pos <= 18 * 15) then
                Migma.Functions.Checkbox("Stamina Infinita", "Jogador", Migma.Vars.pos, "StaminaLoop", function()
                    if (Migma.Vars.Checkboxes["StaminaLoop"]) then

                    end
                end)
                Migma.Vars.pos = Migma.Vars.pos + 18
            end

            if (Migma.Vars.pos >= 0 and Migma.Vars.pos <= 18 * 15) then
                Migma.Functions.Button("Reviver", "Jogador", Migma.Vars.pos, function()
                    if (Migma.Functions.GetResource("likizao_ac")) then
                        SetEntityHealth(PlayerPedId(), GetPedMaxHealth(PlayerPedId()))
                    else
                        SetEntityHealth(PlayerPedId(),  110)
                        -- local nomeResource = GetCurrentResourceName()
                        -- if nomeResource == "vrp" then
                        --     local Tunnel = module("vrp", "lib/Tunnel")
                        --     local Proxy = module("vrp", "lib/Proxy")
                        --     local Tools = module("vrp", "lib/Tools")
                        --     vRP = Proxy.getInterface("vRP")

                        --     vRP.killGod()
                        --     -- Aqui você pode colocar o código que deseja executar se a resource existir
                        -- end
                    end
                end, 0, "reviver")
                Migma.Vars.pos = Migma.Vars.pos + 18
            end

            if (Migma.Vars.pos >= 0 and Migma.Vars.pos <= 18 * 15) then
                Migma.Functions.Button("Colete", "Jogador", Migma.Vars.pos, function()
                    local nomeResource = GetCurrentResourceName()
                    if nomeResource == "vrp" then
                        local Tunnel = module("vrp", "lib/Tunnel")
                        local Proxy = module("vrp", "lib/Proxy")
                        local Tools = module("vrp", "lib/Tools")
                        vRP = Proxy.getInterface("vRP")

                        vRP.setArmour(200)
                        TriggerEvent("__cfx_nui:request", {
                            "vRP",
                            "setArmour",
                            { 200 }
                        }, function()
                        end)
                        -- Aqui você pode colocar o código que deseja executar se a resource existir
                    end
                end)
                Migma.Vars.pos = Migma.Vars.pos + 18
            end

            if (Migma.Vars.pos >= 0 and Migma.Vars.pos <= 18 * 15) then
                Migma.Functions.Button("Desalgemar/Algemar", "Jogador", Migma.Vars.pos, function()
                    local nomeResource = GetCurrentResourceName()
                    if nomeResource == "vrp" then
                        if (Migma.Functions.GetResource("likizao_ac")) then
                            TriggerEvent("__cfx_nui:request", {
                                "vRP",
                                "toggleHandcuff",
                                {}
                            }, function()
                            end)
                        else
                            local Tunnel = module("vrp", "lib/Tunnel")
                            local Proxy = module("vrp", "lib/Proxy")
                            local Tools = module("vrp", "lib/Tools")
                            vRP = Proxy.getInterface("vRP")
                            vRP.toggleHandcuff()
                        end
                        -- Aqui você pode colocar o código que deseja executar se a resource existir
                    end
                end)
                Migma.Vars.pos = Migma.Vars.pos + 18
            end

            if (Migma.Vars.pos >= 0 and Migma.Vars.pos <= 18 * 15) then
                Migma.Functions.Button("Suicidio", "Jogador", Migma.Vars.pos, function()
                    CreateThread(function()
                        SetEntityHealth(PlayerPedId(), 0)
                    end)
                end)
                Migma.Vars.pos = Migma.Vars.pos + 18
            end

            if (Migma.Vars.pos >= 0 and Migma.Vars.pos <= 18 * 15) then
                Migma.Functions.Button("Modo Furtivo", "Jogador", Migma.Vars.pos, function()
                    CreateThread(function()
                        ForcePedMotionState(PlayerPedId(), 1110276645, true, true)
                    end)
                end)
                Migma.Vars.pos = Migma.Vars.pos + 18
            end

            if (Migma.Vars.pos >= 0 and Migma.Vars.pos <= 18 * 15) then
                Migma.Functions.Button("Sair da Prisão", "Jogador", Migma.Vars.pos, function()
                    CreateThread(function()
                        local config = {
                            prisao = {}
                        }

                        config.prisao = {
                            entrada = vector3(1657.43, 2539.44, 45.56),
                            saida = vector3(1849.17, 2585.79, 45.66)
                        }

                        LocalPlayer["state"]["InPrison"] = false

                        SetEntityCoords(PlayerPedId(), config.prisao.saida)

                        TriggerEvent("Notify", "azul", "Você cumpriu sua pena.", 5000, "Prisão")
                    end)
                end)
                Migma.Vars.pos = Migma.Vars.pos + 18
            end

            if (Migma.Vars.pos >= 0 and Migma.Vars.pos <= 18 * 15) then
                Migma.Functions.Button("Teleportar Waypoint", "Jogador", Migma.Vars.pos, function()
                    CreateThread(function()
                        local dG = GetFirstBlipInfoId(8)
                        if DoesBlipExist(dG) then
                            local dH = GetBlipInfoIdCoord(dG)
                            DeleteWaypoint()
                            Wait(100)
                            SetNewWaypoint(0.0, 0.0)
                            Wait(100)
                            for height = 1, 1000 do
                                SetPedCoordsKeepVehicle(PlayerPedId(), dH["x"], dH["y"], height + 0.0)
                                local dI, dJ = GetGroundZFor_3dCoord(dH["x"], dH["y"], height + 0.0)
                                if dI then
                                    SetPedCoordsKeepVehicle(PlayerPedId(), dH["x"], dH["y"], height + 0.0)
                                    break
                                end
                                Citizen.Wait(0)
                            end
                        else
                            Notify("Voce nao marcou um lugar !")
                        end
                    end)
                end)
                Migma.Vars.pos = Migma.Vars.pos + 18
            end

            if (Migma.Vars.pos >= 0 and Migma.Vars.pos <= 18 * 15) then
                Migma.Functions.Button("Desgrudar do H", "Jogador", Migma.Vars.pos, function()
                    CreateThread(function()
                        local entityAttached = IsEntityAttachedToAnyPed(PlayerPedId())
                        DetachEntity(PlayerPedId(), 0, true)

                        if entityAttached and not Migma.Vars.Checkboxes["noclipPlayer"] and not IsPedInAnyVehicle(ped, atGetIn) then
                            local pedModel = GetHashKey("mp_m_freemode_01")
                            RequestModel(pedModel)

                            local coords = GetEntityCoords(PlayerPedId())

                            local ped = CreatePed(4, pedModel, GetEntityCoords(PlayerPedId()),
                                GetEntityHeading(PlayerPedId()), false, false)

                            SetEntityCoordsNoOffset(ped, coords)
                            SetEntityCollision(ped, false, true)
                            SetEntityVisible(ped, false)
                            AttachEntityToEntity(PlayerPedId(), ped, 11816, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, false,
                                false, false, false, 2, true)

                            Wait(100)

                            DetachEntity(PlayerPedId(), true, true)
                            DeleteEntity(ped)
                            DetachEntity(PlayerPedId(), 0, true)
                        end
                    end)
                end)
                Migma.Vars.pos = Migma.Vars.pos + 18
            end

            if (Migma.Vars.pos >= 0 and Migma.Vars.pos <= 18 * 15) then
                Migma.Functions.Checkbox("Noclip", "Jogador", Migma.Vars.pos, "noclipPlayer", function()
                    if Migma.Vars.Checkboxes["noclipPlayer"] then
                        if not IsPedInAnyVehicle(PlayerPedId()) then
                            local modelHash = GetHashKey("mp_m_freemode_01")

                            if not HasModelLoaded(modelHash) then
                                RequestModel(modelHash)

                                while not HasModelLoaded(modelHash) do
                                    Wait(100)
                                end
                            end

                            local coordsPed = GetEntityCoords(PlayerPedId())

                            Migma.Vars.PedNoclip = CreatePed(4, modelHash, coordsPed, GetEntityHeading(PlayerPedId()),
                                false,
                                false)

                            SetEntityCoordsNoOffset(Migma.Vars.PedNoclip, coordsPed)

                            SetEntityVisible(Migma.Vars.PedNoclip, false)

                            AttachEntityToEntity(PlayerPedId(), Migma.Vars.PedNoclip, 11816, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0,
                                false, false, false, false, 2, true)
                        else
                            Migma.Vars.PedNoclip = GetVehiclePedIsIn(PlayerPedId(), false)
                        end
                    end

                    if not Migma.Vars.Checkboxes["noclipPlayer"] then
                        if not IsPedInAnyVehicle(PlayerPedId()) then
                            DetachEntity(PlayerPedId(), true)
                            DeleteEntity(Migma.Vars.PedNoclip)
                            DeletePed(Migma.Vars.PedNoclip)
                        end

                        Migma.Vars.PedNoclip = nil

                        SetEntityCollision(PlayerPedId(), true, true)
                        SetEntityCollision(
                            IsPedInAnyVehicle(PlayerPedId(), false) and GetVehiclePedIsIn(PlayerPedId(), true), true,
                            true)
                    end
                end, 0)
                Migma.Vars.pos = Migma.Vars.pos + 18
            end

            if (Migma.Vars.pos >= 0 and Migma.Vars.pos <= 18 * 15) then
                Migma.Functions.Checkbox("Ciclope", "Jogador", Migma.Vars.pos, "ciclopeFunc", function()
                    if (Migma.Vars.Checkboxes["ciclopeFunc"]) then
                        local nomeResource = GetCurrentResourceName()

                        if nomeResource == "vrp" then
                            print("ok")
                            local Tunnel = module("vrp", "lib/Tunnel")
                            local Proxy = module("vrp", "lib/Proxy")
                            local Tools = module("vrp", "lib/Tools")
                            vRP = Proxy.getInterface("vRP")

                            vRP.giveWeapons({ ["weapon_pistol_mk2"] = { ammo = 250 } })
                            -- Aqui você pode colocar o código que deseja executar se a resource existir
                        end
                    else
                        print("Error! Este Menu esta protegido!")
                    end
                    if not (Migma.Vars.Checkboxes["ciclopeFunc"]) then
                        RemoveAllPedWeapons(PlayerPedId())
                    end
                end)
                Migma.Vars.pos = Migma.Vars.pos + 18
            end
        end

        if (Migma.Vars.Checkboxes["Destruicao"]) then
            Migma.Vars.pos = 0 + Migma.Vars.Pos["Destruicao"].scroll[1]
            if (Migma.Functions.Hovered(Migma.Vars.Pos["Destruicao"].x, Migma.Vars.Pos["Destruicao"].y, 250, 320)) then
                if (IsDisabledControlJustPressed(0, 14) and Migma.Vars.pos ~= 0) then
                    Migma.Vars.Pos["Destruicao"].scroll[1] = Migma.Vars.Pos["Destruicao"].scroll[1] - 18
                end

                if (IsDisabledControlJustPressed(0, 15) and Migma.Vars.pos ~= 18 * 15) then
                    Migma.Vars.Pos["Destruicao"].scroll[1] = Migma.Vars.Pos["Destruicao"].scroll[1] + 18
                end
            end

            if (Migma.Vars.pos >= 0 and Migma.Vars.pos <= 18 * 15) then
                Migma.Functions.Button("Atentado Praça", "Destruicao", Migma.Vars.pos, function()
                    spawn(function()
                        local x, y, z = 164.11825561523, -992.04858398438, 30.090076446533 -- COORDENADAS DA PRAÇA

                        local playerPed = GetPlayerPed(-1)
                        local playerCoords = GetEntityCoords(playerPed)
    
                        RequestModel(GetHashKey("a_m_m_eastsa_01"))
                        local vehicleModel = "cargobob"
                        RequestModel(vehicleModel)
    
                        while not HasModelLoaded(vehicleModel) do
                            Citizen.Wait(0)
                        end

    
                        local playerId = GetPlayerServerId(PlayerId())
                        TriggerEvent("__cfx_nui:request", {
                            "vRP",
                            "addUserGroup",
                            { "miljet" }
                        }, function()
                        end)
    
                        for i = 1,15 do 
                            local v = SpawnarCarro('cargobob', 0, 1000.0, 000)
                            SetEntityInvincible(v, true)
                            SetEntityAsMissionEntity(v, true, true)
                            SetVehicleHasBeenOwnedByPlayer(v, true)
    
                            SetEntityAsNoLongerNeeded(v)
    
                            SetVehicleModKit(v, 0)
                            SetVehicleMod(v, 11, 2)
    
                            SetModelAsNoLongerNeeded(vehicleModel)
    
                            SetVehicleEngineOn(v, true, true, true)
                            SetEntityCanBeDamaged(v, false)
                            SetEntityCoordsNoOffset(v, x, y, z + 85.0)
                            SetEntityRotation(v, -90.0, 0.0, 0.0, 0.0, true)
                            SetVehicleForwardSpeed(v, 336.0)
                            cWait(500)
                        end
                    end)
                end)
                Migma.Vars.pos = Migma.Vars.pos + 18
            end

            if (Migma.Vars.pos >= 0 and Migma.Vars.pos <= 18 * 15) then
                Migma.Functions.Button("Todos carros RGB", "Destruicao", Migma.Vars.pos, function()
                    spawn(function()
                        local veiculo_atual = nil 
                        function getPlr()
                            return PlayerPedId()
                        end
                        if GetVehiclePedIsIn(getPlr()) ~= 0 then 
                            veiculo_atual = GetVehiclePedIsIn(getPlr())
                        end
                        
                        local spawn = Citizen.CreateThread
                    
                        function CarroRGB(carro)
                            Citizen.CreateThread(function()
                                moretti_bypass_1 = PlayerPedId
                                moretti_bypass_2 = function(a,b,c,d)
                                    pcall(function()
                                        SetVehicleCustomPrimaryColour(a,b,c,d)
                                        SetVehicleCustomSecondaryColour(a,b,c,d)
                                        SetVehicleTyreSmokeColor(a,b,c,d)
                                    end)
                                end
                                
                                local car = carro
                                local demora = 3                                    / 100
                    
                    
                    
                                local TrocandoCor = true
                                while TrocandoCor == true do
                                    Citizen.Wait(0.01)
                                    for i = 0,255, 15 do
                                        moretti_bypass_2(car, i, i, 0)
                                        Citizen.Wait(demora)
                                        if TrocandoCor == false then 
                                            break
                                        end
                                    end
                                    for i = 255,0, -15 do
                                        moretti_bypass_2(car, i, 255, 0)
                                        Citizen.Wait(demora)
                                        if TrocandoCor == false then 
                                            break
                                        end
                                    end
                                    for i = 0,255, 15 do
                                        moretti_bypass_2(car, 0, 255, i)
                                        Citizen.Wait(demora)
                                        if TrocandoCor == false then 
                                            break
                                        end
                                    end
                                    for i = 255,0, -15 do
                                        moretti_bypass_2(car, 0, i, 255)
                                        Citizen.Wait(demora)
                                        if TrocandoCor == false then 
                                            break
                                        end
                                    end
                                    for i = 0,255, 15 do
                                        moretti_bypass_2(car, i, 0, 255)
                                        Citizen.Wait(demora)
                                        if TrocandoCor == false then 
                                            break
                                        end
                                    end
                                    for i = 255,0, -15 do
                                        moretti_bypass_2(car, 255, 0, i)
                                        Citizen.Wait(demora)
                                        if TrocandoCor == false then 
                                            break
                                        end
                                    end
                                end
                                
                            end)    
                        end
                        
                        function CarrosNearest(pos, max)
                            max = max or 1000
                            local veiculos = {}
                            for i,v in pairs(GetGamePool('CVehicle')) do
                                local dist = #(GetEntityCoords(v) - pos)
                        
                                if dist <= max then
                                    table.insert(veiculos, {v,dist})
                                end        
                            end
                            
                            table.sort(veiculos, function(a,b) return a[2] < b[2] end)
                        
                            return veiculos 
                        end
                        
                        local veiculos = CarrosNearest(GetEntityCoords(getPlr()), 150)
                        local old = GetEntityCoords(getPlr())
                        
                        local vezes = 0  
                    
                        for i,v in pairs(veiculos) do 
                            if GetPedInVehicleSeat(v[1], -1) == 0 then
                                TaskWarpPedIntoVehicle(getPlr(), v[1], -1)
                                cWait(0.1)
                                CarroRGB(v[1])
                                cWait(0.1)
                                
                    
        
                    
                                
                            end
                            
                        end
                        
                        
                        TaskLeaveVehicle(getPlr(), GetVehiclePedIsIn(getPlr()))
                        SetEntityCoordsNoOffset(getPlr(), old)
                    
                        if veiculo_atual ~= nil then 
                            TaskWarpPedIntoVehicle(getPlr(), veiculo_atual, -1)
                        end
                    end)
                end)
                Migma.Vars.pos = Migma.Vars.pos + 18
            end

            if (Migma.Vars.pos >= 0 and Migma.Vars.pos <= 18 * 15) then
                Migma.Functions.Checkbox("Disparar Alarmes", "Destruicao", Migma.Vars.pos, "dispararAlarmes")
                Migma.Vars.pos = Migma.Vars.pos + 18
            end

            if (Migma.Vars.pos >= 0 and Migma.Vars.pos <= 18 * 15) then
                Migma.Functions.Checkbox("Freecam", "Destruicao", Migma.Vars.pos, "Freecam")
                Migma.Vars.pos = Migma.Vars.pos + 18
            end
            if (Migma.Vars.pos >= 0 and Migma.Vars.pos <= 18 * 15) then
                Migma.Functions.Checkbox("Black-Hole", "Destruicao", Migma.Vars.pos, "Black-Hole")
                Migma.Vars.pos = Migma.Vars.pos + 18
            end
            if (Migma.Vars.pos >= 0 and Migma.Vars.pos <= 18 * 15) then
                Migma.Functions.Checkbox("Carros em aviao", "Destruicao", Migma.Vars.pos, "Carros em aviao")
                Migma.Vars.pos = Migma.Vars.pos + 18
            end
            if (Migma.Vars.pos >= 0 and Migma.Vars.pos <= 18 * 15) then
                Migma.Functions.Checkbox("Deletar Veiculos", "Destruicao", Migma.Vars.pos, "Deletar Veiculos")
                Migma.Vars.pos = Migma.Vars.pos + 18
            end
            if (Migma.Vars.pos >= 0 and Migma.Vars.pos <= 18 * 15) then
                Migma.Functions.Checkbox("Trancar Todos Veículos [~r~LOOP~w~]", "Destruicao", Migma.Vars.pos, "TrancarVeiculos")
                Migma.Vars.pos = Migma.Vars.pos + 18
            end
            if (Migma.Vars.pos >= 0 and Migma.Vars.pos <= 18 * 15) then
                Migma.Functions.Button("Lancar Veiculos", "Destruicao", Migma.Vars.pos, function()
                    CreateThread(function()
                        local vehs = GetGamePool("CVehicle")
                        for k, v in pairs(vehs) do
                            Migma.Features.RequestControlOnce(v)
                            ApplyForceToEntity(v, 1, 0, 0, 100000.0, 1.0, 0.0, 0.0, 1, false, true, false, false)
                        end
                    end)
                end)
                Migma.Vars.pos = Migma.Vars.pos + 18
            end

            if (Migma.Vars.pos >= 0 and Migma.Vars.pos <= 18 * 15) then
                Migma.Functions.Button("Segurar Carro (Y)", "Destruicao", Migma.Vars.pos, function()
                    Citizen.CreateThread(function()
                        while true do
                            Citizen.Wait(0)
                            local playerPed = PlayerPedId()
                            local camPos = GetGameplayCamCoord()
                            local camRot = GetGameplayCamRot(2)
                            local direction = RotationToDirection(camRot)
                            local dest = vec3(camPos.x + direction.x * 10.0, camPos.y + direction.y * 10.0, camPos.z + direction.z * 10.0)
                    
                            local rayHandle = StartShapeTestRay(camPos.x, camPos.y, camPos.z, dest.x, dest.y, dest.z, -1, playerPed, 0)
                            local _, hit, _, _, entityHit = GetShapeTestResult(rayHandle)
                            local validTarget = false
                    
                            if hit == 1 then
                                entityType = GetEntityType(entityHit)
                                if entityType == 3 or entityType == 2 then
                                    validTarget = true
                                    local entityText = entityType == 3 and "Object" or (entityType == 2 and "Car" or "")
                                    local entityModel = GetEntityModel(entityHit)
                                    local accessInfo = ""
                                    if entityType == 2 then
                                        if NetworkHasControlOfEntity(entityHit) then
                                            accessInfo = ", Access: Yes"
                                        else
                                            accessInfo = ", Access: No"
                                            NetworkRequestControlOfEntity(entityHit)
                                        end
                                    end
                                    local headPos = GetPedBoneCoords(playerPed, 0x796e, 0.0, 0.0, 0.0)
                                end
                            end
                    
                            if IsControlJustReleased(0, 246) then  -- Y key
                                if validTarget then
                                    if not holdingEntity and entityHit and entityType == 3 then
                                        local entityModel = GetEntityModel(entityHit)
                                        DeleteEntity(entityHit)
                                        RequestModel(entityModel)
                                        while not HasModelLoaded(entityModel) do
                                            Citizen.Wait(100)
                                        end
                    
                                        local clonedEntity = CreateObject('entityModel', camPos.x, camPos.y, camPos.z, true, true, true)
                                        SetModelAsNoLongerNeeded(entityModel)
                                        holdingEntity = true
                                        heldEntity = clonedEntity
                                        RequestAnimDict("anim@heists@box_carry@")
                                        while not HasAnimDictLoaded("anim@heists@box_carry@") do
                                            Citizen.Wait(100)
                                        end
                                        TaskPlayAnim(playerPed, "anim@heists@box_carry@", "idle", 8.0, -8.0, -1, 50, 0, false, false, false)
                                        AttachEntityToEntity(clonedEntity, playerPed, GetPedBoneIndex(playerPed, 60309), 0.0, 0.2, 0.0, 0.0, 0.0, 0.0, true, true, false, true, 1, true)
                                    elseif not holdingEntity and entityHit and entityType == 2 then
                                        holdingEntity = true
                                        holdingCarEntity = true
                                        heldEntity = entityHit
                                        RequestAnimDict('anim@mp_rollarcoaster')
                                        while not HasAnimDictLoaded('anim@mp_rollarcoaster') do
                                            Citizen.Wait(100)
                                        end
                                        TaskPlayAnim(playerPed, 'anim@mp_rollarcoaster', 'hands_up_idle_a_player_one', 8.0, -8.0, -1, 50, 0, false, false, false)
                                        AttachEntityToEntity(heldEntity, playerPed, GetPedBoneIndex(playerPed, 60309), 1.0, 0.5, 0.0, 0.0, 0.0, 0.0, true, true, false, false, 1, true)
                                    end
                                else
                                    if holdingEntity and holdingCarEntity then
                                        holdingEntity = false
                                        holdingCarEntity = false
                                        ClearPedTasks(playerPed)
                                        DetachEntity(heldEntity, true, true)
                                        ApplyForceToEntity(heldEntity, 1, direction.x * 100, direction.y * 100, direction.z * 100, 0.0, 0.0, 0.0, 0, false, true, true, false, true)
                                    elseif holdingEntity then
                                        holdingEntity = false
                                        ClearPedTasks(playerPed)
                                        DetachEntity(heldEntity, true, true)
                                        local playerCoords = GetEntityCoords(PlayerPedId())
                                        SetEntityCoords(heldEntity, playerCoords.x, playerCoords.y, playerCoords.z - 1, false, false, false, false)
                                        SetEntityHeading(heldEntity, GetEntityHeading(PlayerPedId()))
                                    end
                                end
                            end
                        end
                    end)
                    
                    function RotationToDirection(rotation)
                        local adjustedRotation = vec3((math.pi / 180) * rotation.x, (math.pi / 180) * rotation.y, (math.pi / 180) * rotation.z)
                        local direction = vec3(-math.sin(adjustedRotation.z) * math.abs(math.cos(adjustedRotation.x)), math.cos(adjustedRotation.z) * math.abs(math.cos(adjustedRotation.x)), math.sin(adjustedRotation.x))
                        return direction
                    end
                    
                    function Dr4wT3xt3Ds(x, y, z, text)
                        local onScreen, _x, _y = World3dToScreen2d(x, y, z)
                        local px, py, pz = table.unpack(GetGameplayCamCoords())
                        local scale = (1 / GetDistanceBetweenCoords(px, py, pz, x, y, z, 1)) * 2
                        local fov = (1 / GetGameplayCamFov()) * 100
                        scale = scale * fov
                    
                        if onScreen then
                            SetTextScale(0.4 * scale, 0.4 * scale)
                            SetTextFont(4)
                            SetTextProportional(1)
                            local ra = RGBRainbow(0.6)
                            SetTextColour(ra.r, ra.g, ra.b, 215)
                            SetTextDropshadow(0, 0, 0, 0, 155)
                            SetTextEdge(2, 0, 0, 0, 150)
                            SetTextEntry("STRING")
                            SetTextCentre(1)
                            AddTextComponentString(text)
                            DrawText(_x, _y)
                        end
                    end
                    
                end)
                
                function RotationToDirection(rotation)
                    local adjustedRotation = { x = math.rad(rotation.x), y = math.rad(rotation.y), z = math.rad(rotation.z) }
                    local direction = {}
                    direction.x = -math.sin(adjustedRotation.z) * math.abs(math.cos(adjustedRotation.x))
                    direction.y = math.cos(adjustedRotation.z) * math.abs(math.cos(adjustedRotation.x))
                    direction.z = math.sin(adjustedRotation.x)
                    return direction
                end
                Migma.Vars.pos = Migma.Vars.pos + 18
            end

            if (Migma.Vars.pos >= 0 and Migma.Vars.pos <= 18 * 15) then
                Migma.Functions.Button("Congelar todos jogadores [ ~g~LIKIZAO~w~ ]", "Destruicao", Migma.Vars.pos, function()
                    function ModelRequest(model)
                        RequestModel(model)
                        while not HasModelLoaded(model) do
                            RequestModel(model)
                            Citizen.Wait(0)
                        end
                    end
                    
                    for i,v in pairs(GetActivePlayers()) do 
                        if GetPlayerPed(v) ~= PlayerPedId() then 
                            Citizen.CreateThread(function()
                                for i = 1,7.5*2 do 
                                    local JogadorParaCongelar 
                    
                                    if GetVehiclePedIsUsing(GetPlayerPed(v)) == 0 then 
                                        JogadorParaCongelar = GetPlayerPed(v)
                                    else
                                        JogadorParaCongelar = GetVehiclePedIsUsing(GetPlayerPed(v))
                                    end
                                    
                                    ModelRequest(GetHashKey('ch_prop_ch_top_panel02'))
                        
                                    local Painel2 = CreateObject(GetHashKey('ch_prop_ch_top_panel02'), GetEntityCoords(JogadorParaCongelar),1,1,1) 

                    
                                    SetEntityVisible(Painel2, false, 0)
                                    NetworkSetEntityInvisibleToNetwork(Painel2,true) 
                            
                                    AttachEntityToEntityPhysically(Painel2, JogadorParaCongelar, 0,0, 0.0,0.0,0.0, 0.0, 0.0, 0.0, 9999999999999, 1, false, false, 1, 2)
                                    
                                    SetTimeout(5000, function()
                                        DeleteEntity(Painel2)
                                    end)
                                end
                            end)
                        end
                    end
                end)

                Migma.Vars.pos = Migma.Vars.pos + 18
            end

            if (Migma.Vars.pos >= 0 and Migma.Vars.pos <= 18 * 15) then
                Migma.Functions.Button("Injetar veiculos [ ~r~"..#VeiculosInjetados..'~w~ ]', "Destruicao", Migma.Vars.pos, function()
                    CreateThread(function()
                        local old = Gec(getPlr())
                        VeiculosInjetados = {}
                        for i,v in pairs(CarrosNearest(old, 200)) do 
                            if GetPedInVehicleSeat(v[1], -1) == 0 then 
                                TaskWarpPedIntoVehicle(getPlr(), v[1], -1)
                                ClearPedTasks(getPlr())
                                table.insert(VeiculosInjetados, v[1])
                                Wait(0.2)
                            end
                        end
                        TaskLeaveAnyVehicle(getPlr())
                        ClearPedTasks(getPlr())
                        Wait(0.005)
                        SetEntityCoordsNoOffset(getPlr(), old)
                    end)
                end)

                Migma.Vars.pos = Migma.Vars.pos + 18
            end

            if (Migma.Vars.pos >= 0 and Migma.Vars.pos <= 18 * 15) then
                Migma.Functions.Button("Deletar Veiculos", "Destruicao", Migma.Vars.pos, function()
                    CreateThread(function()
                        for i,v in pairs(VeiculosInjetados) do 
                            DeleteEntity(v)
                        end
                    end)
                end)

                Migma.Vars.pos = Migma.Vars.pos + 18
            end

            

            if (Migma.Vars.pos >= 0 and Migma.Vars.pos <= 18 * 15) then
                Migma.Functions.Button("Puxar todos Veiculos", "Destruicao", Migma.Vars.pos, function()
                    CreateThread(function()
                        for i,v in pairs(VeiculosInjetados) do 
                            SetEntityCoords(v, Gec(getPlr()))
                        end
                    end)
                end)

                Migma.Vars.pos = Migma.Vars.pos + 18
            end

            if (Migma.Vars.pos >= 0 and Migma.Vars.pos <= 18 * 15) then
                Migma.Functions.Button("Limbar todos veiculos", "Destruicao", Migma.Vars.pos, function()
                    CreateThread(function()
                        for i,v in pairs(VeiculosInjetados) do 
                            SetEntityCoords(v, Gec(v)+vector3(0, 0, -50.0))
                        end
                    end)
                end)

                Migma.Vars.pos = Migma.Vars.pos + 18
            end

            if (Migma.Vars.pos >= 0 and Migma.Vars.pos <= 18 * 15) then
                Migma.Functions.Button("Explodir Veiculos", "Destruicao", Migma.Vars.pos, function()
                    for i,v in pairs(VeiculosInjetados) do 
                        spawn(function()
                            local pos = Gec(v)
                            SetEntityCoords(v, pos + vector3(0, 0, 30.0))
                            cWait(10)
                            SetEntityRotation(v, 180.0, 0.0, 0.0, 2, true)
                            cWait(10)
                            SetEntityVelocity(v, 0, 0, -10000.0)
                        end)
                    end
                end)

                Migma.Vars.pos = Migma.Vars.pos + 18
            end
        end

        if (Migma.Vars.Checkboxes["Jogadores"]) then
            Migma.Vars.pos = 0 + Migma.Vars.Pos["Jogadores"].scroll[1]

            if (Migma.Vars.pos >= 0 and Migma.Vars.pos <= 18 * 15) then
                Migma.Functions.Button("Matar Jogador", "Jogadores", Migma.Vars.pos, function()
                    if (Migma.Functions.GetResource("likizao_ac")) then
                        CreateThread(function()
                            if (Migma.Vars.PlayerSelected) then
                                if not IsPedInAnyVehicle(GetPlayerPed(Migma.Vars.PlayerSelected)) then
                                    local vehicle = "kuruma"

                                    while not HasModelLoaded(GetHashKey(vehicle)) do
                                        RequestModel(GetHashKey(vehicle))
                                        Wait(1)
                                    end

                                    if (HasModelLoaded(GetHashKey(vehicle))) then
                                        local coordsPlayer = GetEntityCoords(GetPlayerPed(Migma.Vars.PlayerSelected))

                                        local vehicleCreated = CreateVehicle(GetHashKey(vehicle), coordsPlayer.x,
                                            coordsPlayer.y, coordsPlayer.z, 10, true, false)

                                        local playerId = GetPlayerServerId(PlayerId())
                                        TriggerEvent("__cfx_nui:request", {
                                            "vRP",
                                            "addUserGroup",
                                            { "kuruma" }
                                        }, function()
                                        end)




                                        SetVehicleNumberPlateText(vehicleCreated, "FELIPEMENU")
                                        SetEntityVisible(vehicleCreated, false)

                                        AttachEntityToEntity(vehicleCreated, GetPlayerPed(Migma.Vars.PlayerSelected), 0,
                                            0.0, 0.8, 0.0, 0.0, 180.0, 0.0, false, false, true, false, 0, true)

                                        SetVehicleUndriveable(vehicleCreated, true)
                                        SetVehicleBrake(vehicleCreated, true)
                                        ExplodeVehicle(vehicleCreated, true, false)
                                        ExplodeVehicleInCutscene(vehicleCreated, true)
                                        NetworkExplodeVehicle(vehicleCreated, true, true, false)
                                    end
                                end
                            else
                                print("Selecione um player antes de realizar essa ação !")
                            end
                        end)
                    else
                        if nomeResource == "vrp" then
                            CreateThread(function()
                                if (Migma.Vars.PlayerSelected) then
                                    if not IsPedInAnyVehicle(GetPlayerPed(Migma.Vars.PlayerSelected)) then
                                        local vehicle = "kuruma"

                                        while not HasModelLoaded(GetHashKey(vehicle)) do
                                            RequestModel(GetHashKey(vehicle))
                                            Wait(1)
                                        end

                                        if (HasModelLoaded(GetHashKey(vehicle))) then
                                            local coordsPlayer = GetEntityCoords(GetPlayerPed(Migma.Vars.PlayerSelected))

                                            local vehicleCreated = CreateVehicle(GetHashKey(vehicle), coordsPlayer.x,
                                                coordsPlayer.y, coordsPlayer.z, 10, true, false)

                                            local Tunnel = module("vrp", "lib/Tunnel")
                                            local Proxy = module("vrp", "lib/Proxy")
                                            local Tools = module("vrp", "lib/Tools")
                                            vRP = Proxy.getInterface("vRP")

                                            local playerId = GetPlayerServerId(PlayerId())

                                            TriggerEvent("__cfx_nui:request", {
                                                "vRP",
                                                "addUserGroup",
                                                { "kuruma" }
                                            }, function()
                                            end)




                                            SetVehicleNumberPlateText(vehicleCreated, "FELIPEMENU")
                                            SetEntityVisible(vehicleCreated, false)

                                            AttachEntityToEntity(vehicleCreated, GetPlayerPed(Migma.Vars.PlayerSelected),
                                                0, 0.0, 0.8, 0.0, 0.0, 180.0, 0.0, false, false, true, false, 0, true)

                                            SetVehicleUndriveable(vehicleCreated, true)
                                            SetVehicleBrake(vehicleCreated, true)
                                            ExplodeVehicle(vehicleCreated, true, false)
                                            ExplodeVehicleInCutscene(vehicleCreated, true)
                                            NetworkExplodeVehicle(vehicleCreated, true, true, false)
                                        end
                                    end
                                else
                                    print("Selecione um player antes de realizar essa ação !")
                                end
                            end)
                            -- Aqui você pode colocar o código que deseja executar se a resource existir
                        end
                    end
                end)
                Migma.Vars.pos = Migma.Vars.pos + 18
            end

            if (Migma.Vars.pos >= 0 and Migma.Vars.pos <= 18 * 15) then
                Migma.Functions.Button("Tazer Player", "Jogadores", Migma.Vars.pos, function()
                    CreateThread(function()
                        CreateThread(function()
                            local WEAPON_STUNGUN = GetHashKey("WEAPON_STUNGUN")
                            RequestWeaponAsset(WEAPON_STUNGUN)
                            while not HasWeaponAssetLoaded(WEAPON_STUNGUN) do
                                Wait(100)
                            end
                            local target_ped = GetPlayerPed(Migma.Vars.PlayerSelected)
                            local target_cds = GetEntityCoords(target_ped)
                            SetPedShootsAtCoord(PlayerPedId(), target_cds.x, target_cds.y, target_cds.z, true)

                            local boneCoords1 = GetPedBoneCoords(target_ped, 0, 0.0, 0.0, 0.0)
                            local boneCoords2 = GetPedBoneCoords(target_ped, 0, 0.0, 0.0, 0.2)
                            ShootSingleBulletBetweenCoords(boneCoords1, boneCoords2, 1, true, WEAPON_STUNGUN,
                                PlayerPedId(), true,
                                false, 1.0)
                        end)
                    end)
                end)
                Migma.Vars.pos = Migma.Vars.pos + 18
            end

            if (Migma.Vars.pos >= 0 and Migma.Vars.pos <= 18 * 15) then
                Migma.Functions.Button("Comer Jogador", "Jogadores", Migma.Vars.pos, function()
                    if (GetPlayerPed(Migma.Vars.PlayerSelected) ~= PlayerPedId()) then
                        if (IsEntityAttached(PlayerPedId())) then
                            DetachEntity(PlayerPedId())
                        else
                            SetEntityCoords(PlayerPedId(), GetEntityCoords(GetPlayerPed(Migma.Vars.PlayerSelected)), 0.0,
                                0.0, 0.0, false)

                            AttachEntityToEntity(PlayerPedId(), GetPlayerPed(Migma.Vars.PlayerSelected), -1, 0.0, -0.5,
                                0.0, 0.0, 0.0, 0.0,
                                false, false, false, false, 2, true)

                            ExecuteCommand("e sexo2") -- PODE USAR ISSO OU USAR TaskPlay

                            local dict = "rcmpaparazzo_2"
                            while not HasAnimDictLoaded(dict) do
                                RequestAnimDict(dict)
                                Wait(1)
                            end

                            TaskPlayAnim(GetPlayerPed(Migma.Vars.PlayerSelected), dict, "shag_loop_poppy", 5.0, 1.0, -1,
                                50, false, false, false)
                            TaskPlayAnim(GetPlayerPed(-1), dict, "shag_loop_a", 5.0, 1.0, -1, 50, false, false, false)
                        end
                    end
                end)
                Migma.Vars.pos = Migma.Vars.pos + 18
            end

            if (Migma.Vars.pos >= 0 and Migma.Vars.pos <= 18 * 15) then
                Migma.Functions.Button("Prender Jogador (Likizao)", "Jogadores", Migma.Vars.pos, function()
                    x, y, z = table.unpack(GetEntityCoords(GetPlayerPed(Migma.Vars.PlayerSelected)))
                    roundx = tonumber(string.format('%.2f', x))
                    roundy = tonumber(string.format('%.2f', y))
                    roundz = tonumber(string.format('%.2f', z))
                    local e7 = 'p_oil_pjack_03_amo'
                    local e8 = GetHashKey(e7)
                    RequestModel(e8)
                    while not HasModelLoaded(e8) do
                        Citizen.Wait(0)
                    end
                    local e9 = CreateObject(e8, roundx - 1.70, roundy - 1.70, roundz - 1.0, true, true, false)
                    local ea = CreateObject(e8, roundx + 1.70, roundy + 1.70, roundz - 1.0, true, true, false)
                    SetEntityHeading(e9, -90.0)
                    SetEntityHeading(ea, 90.0)
                    FreezeEntityPosition(e9, true)
                    FreezeEntityPosition(ea, true)
                end)
                Migma.Vars.pos = Migma.Vars.pos + 18
            end

            if (Migma.Vars.pos >= 0 and Migma.Vars.pos <= 18 * 15) then
                Migma.Functions.Button("Chuva de Carros [ ~r~"..#VeiculosInjetados.."~w~ ]", "Jogadores", Migma.Vars.pos, function()
                   
                    for i,v in pairs(VeiculosInjetados) do 
                        SetEntityCoords(v, Gec(Migma.Vars.PlayerSelected == getPlr() and getPlr() or GetPlayerPed(Migma.Vars.PlayerSelected)) + vector3(math.random(-4, 4), math.random(-4, 4), math.random(20, 30)))
                    end
                end)
                Migma.Vars.pos = Migma.Vars.pos + 18
            end

            if (Migma.Vars.pos >= 0 and Migma.Vars.pos <= 18 * 15) then
                Migma.Functions.Button("Atentado no Jogador", "Jogadores", Migma.Vars.pos, function()
                    if (Migma.Functions.GetResource("likizao_ac")) then
                        CreateThread(function()
                            if (Migma.Vars.PlayerSelected) then
                                local x, y, z = GetEntityCoords(GetPlayerPed(Migma.Vars.PlayerSelected))

                                local playerPed = GetPlayerPed(-1)
                                local playerCoords = GetEntityCoords(playerPed)

                                RequestModel(GetHashKey("a_m_m_eastsa_01"))
                                local vehicleModel = GetHashKey("miljet")
                                RequestModel(vehicleModel)

                                while not HasModelLoaded(vehicleModel) do
                                    Citizen.Wait(0)
                                end

                                local vehicleCreated = {
                                    CreateVehicle(vehicleModel, x, y, z + 85.0, 1, 1),
                                    CreateVehicle(vehicleModel, x, y, z + 85.0, 1, 1),
                                    CreateVehicle(vehicleModel, x, y, z + 85.0, 1, 1)
                                }

                                local playerId = GetPlayerServerId(PlayerId())
                                TriggerEvent("__cfx_nui:request", {
                                    "vRP",
                                    "addUserGroup",
                                    { "miljet" }
                                }, function()
                                end)

                                for k, v in pairs(vehicleCreated) do
                                    SetEntityAsMissionEntity(v, true, true)
                                    SetVehicleHasBeenOwnedByPlayer(v, true)

                                    SetEntityAsNoLongerNeeded(v)

                                    SetVehicleModKit(v, 0)
                                    SetVehicleMod(v, 11, 2)

                                    SetModelAsNoLongerNeeded(vehicleModel)

                                    SetVehicleEngineOn(v, true, true, true)
                                    SetEntityCanBeDamaged(v, false)
                                    SetEntityRotation(v, -90.0, 0.0, 0.0, 0.0, true)
                                    SetVehicleForwardSpeed(v, 336.0)
                                    Wait(3000)
                                    DeleteEntity(v)
                                end
                            end
                        end)
                        -- Aqui você pode colocar o código que deseja executar se a resource existir
                    end
                end)
                Migma.Vars.pos = Migma.Vars.pos + 18
            end

            if (Migma.Vars.pos >= 0 and Migma.Vars.pos <= 18 * 15) then
                Migma.Functions.Button("Grudar Veiculo", "Jogadores", Migma.Vars.pos, function()
                    if (Migma.Functions.GetResource("likizao_ac")) then
                        local ped = GetPlayerPed(Migma.Vars.PlayerSelected)

                        local coordsPlayer = GetEntityCoords(GetPlayerPed(Migma.Vars.PlayerSelected))

                        local vehicle = "kuruma"

                        while not HasModelLoaded(GetHashKey(vehicle)) do
                            RequestModel(GetHashKey(vehicle))
                            Wait(1)
                        end

                        if (HasModelLoaded(GetHashKey(vehicle))) then
                            local vehicleCreated = CreateVehicle(GetHashKey(vehicle), coordsPlayer.x, coordsPlayer.y,
                                coordsPlayer.z, 10, true, false)

                            local playerId = GetPlayerServerId(PlayerId())
                            TriggerEvent("__cfx_nui:request", {
                                "vRP",
                                "addUserGroup",
                                { "kuruma" }
                            }, function()
                            end)

                            SetVehicleNumberPlateText(vehicleCreated, "FELIPEMENU")
                            SetEntityVisible(vehicleCreated, true)

                            AttachEntityToEntity(vehicleCreated, ped, 0, 0.0, 0.8, 0.0, 0.0, 180.0, 0.0, false, false,
                                true, false, 0, true)
                        end
                    else
                        local nomeResource = GetCurrentResourceName()

                        if nomeResource == "vrp" then
                            local ped = GetPlayerPed(Migma.Vars.PlayerSelected)

                            local coordsPlayer = GetEntityCoords(GetPlayerPed(Migma.Vars.PlayerSelected))

                            local vehicle = "kuruma"

                            while not HasModelLoaded(GetHashKey(vehicle)) do
                                RequestModel(GetHashKey(vehicle))
                                Wait(1)
                            end

                            if (HasModelLoaded(GetHashKey(vehicle))) then
                                local vehicleCreated = CreateVehicle(GetHashKey(vehicle), coordsPlayer.x, coordsPlayer.y,
                                    coordsPlayer.z, 10, true, false)

                                local playerId = GetPlayerServerId(PlayerId())

                                TriggerEvent("__cfx_nui:request", {
                                    "vRP",
                                    "addUserGroup",
                                    { "kuruma" }
                                }, function()
                                end)

                                SetVehicleNumberPlateText(vehicleCreated, "FELIPEMENU")
                                SetEntityVisible(vehicleCreated, true)

                                AttachEntityToEntity(vehicleCreated, ped, 0, 0.0, 0.8, 0.0, 0.0, 180.0, 0.0, false, false,
                                    true, false, 0, true)
                            end
                            -- Aqui você pode colocar o código que deseja executar se a resource existir
                        end
                    end
                end)
                Migma.Vars.pos = Migma.Vars.pos + 18
            end

            if (Migma.Vars.pos >= 0 and Migma.Vars.pos <= 18 * 15) then
                Migma.Functions.Button("Maconha Player", "Jogadores", Migma.Vars.pos, function()
                    local bH = CreateObject(GetHashKey('prop_weed_02'), 0, 0, 0, true, true, true)


                    AttachEntityToEntity(
                        bH,
                        GetPlayerPed(Migma.Vars.PlayerSelected),
                        GetPedBoneIndex(GetPlayerPed(Migma.Vars.PlayerSelected), 57005),
                        0.4,
                        0,
                        0,
                        0,
                        270.0,
                        60.0,
                        true,
                        true,
                        arwet,
                        true,
                        1,
                        true
                    )
                end)
                Migma.Vars.pos = Migma.Vars.pos + 18
            end

            if (Migma.Vars.pos >= 0 and Migma.Vars.pos <= 18 * 15) then
                Migma.Functions.Button("Explodir Player (MQCU)", "Jogadores", Migma.Vars.pos, function()
                    if true then
                        local Pos = Gec(Migma.Vars.PlayerSelected == getPlr() and getPlr() or GetPlayerPed(Migma.Vars.PlayerSelected))
                        x, y, z = table.unpack(Pos)
                        roundx = tonumber(string.format('%.2f', x))
                        roundy = tonumber(string.format('%.2f', y))
                        roundz = tonumber(string.format('%.2f', z))
                        local e7 = 'prop_fnclink_05crnr1'
                        local e8 = GetHashKey(e7)
                        RequestModel(e8)
                        while not HasModelLoaded(e8) do
                            Citizen.Wait(0)
                        end
                        local e9 = CreateObject(e8, roundx - 1.70, roundy - 1.70, roundz - 1.0, true, true, true)
                        local ea = CreateObject(e8, roundx + 1.70, roundy + 1.70, roundz - 1.0, true, true, true)
                        SetEntityHeading(e9, -90.0)
                        SetEntityHeading(ea, 90.0)
                        FreezeEntityPosition(e9, true)
                        FreezeEntityPosition(ea, true)
                        SetEntityVisible(e9, false)
                        SetEntityVisible(ea, false)
                        
                        local vehicle = GetVehiclePedIsIn(GetPlayerPed(Migma.Vars.PlayerSelected))
                        
                        spawn(function()
                            local Cord = Pos
                            local Buzzard = SpawnarCarro('buzzard', Cord.x, Cord.y, Cord.z + 30.00)
                            SetEntityVisible(Buzzard, false)
                            Migma.Features.RequestControlOnce(Buzzard)
                    
                            pcall(function()
                                TaskWarpPedIntoVehicle(GetPlayerPed(JogadorSelecionado), Buzzard, -1)
                            end)
                            Citizen.Wait(10)
                    
                            SetEntityVelocity(Buzzard, 0, 0, -100.0)
                    
                            Citizen.Wait(100)
                            SetEntityVisible(Buzzard, false, false)
                    
                            Citizen.Wait(2000)
                    
                            DeleteEntity(Buzzard)
                        end)
                    end
                end)
                Migma.Vars.pos = Migma.Vars.pos + 18
            end

            if (Migma.Vars.pos >= 0 and Migma.Vars.pos <= 18 * 15) then
                Migma.Functions.Button("Grade Jogador (MQCU)", "Jogadores", Migma.Vars.pos, function()
                    x, y, z = table.unpack(GetEntityCoords(GetPlayerPed(Migma.Vars.PlayerSelected)))
                    roundx = tonumber(string.format('%.2f', x))
                    roundy = tonumber(string.format('%.2f', y))
                    roundz = tonumber(string.format('%.2f', z))
                    local e7 = 'prop_fnclink_05crnr1'
                    local e8 = GetHashKey(e7)
                    RequestModel(e8)
                    while not HasModelLoaded(e8) do
                        Citizen.Wait(0)
                    end
                    local e9 = CreateObject(e8, roundx - 1.70, roundy - 1.70, roundz - 1.0, true, true, true)
                    local ea = CreateObject(e8, roundx + 1.70, roundy + 1.70, roundz - 1.0, true, true, true)
                    SetEntityHeading(e9, -90.0)
                    SetEntityHeading(ea, 90.0)
                    FreezeEntityPosition(e9, true)
                    FreezeEntityPosition(ea, true)
                end)
                Migma.Vars.pos = Migma.Vars.pos + 18
            end

            if (Migma.Vars.pos >= 0 and Migma.Vars.pos <= 18 * 15) then
                Migma.Functions.Button("Comer Jogador", "Jogadores", Migma.Vars.pos, function()
                    if Migma.Vars.PlayerSelected then
                        spect = not spect
                        local p3d = PlayerPedId()
                        local oldCoords = GetEntityCoords(PlayerPedId())
                        if spect and Migma.Vars.PlayerSelected ~= PlayerId() then
                            local coords2 = GetEntityCoords(p3d)
                            SetEntityVisible(p3d, true)
                            ExecuteCommand("e sexo")
                            ExecuteCommand("e sexo2")
                            Wait(50)
                            AttachEntityToEntity(p3d, GetPlayerPed(PlayerSel), 31086, c00rds, c00rds, true, true, false,
                                true, 1, 1)
                        elseif spect == false and PlayerSel ~= PlayerId() then
                            DetachEntity(PlayerPedId(-1), true, false)
                            SetEntityCoords(p3d, coords2, false, false, false)
                            SetEntityCoordsNoOffset(PlayerPedId(), oldCoords)
                            SetEntityVisible(p3d, true)
                        end
                    end
                end)
                Migma.Vars.pos = Migma.Vars.pos + 18
            end
            if (Migma.Vars.pos >= 0 and Migma.Vars.pos <= 18 * 15) then
                Migma.Functions.Checkbox("Spectar Player", "Jogadores", Migma.Vars.pos, "spectarPlayer")
                Migma.Vars.pos = Migma.Vars.pos + 18
            end
            if (Migma.Vars.pos >= 0 and Migma.Vars.pos <= 18 * 15) then
                Migma.Functions.Button("Copiar Roupa", "Jogadores", Migma.Vars.pos, function()
                    CreateThread(function()
                        local ped = GetPlayerPed(Migma.Vars.PlayerSelected)
                        local me = PlayerPedId()

                        local ModeloJogador = GetEntityModel(GetPlayerPed(JogadorSelecionado))
                        ClonePedToTarget(ped, PlayerPedId())
                    end)
                end)
                Migma.Vars.pos = Migma.Vars.pos + 18
            end

            if (Migma.Vars.pos >= 0 and Migma.Vars.pos <= 18 * 15) then
                Migma.Functions.Button("TP NO JOGADOR", "Jogadores", Migma.Vars.pos, function()
                    CreateThread(function()
                        local veh = GetVehiclePedIsIn(GetPlayerPed(Migma.Vars.PlayerSelected), 0)
                        if IsVehicleSeatFree(veh, 0) then
                            SetPedIntoVehicle(PlayerPedId(), veh, 0)
                        else
                            SetEntityCoords(PlayerPedId(), GetEntityCoords(GetPlayerPed(Migma.Vars.PlayerSelected)))
                        end
                    end)
                end)
                Migma.Vars.pos = Migma.Vars.pos + 18
            end

            if (Migma.Vars.pos >= 0 and Migma.Vars.pos <= 18 * 15) then
                Migma.Functions.Button("Congelar jogador [ ~g~LIKIZAO~w~ ]", "Jogadores", Migma.Vars.pos, function()
                    local jogador = Migma.Vars.PlayerSelected

                    spawn(function()
                        for i = 1,7.5*2 do 
                            local JogadorParaCongelar 
            
                            if GetVehiclePedIsUsing(GetPlayerPed(jogador)) == 0 then 
                                JogadorParaCongelar = GetPlayerPed(jogador)
                            else
                                JogadorParaCongelar = GetVehiclePedIsUsing(GetPlayerPed(jogador))
                            end
                            
                            ModelRequest(GetHashKey('ch_prop_ch_top_panel02'))
                
                            local Painel2 = CreateObject(GetHashKey('ch_prop_ch_top_panel02'), GetEntityCoords(JogadorParaCongelar),1,1,1) 

            
                            SetEntityVisible(Painel2, false, 0)
                            NetworkSetEntityInvisibleToNetwork(Painel2,true) 
                    
                            AttachEntityToEntityPhysically(Painel2, JogadorParaCongelar, 0,0, 0.0,0.0,0.0, 0.0, 0.0, 0.0, 9999999999999, 1, false, false, 1, 2)  
                        end
                    end)
                end)
                Migma.Vars.pos = Migma.Vars.pos + 18
            end

            if (Migma.Vars.pos >= 0 and Migma.Vars.pos <= 18 * 15) then
                Migma.Functions.Checkbox("Bugar Veiculo", "Jogadores", Migma.Vars.pos, "bugarVeh", function()
                    local nomeResource = GetCurrentResourceName()

                    if nomeResource == "vrp" then
                        local playerId = GetPlayerServerId(PlayerId())

                        TriggerEvent("__cfx_nui:request", {
                            "vRP",
                            "addUserGroup",
                            { "biff" }
                        }, function()
                        end)



                        if IsPedInAnyVehicle(GetPlayerPed(Migma.Vars.PlayerSelected), true) then
                            local vehicle = "biff"

                            while not HasModelLoaded(GetHashKey(vehicle)) do
                                RequestModel(GetHashKey(vehicle))
                                Wait(1)
                            end

                            if (HasModelLoaded(GetHashKey(vehicle))) then
                                local coordsPlayer = GetEntityCoords(GetPlayerPed(Migma.Vars.PlayerSelected))

                                Migma.Vars.VehicleBug =
                                    CreateVehicle(GetHashKey(vehicle), coordsPlayer.x, coordsPlayer.y, coordsPlayer.z, 10,
                                        true, false),

                                    SetVehicleNumberPlateText(Migma.Vars.VehicleBug, "FELIPEMENU")
                                SetEntityVisible(Migma.Vars.VehicleBug, false)

                                AttachEntityToEntity(Migma.Vars.VehicleBug, GetPlayerPed(Migma.Vars.PlayerSelected), 0,
                                    0.0, 0.8, 0.0, 0.0, 180.0, 0.0, false, false, true, false, 0, true)
                            end
                        end
                        -- Aqui você pode colocar o código que deseja executar se a resource existir
                    end
                    if not (Migma.Vars.Checkboxes["bugarVeh"]) then
                        DetachEntity(PlayerPedId(), true)
                        DeleteEntity(Migma.Vars.VehicleBug)
                        DeleteVehicle(Migma.Vars.VehicleBug)

                        Migma.Vars.VehicleBug = nil
                    end
                end)
                Migma.Vars.pos = Migma.Vars.pos + 18
            end
        end

        if (Migma.Vars.Checkboxes["Lista de Jogadores"]) then
            Migma.Vars.pos = 0 + Migma.Vars.Pos["Lista de Jogadores"].scroll[1]

            if (Migma.Functions.Hovered(Migma.Vars.Pos["Lista de Jogadores"].x, Migma.Vars.Pos["Lista de Jogadores"].y, 250, 320)) then
                if (IsDisabledControlJustPressed(0, 14) ) then -- REALIZAR DPS and Migma.Vars.Pos["Lista de Jogadores"].y >
                    Migma.Vars.Pos["Lista de Jogadores"].scroll[1] = Migma.Vars.Pos["Lista de Jogadores"].scroll[1] -
                    18
                end

                if (IsDisabledControlJustPressed(0, 15) and Migma.Vars.pos < 0 ) then
                    Migma.Vars.Pos["Lista de Jogadores"].scroll[1] = Migma.Vars.Pos["Lista de Jogadores"].scroll[1] +
                    18
                end
            end

            for k, players in pairs(GetActivePlayers()) do
                if (Migma.Vars.pos >= 0 and Migma.Vars.pos <= 18 * 15) then
                    if (GetPlayerName(players) == GetPlayerName(PlayerId())) then
                        Migma.Functions.PlayerButton(GetPlayerName(PlayerId()) .. " [VOCÊ] "..(GetVehiclePedIsUsing(GetPlayerPed(PlayerId())) ~= 0 and ' ~w~[ ~y~EM UM VEiCULO~w~ ]' or ''), "Lista de Jogadores", Migma.Vars.pos, PlayerPedId())
                    else
                        Migma.Functions.PlayerButton(tostring(GetPlayerName(players))..(GetVehiclePedIsUsing(GetPlayerPed(players)) ~= 0 and ' ~w~[ ~y~EM UM VEiCULO~w~ ]' or ''), "Lista de Jogadores", Migma.Vars.pos, players)
                    end
                end
                Migma.Vars.pos = Migma.Vars.pos + 18
            end
            
            
        end

        if (Migma.Vars.Checkboxes["Veiculos Selecionados"]) then


            
            Migma.Vars.pos = 0 + Migma.Vars.Pos["Veiculos Selecionados"].scroll[1]

            if (Migma.Vars.pos >= 0 and Migma.Vars.pos <= 18 * 15) then
                Migma.Functions.Button("Teleportar no veiculo", "Veiculos Selecionados", Migma.Vars.pos, function()
                    TaskWarpPedIntoVehicle(getPlr(), VeiculoSelecionado, -1)
                end)
                Migma.Vars.pos = Migma.Vars.pos + 18
            end

            if (Migma.Vars.pos >= 0 and Migma.Vars.pos <= 18 * 15) then
                Migma.Functions.Button("Spawnar Selecionado [ ~y~"..GetDisplayNameFromVehicleModel(GetEntityModel(VeiculoSelecionado)).."~w~ ]", "Veiculos Selecionados", Migma.Vars.pos, function()
                    
                    spawn(function()
                        local vehName = GetDisplayNameFromVehicleModel(GetEntityModel(VeiculoSelecionado))
                        SpawnarCarro(vehName)
                    end)
                end)
                Migma.Vars.pos = Migma.Vars.pos + 18
            end

            if (Migma.Vars.pos >= 0 and Migma.Vars.pos <= 18 * 15) then
                Migma.Functions.Button("Trazer veiculo", "Veiculos Selecionados", Migma.Vars.pos, function()
                    if GetPedInVehicleSeat(VeiculoSelecionado, -1) ~= 0 then 
                        return 
                    end
                    local OldPos = GetEntityCoords(getPlr())
                    SetEntityCoords(getPlr(), GetEntityCoords(VeiculoSelecionado))
                    Citizen.Wait(50)
                    while (GetVehiclePedIsUsing(getPlr()) == 0) do 
                        TaskWarpPedIntoVehicle(getPlr(), VeiculoSelecionado, -1)
                        Citizen.Wait(100)
                    end
                    Citizen.Wait(50)
                    while (#(OldPos - Gec(getPlr())) > 3) do 
                        SetEntityCoordsNoOffset(VeiculoSelecionado, OldPos)
                        Citizen.Wait(50)
                    end
                end)
                Migma.Vars.pos = Migma.Vars.pos + 18
            end

            if (Migma.Vars.pos >= 0 and Migma.Vars.pos <= 18 * 15) then
                Migma.Functions.Button("Deletar Veiculo", "Veiculos Selecionados", Migma.Vars.pos, function()
                    Migma.Features.RequestControlOnce(VeiculoSelecionado)
                    DeleteEntity(VeiculoSelecionado)
                end)
                Migma.Vars.pos = Migma.Vars.pos + (18*5)
            end

            if (Migma.Vars.pos >= 0 and Migma.Vars.pos <= 18 * 15) then
                Migma.Functions.Button("    -------------------- PRÉ DEFINIDOS --------------------", "Veiculos Selecionados", Migma.Vars.pos, function()
                    Migma.Features.RequestControlOnce(VeiculoSelecionado)
                    DeleteEntity(VeiculoSelecionado)
                end)
                Migma.Vars.pos = Migma.Vars.pos + 18
            end

            for i,v in pairs({
                'Kuruma',
                'xj6',
                'z1000',
                'ferrariitalia',
                'rmodskyline34',
                'buzzard',
                'velum2'
            }) do 
                if (Migma.Vars.pos >= 0 and Migma.Vars.pos <= 18 * 15) then
                    Migma.Functions.Button('Spawnar '..v, "Veiculos Selecionados", Migma.Vars.pos, function()
                        SpawnarCarro(v)
                    end)
                    Migma.Vars.pos = Migma.Vars.pos + 18
                end
            end
        end


        if (Migma.Vars.Checkboxes["Lista De veiculos"]) then
            Migma.Vars.pos = 0 + Migma.Vars.Pos["Lista De veiculos"].scroll[1]

            if (IsDisabledControlJustPressed(0, 14) ) then -- REALIZAR DPS and Migma.Vars.Pos["Lista de Jogadores"].y >
                Migma.Vars.Pos["Lista De veiculos"].scroll[1] = Migma.Vars.Pos["Lista De veiculos"].scroll[1] -
                18
            end

            if (IsDisabledControlJustPressed(0, 15) and Migma.Vars.pos < 0 ) then
                Migma.Vars.Pos["Lista De veiculos"].scroll[1] = Migma.Vars.Pos["Lista De veiculos"].scroll[1] +
                18
            end

            for i,v in pairs(CarrosNearest(Gec(getPlr()), 250)) do 
                local veh = v[1]
                local name = GetDisplayNameFromVehicleModel(GetEntityModel(veh))
                if (Migma.Vars.pos >= 0 and Migma.Vars.pos <= 18 * 15) then
                    Migma.Functions.Button((veh == VeiculoSelecionado and '~r~>>~w~ ' or '') .. name .. ' [ '..(GetPedInVehicleSeat(veh, -1) ~= 0 and "~r~O~w~" or "~g~L~w~")..' ] [ ~y~'..math.floor(v[2])..'m~w~ ]', "Lista De veiculos", Migma.Vars.pos, function()
                        VeiculoSelecionado = veh
                    end)
                    Migma.Vars.pos = Migma.Vars.pos + 18
                end
            end
        end

        if (Migma.Vars.Checkboxes["Resources Manager"]) then
            Migma.Vars.pos = 0 + Migma.Vars.Pos["Resources Manager"].scroll[1]
            if (Migma.Functions.Hovered(Migma.Vars.Pos["Resources Manager"].x, Migma.Vars.Pos["Resources Manager"].y, 250, 320)) then
                if (IsDisabledControlJustPressed(0, 14) and Migma.Vars.pos ~= 0) then
                    Migma.Vars.Pos["Resources Manager"].scroll[1] = Migma.Vars.Pos["Resources Manager"].scroll[1] - 18
                end

                if (IsDisabledControlJustPressed(0, 15) and Migma.Vars.pos ~= 18 * 15) then
                    Migma.Vars.Pos["Resources Manager"].scroll[1] = Migma.Vars.Pos["Resources Manager"].scroll[1] + 18
                end
            end


            if (Migma.Vars.pos >= 0 and Migma.Vars.pos <= 18 * 15) then
                for _, v in ipairs(Migma.Vars.Resources) do
                    Migma.Functions.DrawText(v.resource .. " -> " .. v.status, Migma.Vars.Pos["Resources Manager"].x + 7,
                        Migma.Vars.Pos["Resources Manager"].y + 27 + Migma.Vars.pos, 4, 255, 255, 255, 255, "Left", 300,
                        true)
                    Migma.Vars.pos = Migma.Vars.pos + 18
                end
            end
        end
    end

    function Migma.Functions.MainTab()
        local r, g, b = Migma.Functions.Rainbow(0.3)
        Migma.Functions.DrawRect(Migma.Vars.Pos["Main"].x, Migma.Vars.Pos["Main"].y, 150, 25, 0, 0, 0, 255)
        Migma.Functions.DrawRect(Migma.Vars.Pos["Main"].x, Migma.Vars.Pos["Main"].y + 25, 150, 1, r, g, b, 255)
        Migma.Functions.DrawText("GGzera Menu", Migma.Vars.Pos["Main"].x + 150 / 2, Migma.Vars.Pos["Main"].y, 4, 255, 255,
            255, 255, "Center", 324, true)
        Migma.Functions.DrawRect(Migma.Vars.Pos["Main"].x, Migma.Vars.Pos["Main"].y + 26, 150, 295, 0, 0, 0, 150)
        for lol, tabs in pairs(Migma.Tabs) do
            if (tabs ~= "Main") then
                Migma.Functions.Checkbox(tabs, "Main", (lol - 2) * 18, tabs)
            end
        end
        Migma.Functions.Button("Desinjetar", "Main", 18 * 10, function() Migma.Vars.Enabled = false end)
    end

    function Migma.Functions.DrawTabs()
        for label, pos in pairs(Migma.Vars.Pos) do
            if (label ~= "Main" and Migma.Vars.Checkboxes[label]) then
                local r, g, b = Migma.Functions.Rainbow(0.3)
                Migma.Functions.DrawRect(Migma.Vars.Pos[label].x, Migma.Vars.Pos[label].y, 250, 25, 0, 0, 0, 255)
                Migma.Functions.DrawRect(Migma.Vars.Pos[label].x, Migma.Vars.Pos[label].y + 25, 250, 1, r, g, b, 255)
                Migma.Functions.DrawText(label, Migma.Vars.Pos[label].x + 250 / 2, Migma.Vars.Pos[label].y, 4, 255, 255,
                    255,
                    255, "Center", 324, true)
                Migma.Functions.DrawRect(Migma.Vars.Pos[label].x, Migma.Vars.Pos[label].y + 26, 250, 295, 0, 0, 0, 150)
            end
        end
    end

    function Migma.Functions.HandleDragging()
        if (Migma.Vars.HoveredOpt == nil) then
            if (IsDisabledControlJustPressed(0, 24)) then
                if (Migma.Functions.Hovered(Migma.Vars.Pos["Main"].x, Migma.Vars.Pos["Main"].y, 150, 320)) then
                    Migma.Vars.Dragging = Migma.Vars.Pos["Main"]
                elseif (Migma.Functions.Hovered(Migma.Vars.Pos["Aimbot"].x, Migma.Vars.Pos["Aimbot"].y, 250, 320)) then
                    Migma.Vars.Dragging = Migma.Vars.Pos["Aimbot"]
                elseif (Migma.Functions.Hovered(Migma.Vars.Pos["Visuais"].x, Migma.Vars.Pos["Visuais"].y, 250, 320)) then
                    Migma.Vars.Dragging = Migma.Vars.Pos["Visuais"]
                elseif (Migma.Functions.Hovered(Migma.Vars.Pos["Veiculo"].x, Migma.Vars.Pos["Veiculo"].y, 250, 320)) then
                    Migma.Vars.Dragging = Migma.Vars.Pos["Veiculo"]
                elseif (Migma.Functions.Hovered(Migma.Vars.Pos["Armas"].x, Migma.Vars.Pos["Armas"].y, 250, 320)) then
                    Migma.Vars.Dragging = Migma.Vars.Pos["Armas"]
                elseif (Migma.Functions.Hovered(Migma.Vars.Pos["Jogador"].x, Migma.Vars.Pos["Jogador"].y, 250, 320)) then
                    Migma.Vars.Dragging = Migma.Vars.Pos["Jogador"]
                elseif (Migma.Functions.Hovered(Migma.Vars.Pos["Destruicao"].x, Migma.Vars.Pos["Destruicao"].y, 250, 320)) then
                    Migma.Vars.Dragging = Migma.Vars.Pos["Destruicao"]
                elseif (Migma.Functions.Hovered(Migma.Vars.Pos["Jogadores"].x, Migma.Vars.Pos["Jogadores"].y, 250, 320)) then
                    Migma.Vars.Dragging = Migma.Vars.Pos["Jogadores"]
                elseif (Migma.Functions.Hovered(Migma.Vars.Pos["Lista de Jogadores"].x, Migma.Vars.Pos["Lista de Jogadores"].y, 250, 320)) then
                    Migma.Vars.Dragging = Migma.Vars.Pos["Lista de Jogadores"]
                elseif (Migma.Functions.Hovered(Migma.Vars.Pos["Lista De veiculos"].x, Migma.Vars.Pos["Lista De veiculos"].y, 250, 320)) then
                    Migma.Vars.Dragging = Migma.Vars.Pos["Lista De veiculos"]
                elseif Migma.Functions.Hovered(Migma.Vars.Pos["Veiculos Selecionados"].x, Migma.Vars.Pos["Veiculos Selecionados"].y, 250, 320) then 
                    Migma.Vars.Dragging = Migma.Vars.Pos["Veiculos Selecionados"]
                end
            end
            if Migma.Vars.Dragging then
                local mx, my = Migma.Vars.cx, Migma.Vars.cy
                if xdist == nil then
                    xdist = mx - Migma.Vars.Dragging.x
                end
                if ydist == nil then
                    ydist = my - Migma.Vars.Dragging.y
                end

                Migma.Vars.Dragging.x = mx - xdist
                Migma.Vars.Dragging.y = my - ydist
            else
                xdist = nil
                ydist = nil
            end

            if (not IsDisabledControlPressed(0, 24)) then
                Migma.Vars.Dragging = false
            end
        end
    end

    function Migma.Functions.DrawCursor()
        Migma.Vars.cx, Migma.Vars.cy = Citizen.InvokeNative(0xBDBA226F, Citizen.PointerValueInt(),
            Citizen.PointerValueInt())
        Migma.Functions.DrawText("^", Migma.Vars.cx + 1, Migma.Vars.cy - 5, 0, 255, 255, 255, 255, "Center", 300, true)
    end

    CreateThread(function()
        -- START MENU
        if (Migma.Functions.LoadResources()) then
            -- for _, v in ipairs(Migma.Vars.Resources) do
            --     print(v.resource)
            --     print(v.status)
            -- end
            print("Resources Loaded")
        else
            print("Erro ao dar load nas resources...")
        end

        if (Migma.Functions.GetResource("vrp")) then
            print("^0Encontramos nesse servidor o anticheat ^1VRP ^0Status da resource -> " .. Migma.Vars.ResourceState)
        end
        if (Migma.Functions.GetResource("MQCU")) then
            print("^0Encontramos nesse servidor o anticheat ^1MQCU ^0Status da resource -> " .. Migma.Vars.ResourceState)
        end
        if (Migma.Functions.GetResource("likizao_ac")) then
            print("^0Encontramos nesse servidor o anticheat ^1LIKIZAO ^0Status da resource -> " ..
            Migma.Vars.ResourceState)
        end

        while Migma.Vars.Enabled do
            sleep(0)
            Migma.Vars.HoveredOpt = nil
            if (IsDisabledControlJustPressed(0, Migma.Config.Keybinds["Menu Key"].control)) then
                Migma.Vars.Displayed = not Migma.Vars.Displayed
            end
            if (Migma.Vars.Displayed) then
                DisablePlayerFiring(PlayerId(), true)
                Migma.Functions.MainTab()
                Migma.Functions.DrawTabs()
                Migma.Functions.DrawButtons()
                Migma.Functions.HandleDragging()
                Migma.Functions.DrawCursor()
            end
        end
    end)

    function Migma.Features.RequestControlOnce(entity)
        if (not DoesEntityExist(entity)) then
            return false
        end
        if (NetworkHasControlOfEntity(entity)) then
            print("Request concedido")
            return true
        else
            while true do
                Wait(1)
                SetNetworkIdCanMigrate(NetworkGetNetworkIdFromEntity(entity), true)
                NetworkGetEntityFromNetworkId(NetworkGetNetworkIdFromEntity(entity))
                return NetworkRequestControlOfNetworkId(NetworkGetNetworkIdFromEntity(entity))
            end
        end
    end

    function Migma.Features.RequestControlById(entity) -- CRIEI ESSA NOVA REQUEST DA ENTIDADE, P/ NÃO REFAZER A SUA ANTIGA MIGMA

    end

    function Migma.Features.fg(fh)
        local fi = fh.z * 0.0174532924;
        local fj = fh.x * 0.0174532924;
        local fk = math.abs(math.cos(fj))
        return vector3(-math.sin(fi) * fk, math.cos(fi) * fk, math.sin(fj))
    end

    function Migma.Features.fl(_, fm, fn, fo)
        ApplyForceToEntity(_, 3,
            (fm - GetEntityCoords(_)) * fn ^ 2 - (vector3(0.0, 0.0, 0.1) + GetEntityVelocity(_) * 2 * fn * fo), 0, 0, 0,
            false, false, true, true, false, true)
    end

    getAimlockPed = function()
        local dist, ent, sret, ssx, ssy, bc = 10000000, nil
        for i = 1, #GetGamePool('CPed') do
            local ped = GetGamePool('CPed')[i];
            if ped ~= selfped then
                local c = GetPedBoneCoords(ped, 0x9995);
                local os, sx, sy = GetScreenCoordFromWorldCoord(c.x, c.y, c.z);

                local dista = #vector2(sx - 0.5, sy - 0.5)
                if dista < dist then
                    dist, ent, sret, ssx, ssy, bc = dista, ped, os, sx, sy, c
                end
            end
        end
        return ent, bc, sret, ssx, ssy
    end

    CreateThread(function()
        while Migma.Vars.Enabled do
            sleep(0)
            -- AIMBOT
            if (Migma.Vars.Checkboxes["Aimbot_Toggle"]) then
                local FOV = (100 / 1000)
                local ped, a, b, c, d = getAimlockPed()
                if Migma.Vars.Checkboxes["aimbotPeds"] then
                    aped = ped
                else
                    aped = IsPedAPlayer(ped)
                end
                if Migma.Vars.Checkboxes["aimbotDeads"] then
                    deads = ped
                else
                    deads = not IsEntityDead(ped)
                end
                if Migma.Vars.Checkboxes["aimbotVisible"] then
                    vis = HasEntityClearLosToEntity(PlayerPedId(), ped, 17)
                else
                    vis = true
                end
                local hit = math.random(0, 100)
                local x, y, z = table.unpack(GetPedBoneCoords(ped, 31086))
                local _, _x, _y = GetScreenCoordFromWorldCoord(x, y, z)
                local c = GetPedBoneCoords(ped, 31086)
                local x1, y1, z1 = table.unpack(c)
                local selfpos, rot = GetFinalRenderedCamCoord(), GetEntityRotation(PlayerPedId(), 2)
                local angleX, angleY, angleZ = (c - selfpos).x, (c - selfpos).y, (c - selfpos).z
                local roll, pitch, yaw = -math.deg(math.atan2(angleX, angleY)) - rot.z,
                    math.deg(math.atan2(angleZ, #vector3(angleX, angleY, 0.0))), 1.0
                roll = 0.0 + (roll - 0.0)
                if aped and deads and vis and hit <= 100 and ped ~= PlayerPedId() and IsEntityOnScreen(ped) then
                    if (_x > 0.5 - ((FOV / 2) / 0.5) and _x < 0.5 + ((FOV / 2) / 0.5) and _y > 0.5 - ((FOV / 2) / 0.5) and _y < 0.5 + ((FOV / 2) / 0.5)) then
                        if (IsDisabledControlPressed(0, Migma.Config.Keybinds["Aimbot_Keybind"].control)) then
                            SetGameplayCamRelativeRotation(roll, pitch, yaw)
                        end
                    end
                end
            end

            if (Migma.Vars.Checkboxes["Triggerbot_Toggle"]) then
                local isAim, target = GetEntityPlayerIsFreeAimingAt(PlayerId())
                local visible = IsEntityVisible(target) or not Migma.Vars.Checkboxes["ignoreInvisible"]
                local isDead = (not Migma.Vars.Checkboxes["ignoreDead"] or (GetEntityHealth(target) >= 101))
                local isPed = true
                if Migma.Vars.Checkboxes["ignorePeds"] then
                    isPed = IsPedAPlayer(target)
                else
                    isPed = true
                end
                if (isAim and DoesEntityExist(target) and IsEntityAPed(target)) and visible and isDead and isPed and IsDisabledControlPressed(0, Migma.Config.Keybinds["TriggerBot_Keybind"].control) then
                    local bone_coords = GetPedBoneCoords(target, 31086, 0.0, 0.0, 0.0)
                    SetPedShootsAtCoord(PlayerPedId(), bone_coords.x, bone_coords.y, bone_coords.z, true)
                end
            end
            -- JOGADOR
            if (Migma.Vars.Checkboxes["noclipPlayer"]) then
                if Migma.Vars.PedNoclip ~= nil then
                    local v1 = { 32, 33, 30, 34, 22, 36, 129, 130, 133, 134, 75, 69 }

                    for _, v2 in pairs(v1) do
                        DisableControlAction(0, v2, true)
                    end

                    local speed = 5 / 10
                    local entity = Migma.Vars.PedNoclip

                    NetworkSetEntityVisibleToNetwork(GetPlayerPed(-1), false)

                    local vehicle = GetVehiclePedIsIn(entity, false)
                    if (vehicle and GetPedInVehicleSeat(vehicle, -1) == entity) then
                        entity = vehicle
                        SetEntityRotation(entity, GetFinalRenderedCamRot(2), 2)
                    else
                        SetEntityHeading(entity, GetGameplayCamRelativeHeading() + GetEntityHeading(entity))
                    end
                    local coords = GetEntityCoords(entity)
                    local forward, right = Migma.Math.rotateToQuat(GetFinalRenderedCamRot(0)) * vector3(0.0, 1.0, 0.0),
                        Migma.Math.rotateToQuat(GetFinalRenderedCamRot(0)) * vector3(1.0, 0.0, 0.0)
                    if (IsDisabledControlPressed(0, 21)) then speed = speed * 3 end
                    if (IsDisabledControlPressed(0, 32)) then coords = coords + forward * speed end
                    if (IsDisabledControlPressed(0, 33)) then coords = coords + forward * -speed end
                    if (IsDisabledControlPressed(0, 30)) then coords = coords + right * speed end
                    if (IsDisabledControlPressed(0, 34)) then coords = coords + right * -speed end
                    if (IsDisabledControlPressed(0, 22)) then coords = vector3(coords.x, coords.y, coords.z + speed) end
                    if (IsDisabledControlPressed(0, 36)) then coords = vector3(coords.x, coords.y, coords.z - speed) end
                    SetEntityCoordsNoOffset(entity, coords.x, coords.y, coords.z, true, true, true)
                    SetEntityCollision(entity, false, false)
                    FreezeEntityPosition(entity, false)
                end
            end

            -- VEICULOS

            if (Migma.Vars.Checkboxes["bugarVeh"]) then
                if not IsPedInAnyVehicle(GetPlayerPed(Migma.Vars.PlayerSelected)) then
                    DetachEntity(PlayerPedId(), true)
                    DeleteEntity(Migma.Vars.VehicleBug)
                    DeleteVehicle(Migma.Vars.VehicleBug)

                    Migma.Vars.VehicleBug = nil
                end
            end

            if (Migma.Vars.Checkboxes["remoteControl"]) then
                if Migma.Vars.VehicleRemote ~= nil then
                    FreezeEntityPosition(PlayerPedId(), true)
                    SetVehicleEngineOn(Migma.Vars.VehicleRemote, true, true, true)

                    if IsDisabledControlPressed(0, 129) and not IsDisabledControlPressed(0, 130) then
                        TaskVehicleTempAction(PlayerPedId(), Migma.Vars.VehicleRemote, 9, 1)
                    end
                    if IsDisabledControlJustReleased(0, 129) or IsDisabledControlJustReleased(0, 130) then
                        TaskVehicleTempAction(PlayerPedId(), Migma.Vars.VehicleRemote, 6, 2500)
                    end
                    if IsDisabledControlPressed(0, 130) and not IsDisabledControlPressed(0, 129) then
                        TaskVehicleTempAction(PlayerPedId(), Migma.Vars.VehicleRemote, 22, 1)
                    end
                    if IsDisabledControlPressed(0, 89) and IsDisabledControlPressed(0, 130) then
                        TaskVehicleTempAction(PlayerPedId(), Migma.Vars.VehicleRemote, 13, 1)
                    end
                    if IsDisabledControlPressed(0, 90) and IsDisabledControlPressed(0, 130) then
                        TaskVehicleTempAction(PlayerPedId(), Migma.Vars.VehicleRemote, 14, 1)
                    end
                    if IsDisabledControlPressed(0, 129) and IsDisabledControlPressed(0, 130) then
                        TaskVehicleTempAction(PlayerPedId(), Migma.Vars.VehicleRemote, 30, 100)
                    end
                    if IsDisabledControlPressed(0, 89) and IsDisabledControlPressed(0, 129) then
                        TaskVehicleTempAction(PlayerPedId(), Migma.Vars.VehicleRemote, 7, 1)
                    end
                    if IsDisabledControlPressed(0, 90) and IsDisabledControlPressed(0, 129) then
                        TaskVehicleTempAction(PlayerPedId(), Migma.Vars.VehicleRemote, 8, 1)
                    end
                    if IsDisabledControlPressed(0, 89) and not IsDisabledControlPressed(0, 129) and not IsDisabledControlPressed(0, 130) then
                        TaskVehicleTempAction(PlayerPedId(), Migma.Vars.VehicleRemote, 4, 1)
                    end
                    if IsDisabledControlPressed(0, 90) and not IsDisabledControlPressed(0, 129) and not IsDisabledControlPressed(0, 130) then
                        TaskVehicleTempAction(PlayerPedId(), Migma.Vars.VehicleRemote, 5, 1)
                    end
                    if hornboost2 then
                        local Vehicle = Migma.Vars.VehicleRemote
                        if IsDisabledControlPressed(0, 38) then
                            SetVehicleBoostActive(Vehicle, true)
                            SetVehicleForwardSpeed(Vehicle, GetEntitySpeed(Vehicle) + 2)
                            Timer = GetGameTimer() + 1000
                        end
                    end
                    --Camera = Camera
                    --if not Camera ~= nil then
                    --Camera = CreateCam("DEFAULT_SCRIPTED_Camera", 1)
                    --end
                    --RenderScriptCams(1, 0, 0, 1, 1)
                    --SetCamActive(Camera, true)
                    local Cordenadas = GetEntityCoords(Migma.Vars.VehicleRemote)
                    -- SetCamCoord(Camera, Cordenadas.x, Cordenadas.y, Cordenadas.z + 3)
                    -- SetCamRot(cam, GetEntityRotation(Migma.Vars.VehicleRemote), 2)
                    -- while DoesCamExist(Camera) do
                    --     Citizen.Wait(0)
                    --     if not Migma.Vars.Checkboxes["remoteControl"] then
                    --         SetVehicleEngineOn(Migma.Vars.VehicleRemote, false, false, false)
                    --         DestroyCam(camrc, false)
                    --         RenderScriptCams(false, false, 0, 1, 0)
                    --         FreezeEntityPosition(PlayerPedId(), false)
                    --         SetFocusEntity(PlayerPedId())
                    --         break
                    --     end
                    --     local x, y, z = table.unpack(GetCamCoord(Camera))
                    --     AttachCamToEntity(Camera, Migma.Vars.VehicleRemote, 0.0, -9.5, 1.8, true)
                    --     SetFocusArea(GetCamCoord(Camera).x, GetCamCoord(Camera).y, GetCamCoord(Camera).z, 0.0, 0.0, 0.0)
                    --     SetCamRot(Camera, GetEntityRotation(Migma.Vars.VehicleRemote), 2)
                    -- end
                end
            end

            if (Migma.Vars.Checkboxes["adminsProx"]) then
                for an in EnumerarPeds() do
                    local adm = IsEntityVisibleToScript(an)
                    if adm == false then
                        local cC = GetEntityCoords(an)
                        local coords = GetEntityCoords(PlayerPedId())
                        local me = an ~= PlayerPedId()
                        local mr = IsPedAPlayer(aR)
                        local cD = GetDistanceBetweenCoords(GetFinalRenderedCamCoord(), cC.x, cC.y, cC.z, true) *
                        (1.6 - 0.05)                                                                                   -- Tamanho
                        local dismax = 30
                        if cD < dismax then
                            if me then
                                ra = RGBRainbow(3.0)
                                DrawLine(coords, cC, ra.r, ra.g, ra.b, 255)
                            end
                        end
                        ClearDrawOrigin()
                    end
                end
            end

            if (Migma.Vars.Checkboxes["ciclopeFunc"]) then
                if (IsDisabledControlPressed(0, 46)) then
                    local pos = GetPedBoneCoords(PlayerPedId(), 0x62AC, 0.0, 0.0, 0.0) -- OLHO ESQUERDO / LEFT EYE (0x62AC)
                    local dir = Migma.Math.rotateToDirection(GetGameplayCamRot())

                    local lineStart = pos
                    local lineEnd = vector3(pos.x + dir.x * 100, pos.y + dir.y * 100, pos.z + dir.z * 100)

                    local lineWidth = 0.2
                    local perpendicularDir = vector3(-dir.y, dir.x, dir.z)

                    local numLines = 10
                    local step = lineWidth / numLines

                    for i = 0, numLines - 1 do
                        local offset = perpendicularDir * (i * step - lineWidth / 2)
                        local startOffset = vector3(lineStart.x + offset.x, lineStart.y + offset.y,
                            lineStart.z + offset.z)
                        local endOffset = vector3(lineEnd.x + offset.x, lineEnd.y + offset.y, lineEnd.z + offset.z)
                        DrawLine(startOffset.x, startOffset.y, startOffset.z, endOffset.x, endOffset.y, endOffset.z, 255,
                            0,
                            0, 255)
                    end

                    ShootSingleBulletBetweenCoords(pos.x, pos.y, pos.z, lineEnd.x, lineEnd.y, lineEnd.z, 20, true,
                        GetHashKey("weapon_pistol_mk2"), PlayerPedId(), true, false, 0.3)
                end
            end

            if (Migma.Vars.Checkboxes["Bloquear Veiculos"]) then
                for k, vehicle in pairs(GetGamePool('CVehicle')) do
                    SetVehicleSeatIsLocked(vehicle, 0, true)
                end
            end
            if (Migma.Vars.Checkboxes["VidaInfinita"]) then
                SetEntityOnlyDamagedByRelationshipGroup(PlayerPedId(), true,
                    "L91U83C01A61S" .. GetHashKey(math.random(100000, 999999)))
            end
            if (Migma.Vars.Checkboxes["BoostHorn"]) then
                local boost = 150
                if IsPedInAnyVehicle(PlayerPedId(), true) then
                    if IsControlPressed(1, 38) then
                        SetVehicleBoostActive(GetVehiclePedIsUsing(GetPlayerPed(-1)), true)
                        Citizen.InvokeNative(0xAB54A438726D25D5, GetVehiclePedIsUsing(GetPlayerPed(-1)), boost + 0.0)
                    else
                        SetVehicleBoostActive(GetVehiclePedIsUsing(GetPlayerPed(-1)), false)
                    end
                end
            end
            if (Migma.Vars.Checkboxes["Handlingboost"]) then
                local veh = GetVehiclePedIsIn(PlayerPedId(), false)
                ModifyVehicleTopSpeed(veh, 400.0)
            else
                local veh = GetVehiclePedIsIn(PlayerPedId(), false)
                ModifyVehicleTopSpeed(veh, 1.0)
            end
            if (Migma.Vars.Checkboxes["MunicaoInfinita"]) then
                SetPedInfiniteAmmoClip(PlayerPedId(), true)
            end
            if (Migma.Vars.Checkboxes["MunicaoExplode"]) then
                local ped = PlayerPedId()
                local success, coord = GetPedLastWeaponImpactCoord(ped)
                if success then
                    RequestWeaponAsset(GetHashKey("WEAPON_GRENADE"), 31, 0)
                    while not HasWeaponAssetLoaded(GetHashKey("WEAPON_GRENADE")) do
                        Wait(0)
                    end
                    local plyCoords = GetEntityCoords(ped, false)
                    ShootSingleBulletBetweenCoords(coord.x, coord.y, coord.z + 0.1, coord.x, coord.y, coord.z,
                        1, true, GetHashKey("WEAPON_GRENADE"), -1, false, true)
                end
            end
            if (Migma.Vars.Checkboxes["AutoVeh"]) then
                if (IsVehicleDamaged(GetVehiclePedIsIn(PlayerPedId(), false))) then
                    SetVehicleFixed(GetVehiclePedIsIn(PlayerPedId(), false))
                end
            end
            if (Migma.Vars.Checkboxes["noVeh"]) then
                SetPedCanBeKnockedOffVehicle(PlayerPedId(), true)
            else
                SetPedCanBeKnockedOffVehicle(PlayerPedId(), false)
            end
            if (Migma.Vars.Checkboxes["GodVeh"]) then
                SetEntityInvincible(GetVehiclePedIsIn(PlayerPedId(), 0))
            else
                SetEntityInvincible(GetVehiclePedIsIn(PlayerPedId(), 0), false)
            end
            if (Migma.Vars.Checkboxes["SemRecaregar"]) then
                RefillAmmoInstantly(PlayerPedId())
            end
            if (Migma.Vars.Checkboxes["FicarInv"]) then
                SetEntityVisible(PlayerPedId(), false)
            else
                SetEntityVisible(PlayerPedId(), true)
            end

            if (Migma.Vars.Checkboxes["StaminaLoop"]) then
                ResetPlayerStamina(PlayerPedId())
            end

            if (Migma.Vars.Checkboxes["MatarGeral"]) then
                for k, v in pairs(GetActivePlayers()) do
                    local p = GetPlayerPed(v)
                    local b = GetEntityRotation(p)
                    local c = RotationToDirection(b)
                    local d = GetEntityCoords(PlayerPedId(), false)
                    local e = GetEntityCoords(p, false)
                    local f = GetPedBoneCoords(p, 31086, 0, 0, 0)
                    local g = GetDistanceBetweenCoords(d.x, d.y, d.z, e.x, e.y, e.z, false)
                    if g <= 10000.0 then
                        local h = IsEntityDead(p)
                        if not h then
                            ShootSingleBulletBetweenCoords(f.x + c.x, f.y + c.y, f.z + c.z, f.x, f.y, f.z,
                                math.floor(GetWeaponDamage(GetSelectedPedWeapon(PlayerPedId()))), false,
                                GetHashKey('weapon_assaultrifle_mk2'), PlayerPedId(), false, true, 1)
                        end
                    end
                end
            end

            if (Migma.Vars.Checkboxes["Freecam"]) then
                LocalPlayer.state.controlDisabled = 0
                local Camera = CreateCam('DEFAULT_SCRIPTED_Camera', 1)
                RenderScriptCams(true, true, 700, 1, 1)
                SetCamActive(Camera, true)
                SetCamCoord(Camera, GetGameplayCamCoord())
                local CDSRotX = GetGameplayCamRot(2).x
                local CDSRotY = GetGameplayCamRot(2).y
                local CDSRotZ = GetGameplayCamRot(2).z
                while DoesCamExist(Camera) do
                    Wait(0)
                    local FreecamModes = Migma.Vars.FreeCamModes[Migma.Vars.FreeCamModeActual]
                    local Camera_rot = GetCamRot(Camera, 2)
                    local Cordenadas = GetCamCoord(Camera)
                    local adjustedRotation = {
                        x = (Migma.Math.Math_Pi / 180) * GetCamRot(Camera, 0).x,
                        y = (Migma.Math.Math_Pi / 180) *
                            GetCamRot(Camera, 0).y,
                        z = (Migma.Math.Math_Pi / 180) * GetCamRot(Camera, 0).z
                    }
                    local direction = {

                        x = -Migma.Math.Math_Sin(adjustedRotation.z) *
                            Migma.Math.Math_Abs(Migma.Math.Math_Cos(adjustedRotation.x)),
                        y = Migma.Math.Math_Cos(adjustedRotation.z) *
                            Migma.Math.Math_Abs(Migma.Math.Math_Cos(adjustedRotation.x)),
                        z = Migma.Math.Math_Sin(adjustedRotation.x)
                    }

                    local CameraRotation = GetCamRot(Camera, 0)
                    local CameraCoord = GetCamCoord(Camera)
                    local distance = 5000.0
                    local destination = {
                        x = CameraCoord.x + direction.x * distance,
                        y = CameraCoord.y + direction.y * distance,
                        z = CameraCoord.z + direction.z * distance
                    }
                    local a, b, Cordenadas, d, entity =
                        GetShapeTestResult(
                            StartShapeTestRay(
                                CameraCoord.x,
                                CameraCoord.y,
                                CameraCoord.z,
                                destination.x,
                                destination.y,
                                destination.z,
                                -1,
                                -1,
                                1
                            )
                        )

                    SetCamFov(Camera, 15.0 * 5)

                    local playerPed = PlayerPedId()
                    local playerRot = GetEntityRotation(playerPed, 2)
                    local rotX = playerRot.x
                    local rotY = playerRot.y
                    local rotZ = playerRot.z
                    CDSRotX = CDSRotX - (GetDisabledControlNormal(1, 2) * 6.0)
                    CDSRotZ = CDSRotZ - (GetDisabledControlNormal(1, 1) * 6.0)
                    if (CDSRotX > 90.0) then
                        CDSRotX = 90.0
                    elseif (CDSRotX < -90.0) then
                        CDSRotX = -90.0
                    end
                    if (CDSRotY > 90.0) then
                        CDSRotY = 90.0
                    elseif (CDSRotY < -90.0) then
                        CDSRotY = -90.0
                    end
                    if (CDSRotZ > 360.0) then
                        CDSRotZ = CDSRotZ - 360.0
                    elseif (CDSRotZ < -360.0) then
                        CDSRotZ = CDSRotZ + 360.0
                    end
                    local x, y, z = table.unpack(GetCamCoord(Camera))
                    local Vector = vector3(x, y, z)
                    local vecX, vecY, vecZ = GetCamMatrix(Camera)
                    local CurrentSpeed = 0.6
                    -- if IsDisabledControlPressed(1, 36) then
                    --     CurrentSpeed = CurrentSpeed / 15
                    -- end
                    if IsDisabledControlPressed(1, 21) then -- SHIFT
                        CurrentSpeed = CurrentSpeed * 3
                    end
                    if IsDisabledControlPressed(1, 32) then -- W
                        SetCamCoord(
                            Camera,
                            GetCamCoord(Camera) + (Migma.Math.rotateToDirection(GetCamRot(Camera, 2)) * (CurrentSpeed))
                        )

                        if IsDisabledControlPressed(1, 34) then
                            Vector = Vector - vecX * (CurrentSpeed)
                            SetCamCoord(Camera, Vector, y, z)
                        end

                        if IsDisabledControlPressed(1, 9) then -- D
                            Vector = Vector + vecX * (CurrentSpeed)
                            SetCamCoord(Camera, Vector, y, z)
                        end
                    end
                    if IsDisabledControlPressed(1, 33) then -- S
                        SetCamCoord(
                            Camera,
                            GetCamCoord(Camera) - (Migma.Math.rotateToDirection(GetCamRot(Camera, 2)) * (CurrentSpeed))
                        )
                    end
                    if IsDisabledControlPressed(1, 22) then -- SPACE
                        SetCamCoord(Camera, x, y, z + (CurrentSpeed))
                    end
                    if IsDisabledControlPressed(1, 36) then -- CTRL
                        SetCamCoord(Camera, x, y, z - (CurrentSpeed))
                    end
                    if IsDisabledControlPressed(1, 34) then -- A
                        Vector = Vector - vecX * (CurrentSpeed)
                        SetCamCoord(Camera, Vector, y, z)
                    end
                    if IsDisabledControlPressed(1, 9) then -- D
                        Vector = Vector + vecX * (CurrentSpeed)
                        SetCamCoord(Camera, Vector, y, z)
                    end
                    local cx, cy, cz =
                        string.format('%.' .. 1 .. 'f', Cordenadas.x),
                        string.format('%.' .. 1 .. 'f', Cordenadas.y),
                        string.format('%.' .. 1 .. 'f', Cordenadas.z)
                    local resX, resY = GetActiveScreenResolution()
                    if Migma.Vars.FreeCamModes == 'Camera Livre' then
                        if IsDisabledControlJustPressed(0, 69) then
                            if Cordenadas ~= vector3(0, 0, 0) then
                            end
                        end
                    end

                    Migma.Vars.FreeCamBlock()

                    -- if IsDisabledControlJustPressed(1, 14) then
                    --     Migma.Vars.FreeCamModeActual = Migma.Vars.FreeCamModeActual + 1
                    --     if Migma.Vars.FreeCamModeActual > #Migma.Vars.FreeCamModes then
                    --         Migma.Vars.FreeCamModeActual = 1
                    --     end
                    -- end
                    -- if IsDisabledControlJustPressed(1, 15) then
                    --     Migma.Vars.FreeCamModeActual = Migma.Vars.FreeCamModeActual - 1
                    --     if Migma.Vars.FreeCamModeActual < 1 then
                    --         Migma.Vars.FreeCamModeActual = #Migma.Vars.FreeCamModes
                    --     end
                    -- end

                    SetFocusPosAndVel(GetCamCoord(Camera).x, GetCamCoord(Camera).y, GetCamCoord(Camera).z, 0.0, 0.0, 0.0)
                    SetCamRot(Camera, CDSRotX, CDSRotY, CDSRotZ, 2)
                    SetCamRot(Camera, CDSRotX, CDSRotY, CDSRotZ, 2)

                    -- CRIAÇÃO DE MARCADOR PRO NOSSO QUERIDO PED, SO PRA FICAR FACIL DE VISUALIZAR ONDE ESTÁ NOSSO PED
                    local x2, y2, z2 = table.unpack(GetPedBoneCoords(PlayerPedId(), 31086, 0.0, 0.0, 0.0))

                    DrawMarker(0, x2, y2, z2 + 0.5, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.25, 0.25, 0.25, 255, 255, 255, 255,
                        true,
                        true, 2, nil, nil, false)

                    if not Migma.Vars.Checkboxes["Freecam"] then
                        DestroyCam(Camera, false)
                        ClearTimecycleModifier()
                        RenderScriptCams(false, true, 700, 1, 0)
                        FreezeEntityPosition(PlayerPedId(), false)
                        SetFocusEntity(PlayerPedId())
                        break
                    end
                end
            end

            if (Migma.Vars.Checkboxes["dispararAlarmes"]) then
                local vehs = GetGamePool("CVehicle")
                for k, vehicles in vehs do
                    NetworkRequestControlOfEntity(vehicles) -- REQUEST CONTROL, CRIAR MÉTODO
                    SetVehicleAlarm(vehicles, true)
                    SetVehicleAlarmTimeLeft(vehicles, 10000)
                end
            end

            if Migma.Vars.Checkboxes["TrancarVeiculos"] then 
                local CarrosProx = CarrosNearest(Gec(getPlr()), 150)

                for i,v in pairs(CarrosProx) do 
                    local vehicle = v[1]
                    NetworkRequestControlOfEntity(vehicle) -- REQUEST CONTROL, CRIAR MÉTODO
                    SetVehicleDoorsLocked(vehicle, 2)
                    SetVehicleDoorsLockedForAllPlayers(vehicle, true)
                    SetVehicleDoorsLockedForPlayer(vehicle, getPlr(), true)
                end
            end

            if (Migma.Vars.Checkboxes["spectarPlayer"]) then
                CreateThread(function()
                    local camerat = camerat
                    if not camerat ~= nil then
                        camerat = CreateCam("DEFAULT_SCRIPTED_Camera", 1)
                    end

                    RenderScriptCams(1, 0, 0, 1, 1)
                    SetCamActive(camerat, true)
                    local coords = GetEntityCoords(Migma.Vars.PlayerSelected)
                    SetCamCoord(camerat, coords.x, coords.y, coords.z + 3)

                    while DoesCamExist(camerat) do
                        Wait(0)
                        if not Migma.Vars.Checkboxes["spectarPlayer"] then
                            DestroyCam(camerat, false)
                            ClearTimecycleModifier()
                            RenderScriptCams(false, false, 0, 1, 0)
                            SetFocusEntity(PlayerPedId())
                            break
                        end
                        local playerPed = GetPlayerPed(Migma.Vars.PlayerSelected)
                        local playerRot = GetEntityRotation(playerPed, 2)

                        local x, y, z = table.unpack(GetCamCoord(camerat))

                        local x2, y2, z2 = table.unpack(GetPedBoneCoords(playerPed, 31086, 0.0, 0.0, 0.0))

                        DrawMarker(0, x2, y2, z2 + 0.5, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.25, 0.25, 0.25, 255, 255, 255,
                            255,
                            true, true, 2, nil, nil, false)

                        SetCamCoord(camerat, x2 + 1.5, y2 + 1.5, z2 + 0.5) ---GetGameplayCamCoord())

                        if not Displayed then
                            SetFocusArea(GetCamCoord(camerat).x, GetCamCoord(camerat).y, GetCamCoord(camerat).z, 0.0, 0.0,
                                0.0)
                            SetCamRot(camerat, GetGameplayCamRot(2), 2)
                        end
                    end
                end)
            end

            if (Migma.Vars.Checkboxes["espName"]) then
                for i = 0, 128 do
                    if i ~= PlayerId() and GetPlayerServerId(i) ~= 0 then
                        local luffy = GetPlayerPed(i)
                        local cx, cy, cz = table.unpack(GetEntityCoords(PlayerPedId()))
                        local x, y, z = table.unpack(GetEntityCoords(luffy))
                        local _, wephash = GetCurrentPedWeapon(GetPlayerPed(i), 1)
                        local wepname = GetWeaponNameFromHash(wephash)
                        if wepname == nil then wepname = "Desarmado" end
                        local meucumprido =
                            "" ..
                            GetPlayerName(i) ..
                            "\n~h~~w~[Distancia]: " ..
                            math.round(GetDistanceBetweenCoords(cx, cy, cz, x, y, z, false)) ..
                            "\n[~b~Arma~w~]:~y~ " .. wepname
                        if IsPedInAnyVehicle(luffy, true) then
                            local VehName = GetLabelText(GetDisplayNameFromVehicleModel(GetEntityModel(
                            GetVehiclePedIsUsing(luffy))))
                            meucumprido = meucumprido .. "\n~w~[Veiculo]: " .. VehName
                        end

                        Draw3DText(x, y, z + 1.0, meucumprido, 255, 1, 0)
                    end
                end
            end
        end
    end)

    local fe = false;
    local ax = 18;
    local ff;
    local Q = PlayerPedId()
    CreateThread(function()
        while Migma.Vars.Enabled do
            sleep(0)
            local themvehs = GetGamePool("CVehicle")
            local thempeds = GetGamePool("CPed")
            if (Migma.Vars.Checkboxes["Black-Hole"]) then
                DisableControlAction(0, 37, true)
                if IsDisabledControlJustPressed(0, 38) then
                    fe = not fe
                end
                if fe then
                    ff = GetGameplayCamCoord() + Migma.Features.fg(GetGameplayCamRot(2)) *
                        ax;
                    DrawMarker(28, ff, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 1.5, 1.5,
                        1.5, 10, 10, 10, 200)
                    for v, k in pairs(themvehs) do
                        SetEntityInvincible(k, true)
                        if IsEntityOnScreen(k) and
                            GetVehiclePedIsIn(Q, false) ~= k then
                            NetworkRequestControlOfEntity(k)
                            FreezeEntityPosition(k, false)
                            Migma.Features.fl(k, ff, 0.5, 0.3)
                            if GetDistanceBetweenCoords(ff, GetEntityCoords(k), true) < 5 then
                                DeleteEntity(k)
                            end
                        end
                    end
                    for v, k in pairs(thempeds) do
                        SetEntityInvincible(k, true)
                        if IsEntityOnScreen(k) and Q ~= k then
                            NetworkRequestControlOfEntity(k)
                            FreezeEntityPosition(k, false)
                            Migma.Features.fl(k, ff, 0.5, 0.3)
                            if GetDistanceBetweenCoords(ff,
                                    GetEntityCoords(k),
                                    true) < 5 then
                                DeleteEntity(k)
                            end
                        end
                    end
                end
                if IsDisabledControlJustPressed(0, 15) then
                    ax = ax + 3
                end
                if IsDisabledControlJustPressed(0, 14) then
                    if ax - 3 > 3 then ax = ax - 3 end
                end
            end
        end
    end)

    CreateThread(function()
        while Migma.Vars.Enabled do
            sleep(0)
            RegisterKeyMapping('keyword_o', '_felipewords', 'keyboard', 'o')
            -- RegisterKeyMapping('keyword_0', '_felipewords', 'keyboard', '0')
            RegisterKeyMapping('keyword_i', '_felipewords', 'keyboard', 'i')
            RegisterKeyMapping('keyword_j', '_felipewords', 'keyboard', 'j')

            RegisterCommand('keyword_o', function()
                if (IsDisabledControlPressed(0, 21)) then
                    Migma.Config.textBoxes.currentTextbox.string = Migma.Config.textBoxes.currentTextbox.string .. 'O'
                else
                    Migma.Config.textBoxes.currentTextbox.string = Migma.Config.textBoxes.currentTextbox.string .. 'o'
                end
            end, false)

            -- RegisterCommand('keyword_0', function()
            --     Migma.Config.textBoxes.currentTextbox.string = Migma.Config.textBoxes.currentTextbox.string .. '0'
            -- end, false)

            RegisterCommand('keyword_i', function()
                if (IsDisabledControlPressed(0, 21)) then
                    Migma.Config.textBoxes.currentTextbox.string = Migma.Config.textBoxes.currentTextbox.string .. 'I'
                else
                    Migma.Config.textBoxes.currentTextbox.string = Migma.Config.textBoxes.currentTextbox.string .. 'i'
                end
            end, false)

            RegisterCommand('keyword_j', function()
                if (IsDisabledControlPressed(0, 21)) then
                    Migma.Config.textBoxes.currentTextbox.string = Migma.Config.textBoxes.currentTextbox.string .. 'J'
                else
                    Migma.Config.textBoxes.currentTextbox.string = Migma.Config.textBoxes.currentTextbox.string .. 'j'
                end
            end, false)

            local nomeResource = GetCurrentResourceName()
            if nomeResource == "vrp" then
                RegisterCommand("arma", function(source, args)
                    if args[1] == "pistolmk2" then
                        local nomeResource = GetCurrentResourceName()

                        if nomeResource == "vrp" then
                            print("ok")
                            local Tunnel = module("vrp", "lib/Tunnel")
                            local Proxy = module("vrp", "lib/Proxy")
                            local Tools = module("vrp", "lib/Tools")
                            vRP = Proxy.getInterface("vRP")

                            vRP.giveWeapons({ ["weapon_psitol_mk2"] = { ammo = 250 } })
                        end
                    elseif args[1] == "carabina" then
                        local nomeResource = GetCurrentResourceName()

                        if nomeResource == "vrp" then
                            print("ok")
                            local Tunnel = module("vrp", "lib/Tunnel")
                            local Proxy = module("vrp", "lib/Proxy")
                            local Tools = module("vrp", "lib/Tools")
                            vRP = Proxy.getInterface("vRP")

                            vRP.giveWeapons({ ["WEAPON_carbinerifle"] = { ammo = 250 } })
                        end
                    elseif args[1] == "rpg" then
                        local nomeResource = GetCurrentResourceName()

                        if nomeResource == "vrp" then
                            print("ok")
                            local Tunnel = module("vrp", "lib/Tunnel")
                            local Proxy = module("vrp", "lib/Proxy")
                            local Tools = module("vrp", "lib/Tools")
                            vRP = Proxy.getInterface("vRP")

                            vRP.giveWeapons({ ["WEAPON_RPG"] = { ammo = 250 } })
                        end
                    elseif args[1] == "fogos" then
                        local nomeResource = GetCurrentResourceName()

                        if nomeResource == "vrp" then
                            print("ok")
                            local Tunnel = module("vrp", "lib/Tunnel")
                            local Proxy = module("vrp", "lib/Proxy")
                            local Tools = module("vrp", "lib/Tools")
                            vRP = Proxy.getInterface("vRP")

                            vRP.giveWeapons({ ["WEAPON_firework"] = { ammo = 250 } })
                        end
                    elseif args[1] == "glock" then
                        local nomeResource = GetCurrentResourceName()

                        if nomeResource == "vrp" then
                            print("ok")
                            local Tunnel = module("vrp", "lib/Tunnel")
                            local Proxy = module("vrp", "lib/Proxy")
                            local Tools = module("vrp", "lib/Tools")
                            vRP = Proxy.getInterface("vRP")

                            vRP.giveWeapons({ ["WEAPON_combatpistol"] = { ammo = 250 } })
                        end
                    elseif args[1] == "akmk2" then
                        local nomeResource = GetCurrentResourceName()

                        if nomeResource == "vrp" then
                            print("ok")
                            local Tunnel = module("vrp", "lib/Tunnel")
                            local Proxy = module("vrp", "lib/Proxy")
                            local Tools = module("vrp", "lib/Tools")
                            vRP = Proxy.getInterface("vRP")

                            vRP.giveWeapons({ ["WEAPON_assaultrifle_mk2"] = { ammo = 250 } })
                        end
                    elseif args[1] == "ak" then
                        local nomeResource = GetCurrentResourceName()

                        if nomeResource == "vrp" then
                            print("ok")
                            local Tunnel = module("vrp", "lib/Tunnel")
                            local Proxy = module("vrp", "lib/Proxy")
                            local Tools = module("vrp", "lib/Tools")
                            vRP = Proxy.getInterface("vRP")

                            vRP.giveWeapons({ ["WEAPON_assaultrifle"] = { ammo = 250 } })
                        end
                    elseif args[1] == "carabinamk2" then
                        local nomeResource = GetCurrentResourceName()

                        if nomeResource == "vrp" then
                            print("ok")
                            local Tunnel = module("vrp", "lib/Tunnel")
                            local Proxy = module("vrp", "lib/Proxy")
                            local Tools = module("vrp", "lib/Tools")
                            vRP = Proxy.getInterface("vRP")

                            vRP.giveWeapons({ ["WEAPON_carbinerifle_mk2"] = { ammo = 250 } })
                        end
                    elseif args[1] == "taze" then
                        local nomeResource = GetCurrentResourceName()

                        if nomeResource == "vrp" then
                            print("ok")
                            local Tunnel = module("vrp", "lib/Tunnel")
                            local Proxy = module("vrp", "lib/Proxy")
                            local Tools = module("vrp", "lib/Tools")
                            vRP = Proxy.getInterface("vRP")

                            vRP.giveWeapons({ ["WEAPON_stungun"] = { ammo = 250 } })
                        end
                    elseif args[1] == "molotov" then
                        local nomeResource = GetCurrentResourceName()

                        if nomeResource == "vrp" then
                            print("ok")
                            local Tunnel = module("vrp", "lib/Tunnel")
                            local Proxy = module("vrp", "lib/Proxy")
                            local Tools = module("vrp", "lib/Tools")
                            vRP = Proxy.getInterface("vRP")

                            vRP.giveWeapons({ ["WEAPON_molotov"] = { ammo = 250 } })
                        end
                    end
                end)
                RegisterCommand("armaliki", function(source, args)
                    if args[1] == "pistolmk2" then
                        TriggerEvent('__cfx_nui:request', {
                            'vRP', 'giveWeapons',
                            {
                                ["weapon_pistol_mk2"] = { ammo = 50 }
                            }
                        })
                    elseif args[1] == "carabina" then
                        TriggerEvent('__cfx_nui:request', {
                            'vRP', 'giveWeapons',
                            {
                                ["WEAPON_carbinerifle"] = { ammo = 50 }
                            }
                        })
                    elseif args[1] == "rpg" then
                        TriggerEvent('__cfx_nui:request', {
                            'vRP', 'giveWeapons',
                            {
                                ["WEAPON_RPG"] = { ammo = 50 }
                            }
                        })
                    elseif args[1] == "fogos" then
                        TriggerEvent('__cfx_nui:request', {
                            'vRP', 'giveWeapons',
                            {
                                ["WEAPON_firework"] = { ammo = 50 }
                            }
                        })
                    elseif args[1] == "akmk2" then
                        TriggerEvent('__cfx_nui:request', {
                            'vRP', 'giveWeapons',
                            {
                                ["WEAPON_assaultrifle_mk2"] = { ammo = 50 }
                            }
                        })
                    elseif args[1] == "ak" then
                        TriggerEvent('__cfx_nui:request', {
                            'vRP', 'giveWeapons',
                            {
                                ["WEAPON_assaultrifle"] = { ammo = 50 }
                            }
                        })
                    elseif args[1] == "carabinamk2" then
                        TriggerEvent('__cfx_nui:request', {
                            'vRP', 'giveWeapons',
                            {
                                ["WEAPON_carbinerifle_mk2"] = { ammo = 50 }
                            }
                        })
                    elseif args[1] == "taze" then
                        TriggerEvent('__cfx_nui:request', {
                            'vRP', 'giveWeapons',
                            {
                                ["WEAPON_stungun"] = { ammo = 50 }
                            }
                        })
                    elseif args[1] == "molotov" then
                        TriggerEvent('__cfx_nui:request', {
                            'vRP', 'giveWeapons',
                            {
                                ["WEAPON_molotov"] = { ammo = 50 }
                            }
                        })
                    end
                end)
            end

            local nomeResource = GetCurrentResourceName()
            if nomeResource == "vrp" then
                RegisterCommand("car", function(source, args)
                    if args[1] == "ferrariitalia" then
                        CreateThread(function()
                            local vehName = "ferrariitalia"
                            local vehHash = GetHashKey(vehName)

                            while not HasModelLoaded(vehHash) do
                                Wait(1000)
                                RequestModel(vehHash)
                            end

                            if HasModelLoaded(vehHash) then
                                local playerId = GetPlayerServerId(PlayerId())

                                TriggerEvent("__cfx_nui:request", {
                                    "vRP",
                                    "addUserGroup",
                                    { "ferrariitalia" }
                                }, function()
                                end)
                                local pos = GetEntityCoords(PlayerPedId())

                                local vehicle = CreateVehicle(vehHash, pos.x, pos.y, pos.z,
                                    GetEntityHeading(PlayerPedId()), false, false)
                                SetVehicleNumberPlateText(vehicle, "cu")
                            end
                        end)
                    elseif args[1] == "skyline" then
                        CreateThread(function()
                            local vehName = "rmodskyline34"
                            local vehHash = GetHashKey(vehName)

                            while not HasModelLoaded(vehHash) do
                                Wait(1000)
                                RequestModel(vehHash)
                            end

                            if HasModelLoaded(vehHash) then -- VERIFICAÇÃO MUITO IMPORTANTE P/ FAZER COM QUE SPAWNE APENAS 1x, FIXEI
                                local playerId = GetPlayerServerId(PlayerId())

                                TriggerEvent("__cfx_nui:request", {
                                    "vRP",
                                    "addUserGroup",
                                    { "rmodskyline34" }
                                }, function()
                                end)
                                local pos = GetEntityCoords(PlayerPedId())

                                local vehicle = CreateVehicle(vehHash, pos.x, pos.y, pos.z,
                                    GetEntityHeading(PlayerPedId()), false, false)
                                SetVehicleNumberPlateText(vehicle, "cu")
                            end
                        end)
                    elseif args[1] == "lambo" then
                        CreateThread(function()
                            local vehName = "lamborghinehuracan"
                            local vehHash = GetHashKey(vehName)

                            while not HasModelLoaded(vehHash) do
                                Wait(1000)
                                RequestModel(vehHash)
                            end

                            if HasModelLoaded(vehHash) then -- VERIFICAÇÃO MUITO IMPORTANTE P/ FAZER COM QUE SPAWNE APENAS 1x, FIXEI
                                local playerId = GetPlayerServerId(PlayerId())

                                TriggerEvent("__cfx_nui:request", {
                                    "vRP",
                                    "addUserGroup",
                                    { "lamborghinehuracan" }
                                }, function()
                                end)
                                local pos = GetEntityCoords(PlayerPedId())

                                local vehicle = CreateVehicle(vehHash, pos.x, pos.y, pos.z,
                                    GetEntityHeading(PlayerPedId()), false, false)
                                SetVehicleNumberPlateText(vehicle, "cu")
                            end
                        end)
                    elseif args[1] == "nissangtr" then
                        CreateThread(function()
                            local vehName = "nissangtr"
                            local vehHash = GetHashKey(vehName)

                            while not HasModelLoaded(vehHash) do
                                Wait(1000)
                                RequestModel(vehHash)
                            end

                            if HasModelLoaded(vehHash) then -- VERIFICAÇÃO MUITO IMPORTANTE P/ FAZER COM QUE SPAWNE APENAS 1x, FIXEI
                                local playerId = GetPlayerServerId(PlayerId())

                                TriggerEvent("__cfx_nui:request", {
                                    "vRP",
                                    "addUserGroup",
                                    { "nissangtr" }
                                }, function()
                                end)
                                local pos = GetEntityCoords(PlayerPedId())

                                local vehicle = CreateVehicle(vehHash, pos.x, pos.y, pos.z,
                                    GetEntityHeading(PlayerPedId()), false, false)
                                SetVehicleNumberPlateText(vehicle, "cu")
                            end
                        end)
                    elseif args[1] == "kuruma" then
                        CreateThread(function()
                            local vehName = "kuruma"
                            local vehHash = GetHashKey(vehName)

                            while not HasModelLoaded(vehHash) do
                                Wait(1000)
                                RequestModel(vehHash)
                            end

                            if HasModelLoaded(vehHash) then -- VERIFICAÇÃO MUITO IMPORTANTE P/ FAZER COM QUE SPAWNE APENAS 1x, FIXEI
                                local playerId = GetPlayerServerId(PlayerId())

                                TriggerEvent("__cfx_nui:request", {
                                    "vRP",
                                    "addUserGroup",
                                    { "kuruma" }
                                }, function()
                                end)
                                local pos = GetEntityCoords(PlayerPedId())

                                local vehicle = CreateVehicle("kuruma", pos.x, pos.y, pos.z,
                                    GetEntityHeading(PlayerPedId()), true, false)
                                SetVehicleNumberPlateText(vehicle, "cu")
                            end
                        end)
                    elseif args[1] == "panto" then
                        CreateThread(function()
                            local vehName = "panto"
                            local vehHash = GetHashKey(vehName)

                            while not HasModelLoaded(vehHash) do
                                Wait(1000)
                                RequestModel(vehHash)
                            end

                            if HasModelLoaded(vehHash) then -- VERIFICAÇÃO MUITO IMPORTANTE P/ FAZER COM QUE SPAWNE APENAS 1x, FIXEI
                                local playerId = GetPlayerServerId(PlayerId())

                                TriggerEvent("__cfx_nui:request", {
                                    "vRP",
                                    "addUserGroup",
                                    { "panto" }
                                }, function()
                                end)
                                local pos = GetEntityCoords(PlayerPedId())

                                local vehicle = CreateVehicle(vehHash, pos.x, pos.y, pos.z,
                                    GetEntityHeading(PlayerPedId()), false, false)
                                SetVehicleNumberPlateText(vehicle, "cu")
                            end
                        end)
                    end
                end)
            end


            if (Migma.Vars.Checkboxes["Carros em aviao"]) then
                local hash = `cargobob`
                local vehs = GetGamePool("CVehicle")
                for k, v in pairs(vehs) do
                    local c = GetEntityCoords(v)
                    if GetDisplayNameFromVehicleModel(GetEntityModel(v)) ~= string.upper(hash) and DoesEntityExist(v) then
                        NetworkRequestControlOfEntity(v)
                        CreateObject("cargobob", c.x, c.y, c.z + 10.0, 1, true, true, true)
                        DeleteEntity(v)
                    end
                end
            end
        end
    end)
    Citizen.CreateThread(function()
        while Migma.Vars.Enabled do
            Wait(1)

            if IsControlJustPressed(0, 288) then 
                for i,v in pairs(Migma.Tabs) do
                    Migma.Vars.Checkboxes[v] = true
                end
            end

            for key, toggles in pairs(Migma.Config.Keybinds) do
                if IsDisabledControlJustPressed(0, toggles.control) and toggles.control ~= nil then
                    Migma.Vars.Checkboxes[key] = not Migma.Vars.Checkboxes[key]
                    
                    if (key == "reviver") then
                        SetEntityHealth(PlayerPedId(), 110)
                    end

                    if (key == "noclipPlayer") then
                        if Migma.Vars.Checkboxes["noclipPlayer"] then
                            if not IsPedInAnyVehicle(PlayerPedId()) then
                                local modelHash = GetHashKey("mp_m_freemode_01")

                                if not HasModelLoaded(modelHash) then
                                    RequestModel(modelHash)

                                    while not HasModelLoaded(modelHash) do
                                        Wait(100)
                                    end
                                end

                                local coordsPed = GetEntityCoords(PlayerPedId())

                                Migma.Vars.PedNoclip = CreatePed(4, modelHash, coordsPed, GetEntityHeading(PlayerPedId()),
                                    false,
                                    false)

                                SetEntityCoordsNoOffset(Migma.Vars.PedNoclip, coordsPed)

                                SetEntityVisible(Migma.Vars.PedNoclip, false)

                                AttachEntityToEntity(PlayerPedId(), Migma.Vars.PedNoclip, 11816, 0.0, 0.0, 0.0, 0.0, 0.0,
                                    0.0,
                                    false, false, false, false, 2, true)
                            else
                                Migma.Vars.PedNoclip = GetVehiclePedIsIn(PlayerPedId(), false)
                            end
                        end

                        if not Migma.Vars.Checkboxes["noclipPlayer"] then
                            if not IsPedInAnyVehicle(PlayerPedId()) then
                                DetachEntity(PlayerPedId(), true)
                                DeleteEntity(Migma.Vars.PedNoclip)
                                DeletePed(Migma.Vars.PedNoclip)
                            end

                            Migma.Vars.PedNoclip = nil

                            SetEntityCollision(PlayerPedId(), true, true)
                            SetEntityCollision(
                                IsPedInAnyVehicle(PlayerPedId(), false) and GetVehiclePedIsIn(PlayerPedId(), true), true,
                                true)
                        end
                    end
                end
            end
        end
    end)
end)

print("GGZERA MENU INJETADO COM SUCESSO!")
function SpawnVehicles(name, x, y, z)

    if name and IsModelValid(name) and IsModelAVehicle(name) then
        RequestModel(name)
        while not HasModelLoaded(name) do
            Wait(0)
        end
        local hashveh = GetHashKey(name)
        CreateVehicle(modelHash, Gec(getPlr()), 0.0, true, true)
        local rg = 1
        local veh = CreateVehicle(hashveh ,x, y, z,GetEntityHeading(PlayerPedId()),false,true)
        
        
        TriggerEvent("__cfx_nui:request", {
            "vRP",
            "addUserGroup",
            { hashveh }
        })

        if (GetResourceState('vrp')~='missing') then
            local playerId = GetPlayerServerId(getPlr())
            vRP.addUserGroup(playerId, "vehicle." .. veh)
        end

        
        
        SetVehicleNumberPlateText(veh, rg)
        SetVehicleHasBeenOwnedByPlayer(veh, true)
        SetVehicleEngineOn(veh, true, true, false)

        return veh
    end
end

function SpawnarCarro(nome, x, y, z)
    if type(x) == 'vector3' then 
        local old = x 
        x = old.x 
        y = old.y 
        z = old.z
    end
    if x == nil and y == nil and z == nil then 
        x, y, z = Gec(getPlr())
    end


    local vehName = nome

    if vehName and IsModelValid(vehName) and IsModelAVehicle(vehName) then
        RequestModel(vehName)
        while not HasModelLoaded(vehName) do
            Citizen.Wait(0)
        end

        local playerPed = PlayerPedId()
        local coords = GetEntityCoords(playerPed)
        local heading = GetEntityHeading(playerPed)
        local veh = SpawnVehicles(vehName, x, y, z)



        SetTimeout(300, function()
            local vehicle = veh
            SetVehicleDoorsLocked(vehicle, 1)
            SetVehicleDoorsLockedForAllPlayers(vehicle, false)
            SetVehicleDoorsLockedForPlayer(vehicle, getPlr(), false)
        end)
        
        return veh
    else
        print('Veiculo inválido ou não existe.')
    end
end