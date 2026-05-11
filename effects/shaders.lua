-- CRT Shader effects — subtle scanlines, light chromatic aberration, vignette
local Shaders = {}

-- Fragment shader with a restrained CRT effect.
Shaders.fragmentCode = [[
    extern float time;
    extern float brainrot;
    extern vec2 resolution;

    vec4 effect(vec4 vcolor, Image tex, vec2 texture_coords, vec2 screen_coords) {
        vec2 uv = texture_coords;

        // Very light chromatic aberration. Keep this low so text stays sharp.
        float aberration = 0.00035 + brainrot * 0.00012;
        vec4 color;
        color.r = Texel(tex, uv + vec2(aberration, 0.0)).r;
        color.g = Texel(tex, uv).g;
        color.b = Texel(tex, uv - vec2(aberration, 0.0)).b;
        color.a = 1.0;

        // Fine scanline texture, not a full-screen darkening pass.
        float scanline = (sin(uv.y * resolution.y * 1.25) * 0.5 + 0.5) * 0.018;
        color.rgb *= 1.0 - scanline;

        // Soft vignette that preserves the center and avoids heavy corner warping.
        vec2 vig = uv * (1.0 - uv.xy);
        float vigAmount = clamp(pow(vig.x * vig.y * 16.0, 0.16), 0.72, 1.0);
        color.rgb *= vigAmount;

        // Minimal phosphor tint.
        color.rgb += vec3(0.0, 0.004, 0.0);

        // Brainrot: add RGB shift/glitch at high levels
        if (brainrot > 6.0) {
            float glitch = sin(time * 10.0 + uv.y * 50.0) * 0.003 * (brainrot - 6.0);
            color.r += glitch;
            color.b -= glitch;
        }

        // Brainrot: noise at endgame
        if (brainrot > 8.0) {
            float noise = fract(sin(dot(uv, vec2(12.9898, 78.233)) + time) * 43758.5453);
            color.rgb += (noise - 0.5) * 0.035 * (brainrot - 8.0) / 2.0;
        }

        return color * vcolor;
    }
]]

function Shaders.new()
    local ok, shader = pcall(love.graphics.newShader, Shaders.fragmentCode)
    if not ok then
        -- Fallback if shader fails
        return nil
    end
    return setmetatable({
        shader = shader,
        brainrot = 0,
    }, {__index = Shaders})
end

function Shaders:setBrainrot(level)
    self.brainrot = level or 0
    if self.shader then
        self.shader:send("brainrot", self.brainrot)
    end
end

function Shaders:sendResolution(w, h)
    if self.shader then
        self.shader:send("resolution", {w, h})
    end
end

function Shaders:sendTime(t)
    if self.shader then
        self.shader:send("time", t)
    end
end

function Shaders:apply()
    if self.shader then
        love.graphics.setShader(self.shader)
    end
end

function Shaders:reset()
    love.graphics.setShader()
end

return Shaders
