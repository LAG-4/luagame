-- CRT Shader effects — barrel distortion, scanlines, chromatic aberration, vignette
local Shaders = {}

-- Vertex shader (standard)
Shaders.vertexCode = [[
    vertex attribute vec2 VertexPosition;
    uniform mat4 Projection;
    void main() {
        gl_Position = Projection * vec4(VertexPosition, 0.0, 1.0);
    }
]]

-- Fragment shader with full CRT effect
Shaders.fragmentCode = [[
    uniform float time;
    uniform float brainrot;
    uniform vec2 resolution;
    uniform sampler2D background;

    // Curve the screen (barrel distortion)
    vec2 curve(vec2 uv) {
        uv = uv * 2.0 - 1.0;
        vec2 offset = abs(uv.yx) / vec2(6.0, 4.0);
        uv = uv + uv * offset * offset;
        uv = uv * 0.5 + 0.5;
        return uv;
    }

    void main() {
        vec2 uv = gl_FragCoord.xy / resolution;

        // Apply barrel distortion
        vec2 curved = curve(uv);

        // Check bounds after curvature
        if (curved.x < 0.0 || curved.x > 1.0 || curved.y < 0.0 || curved.y > 1.0) {
            gl_FragColor = vec4(0.0, 0.0, 0.0, 1.0);
            return;
        }

        // Chromatic aberration — increases with brainrot
        float aberration = 0.002 + brainrot * 0.001;
        vec4 color;
        color.r = texture2D(background, curved + vec2(aberration, 0.0)).r;
        color.g = texture2D(background, curved).g;
        color.b = texture2D(background, curved - vec2(aberration, 0.0)).b;
        color.a = 1.0;

        // Scanlines
        float scanline = sin(gl_FragCoord.y * 2.0) * 0.04;
        color.rgb -= scanline;

        // Vignette
        vec2 vig = uv * (1.0 - uv.xy);
        float vigAmount = vig.x * vig.y * 15.0;
        vigAmount = pow(vigAmount, 0.25);
        color.rgb *= vigAmount;

        // Phosphor glow (subtle green tint)
        color.rgb += vec3(0.0, 0.02, 0.0);

        // Brainrot: add RGB shift/glitch at high levels
        if (brainrot > 6.0) {
            float glitch = sin(time * 10.0 + uv.y * 50.0) * 0.01 * (brainrot - 6.0);
            color.r += glitch;
            color.b -= glitch;
        }

        // Brainrot: noise at endgame
        if (brainrot > 8.0) {
            float noise = fract(sin(dot(uv, vec2(12.9898, 78.233)) + time) * 43758.5453);
            color.rgb += (noise - 0.5) * 0.1 * (brainrot - 8.0) / 2.0;
        }

        gl_FragColor = color;
    }
]]

function Shaders.new()
    local ok, shader = pcall(love.graphics.newShader, Shaders.vertexCode, Shaders.fragmentCode)
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