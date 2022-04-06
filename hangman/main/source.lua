if not game:IsLoaded() then game.Loaded:Wait() end --waits for game to finish loading
local chat = game:GetService("ReplicatedStorage").DefaultChatSystemChatEvents.SayMessageRequest

local words = {"sheep", "lion", "panther", "elephant", "dog", "eagle", "bear", "snake", "butterfly", "cow"}
local allowed = {"a", "b", "c", "d", "e", "f", "g", "h", "i", "j", "k", "l", "m", "n", "o", "p", "q", "r", "s", "t", "u", "v", "w", "x", "y", "z"}
local inGame = false
local word = nil
local defaultAttempts = 10
local attempts = 0
local word_tagged = nil
local correct = {}
local wrong = {}

local function hangman(player, input)
    if string.lower(input) == "/hangman" then
        if not inGame then
            --start game
            inGame = true
            print(player.Name.." Started a hangman game")
            word = words[math.random(1,#words)]
            print(word)
            attempts = defaultAttempts
            local output = "Word chosen, Starting game..."
            chat:FireServer(output, "all")
            word_tagged = ""
            for i = 1, string.len(word) do
                word_tagged = word_tagged.."_"
            end
            local output = attempts.." Attempts left | "..word_tagged
            chat:FireServer(output, "all")
        end
    end
    if inGame then
        if string.len(input) == 1 then
            if table.find(allowed, string.lower(input)) then
                --when letter in word
                if string.find(word, string.lower(input)) then
                    if table.find(correct, string.lower(input)) then
                        local output = string.lower(input).." was already guessed"
                        chat:FireServer(output, "all")
                        print(player.Name.." did a dublicated guess")
                    else
                        table.insert(correct, string.lower(input))
                        word_tagged = ""
                        for i = 1, string.len(word) do
                            local letter = string.sub(word, i, i)
                            if table.find(correct, letter) then
                                word_tagged = word_tagged..letter
                            else
                                word_tagged = word_tagged.."_"
                            end
                        end
                        if #correct == string.len(word) or word_tagged == word then
                            local output = player.Name.." Guessed the word!"
                            chat:FireServer(output, "all")
                            print(player.Name.." guessed "..word)
                            word = nil
                            inGame = false
                            attempts = 0
                            word_tagged = nil
                            correct = {}
                            wrong = {}
                        else
                            local output = attempts.." Attempts left | "..word_tagged
                            chat:FireServer(output, "all")
                            print(player.Name.." guessed "..string.lower(input).." right, "..word_tagged)
                        end
                    end
                else
                    if table.find(wrong, string.lower(input)) then
                        local output = string.lower(input).." was already guessed"
                        chat:FireServer(output, "all")
                        print(player.Name.." did a dublicated guess")
                    else
                        table.insert(wrong, string.lower(input))
                        attempts = attempts - 1
                        if attempts == 0 then
                            local output = "Game ended, no more attempts"
                            chat:FireServer(output, "all")
                            print(player.Name.." guessed "..string.lower(input).." wrong, no attempts left")
                            word = nil
                            inGame = false
                            attempts = 0
                            word_tagged = nil
                            correct = {}
                            wrong = {}
                        elseif attempts == 1 then
                            local output = attempts.." Attempt left | "..word_tagged
                            chat:FireServer(output, "all")
                            print(player.Name.." guessed "..string.lower(input).." wrong, "..word_tagged)
                        else
                            local output = attempts.." Attempts left | "..word_tagged
                            chat:FireServer(output, "all")
                            print(player.Name.." guessed "..string.lower(input).." wrong, "..word_tagged)
                        end
                    end
                end
            end
        end
        if string.lower(input) == word then
            --when player guessed succesfully
            local output = player.Name.." Guessed the word!"
            chat:FireServer(output, "all")
            print(player.Name.." guessed "..word)
            word = nil
            inGame = false
            attempts = 0
            word_tagged = nil
            correct = {}
            wrong = {}
        end
    end
end

for _, player in pairs(game:GetService("Players"):GetPlayers()) do
    player.Chatted:connect(function(input)
        hangman(player, input)
    end)
end

game:GetService("Players").PlayerAdded:connect(function(player)
	player.Chatted:connect(function(input)
        hangman(player, input)
    end)
end)
print("hangman loaded")
