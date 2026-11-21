local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local StarterGui = game:GetService("StarterGui")

local player = Players.LocalPlayer
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
        print("[Magma Auto] Ligado! Aguardando o surto...")
    else
        botao.Text = "Farm Magma: OFF"
        botao.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
        print("[Magma Auto] Desligado.")
    end
end)

-- ==========================================
-- 3. LÓGICA DE DETECÇÃO (MENSAGEM + TELEPORTE)
-- ==========================================
-- Essa função procura o efeito de luz do fogo no mapa
local function teleportarParaOFogo()
    local character = player.Character
    if not character then return end
    local rootPart = character:FindFirstChild("HumanoidRootPart")
    if not rootPart then return end

    local alvoMagma = nil

    -- Varre o mapa procurando efeitos de fogo/luz que acabaram de spawnar
    for _, obj in pairs(Workspace:GetDescendants()) do
        -- Procura por PointLight (luz), Fire (fogo clássico) ou ParticleEmitter (fumaça/fogo)
        if obj:IsA("PointLight") or obj:IsA("Fire") or obj:IsA("ParticleEmitter") then
            -- Pega o objeto "pai" (o bloco onde o fogo está)
            local parentPart = obj.Parent
            if parentPart and parentPart:IsA("BasePart") then
                
                -- Verifica se o objeto pai está com a cor laranja/vermelha ou se tem "Magma" no nome
                local cor = parentPart.Color
                local nome = string.lower(parentPart.Name)
                
                -- Se a cor for laranja (muito Vermelho e um pouco de Verde)
                local isLaranja = (cor.R > 0.7 and cor.G > 0.2 and cor.G < 0.7)
                
                if isLaranja or string.find(nome, "magma") or string.find(nome, "fogo") or string.find(nome, "fire") then
                    alvoMagma = parentPart
                    break -- Achou o fogo, para de procurar
                end
            end
        end
    end

    -- Se achou o fogo, teleporta
    if alvoMagma then
        print("[Magma Auto] Fogo ativo detectado! Teleportando...")
        
        -- Faz o personagem teleportar exatamente para cima da parte do fogo
        -- (Adicionei +3 no eixo Y para você não ficar preso dentro do chão)
        local posicaoAlvo = alvoMagma.Position + Vector3.new(0, 3, 0)
        rootPart.CFrame = CFrame.new(posicaoAlvo)
        
        -- Notificação na tela
        StarterGui:SetCore("SendNotification", {
            Title = "Farm Magma",
            Text = "Fogo encontrado! Teleportado.",
            Duration = 3
        })
    else
        print("[Magma Auto] Evento começou, mas o fogo não foi achado no mapa.")
    end
end

-- ==========================================
-- 4. OUVINTE DE MENSAGENS DO JOGO
-- ==========================================
-- Fica escutando todas as mensagens do jogo
StarterGui.OnMessageReceived:Connect(function(mensagem)
    -- Se o botão estiver ON e a mensagem for a do evento
    if FarmAtivo and string.find(string.lower(mensagem), "surto") then
        print("[Magma Auto] Mensagem detectada: " .. mensagem)
        
        -- Espera 1 segundo para o jogo carregar o fogo no mapa e teleporta
        task.wait(1) 
        teleportarParaOFogo()
    end
end)

-- ==========================================
-- 5. LOOP DE SEGURANÇA (Caso a mensagem não apareça)
-- ==========================================
-- Fica verificando a cada 3 segundos se tem algum fogo no mapa sem precisar da mensagem
while task.wait(3) do
    if FarmAtivo then
        -- Tenta achar o fogo sem a mensagem
        teleportarParaOFogo()
    end
end
