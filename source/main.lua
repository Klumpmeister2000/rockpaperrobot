import "CoreLibs/object"
import "CoreLibs/graphics"
import "CoreLibs/sprites"
import "CoreLibs/timer"
import "CoreLibs/ui"

local pd <const> = playdate
local gfx <const> = pd.graphics

-- Game states
local GAME_STATE = {
    MENU = 1,
    PLAYING = 2,
    RESULT = 3,
    COUNTDOWN = 4
}

-- Game variables
local gameState = GAME_STATE.MENU
local playerChoice = nil
local robotChoice = nil
local playerScore = 0
local robotScore = 0
local countdown = 3
local countdownTimer = nil
local resultTimer = nil

-- Choice constants
local CHOICES = {
    ROCK = 1,
    PAPER = 2,
    SCISSORS = 3
}

local choiceNames = {"ROCK", "PAPER", "SCISSORS"}
local choiceEmojis = {"ROCK", "PAPER", "SCSR"}

-- Robot sprites and animations
local robotSprite = nil
local playerSprite = nil
local backgroundSprite = nil

-- Fonts and UI
local titleFont = nil
local scoreFont = nil

function pd.update()
    if gameState == GAME_STATE.COUNTDOWN then
        updateCountdown()
    elseif gameState == GAME_STATE.RESULT then
        updateResult()
    end
    
    gfx.sprite.update()
    pd.timer.updateTimers()
    drawUI()
end

function updateCountdown()
    -- Countdown is handled by timer callback
end

function updateResult()
    -- Result display is handled by timer callback
end

function drawUI()
    gfx.clear()
    
    if gameState == GAME_STATE.MENU then
        drawMenu()
    elseif gameState == GAME_STATE.PLAYING then
        drawGameplay()
    elseif gameState == GAME_STATE.COUNTDOWN then
        drawCountdown()
    elseif gameState == GAME_STATE.RESULT then
        drawResult()
    end
    
    -- Always draw score
    drawScore()
end

function drawMenu()
    gfx.setImageDrawMode(gfx.kDrawModeFillBlack)
    
    -- Title
    gfx.drawTextAligned("*** SUPER ROBOT ***", 200, 50, kTextAlignment.center)
    gfx.drawTextAligned("ROCK PAPER SCISSORS", 200, 70, kTextAlignment.center)
    
    -- Robot ASCII art (using basic ASCII)
    gfx.drawTextAligned("    +-----+", 200, 100, kTextAlignment.center)
    gfx.drawTextAligned("    | O O |", 200, 115, kTextAlignment.center)
    gfx.drawTextAligned("    |  -  |", 200, 130, kTextAlignment.center)
    gfx.drawTextAligned("    +-----+", 200, 145, kTextAlignment.center)
    gfx.drawTextAligned("   +-------+", 200, 160, kTextAlignment.center)
    gfx.drawTextAligned("   | READY |", 200, 175, kTextAlignment.center)
    gfx.drawTextAligned("   +-------+", 200, 190, kTextAlignment.center)
    
    -- Instructions
    gfx.drawTextAligned("A=ROCK  UP=PAPER  B=SCISSORS", 200, 220, kTextAlignment.center)
    gfx.drawTextAligned("Press any button to start!", 200, 235, kTextAlignment.center)
end

function drawGameplay()
    gfx.setImageDrawMode(gfx.kDrawModeFillBlack)
    
    -- Robot display
    gfx.drawTextAligned("*** SUPER ROBOT 3000 ***", 200, 30, kTextAlignment.center)
    drawRobot(200, 80)
    
    -- Player area
    gfx.drawTextAligned("Choose your weapon:", 200, 160, kTextAlignment.center)
    gfx.drawTextAligned("A = ROCK", 80, 190, kTextAlignment.center)
    gfx.drawTextAligned("UP = PAPER", 200, 190, kTextAlignment.center)
    gfx.drawTextAligned("B = SCISSORS", 320, 190, kTextAlignment.center)
    
    -- Battle arena border
    gfx.drawRect(20, 20, 360, 200)
end

function drawCountdown()
    gfx.setImageDrawMode(gfx.kDrawModeFillBlack)
    
    -- Large countdown number
    local countdownStr = tostring(countdown)
    if countdown == 0 then
        countdownStr = "FIGHT!"
    end
    
    gfx.setFont(gfx.getSystemFont(gfx.font.kVariantBold))
    gfx.drawTextAligned(countdownStr, 200, 100, kTextAlignment.center)
    
    -- Robot preparing for battle
    gfx.drawTextAligned("*** ANALYZING... ***", 200, 160, kTextAlignment.center)
    drawRobotThinking(200, 180)
    
    -- Reset font
    gfx.setFont(gfx.getSystemFont())
end

function drawResult()
    gfx.setImageDrawMode(gfx.kDrawModeFillBlack)
    
    if playerChoice and robotChoice then
        -- Show choices
        gfx.drawTextAligned("YOU: " .. choiceNames[playerChoice], 200, 60, kTextAlignment.center)
        gfx.drawTextAligned("ROBOT: " .. choiceNames[robotChoice], 200, 80, kTextAlignment.center)
        
        -- Show result
        local result = getWinner(playerChoice, robotChoice)
        if result == "player" then
            gfx.drawTextAligned("*** YOU WIN! ***", 200, 110, kTextAlignment.center)
            drawRobotSad(200, 130)
        elseif result == "robot" then
            gfx.drawTextAligned("*** ROBOT WINS! ***", 200, 110, kTextAlignment.center)
            drawRobotHappy(200, 130)
        else
            gfx.drawTextAligned("*** TIE! ***", 200, 110, kTextAlignment.center)
            drawRobot(200, 130)
        end
        
        gfx.drawTextAligned("Press any button to continue", 200, 220, kTextAlignment.center)
    end
