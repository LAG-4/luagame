-- Game constants — Dark gothic horror aesthetic, 1280x720 virtual resolution
local Config = {}

Config.GAME_WIDTH  = 1280
Config.GAME_HEIGHT = 720

-- Layout — sidebar HUD on left (200px), play area right of it
Config.SIDEBAR_WIDTH    = 195
Config.PLAY_AREA_LEFT   = 200
Config.TOP_BAR_HEIGHT   = 50
Config.PLAY_AREA_TOP    = 55
Config.PLAY_AREA_BOTTOM = 690

Config.STARTING_LIVES = 3

-- Paddle (in play area)
Config.PADDLE_SPEED         = 600
Config.PADDLE_DEFAULT_WIDTH = 150
Config.PADDLE_HEIGHT        = 16
Config.PADDLE_Y             = 670

-- Ball
Config.BALL_RADIUS        = 9
Config.BALL_INITIAL_DY    = -480
Config.BALL_LAUNCH_SPREAD = 280
Config.BALL_MIN_DY        = 130
Config.PADDLE_HIT_SPREAD  = 400

-- Bricks (fit in play area: 200 to 1280)
Config.BRICK_COLS         = 10
Config.BRICK_HEIGHT       = 32
Config.BRICK_MARGIN_LEFT  = 210
Config.BRICK_MARGIN_RIGHT = 15
Config.BRICK_GAP          = 3
Config.BRICK_TOP_OFFSET   = 62
Config.BRICK_SPAWN_CHANCE = 0.82
Config.BRICK_BASE_ROWS    = 4

Config.MAX_STAGES = 10
Config.ENDLESS_MAX_STAGES = 999

Config.SCORE_PER_BRICK        = 100
Config.COMBO_SCORE_MULTIPLIER = 0.1
Config.CARD_BONUS_SCORE       = 500

Config.SHAKE_DECAY_SPEED   = 12
Config.SHAKE_PADDLE_HIT    = 3
Config.SHAKE_BRICK_DESTROY = 5

Config.COMBO_DECAY_TIME     = 5.0  -- Seconds before combo starts decaying
Config.COMBO_DECAY_RATE     = 1.0  -- Combo decreases by this per second after decay time

-- Dark gothic brick palette — worn grunge colors
Config.BRICK_COLORS = {
    {0.70, 0.15, 0.15},   -- blood red
    {0.60, 0.18, 0.12},   -- dark crimson
    {0.45, 0.30, 0.12},   -- rusted bronze
    {0.55, 0.40, 0.10},   -- dark gold
    {0.20, 0.45, 0.20},   -- sickly green
    {0.30, 0.15, 0.45},   -- corrupted purple
    {0.50, 0.25, 0.15},   -- burnt sienna
    {0.15, 0.35, 0.35},   -- dark teal
}

-- Dark gothic UI palette
Config.COLOR_BG           = {0.06, 0.05, 0.05}   -- near black
Config.COLOR_BG_DARK      = {0.04, 0.03, 0.03}   -- deepest black
Config.COLOR_PANEL        = {0.09, 0.08, 0.07, 0.95}  -- dark panel
Config.COLOR_PANEL_BORDER = {0.30, 0.18, 0.10, 0.6}   -- bronze border
Config.COLOR_HUD_BG       = {0.07, 0.06, 0.05, 0.95}
Config.COLOR_HUD_TEXT     = {0.80, 0.75, 0.65}    -- aged parchment
Config.COLOR_ACCENT       = {0.75, 0.20, 0.15}    -- dark red accent
Config.COLOR_ACCENT2      = {0.85, 0.55, 0.15}    -- bronze/gold
Config.COLOR_SCORE        = {0.85, 0.25, 0.20}    -- score red
Config.COLOR_COMBO        = {0.90, 0.55, 0.10}    -- combo fire orange
Config.COLOR_GOLD         = {0.80, 0.60, 0.15}    -- antique gold
Config.COLOR_CREAM        = {0.78, 0.72, 0.62}    -- aged cream
Config.COLOR_CARD_BG      = {0.10, 0.08, 0.07}
Config.COLOR_CARD_BORDER  = {0.35, 0.22, 0.12}
Config.COLOR_LIVES        = {0.85, 0.20, 0.20}
Config.COLOR_BALL         = {0.90, 0.80, 0.55}    -- warm gold ball
Config.COLOR_BALL_GLOW    = {0.90, 0.50, 0.15, 0.12}
Config.COLOR_PADDLE       = {0.55, 0.35, 0.20}    -- bronze paddle
Config.COLOR_MUTED        = {0.40, 0.35, 0.30}    -- muted text

-- Atmospheric background text (faded watermarks)
Config.BG_TEXTS = {
    "NO THOUGHTS", "HEAD EMPTY", "RIZZ", "SIGMA",
    "BRAINROT", "COPE", "DELULU", "SKIBIDI",
    "OHIO", "SLAY", "GYATT", "NPC ENERGY",
}

Config.BRAINROT_MAX = 10

return Config
