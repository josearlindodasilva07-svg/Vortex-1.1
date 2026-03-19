--[[
	WARNING: Heads up! This script has not been verified by ScriptBlox. Use at your own risk!
]]
local Libary = loadstring(game:HttpGet("https://pastefy.app/TYVuPNOS/raw"))()
workspace.FallenPartsDestroyHeight = -math.huge

local Window = Libary:MakeWindow({
    Title = "Vortex HUB",
    SubTitle = "Godenot",
    LoadText = "Vortex ARQUIVO",
    Flags = "Vortexhub_Broookhaven",
    Theme = "Dark"  -- Força tema escuro
})
Window:AddMinimizeButton({
    Button = { 
        Image = "rbxassetid://79844735009091",
        BackgroundTransparency = 0,
        Size = UDim2.new(0, 50, 0, 50)
    },
    Corner = { CornerRadius = UDim.new(35, 1) },
})

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local Workspace = game:GetService("Workspace")
local Teams = game:GetService("Teams")
local Camera = workspace.CurrentCamera
local LocalPlayer = Players.LocalPlayer

local savedPositions = {}
local deletedItems = {}
local isTeleporting = false
local teleportSpeed = 60
local infiniteJumpEnabled = false
local SpeedEnabled = false
local WalkSpeedAmount = 16
local JumpEnabled = false
local JumpAmount = 50
local ESP = {Enabled=false, ShowBoxes=true, ShowNames=true, ShowTracers=true, UseTeamColors=true, ColorMode="🌈 Arco-Íris"}
local ESPObjects = {}

-- ========== INSTANT CLICK ==========
local ProximityPromptService = game:GetService("ProximityPromptService")
local InstantInteract = false
local PromptConnection

local function toggleInstantClick(value)
    InstantInteract = value
    if InstantInteract then
        PromptConnection = ProximityPromptService.PromptButtonHoldBegan:Connect(function(prompt)
            if InstantInteract and prompt then
                fireproximityprompt(prompt)
            end
        end)
    else
        if PromptConnection then
            PromptConnection:Disconnect()
            PromptConnection = nil
        end
    end
end

local function createWaveCleaner()
    local player = Players.LocalPlayer
    local playerGui = player:WaitForChild("PlayerGui")
    if playerGui:FindFirstChild("WaveCleaner") then playerGui.WaveCleaner:Destroy() end
    
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "WaveCleaner"
    screenGui.ResetOnSpawn = false
    screenGui.Parent = playerGui
    
    local main = Instance.new("Frame")
    main.Parent = screenGui
    main.Size = UDim2.new(0, 240, 0, 65)
    main.Position = UDim2.new(0.5, -120, 0.15, 0)
    main.BackgroundColor3 = Color3.fromRGB(20,20,20)
    main.Active = true
    main.Draggable = true
    Instance.new("UICorner", main).CornerRadius = UDim.new(0,18)
    
    local stroke = Instance.new("UIStroke", main)
    stroke.Color = Color3.fromRGB(0,170,255)
    stroke.Thickness = 2
    stroke.Transparency = 0.2
    
    local button = Instance.new("TextButton")
    button.Parent = main
    button.Size = UDim2.new(0.78,0,0.65,0)
    button.Position = UDim2.new(0.08,0,0.2,0)
    button.BackgroundColor3 = Color3.fromRGB(30,30,30)
    button.Text = "🗑 Apagar Waves"
    button.TextColor3 = Color3.fromRGB(255,255,255)
    button.Font = Enum.Font.GothamBold
    button.TextSize = 17
    button.AutoButtonColor = false
    Instance.new("UICorner", button).CornerRadius = UDim.new(0,14)
    
    local close = Instance.new("TextButton")
    close.Parent = main
    close.Size = UDim2.new(0,22,0,22)
    close.Position = UDim2.new(1,-30,0,6)
    close.BackgroundColor3 = Color3.fromRGB(255,70,70)
    close.Text = "✕"
    close.TextColor3 = Color3.new(1,1,1)
    close.Font = Enum.Font.GothamBold
    close.TextSize = 13
    close.AutoButtonColor = false
    Instance.new("UICorner", close).CornerRadius = UDim.new(1,0)
    
    button.MouseEnter:Connect(function()
        TweenService:Create(button, TweenInfo.new(0.15), {
            BackgroundColor3 = Color3.fromRGB(45,45,45),
            Size = UDim2.new(0.82,0,0.7,0)
        }):Play()
    end)
    
    button.MouseLeave:Connect(function()
        TweenService:Create(button, TweenInfo.new(0.15), {
            BackgroundColor3 = Color3.fromRGB(30,30,30),
            Size = UDim2.new(0.78,0,0.65,0)
        }):Play()
    end)
    
    close.MouseEnter:Connect(function()
        TweenService:Create(close, TweenInfo.new(0.15), {
            BackgroundColor3 = Color3.fromRGB(255,100,100)
        }):Play()
    end)
    
    close.MouseLeave:Connect(function()
        TweenService:Create(close, TweenInfo.new(0.15), {
            BackgroundColor3 = Color3.fromRGB(255,70,70)
        }):Play()
    end)
    
    button.MouseButton1Click:Connect(function()
        local folder = workspace:FindFirstChild("Waves")
        if folder then
            local objects = folder:GetChildren()
            local count = #objects
            for _, v in ipairs(objects) do
                v:Destroy()
                task.wait()
            end
            button.Text = "✓ "..count.." deletados"
            button.BackgroundColor3 = Color3.fromRGB(0,170,255)
        else
            button.Text = "Sem pasta"
            button.BackgroundColor3 = Color3.fromRGB(255,140,0)
        end
        task.wait(1.3)
        button.Text = "🗑 Apagar Waves"
        button.BackgroundColor3 = Color3.fromRGB(30,30,30)
    end)
    
    close.MouseButton1Click:Connect(function()
        TweenService:Create(main, TweenInfo.new(0.25), {
            Size = UDim2.new(0,0,0,0),
            BackgroundTransparency = 1
        }):Play()
        task.wait(0.25)
        screenGui:Destroy()
    end)
    
    main.Size = UDim2.new(0,0,0,0)
    TweenService:Create(main, TweenInfo.new(0.35, Enum.EasingStyle.Back), {
        Size = UDim2.new(0,240,0,65)
    }):Play()
