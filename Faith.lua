local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local StarterGui = game:GetService("StarterGui")

local player = Players.LocalPlayer
local FarmAtivo = false

-- CONFIGURAÇÕES
local NOME_VFX = "SurgeWarningVFX" -- O nome que você achou

-- ==========================================
-- 1. INTERFACE (BOTÃO)
-- ==========================================
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "MagmaFarmGUI"
screenGui.ResetOnSpawn = false
screenGui.Parent = player:WaitForChild("PlayerGui")

local botao = Instance.new("TextButton")
botao.Name = "BotaoToggle"
botao.Parent = screenGui
botao.Size = UDim2.new(0, 180, 0, 50)
botao.Position = UDim2.new(0, 20, 0, 200)
botao.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
botao.TextColor3 = Color3.fromRGB(255, 255, 255)
botao.Font = Enum.Font.GothamBold
botao.TextSize = 16
botao.Text = "Farm Magma: OFF"
botao.BorderSizePixel = 0

local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(0, 10)
corner.Parent = botao

-- ==========================================
-- 2. FUNÇÃO DO BOTÃO
-- ==========================================
botao.MouseButton1Click:Connect(function()
    FarmAtivo = not FarmAtivo 
    if FarmAtivo then
        botao.Text = "Farm Magma: ON"
        botao.BackgroundColor3 = Color3.fromRGB(50, 200, 50)
        print("[Magma Auto] Ligado! Procurando por " .. NOME_VFX)
    else
        botao.Text = "Farm Magma: OFF"
        botao.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
        print("[Magma Auto] Desligado.")
    end
end)

-- ==========================================
-- 3. LÓGICA DE TELEPORTE
-- ==========================================
local function procurarETeleportar()
    local character = player.Character
    if not character then return end
    local rootPart = character:FindFirstChild("HumanoidRootPart")
    if not rootPart then return end

    -- Procura o SurgeWarningVFX no mapa inteiro (dentro do Workspace)
    local efeito = Workspace:FindFirstChild(NOME_VFX, true)

    if efeito then
        -- Se o efeito for uma Part (bloco), teleporta direto pra cima dele
        if efeito:IsA("BasePart") then
            print("[Magma Auto] Surto detectado! Teleportando...")
            
            -- +3 no Y para você não ficar preso dentro do chão
            rootPart.CFrame = CFrame.new(efeito.Position + Vector3.new(0, 3, 0))
            
            StarterGui:SetCore("SendNotification", {
                Title = "Farm Magma",
                Text = "Evento encontrado! Teleportado.",
                Duration = 3
            })
        else
            -- Se for um Model (vários blocos juntos), pega a posição principal dele
            print("[Magma Auto] Surto detectado (Model)! Teleportando...")
            
            -- Tenta pegar a parte principal do Model
            local partePrincipal = efeito.PrimaryPart or efeito:FindFirstChildWhichIsA("BasePart")
            if partePrincipal then
                rootPart.CFrame = CFrame.new(partePrincipal.Position + Vector3.new(0, 3, 0))
                
                StarterGui:SetCore("SendNotification", {
                    Title = "Farm Magma",
                    Text = "Evento encontrado! Teleportado.",
                    Duration = 3
                })
            end
        end
    end
end

-- ==========================================
-- 4. LOOP DE VIGILÂNCIA
-- ==========================================
-- Fica checando o tempo todo. Se o botão estiver ON, ele procura o SurgeWarningVFX
while task.wait(0.2) do
    if FarmAtivo then
        procurarETeleportar()
    end
end
