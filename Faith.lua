local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")

local player = Players.LocalPlayer

-- CONFIGURAÇÕES
local NOME_ITEM = "Magma crack"
local VELOCIDADE = 30 

-- Variável de controle do botão
local FarmAtivo = false

-- ==========================================
-- 1. CRIANDO A INTERFACE (BOTÃO)
-- ==========================================
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "MagmaFarmGUI"
screenGui.ResetOnSpawn = false
screenGui.Parent = player:WaitForChild("PlayerGui")

local botao = Instance.new("TextButton")
botao.Name = "BotaoToggle"
botao.Parent = screenGui
botao.Size = UDim2.new(0, 150, 0, 50)
botao.Position = UDim2.new(0, 20, 0, 200) -- Posição na tela
botao.BackgroundColor3 = Color3.fromRGB(200, 50, 50) -- Vermelho (Desligado)
botao.TextColor3 = Color3.fromRGB(255, 255, 255)
botao.Font = Enum.Font.GothamBold
botao.TextSize = 16
botao.Text = "Farm: DESLIGADO"
botao.BorderSizePixel = 0

-- Borda arredondada no botão
local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(0, 10)
corner.Parent = botao

-- ==========================================
-- 2. FUNÇÃO DO BOTÃO (ON/OFF)
-- ==========================================
botao.MouseButton1Click:Connect(function()
    FarmAtivo = not FarmAtivo -- Inverte o valor (se é true vira false, se é false vira true)
    
    if FarmAtivo then
        botao.Text = "Farm: LIGADO"
        botao.BackgroundColor3 = Color3.fromRGB(50, 200, 50) -- Verde (Ligado)
        print("[Magma Auto] Farm LIGADO")
    else
        botao.Text = "Farm: DESLIGADO"
        botao.BackgroundColor3 = Color3.fromRGB(200, 50, 50) -- Vermelho (Desligado)
        print("[Magma Auto] Farm DESLIGADO")
        
        -- Para o personagem quando desliga
        local character = player.Character
        if character then
            local humanoid = character:FindFirstChild("Humanoid")
            if humanoid then
                humanoid:MoveTo(character.HumanoidRootPart.Position) -- Para de andar
            end
        end
    end
end)

-- ==========================================
-- 3. LOOP PRINCIPAL DO FARM
-- ==========================================
print("[Magma Auto] Script iniciado. Procurando por: " .. NOME_ITEM)

while task.wait(0.5) do
    -- Só executa a lógica se o botão estiver LIGADO
    if FarmAtivo then
        local character = player.Character
        if character then
            local humanoid = character:FindFirstChild("Humanoid")
            local rootPart = character:FindFirstChild("HumanoidRootPart")

            if humanoid and rootPart then
                humanoid.WalkSpeed = VELOCIDADE
                
                -- Procura o item
                local item = Workspace:FindFirstChild(NOME_ITEM, true)
                
                if item then
                    print("[Magma Auto] Item encontrado! Movendo...")
                    
                    -- Anda até o item
                    humanoid:MoveTo(item.Position)
                    
                    -- Enquanto o item existir, continua atualizando a direção
                    while item and item.Parent and FarmAtivo do
                        humanoid:MoveTo(item.Position)
                        task.wait(0.2)
                    end
                end
            end
        end
    end
end