end

local function hasTeams()
    if #Teams:GetTeams() > 0 then return true end
    for _, p in ipairs(Players:GetPlayers()) do
        if p.TeamColor ~= BrickColor.new("Medium stone grey") then return true end
    end
    return false
end
local GAME_HAS_TEAMS = hasTeams()

local function getRainbowColor(t)
    return Color3.new(
        math.sin(t * 2) * 0.5 + 0.5,
        math.sin(t * 2 + 2) * 0.5 + 0.5,
        math.sin(t * 2 + 4) * 0.5 + 0.5
    )
end

local function getPlayerTeamColor(player)
    if player.TeamColor and player.TeamColor ~= BrickColor.new("Medium stone grey") then
        return player.TeamColor.Color
    end
    if player.Team and player.Team.TeamColor then
        return player.Team.TeamColor.Color
    end
    return nil
end

local function getPlayerColor(player, t)
    -- Se tiver times e a opção estiver ativada
    if GAME_HAS_TEAMS and ESP.UseTeamColors then
        local teamColor = getPlayerTeamColor(player)
        if teamColor then return teamColor end
    end
    
    -- Cores manuais
    if ESP.ColorMode == "Vermelho" then
        return Color3.fromRGB(255, 0, 0)
    elseif ESP.ColorMode == "Azul" then
        return Color3.fromRGB(0, 0, 255)
    elseif ESP.ColorMode == "Verde" then
        return Color3.fromRGB(0, 255, 0)
    elseif ESP.ColorMode == "Amarelo" then
        return Color3.fromRGB(255, 255, 0)
    elseif ESP.ColorMode == "Roxo" then
    return Color3.fromRGB(138, 43, 226)  -- Azul violeta (roxo verdadeiro)
    elseif ESP.ColorMode == "Laranja" then
        return Color3.fromRGB(255, 165, 0)
    elseif ESP.ColorMode == "Branco" then
        return Color3.fromRGB(255, 255, 255)
    else -- Arco-Íris
        return getRainbowColor(t)
    end
end

local function hideAll(data)
    if data then
        if data.Box then data.Box.Visible = false end
        if data.Name then data.Name.Visible = false end
        if data.Tracer then data.Tracer.Visible = false end
    end
end

