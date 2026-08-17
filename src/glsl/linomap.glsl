
#extension GL_EXT_shader_explicit_arithmetic_types : enable

#ifdef LINOMAP_BINDING_START
const uint linomap_linomaps_binding = LINOMAP_BINDING_START;
#else
const uint linomap_linomaps_binding = 0;
#endif

#ifdef LINOMAP_BINDING_STRIDE
const uint linomap_binding_stride = LINOMAP_BINDING_STRIDE;
#else
#define LINOMAP_BINDING_STRIDE 1
const uint linomap_binding_stride = 1;
#endif

const uint linomap_quadrats_binding = linomap_linomaps_binding + linomap_binding_stride;
const uint linomap_lines_binding = linomap_quadrats_binding + linomap_binding_stride;

const uint linomap_binding_end = linomap_lines_binding;

struct Linomap {
    uint quadrat_buffer_begin;
    uint kern_buffer_begin;
    uint foreground_buffer_begin;
    uint background_buffer_begin;
    ///Width and height in ems
    uint width;
    uint height;
};

struct LinomapSampler {
    ///X spacing (glyph spacing) in ems
    float spacing_x;
    ///Y spacing (line spacing) in ems
    float spacing_y;
    //The rotation applied from uv -> quadrat space
    vec2 uv_rotation_quadrat;
    //The rotation applied from quadrat space -> glyph space
    vec2 uv_rotation_glyph;
    //Global colour of the text
    uint foreground_colour;
    //Global colour of the background sheet
    uint background_colour;
    //The backing texel sampler for this linomap sampler
    uint typeface_texel_sampler;
    //The typeface for this linomap sampler
    uint typeface;
};

const uint LinomapSamplerWrappingMode_repeat = 0;
const uint LinomapSamplerWrappingMode_repeat_mirrored = 1;
const uint LinomapSamplerWrappingMode_clamp_to_border = 2;
const uint LinomapSamplerWrappingMode_clamp_to_edge = 3;
//Return the background colour when sampling out of the uv interval [0, 1]
const uint LinomapSamplerWrappingMode_background = 4;

struct CombinedLinomapSampler {
    Linomap linomap;
    LinomapSampler linomap_sampler;
};

layout(binding = linomap_linomaps_binding) readonly restrict buffer Linomaps {
    Linomap data[];
} linomaps;

struct LinomapQuadrat {
    ///4 bits count + 28 bits address
    uint grapheme_slice;
};

layout(binding = linomap_quadrats_binding) readonly restrict buffer LinomapQuadrats {
    LinomapQuadrat data[];
} linomap_quadrats;

const uint LinomapLineFlags_centred = 1 << 16;
const uint LinomapLineFlags_left_justified = 1 << 15;
const uint LinomapLineFlags_right_justified = 1 << 14;

struct GraphemeLine {
    //The length of the line that has glyphs committed to them
    uint32_t buffer_begin;
    uint8_t flags;
    uint8_t bin_start;
    uint8_t bins_length;
};

layout(binding = linomap_quadrats_binding + 1) readonly restrict buffer GlyphLines {
    GraphemeLine data[];
} grapheme_lines;

struct Glyph {
    uint16_t glyph_index;
};

struct GlyphKerning {
    float16_t kern;
};

layout(binding = linomap_quadrats_binding + 2) readonly restrict buffer GlyphInstances {
    Glyph data[];
} glyphs;

struct GraphemeMaterial {
    uint colour;
};

layout(binding = linomap_quadrats_binding + 3) readonly restrict buffer GraphemeMaterialBuffers {
    GraphemeMaterial data[];
} grapheme_materials;

struct GlyphMetric {
    float width;
    float height;
    float advance;
    float bearing_x;
    float bearing_y;
};

struct LinomapTypeface {
    uint glyph_metrics_begin;
    uint glyph_metrics_count;
    float baseline;
    float ascent;
    float descent;
    float line_gap;
};

layout(binding = linomap_quadrats_binding + 4) readonly restrict buffer GlyphMetrics {
    GlyphMetric data[];
} glyph_metrics;

//Sample a glyph from the linomap at uv
Glyph linomapSampleGlyph(
    CombinedLinomapSampler linomap,
    vec2 uv
) {
    return Glyph(uint16_t(0));
}

Glyph linomapLoadGlyph(
    Linomap linomap,
    uvec2 location
) {
    return Glyph(uint16_t(0));
}

void linomapStoreGlyph(
    Linomap linomap,
    uvec2 location,
    Glyph glyph
) {}

#ifdef LINOMAP_TEXEL_SAMPLER

vec4 linomapSampleGlyphTexelLod(
    CombinedlinomapSampler linomap_sampler,
    Glyph glyph,
    vec2 uv,
    uint lod
);

vec4 linomapSampleGlyphTexel(
    CombinedlinomapSampler linomap_sampler,
    Glyph glyph,
    vec2 uv
);

//Sample a texel from the linomap at uv at the specified level of detail
vec4 linomapSampleTexelLod(
    CombinedLinomapSampler linomap,
    vec2 uv,
    uint lod
) {
    return vec4(0);
}

//Sample a texel from the linomap at uv
vec4 linomapSampleTexel(
    CombinedLinomapSampler linomap_sampler,
    vec2 uv
) {
    vec2 texCoord = uv;
    //TODO: apply wrapping modes
    texCoord = texCoord - floor(texCoord);

    Linomap linomap = linomap_sampler.linomap;

    texCoord.y = 1 - texCoord.y;

    vec2 grapheme_buffer_loc = texCoord * vec2(linomap.width, linomap.height);
    vec2 glyph_uv = grapheme_buffer_loc - floor(grapheme_buffer_loc);
    uint grapheme_bin_index = uint(grapheme_buffer_loc.x) + uint(grapheme_buffer_loc.y) * linomap.width;

    LinomapQuadrat bin = linomap_quadrats.data[linomap.quadrat_buffer_begin + grapheme_bin_index];

    uint glyph_index = bin.grapheme_slice;

    GlyphMetric metrics = glyph_metrics.data[glyph_index];

    vec4 texel = linomapSampleGlyphTexel(linomap_sampler, Glyph(uint16_t(glyph_index)), glyph_uv);

    return texel;
}

#endif
