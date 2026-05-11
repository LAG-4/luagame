# Brainrot Breaker

A LÖVE 11.x arcade brick-breaker roguelite with modifier cards, escalating brainrot effects, CRT distortion, particles, procedural dark-metal UI, and the `assets/Virus Arcade Panic (1).mp3` soundtrack.

## Run

```bash
love .
```

The game targets Linux, Windows, and macOS through LÖVE. It renders to a fixed 1280x720 virtual canvas, then scales with letterboxing to any window size. First launch defaults to desktop fullscreen; press `F11` to toggle fullscreen.

## Controls

| Action | Keyboard | Gamepad |
|---|---|---|
| Move paddle | `A/D` or arrow keys | Left stick |
| Launch / Select | `Space` or `Enter` | A |
| Pause / Back | `Esc` | B |
| Fullscreen | `F11` | - |

## Current Vertical Slice

Implemented and working in the current build:

- Modular game structure with state machine, menu, gameplay, card select, pause, settings, game over, victory, and run summary states.
- Multi-ball-capable ball list, paddle, brick layouts, lives, score, combo, and stage progression.
- 10 stage layouts plus endless mode scaling.
- 17 modifier cards, including multiball, exploding bricks, ghost ball, piercing shot, chain lightning, gravity well, score frenzy, shields, size/speed modifiers, and extra life.
- Persistent high scores and settings through `love.filesystem`.
- Background music streaming from `assets/Virus Arcade Panic (1).mp3`.
- Dynamic SFX pitch/volume, hit sparks, brick debris, ball trails, popup text, fake notifications, screen shake, screen flash support, and LÖVE 11-compatible CRT shader.
- Procedural dark industrial UI inspired by the supplied references: metal panels, red accents, grunge bricks, bolts, glow, scanlines, and skull/brainrot styling cues.
- Fullscreen/windowed support and letterboxed scaling across screen sizes.

## Recent Stabilization

Fixed during the vertical-slice pass:

- Replaced invalid particle APIs (`setAreaShape`, `setGravity`, `setSize`) with LÖVE 11.5-compatible calls.
- Split ball entity trails from particle trails so `ball.trail` and particle rendering no longer corrupt each other.
- Fixed run summary modifier access.
- Fixed card-select stage continuation to use hand-authored layouts.
- Added ball speed limits, minimum vertical velocity enforcement, substep updates, and a multiball cap to reduce tunneling and runaway chaos.
- Replaced the silently failing shader with a LÖVE 11-compatible CRT shader.
- Added fullscreen persistence and applied saved volume to BGM and SFX.

## Visual Direction

The reference images are style targets, not full-screen backgrounds. The game should recreate their look with code and sliced assets:

- dark scratched metal and gothic panel frames
- red neon strips and subtle green brainrot accents
- chunky industrial buttons and HUD frames
- grungy bolted colored bricks
- skull/brain/brainrot motifs
- high-contrast arcade readability

Useful individual assets for the next art pass:

- transparent logo layers: `BRAINROT`, `BREAKER`, brain icon
- skull emblem without background
- panel frames as 9-slice PNGs
- button frames in normal/hover/pressed states
- individual brick sprites by color/type
- HUD icons for score, combo, brainrot, lives, settings, sound, quit
- paddle sprite sized directly for gameplay

## Still Left To Do

Highest priority:

- Make the procedural UI closer to the references screen-by-screen, especially menu, HUD, card select, and end screens.
- Replace code-drawn approximations with sliced transparent assets once available.
- Add mouse support for menus and card select.
- Add better swept brick collision for very high speeds.
- Improve card balance and make synergies explicit with discovery popups.
- Add score targets/rewards beyond the current clear-stage loop.
- Add challenge runs, unlockable card pools, alternate paddles, and cosmetic CRT themes.

Later polish:

- Boss/mini-boss stages.
- More SFX variety and optional meme sound triggers.
- Stronger late-game brainrot overlays: livestream frame, corrupted desktop popups, warning windows, and glitched menus.
- Packaging scripts for Windows/macOS/Linux releases.

## Project Structure

```text
main.lua                 Entry point, canvas scaling, global game object
config.lua               Gameplay constants and colors
conf.lua                 LÖVE window/module config
entities/                Ball, paddle, brick
systems/                 Audio, collision, modifiers
states/                  Menu, gameplay, card select, pause, settings, endings
effects/                 Camera, particles, shader, brainrot overlays
ui/                      HUD and popup systems
data/                    Cards and stage layouts
lib/                     Save and timer helpers
assets/                  Music and visual reference/source assets
sounds/                  SFX
```
