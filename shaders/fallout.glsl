// ============================================================================
// Fallout Terminal Shader for Ghostty — "clean" variant
// CRT look kept, but tuned for readability (no ghosted text in highlights).
// Tunables below: raise TINT_AMOUNT / SCANLINE_STRENGTH for a stronger CRT look.
// ============================================================================

// CRT curvature (higher = flatter)
#define CURVE 18.0, 14.0

const vec3 phosphorColor = vec3(0.25, 1.0, 0.35);

// How much of the original colour is replaced by mono-green phosphor.
// 1.0 = full mono (diff bg and text merge), 0.0 = original colours.
#define TINT_AMOUNT 0.35

// Scanlines
#define SCANLINE_STRENGTH 0.18
#define SCANLINE_PERIOD 3.0

// Glow: small radius, only adds light where neighbours are BRIGHTER than
// the pixel itself, so text on a lit background does not get a ghost copy.
#define BLOOM_STRENGTH 0.22
#define BLOOM_SPREAD 1.5

// Flicker / noise
#define FLICKER_STRENGTH 0.015
#define FLICKER_FREQ 20.0
#define NOISE_STRENGTH 0.025

// Vignette
#define VIGNETTE_STRENGTH 0.18
#define VIGNETTE_BRIGHTNESS 1.25

// Rolling bar
#define BAR_SPEED 0.06
#define BAR_INTENSITY 0.06
#define BAR_WIDTH 8.0

// Aperture grille
#define GRILLE_STRENGTH 0.06

float noise(vec2 uv) {
    return fract(sin(dot(uv, vec2(12.9898, 78.233) + iTime * 0.01)) * 43758.5453);
}

float luma(vec3 c) { return dot(c, vec3(0.299, 0.587, 0.114)); }

void mainImage(out vec4 fragColor, in vec2 fragCoord)
{
    vec2 uv = fragCoord.xy / iResolution.xy;

    // 1. CRT warp
    vec2 w = (uv - 0.5) * 2.0;
    w *= 1.0 + pow(abs(vec2(w.y, w.x)) / vec2(CURVE), vec2(2.0));
    w = w / 2.0 + 0.5;

    if (w.x < 0.0 || w.x > 1.0 || w.y < 0.0 || w.y > 1.0) {
        fragColor = vec4(0.0, 0.0, 0.0, 1.0);
        return;
    }

    vec4 base = texture(iChannel0, w);

    // 2. Partial phosphor tint (keeps contrast between diff bg and text)
    vec3 mono = luma(base.rgb) * phosphorColor * 1.15;
    vec3 color = mix(base.rgb, mono, TINT_AMOUNT);

    // 3. Glow — 3x3 tight kernel, only from brighter neighbours
    vec2 s = BLOOM_SPREAD / iResolution.xy;
    vec3 glow = vec3(0.0);
    for (int x = -1; x <= 1; x++) {
        for (int y = -1; y <= 1; y++) {
            if (x == 0 && y == 0) continue;
            vec3 n = texture(iChannel0, w + vec2(float(x), float(y)) * s).rgb;
            glow += max(n - base.rgb, 0.0);
        }
    }
    color += (glow / 8.0) * phosphorColor * BLOOM_STRENGTH;

    // 4. Scanlines
    float sl = 0.5 + 0.5 * sin(w.y * iResolution.y * (6.28318 / SCANLINE_PERIOD));
    color *= 1.0 - SCANLINE_STRENGTH * (1.0 - sl);

    // 5. Flicker
    color *= 1.0 - FLICKER_STRENGTH * (0.5 + 0.5 * sin(iTime * FLICKER_FREQ));

    // 6. Rolling bar
    float roll = fract(iTime * BAR_SPEED);
    float bar = pow(max(0.0, 1.0 - abs(fract(w.y + roll) - 0.5) * BAR_WIDTH), 3.0);
    color += color * bar * BAR_INTENSITY;

    // 7. Aperture grille
    color *= mix(1.0, 0.85 + 0.15 * sin(fragCoord.x * 1.5), GRILLE_STRENGTH);

    // 8. Grain
    color += (noise(w) - 0.5) * NOISE_STRENGTH * phosphorColor;

    // 9. Vignette
    float vig = w.x * w.y * (1.0 - w.x) * (1.0 - w.y);
    color *= pow(vig * 15.0, VIGNETTE_STRENGTH) * VIGNETTE_BRIGHTNESS;

    fragColor = vec4(clamp(color, 0.0, 1.0), base.a);
}
