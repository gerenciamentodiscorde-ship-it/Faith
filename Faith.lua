local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")

local player = Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local humanoid = character:WaitForChild("Humanoid")
local rootPart = character:WaitForChild("HumanoidRootPart")

-- CONFIGURAÇÕES
local NOME_ITEM = "Magma crack" -- Nome exato do item (respeite maiúsculas/minúsculas)
local VELOCIDADE = 30 -- Velocidade para chegar mais rápido

humanoid.WalkSpeed = VELOCIDADE

print("[Magma Auto] Script iniciado. Procurando por: " .. NOME_ITEM)

while true do
    -- Procura o item em todo o mapa (Workspace)
    -- O 'true' no final serve para procurar dentro de pastas também
    local item = Workspace:FindFirstChild(NOME_ITEM, true)
    
    if item and item:IsA("BasePart") then
        -- Se o item existe, avisa e anda até ele
        print("[Magma Auto] Item encontrado! Movendo...")
        
        -- Move até a posição do item
        humanoid:MoveTo(item.Position)
        
        -- Fica atualizando a posição enquanto o item existir (caso ele se mova)
        while item and item.Parent do
            humanoid:MoveTo(item.Position)
            task.wait(0.2)
        end
        
        print("[Magma Auto] Item sumiu. Voltando a procurar...")
    else
        -- Se não achou o item, espera 1 segundo e tenta de novo
        task.wait(1)
    end
end
