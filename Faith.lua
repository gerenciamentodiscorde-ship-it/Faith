local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")

local player = Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local humanoid = character:WaitForChild("Humanoid")
local rootPart = character:WaitForChild("HumanoidRootPart")

-- CONFIGURAÇÕES
local NOME_PLATAFORMA = "BossFightPlatform" -- Nome que você achou no Dex
local VELOCIDADE = 30 -- Deixe 16 para velocidade normal, ou mais alto para correr rápido

humanoid.WalkSpeed = VELOCIDADE

local function encontrarAlvo()
    -- Procura a plataforma no mapa
    local plataforma = Workspace:FindFirstChild(NOME_PLATAFORMA, true)
    
    if not plataforma then return nil end

    local alvoMaisProximo = nil
    local distanciaMinima = math.huge

    -- Procura dentro da plataforma (e em todos os objetos filhos dela)
    for _, objeto in ipairs(plataforma:GetDescendants()) do
        if objeto:IsA("BasePart") then
            -- Ignora a própria base da plataforma para não tentar andar para o chão
            if objeto ~= plataforma then 
                
                -- Verifica se a parte é vermelha, verde, ou tem nome de área
                local cor = objeto.Color
                local nome = string.lower(objeto.Name)
                
                -- Filtro de cor: Vermelho, Verde ou nomes específicos
                -- (Ajuste os valores de cor se necessário)
                local isVermelho = (cor.R > 0.7 and cor.G < 0.3 and cor.B < 0.3)
                local isVerde = (cor.G > 0.7 and cor.R < 0.3 and cor.B < 0.3)
                
                if isVermelho or isVerde or string.find(nome, "red") or string.find(nome, "green") or string.find(nome, "zone") or string.find(nome, "area") then
                    local distancia = (objeto.Position - rootPart.Position).Magnitude
                    if distancia < distanciaMinima then
                        distanciaMinima = distancia
                        alvoMaisProximo = objeto
                    end
                end
            end
        end
    end
    return alvoMaisProximo
end

-- LOOP PRINCIPAL
print("Script de Auto Move iniciado. Procurando áreas...")

while true do
    local alvo = encontrarAlvo()
    
    if alvo then
        print("Movendo para a área: " .. alvo.Name)
        -- Manda o personagem andar até a área
        humanoid:MoveTo(alvo.Position)
        
        -- Espera um pouco antes de recalcular. 
        -- 0.3s é um bom tempo para não bugar o movimento do Roblox.
        task.wait(0.3) 
    else
        -- Se não achou nada (boss morreu ou não spawnou ainda)
        print("Nenhuma área encontrada. Aguardando Boss...")
        task.wait(1)
    end
end
