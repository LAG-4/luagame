-- Game constants — single source of truth for all tunable values
local Config = {}

-- Window / world
Config.GAME_WIDTH  = 800
Config.GAME_HEIGHT = 600

-- Paddle
Config.PADDLE_SPEED         = 400
Config.PADDLE_DEFAULT_WIDTH = 100
Config.PADDLE_HEIGHT        = 15
Config.PADDLE_Y_OFFSET      = 40   -- distance from bottom

-- Ball
Config.BALL_RADIUS        = 8
Config.BALL_INITIAL_DY    = -350
Config.BALL_LAUNCH_SPREAD = 200
Config.BALL_MIN_DY        = 100    -- prevents near-horizontal loops

-- Paddle-hit physics
Config.PADDLE_HIT_SPREAD = 300     -- max dx imparted by off-center paddle hit

-- Bricks
Config.BRICK_COLS         = 8
Config.BRICK_HEIGHT       = 20
Config.BRICK_MARGIN       = 40     -- total horizontal padding
Config.BRICK_GAP          = 2
Config.BRICK_TOP_OFFSET   = 50
Config.BRICK_SPAWN_CHANCE = 0.8    -- probability a cell contains a brick
Config.BRICK_BASE_ROWS    = 4      -- rows = BASE + stage

-- Stages
Config.MAX_STAGES = 3

-- Scoring
Config.SCORE_PER_BRICK       = 100
Config.COMBO_SCORE_MULTIPLIER = 0.1
Config.CARD_BONUS_SCORE       = 500

-- Screen shake
Config.SHAKE_DECAY_SPEED   = 10
Config.SHAKE_PADDLE_HIT    = 3
Config.SHAKE_BRICK_DESTROY = 5

return Config
