CreateThread(function()
    while true do
        Wait(0)

        if NetworkIsPlayerActive(PlayerId()) then
            Wait(500)
            TriggerServerEvent("mdiscord:server:player_connected")
            break
        end
    end
end)