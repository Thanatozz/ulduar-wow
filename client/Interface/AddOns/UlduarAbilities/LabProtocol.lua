local UA = UlduarAbilitiesUI
UA.Lab = UA.Lab or {}
local Lab = UA.Lab

-- Developer Ability Lab transport. It reuses the core's addon command channel (prefix "AzerothCore",
-- AddonChannelCommandHandler): the request is exactly a `.ua lab ...` chat command, so RBAC, the
-- UlduarAbilities.DebugEditor gate and every validation stay on the server. The UI adds no power.
--
-- Request:  "h" + 4-char counter + "ua lab <args>"   (h = human-readable output)
-- Replies:  "a" + counter (ack), "m" + counter + text (one per output line), "o" + counter (ok),
--           "f" + counter (failed). Replies for any other counter are ignored.
Lab.Prefix = "AzerothCore"
Lab.counter = 0
Lab.Timeout = 8

-- One token per argument: letters, digits and . _ % + - only. No spaces, pipes or newlines, so a
-- request can never smuggle a second command or a chat escape sequence.
function Lab.ValidToken(text)
    return type(text) == "string" and text ~= "" and #text <= 64 and string.match(text, "^[%w%._%%%+%-]+$") ~= nil
end

function Lab.Run(args, onDone)
    if Lab.pending then
        Lab.SetStatus("|cffffd100Waiting for the previous Lab command...|r")
        return false
    end
    for _, token in ipairs(args) do
        if not Lab.ValidToken(token) then
            Lab.SetStatus("|cffff4040Invalid input: use single words (letters, digits, . _ % + -).|r")
            return false
        end
    end
    local command = "ua lab " .. table.concat(args, " ")
    Lab.counter = Lab.counter % 9999 + 1
    local counter = string.format("%04d", Lab.counter)
    local message = "h" .. counter .. command
    if #Lab.Prefix + 1 + #message > 255 then
        Lab.SetStatus("|cffff4040Command too long.|r")
        return false
    end
    Lab.pending = { counter = counter, started = GetTime(), onDone = onDone, lines = 0 }
    Lab.Echo("> ." .. command)
    Lab.SetStatus("Waiting for server...")
    SendAddonMessage(Lab.Prefix, message, "WHISPER", UnitName("player"))
    return true
end

function Lab.Receive(prefix, message, channel, sender)
    local pending = Lab.pending
    if prefix ~= Lab.Prefix or channel ~= "WHISPER" or not pending or type(message) ~= "string" then return end
    local ownName = UnitName("player")
    if not ownName or (sender ~= ownName and sender ~= ownName .. "-" .. GetRealmName()) then return end
    local opcode, counter = string.sub(message, 1, 1), string.sub(message, 2, 5)
    if counter ~= pending.counter then return end
    if opcode == "a" then
        pending.acked = true
    elseif opcode == "m" then
        pending.lines = pending.lines + 1
        Lab.Output(string.sub(message, 6))
    elseif opcode == "o" or opcode == "f" then
        Lab.pending = nil
        local ok = opcode == "o"
        Lab.SetStatus(ok and "|cff40ff40Done.|r" or "|cffff4040The server rejected the command (see output).|r")
        if pending.onDone then pending.onDone(ok) end
    end
end

function Lab.Update()
    local pending = Lab.pending
    if pending and GetTime() - pending.started > Lab.Timeout then
        Lab.pending = nil
        Lab.SetStatus("|cffff4040No server response. The Lab needs GM access and UlduarAbilities.DebugEditor = 1.|r")
    end
end