end

function drawScore()
    gfx.setImageDrawMode(gfx.kDrawModeFillBlack)
    -- Draw scores in corners to avoid overlap
    gfx.drawTextAligned("P:" .. playerScore, 50, 5, kTextAlignment.center)
    gfx.drawTextAligned("R:" .. robotScore, 350, 5, kTextAlignment.center)
end

function drawRobot(x, y)
    gfx.drawTextAligned("+-----+", x, y, kTextAlignment.center)
    gfx.drawTextAligned("| O O |", x, y + 15, kTextAlignment.center)
    gfx.drawTextAligned("|  -  |", x, y + 30, kTextAlignment.center)
    gfx.drawTextAligned("+-----+", x, y + 45, kTextAlignment.center)
end

function drawRobotHappy(x, y)
    gfx.drawTextAligned("+-----+", x, y, kTextAlignment.center)
    gfx.drawTextAligned("| ^ ^ |", x, y + 15, kTextAlignment.center)
    gfx.drawTextAligned("|  U  |", x, y + 30, kTextAlignment.center)
    gfx.drawTextAligned("+-----+", x, y + 45, kTextAlignment.center)
end

function drawRobotSad(x, y)
    gfx.drawTextAligned("+-----+", x, y, kTextAlignment.center)
    gfx.drawTextAligned("| - - |", x, y + 15, kTextAlignment.center)
    gfx.drawTextAligned("|  n  |", x, y + 30, kTextAlignment.center)
    gfx.drawTextAligned("+-----+", x, y + 45, kTextAlignment.center)
end

function drawRobotThinking(x, y)
    gfx.drawTextAligned("+-----+", x, y, kTextAlignment.center)
    gfx.drawTextAligned("| @ @ |", x, y + 15, kTextAlignment.center)
    gfx.drawTextAligned("|  o  |", x, y + 30, kTextAlignment.center)
    gfx.drawTextAligned("+-----+", x, y + 45, kTextAlignment.center)
end

function getWinner(player, robot)
    if player == robot then
        return "tie"
    elseif (player == CHOICES.ROCK and robot == CHOICES.SCISSORS) or
           (player == CHOICES.PAPER and robot == CHOICES.ROCK) or
           (player == CHOICES.SCISSORS and robot == CHOICES.PAPER) then
        return "player"
    else
        return "robot"
    end
end

function startCountdown()
    gameState = GAME_STATE.COUNTDOWN
    countdown = 3
    
    -- Clean up any existing timer
    if countdownTimer then
        countdownTimer:remove()
        countdownTimer = nil
    end
    
    countdownTimer = pd.timer.new(1000, function()
        countdown = countdown - 1
        if countdown < 0 then
            -- Stop the countdown timer
            if countdownTimer then
                countdownTimer:remove()
                countdownTimer = nil
            end
            
            -- Generate robot choice
            robotChoice = math.random(1, 3)
            gameState = GAME_STATE.RESULT
            
            -- Update scores
            local winner = getWinner(playerChoice, robotChoice)
            if winner == "player" then
                playerScore = playerScore + 1
            elseif winner == "robot" then
                robotScore = robotScore + 1
            end
            
            -- Show result for 3 seconds
            if resultTimer then
                resultTimer:remove()
            end
            resultTimer = pd.timer.new(3000, function()
                gameState = GAME_STATE.PLAYING
                playerChoice = nil
                robotChoice = nil
                if resultTimer then
                    resultTimer:remove()
                    resultTimer = nil
                end
            end)
        end
    end)
    countdownTimer.repeats = true
end

function pd.AButtonDown()
    if gameState == GAME_STATE.MENU then
        gameState = GAME_STATE.PLAYING
    elseif gameState == GAME_STATE.PLAYING then
        playerChoice = CHOICES.ROCK
        startCountdown()
    elseif gameState == GAME_STATE.RESULT then
        -- Clean up result timer
        if resultTimer then
            resultTimer:remove()
            resultTimer = nil
        end
        gameState = GAME_STATE.PLAYING
        playerChoice = nil
        robotChoice = nil
    end
end

function pd.BButtonDown()
    if gameState == GAME_STATE.MENU then
        gameState = GAME_STATE.PLAYING
    elseif gameState == GAME_STATE.PLAYING then
        playerChoice = CHOICES.SCISSORS
        startCountdown()
    elseif gameState == GAME_STATE.RESULT then
        -- Clean up result timer
        if resultTimer then
            resultTimer:remove()
            resultTimer = nil
        end
        gameState = GAME_STATE.PLAYING
        playerChoice = nil
        robotChoice = nil
    end
end

function pd.upButtonDown()
    if gameState == GAME_STATE.MENU then
        gameState = GAME_STATE.PLAYING
    elseif gameState == GAME_STATE.PLAYING then
        playerChoice = CHOICES.PAPER
        startCountdown()
    elseif gameState == GAME_STATE.RESULT then
        -- Clean up result timer
        if resultTimer then
            resultTimer:remove()
            resultTimer = nil
        end
        gameState = GAME_STATE.PLAYING
        playerChoice = nil
        robotChoice = nil
    end
end

-- Initialize the game
function pd.gameWillTerminate()
    -- Save high scores here if needed
end

-- Game initialization
math.randomseed(pd.getSecondsSinceEpoch())
gfx.setFont(gfx.getSystemFont())

-- Start the game
gameState = GAME_STATE.MENU