RunService.RenderStepped:Connect(function()
    if not ESP.Enabled then
        for _, data in pairs(ESPObjects) do
            hideAll(data)
        end
        return
    end
    
    local t = tick()
    local center = Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y)
    
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer then
            local char = player.Character
            local hum = char and char:FindFirstChildOfClass("Humanoid")
            if char and hum and hum.Health > 0 then
                local success, cf, size = pcall(function() return char:GetBoundingBox() end)
                if success and cf and size then
                    local points = {}
                    local onScreen = true
                    local half = size/2
                    
                    for x = -1,1,2 do
                        for y = -1,1,2 do
                            for z = -1,1,2 do
                                local corner = cf * Vector3.new(half.X*x, half.Y*y, half.Z*z)
                                local scr, vis = Camera:WorldToViewportPoint(corner)
                                if not vis then onScreen = false end
                                table.insert(points, Vector2.new(scr.X, scr.Y))
                            end
                        end
                    end
                    
                    if onScreen then
                        if not ESPObjects[player] then
                            ESPObjects[player] = {
                                Box = Drawing.new("Square"),
                                Name = Drawing.new("Text"),
                                Tracer = Drawing.new("Line")
                            }
                            ESPObjects[player].Box.Thickness = 2
                            ESPObjects[player].Box.Filled = false
                            ESPObjects[player].Name.Center = true
                            ESPObjects[player].Name.Outline = true
                            ESPObjects[player].Name.Size = 16
                            ESPObjects[player].Name.Font = 2
                            ESPObjects[player].Tracer.Thickness = 1
                        end
                        
                        local data = ESPObjects[player]
                        
                        local minX, minY, maxX, maxY = math.huge, math.huge, -math.huge, -math.huge
                        for _, pt in ipairs(points) do
                            minX = math.min(minX, pt.X)
                            minY = math.min(minY, pt.Y)
                            maxX = math.max(maxX, pt.X)
                            maxY = math.max(maxY, pt.Y)
                        end
                        
                        local color = getPlayerColor(player, t)
                        local boxWidth = maxX - minX
                        local boxHeight = maxY - minY
                        local slimWidth = boxWidth * 0.7
                        local slimX = minX + (boxWidth - slimWidth) / 2
                        
                        if ESP.ShowBoxes then
                            data.Box.Visible = true
                            data.Box.Position = Vector2.new(slimX, minY)
                            data.Box.Size = Vector2.new(slimWidth, boxHeight)
                            data.Box.Color = color
                        else
                            data.Box.Visible = false
                        end
                        
                        if ESP.ShowNames then
                            data.Name.Visible = true
                            data.Name.Text = player.Name
                            data.Name.Position = Vector2.new(slimX + slimWidth/2, minY - 20)
                            data.Name.Color = color
                        else
                            data.Name.Visible = false
                        end
                        
                        if ESP.ShowTracers then
                            data.Tracer.Visible = true
                            data.Tracer.From = center
                            data.Tracer.To = Vector2.new(slimX + slimWidth/2, maxY)
                            data.Tracer.Color = color
                        else
                            data.Tracer.Visible = false
                        end
                    elseif ESPObjects[player] then
                        hideAll(ESPObjects[player])
                    end
                end
            elseif ESPObjects[player] then
                hideAll(ESPObjects[player])
            end
        end
    end
end)

Players.PlayerRemoving:Connect(function(p)
    if ESPObjects[p] then
        ESPObjects[p].Box:Remove()
        ESPObjects[p].Name:Remove()
        ESPObjects[p].Tracer:Remove()
        ESPObjects[p] = nil
    end
end)

local function teleportWithFlight(targetPos)
    if isTeleporting then return end
    local char = LocalPlayer.Character
    if not char or not char:FindFirstChild("HumanoidRootPart") then return end
    local hrp = char.HumanoidRootPart
    isTeleporting = true
    
    local distance = (targetPos - hrp.Position).Magnitude
    local travelTime = distance / teleportSpeed
    
    local tween = TweenService:Create(hrp, TweenInfo.new(travelTime, Enum.EasingStyle.Quad), {
        CFrame = CFrame.new(targetPos)
    })
    tween:Play()
    
    tween.Completed:Connect(function()
        isTeleporting = false
    end)
end

