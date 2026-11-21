local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")

local player = Players.LocalPlayer

-- CONFIGURAÇÕES
local NOME_ITEM = "Magma crack"
local VELOCIDADE = 30 
local FarmAtivo = false

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
botao.Size = UDim2.new(0, 150, 0, 50)
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
-- 2. FUNÇÃO DO BOTÃO (ON/OFF)
-- ==========================================
botao.MouseButton1Click:Connect(function()
    FarmAtivo = not FarmAtivo 
    if FarmAtivo then
        botao.Text = "Farm Magma: ON"
        botao.BackgroundColor3 = Color3.fromRGB(50, 200, 50)
        print("[Magma Auto] Ligado! Procurando fogo...")
    else
        botao.Text = "Farm Magma: OFF"
        botao.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
        print("[Magma Auto] Desligado.")
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
-- 3. INTELIGÊNCIA: ACHAR O MAGMA ATIVO
-- ==========================================
local function encontrarMagmaAtivo()
    local character = player.Character
    if not character then return nil end
    
    local rootPart = character:FindFirstChild("HumanoidRootPart")
    if not rootPart then return nil end

    local melhorAlvo = nil
    local menorDistancia = math.huge

    -- Procura todos os "Magma crack" no mapa
    for _, obj in pairs(Workspace:GetDescendants()) do
        if obj.Name == NOME_ITEM and obj:IsA("BasePart") then
            
            -- 🔥 O SEGREDO ESTÁ AQUI 🔥
            -- Pega a cor do objeto
            local cor = obj.Color
            local brilho = obj.Material -- Pega o material (Neon, etc)
            
            -- Verifica se a cor NÃO é preta (ignora os buracos)
            -- Se for muito escuro (R, G e B menores que 0.1), ele ignora.
            local isPreto = (cor.R < 0.1 and cor.G < 0.1 and cor.B < 0.1)
            
            -- Também verifica se não está 100% invisível
            local isInvisivel = (obj.Transparency >= 1)

            if not isPreto and not isInvisivel then
                -- Se chegou aqui, é um fogo real!
                local distancia = (obj.Position - rootPart.Position).Magnitude
                if distancia < menorDistancia then
                    menorDistancia = distancia
                    melhorAlvo = obj
                end
            end
        end
    end
    return melhorAlvo
end

-- ==========================================
-- 4. LOOP PRINCIPAL DO FARM
-- ==========================================
while task.wait(0.3) do
    if FarmAtivo then
        local character = player.Character
        if character then
            local humanoid = character:FindFirstChild("Humanoid")
            if humanoid then
                humanoid.WalkSpeed = VELOCIDADE
                
                local alvo = encontrarMagmaAtivo()
                
                if alvo then
                    print("[Magma Auto] Fogo ativo encontrado! Movendo...")
                    humanoid:MoveTo(alvo.Position)
                    
                    -- Continua indo até ele enquanto ele não sumir (for destruído) ou ficar preto
                    while alvo and alvo.Parent and FarmAtivo do
                        local corAtual = alvo.Color
                        if (corAtual.R < 0.1 and corAtual.G < 0.1 and corAtual.B < 0.1) then break end -- Se virou preto, para
                        
                        humanoid:MoveTo(alvo.Position)
                        task.wait(0.2)
                    end
                end
            end
        end
    end
end
