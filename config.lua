-- Game constants — Dark gothic horror aesthetic, 1280x720 virtual resolution
local Config = {}

Config.GAME_WIDTH  = 1280
Config.GAME_HEIGHT = 720
Config.RENDER_SCALE = 2

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
Config.BALL_MAX_SPEED     = 820
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

-- Dark gothic brick palette — reference-accurate grunge colors
Config.BRICK_COLORS = {
    {0.72, 0.14, 0.14},   -- blood red
    {0.65, 0.15, 0.12},   -- dark crimson
    {0.50, 0.32, 0.12},   -- rusted bronze
    {0.58, 0.42, 0.10},   -- dark gold
    {0.22, 0.48, 0.20},   -- sickly green
    {0.32, 0.16, 0.48},   -- corrupted purple
    {0.52, 0.26, 0.16},   -- burnt sienna
    {0.16, 0.36, 0.36},   -- dark teal
}

-- Reference-accurate UI palette
Config.COLOR_BG           = {0.04, 0.035, 0.03}   -- near black background
Config.COLOR_BG_DARK      = {0.03, 0.025, 0.02}   -- deepest black
Config.COLOR_PANEL        = {0.06, 0.055, 0.05, 0.92}  -- dark panel
Config.COLOR_PANEL_BORDER = {0.28, 0.22, 0.15, 0.55}   -- bronze border
Config.COLOR_HUD_BG       = {0.05, 0.045, 0.04, 0.95}
Config.COLOR_HUD_TEXT     = {0.82, 0.77, 0.68}    -- aged parchment
Config.COLOR_ACCENT       = {0.82, 0.12, 0.08}    -- bright blood red
Config.COLOR_ACCENT2      = {0.88, 0.52, 0.12}    -- bronze/gold
Config.COLOR_SCORE        = {0.85, 0.22, 0.18}    -- score red
Config.COLOR_COMBO        = {0.92, 0.48, 0.08}    -- combo fire orange
Config.COLOR_GOLD         = {0.78, 0.58, 0.15}    -- antique gold
Config.COLOR_CREAM        = {0.80, 0.74, 0.64}    -- aged cream
Config.COLOR_CARD_BG      = {0.08, 0.07, 0.06}
Config.COLOR_CARD_BORDER  = {0.32, 0.20, 0.12}
Config.COLOR_LIVES        = {0.82, 0.18, 0.18}
Config.COLOR_BALL         = {0.90, 0.80, 0.55}    -- warm gold ball
Config.COLOR_BALL_GLOW    = {0.90, 0.50, 0.15, 0.12}
Config.COLOR_PADDLE       = {0.55, 0.35, 0.20}    -- bronze paddle
Config.COLOR_MUTED        = {0.42, 0.37, 0.32}    -- muted text

-- Reference-specific accent colors
Config.COLOR_RED_BRIGHT   = {0.88, 0.08, 0.05}
Config.COLOR_ORANGE_BRIGHT = {0.95, 0.44, 0.06}
Config.COLOR_GREEN_BRIGHT = {0.30, 0.86, 0.02}
Config.COLOR_PURPLE_BRIGHT = {0.55, 0.18, 1.00}

-- Atmospheric background text (faded watermarks)
Config.BG_TEXTS = {
    "NO THOUGHTS", "HEAD EMPTY", "RIZZ", "SIGMA",
    "BRAINROT", "COPE", "DELULU", "SKIBIDI",
    "OHIO", "SLAY", "GYATT", "NPC ENERGY",
}

Config.BRAINROT_MAX = 10

return Config