local function saveCurrentPosition()
    local char = LocalPlayer.Character
    if char and char:FindFirstChild("HumanoidRootPart") then
        local hrp = char.HumanoidRootPart
        table.insert(savedPositions, hrp.Position)
        
        local marker = Instance.new("Part")
        marker.Name = "SavedPosition_" .. #savedPositions
        marker.Size = Vector3.new(2, 2, 2)
        marker.Position = hrp.Position + Vector3.new(0, 1, 0)
        marker.Anchored = true
        marker.CanCollide = false
        marker.Material = Enum.Material.Neon
        marker.Color = Color3.fromRGB(0, 255, 0)
        marker.Parent = Workspace
        
        print("✅ Posição " .. #savedPositions .. " salva!")
    end
end

local function teleportToFrontPosition()
    if #savedPositions == 0 then 
        print("❌ Nenhuma posição salva!")
        return 
    end
    
    local char = LocalPlayer.Character
    if not char or not char:FindFirstChild("HumanoidRootPart") then return end
    
    local hrp = char.HumanoidRootPart
    local lookVector = hrp.CFrame.LookVector
    local bestPos, bestDot = nil, -1
    
    for _, pos in ipairs(savedPositions) do
        local toPos = (pos - hrp.Position).Unit
        local dot = lookVector:Dot(toPos)
        if dot > 0.7 and dot > bestDot then
            bestDot = dot
            bestPos = pos
        end
    end
    
    if bestPos then
        teleportWithFlight(bestPos)
        print("✅ Teleportando para posição salva!")
    else
        print("❌ Nenhuma posição na frente!")
    end
end

local function clearAllPositions()
    for _, obj in pairs(Workspace:GetChildren()) do
        if obj.Name:find("SavedPosition") then
            obj:Destroy()
        end
    end
    savedPositions = {}
    print("🗑️ Todas as posições foram removidas!")
end

local function giveDeleteCloneTools()
    local backpack = LocalPlayer:FindFirstChild("Backpack")
    if not backpack then return end
    
    local deleteTool = Instance.new("Tool")
    deleteTool.Name = "DeleteTool"
    deleteTool.CanBeDropped = false
    deleteTool.RequiresHandle = true
    
    local handle = Instance.new("Part")
    handle.Name = "Handle"
    handle.Size = Vector3.new(1, 1, 2)
    handle.BrickColor = BrickColor.new("Bright red")
    handle.Material = Enum.Material.Neon
    handle.Parent = deleteTool
    
    deleteTool.Equipped:Connect(function()
        handle.Color = Color3.fromRGB(255, 0, 0)
    end)
    
    deleteTool.Activated:Connect(function()
        local mouse = LocalPlayer:GetMouse()
        local target = mouse.Target
        if target and target:IsA("BasePart") and not target:IsDescendantOf(LocalPlayer.Character) then
            table.insert(deletedItems, {
                Part = target:Clone(),
                CFrame = target.CFrame,
                Parent = target.Parent
            })
            target:Destroy()
            print("🗑️ Item deletado!")
        end
    end)
    deleteTool.Parent = backpack
    
    local cloneTool = Instance.new("Tool")
    cloneTool.Name = "CloneTool"
    cloneTool.CanBeDropped = false
    cloneTool.RequiresHandle = true
    
    local handle2 = Instance.new("Part")
    handle2.Name = "Handle"
    handle2.Size = Vector3.new(1, 1, 2)
    handle2.BrickColor = BrickColor.new("Bright green")
    handle2.Material = Enum.Material.Neon
    handle2.Parent = cloneTool
    
    cloneTool.Equipped:Connect(function()
        handle2.Color = Color3.fromRGB(0, 255, 0)
    end)
    
    cloneTool.Activated:Connect(function()
        local mouse = LocalPlayer:GetMouse()
        local target = mouse.Target
        if target and target:IsA("BasePart") and not target:IsDescendantOf(LocalPlayer.Character) then
            local clone = target:Clone()
            clone.Position = target.Position + Vector3.new(0, 5, 0)
            clone.Parent = Workspace
            print("📋 Item clonado!")
        end
    end)
    cloneTool.Parent = backpack
    
    print("✅ Ferramentas Delete/Clone adicionadas!")
end

local function restoreLastDeleted()
    if #deletedItems == 0 then 
        print("❌ Nada para restaurar!")
        return 
    end
    
    local last = deletedItems[#deletedItems]
    if last and last.Part then
        local clone = last.Part:Clone()
        clone.CFrame = last.CFrame
        clone.Parent = last.Parent or Workspace
        table.remove(deletedItems, #deletedItems)
        print("♻️ Último item restaurado!")
    end
end

local function giveTPTool()
    local backpack = LocalPlayer:FindFirstChild("Backpack")
    if not backpack then return end
    
    if backpack:FindFirstChild("TPTool") then
        backpack:FindFirstChild("TPTool"):Destroy()
    end
    
    local tpTool = Instance.new("Tool")
    tpTool.Name = "TPTool"
    tpTool.CanBeDropped = false
    tpTool.RequiresHandle = true
    
    local handle = Instance.new("Part")
    handle.Name = "Handle"
    handle.Size = Vector3.new(1,1,1)
    handle.Color = Color3.fromRGB(0, 170, 255)
    handle.Material = Enum.Material.Neon
    handle.Shape = Enum.PartType.Ball
    handle.Parent = tpTool
    
    tpTool.Activated:Connect(function()
        local char = LocalPlayer.Character
        if not char then return end
        
        local hrp = char:FindFirstChild("HumanoidRootPart")
        if not hrp then return end
        
        local mouse = LocalPlayer:GetMouse()
        local pos = mouse.Hit.Position
        
        -- Teleporte seguro (um pouco acima do chão)
        hrp.CFrame = CFrame.new(pos + Vector3.new(0, 3, 0))
    end)
    
    tpTool.Parent = backpack
end

local function giveSpeedTool()
    local backpack = LocalPlayer:FindFirstChild("Backpack")
    if not backpack then return end
    
    if backpack:FindFirstChild("SpeedTool") then
        backpack:FindFirstChild("SpeedTool"):Destroy()
    end
    
    local speedTool = Instance.new("Tool")
    speedTool.Name = "SpeedTool"
    speedTool.CanBeDropped = false
    speedTool.RequiresHandle = true
    
    local handle = Instance.new("Part")
    handle.Name = "Handle"
    handle.Size = Vector3.new(1,1,1)
    handle.Color = Color3.fromRGB(255, 255, 0)
    handle.Material = Enum.Material.Neon
    handle.Parent = speedTool
    
    local active = false
    local normalSpeed = nil -- guarda velocidade original

    speedTool.Activated:Connect(function()
        local char = LocalPlayer.Character
        if not char then return end
        
        local humanoid = char:FindFirstChild("Humanoid")
        if not humanoid then return end

        -- salva a velocidade original só uma vez
        if not normalSpeed then
            normalSpeed = humanoid.WalkSpeed
        end

        active = not active

        if active then
            humanoid.WalkSpeed = 60
        else
            humanoid.WalkSpeed = normalSpeed
        end
    end)
    
    speedTool.Parent = backpack
end

local function Fly()
    loadstring(game:HttpGet("https://pastebin.com/raw/mRWia1NF"))()
end

local function ShiftLock()
    loadstring(game:HttpGet("https://rawscripts.net/raw/Universal-Script-Maxus-Shiftlock-55223"))()
end

local function Invisible()
    loadstring(game:HttpGet("https://raw.githubusercontent.com/GhostPlayer352/Test4/main/Invisible%20Gui"))()
end

local function ServerHop()
    loadstring(game:HttpGet("https://pastebin.com/raw/YiydQXHz"))()
end

-- ========== PULO INFINITO ==========
UserInputService.JumpRequest:Connect(function()
    if infiniteJumpEnabled then
        local char = LocalPlayer.Character
        if char then
            local humanoid = char:FindFirstChildOfClass("Humanoid")
            if humanoid then
                humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
            end
        end
    end
end)

-- MINHAS 5 ABAS
local PlayerTab = Window:MakeTab({ Title = "Player", Icon = "rbxassetid://131153193945220" })
local ESPTab = Window:MakeTab({ Title = "ESP", Icon = "rbxassetid://13364900349" })
local TeleportTab = Window:MakeTab({ Title = "Teleport", Icon = "rbxassetid://10723415903" })
local ToolsTab = Window:MakeTab({ Title = "Tools", Icon = "rbxassetid://10734952036" })
local WavesTab = Window:MakeTab({ Title = "Waves", Icon = "rbxassetid://10723415903" })
local TrollTab = Window:MakeTab({ Title = "Players", Icon = "rbxassetid://131153193945220" })

-- ========== TELEPORT TAB ==========
TeleportTab:AddSection({ "Sistema de Teleporte" })

TeleportTab:AddButton({
    Name = "💾 Salvar Posição",
    Callback = saveCurrentPosition
})

TeleportTab:AddButton({
    Name = "🎯 Teleport para Frente",
    Callback = teleportToFrontPosition
})

TeleportTab:AddButton({
    Name = "🗑️ Limpar Posições",
    Callback = clearAllPositions
})

TeleportTab:AddSlider({
    Name = "Velocidade Teleport",
    Min = 10,
    Max = 500,
    Default = 60,
    Callback = function(v)
        teleportSpeed = v
    end
})

-- ========== TOOLS TAB ==========
ToolsTab:AddSection({ "Ferramentas" })

ToolsTab:AddButton({
    Name = "🔨 Delete/Clone Tools",
    Callback = giveDeleteCloneTools
})

ToolsTab:AddButton({
    Name = "♻️ Recuperar Último",
    Callback = restoreLastDeleted
})

ToolsTab:AddButton({
    Name = "📍 TP Tool",
    Callback = giveTPTool
})

ToolsTab:AddButton({
    Name = "⚡ Speed Tool",
    Callback = giveSpeedTool
})

-- ========== ESP TAB ==========
ESPTab:AddSection({ "Configurações ESP" })

ESPTab:AddToggle({
    Name = "👁️ Ativar ESP",
    Default = false,
    Callback = function(v)
        ESP.Enabled = v
    end
})

ESPTab:AddToggle({
    Name = "📦 Mostrar Caixas",
    Default = true,
    Callback = function(v)
        ESP.ShowBoxes = v
    end
})

ESPTab:AddToggle({
    Name = "📝 Mostrar Nomes",
    Default = true,
    Callback = function(v)
        ESP.ShowNames = v
    end
})

ESPTab:AddToggle({
    Name = "📏 Mostrar Tracers",
    Default = true,
    Callback = function(v)
        ESP.ShowTracers = v
    end
})

ESPTab:AddToggle({
    Name = "🎨 Cores dos Times",
    Default = true,
    Callback = function(v)
        ESP.UseTeamColors = v
    end
})

ESPTab:AddDropdown({
    Name = "🎨 Cor do ESP",
    Options = {"🌈 Arco-Íris", "Vermelho", "Azul", "Verde", "Amarelo", "Roxo", "Laranja", "Branco"},
    Default = "🌈 Arco-Íris",
    Callback = function(value)
        ESP.ColorMode = value
    end
})

-- ========== PLAYER TAB ==========
PlayerTab:AddSection({ "Controles do Jogador" })

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

local WalkSpeedAmount = 16
local SpeedEnabled = false
local DefaultSpeed = 16

-- Função pra aplicar velocidade
local function applySpeed()
    local char = LocalPlayer.Character
    if char then
        local hum = char:FindFirstChildOfClass("Humanoid")
        if hum then
            if not DefaultSpeed or DefaultSpeed == 16 then
                DefaultSpeed = hum.WalkSpeed -- salva a velocidade original
            end
            
            hum.WalkSpeed = SpeedEnabled and WalkSpeedAmount or DefaultSpeed
        end
    end
end

-- Quando spawnar
LocalPlayer.CharacterAdded:Connect(function(char)
    local hum = char:WaitForChild("Humanoid")
    DefaultSpeed = hum.WalkSpeed -- pega a velocidade do jogo
    task.wait(0.3)
    applySpeed()
end)

-- Slider
PlayerTab:AddSlider({
    Name = "WalkSpeed",
    Min = 16,
    Max = 400,
    Default = 16,
    Callback = function(v)
        WalkSpeedAmount = v
        if SpeedEnabled then
            applySpeed()
        end
    end
})

-- Toggle
PlayerTab:AddToggle({
    Name = "Enable Speed",
    Default = false,
    Callback = function(v)
        SpeedEnabled = v
        applySpeed()
    end
})

PlayerTab:AddSlider({
    Name = "JumpPower",
    Min = 50,
    Max = 500,
    Default = 50,
    Callback = function(v)
        JumpAmount = v
        if JumpEnabled and LocalPlayer.Character then
            local h = LocalPlayer.Character.Humanoid
            h.UseJumpPower = true
            h.JumpPower = v
        end
    end
})

PlayerTab:AddToggle({
    Name = "Enable JumpPower",
    Default = false,
    Callback = function(v)
        JumpEnabled = v
        local h = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid")
        if h then
            h.UseJumpPower = true
            h.JumpPower = v and JumpAmount or 50
        end
    end
})

PlayerTab:AddSection({ "Funções Extras" })

PlayerTab:AddToggle({
    Name = "🦘 Pulo Infinito",
    Default = false,
    Callback = function(v)
        infiniteJumpEnabled = v
    end
})

PlayerTab:AddToggle({
    Name = "⚡ Instant Click",
    Description = "Ativa interação instantânea com prompts",
    Default = false,
    Callback = toggleInstantClick
})

PlayerTab:AddButton({
    Name = "🕊️ Fly",
    Callback = Fly
})

PlayerTab:AddButton({
    Name = "🎯 Shift Lock",
    Callback = ShiftLock
})

PlayerTab:AddButton({
    Name = "👻 Invisibilidade",
    Callback = Invisible
})

PlayerTab:AddButton({
    Name = "🌍 Server Hop",
    Callback = ServerHop
})

PlayerTab:AddSection({ "─── Vortex Explorer ───" })

PlayerTab:AddButton({
    Name = "🚀 Abrir Explorer",
    Callback = function()
        loadstring(game:HttpGet("https://raw.githubusercontent.com/josearlindodasilva07-svg/Vortex-Explorer/refs/heads/main/Vortex.lua"))()
    end
})

PlayerTab:AddSection({ "─── Vortex Universal ───" })

PlayerTab:AddButton({
    Name = "🌍 Abrir Universal",
    Callback = function()
        loadstring(game:HttpGet("https://raw.githubusercontent.com/josearlindodasilva07-svg/Vortex-Universal/refs/heads/main/Vortex2.lua"))()
    end
})

PlayerTab:AddSection({ "─── Vortex Yield ───" })

PlayerTab:AddButton({
    Name = "⚡ Abrir Vortex Yield",
    Callback = function()
        loadstring(game:HttpGet("https://raw.githubusercontent.com/josearlindodasilva07-svg/Vortex-Yield/refs/heads/main/VortexYield.lua"))()
    end
})

PlayerTab:AddSection({ "─── Aimbot ───" })

PlayerTab:AddButton({
    Name = "🎯 Aimbot",
    Callback = function()
        loadstring(game:HttpGet("https://pastebin.com/raw/zPZy2AN9"))()
    end
})

-- ========== WAVES TAB ==========
WavesTab:AddSection({ "Wave Cleaner V3" })

WavesTab:AddButton({
    Name = "🌊 Abrir Wave Cleaner",
    Callback = createWaveCleaner
})

WavesTab:AddButton({
    Name = "🗑️ Apagar Waves Agora",
    Callback = function()
        local f = workspace:FindFirstChild("Waves")
        if f then 
            local c = #f:GetChildren() 
            for _, v in ipairs(f:GetChildren()) do 
                v:Destroy() 
                task.wait() 
            end 
            print("✅ "..c.." waves apagadas!") 
        else 
            print("❌ Pasta não encontrada") 
        end
    end
})

-- ===== PLAYER LIST + VIEW =====

local selectedPlayerName = nil

local function getPlayerList()
    local list = {}
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= LocalPlayer then
            table.insert(list, p.Name)
        end
    end
    return list
end

local playerDropdown = TrollTab:AddDropdown({
    Name = "Selecionar Player",
    Options = getPlayerList(),
    Default = "",
    Callback = function(v)
        selectedPlayerName = v
    end
})

TrollTab:AddButton({
    Name = "Atualizar Lista",
    Callback = function()
        playerDropdown:Set(getPlayerList())
    end
})

-- TELEPORTAR
TrollTab:AddButton({
    Name = "Teleportar até Player",
    Callback = function()
        if not selectedPlayerName then return end
        
        local target = Players:FindFirstChild(selectedPlayerName)
        if target and target.Character and target.Character:FindFirstChild("HumanoidRootPart") then
            LocalPlayer.Character.HumanoidRootPart.CFrame =
                target.Character.HumanoidRootPart.CFrame
        end
    end
})

-- SPECTAR (VIEW)
local spectando = false
local connection = nil

TrollTab:AddToggle({
    Name = "Spectar Player",
    Default = false,
    Callback = function(v)
        spectando = v

        if spectando then
            connection = RunService.RenderStepped:Connect(function()
                local target = Players:FindFirstChild(selectedPlayerName)
                if target and target.Character then
                    local hum = target.Character:FindFirstChild("Humanoid")
                    if hum then
                        Camera.CameraSubject = hum
                    end
                end
            end)
        else
            if connection then
                connection:Disconnect()
                connection = nil
            end

            local hum = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid")
            if hum then
                Camera.CameraSubject = hum
            end
        end
    end
})
