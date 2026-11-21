local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local StarterGui = game:GetService("StarterGui")

local player = Players.LocalPlayer
local FarmAtivo = false

-- CONFIGURAÇÕES
local NOME_VFX = "SurgeWarningVFX" 

-- Variável de memória: guarda o último VFX que já fomos
local ultimoVFX = nil 

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
        print("[Magma Auto] Ligado!")
    else
        botao.Text = "Farm Magma: OFF"
        botao.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
        print("[Magma Auto] Desligado.")
        ultimoVFX = nil -- Reseta a memória ao desligar
    end
end)

-- ==========================================
-- 3. LÓGICA DE TELEPORTE INTELIGENTE
-- ==========================================
local function procurarETeleportar()
    local character = player.Character
    if not character then return end
    local rootPart = character:FindFirstChild("HumanoidRootPart")
    if not rootPart then return end

    -- Procura o efeito no mapa
    local efeito = Workspace:FindFirstChild(NOME_VFX, true)

    -- Se achou o efeito E ele é DIFERENTE do último que a gente já foi
    if efeito and efeito ~= ultimoVFX then
        
        -- Pega a posição do efeito
        local posicaoAlvo = nil
        if efeito:IsA("BasePart") then
            posicaoAlvo = efeito.Position
        elseif efeito:IsA("Model") then
            local partePrincipal = efeito.PrimaryPart or efeito:FindFirstChildWhichIsA("BasePart")
            if partePrincipal then
                posicaoAlvo = partePrincipal.Position
            end
        end

        -- Se conseguiu achar uma posição, teleporta
        if posicaoAlvo then
            print("[Magma Auto] Novo evento detectado! Teleportando uma única vez...")
            
            -- Salva na memória para não teleportar de novo nesse mesmo evento
            ultimoVFX = efeito 
            
            -- Faz o teleporte (só uma vez)
            rootPart.CFrame = CFrame.new(posicaoAlvo + Vector3.new(0, 3, 0))
            
            StarterGui:SetCore("SendNotification", {
                Title = "Farm Magma",
                Text = "Evento encontrado! Teleportado.",
                Duration = 3
            })
        end
    end
    
    -- Limpa a memória se o efeito sumiu do mapa (evento acabou)
    if ultimoVFX and not ultimoVFX.Parent then
        ultimoVFX = nil
    end
end

-- ==========================================
-- 4. LOOP DE VIGILÂNCIA
-- ==========================================
while task.wait(0.2) do
    if FarmAtivo then
        procurarETeleportar()
    end
end
