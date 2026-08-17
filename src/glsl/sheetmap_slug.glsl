vec4 sheetmapSampleGlyphTexelLod(
    CombinedSheetmapSampler sampler,
    Glyph glyph,
    vec2 uv,
    uint lod
) {
    return vec4(0);
}

vec4 sheetmapSampleGlyphTexel(
    CombinedSheetmapSampler sampler,
    Glyph glyph,
    vec2 uv
) {
    GlyphMetric metrics = glyph_metrics.data[glyph.glyph_index];

    vec2 texCoord = uv;
    texCoord.y += 0.25;
    texCoord.y += metrics.bearing_y;

    float em_width = glyph_metrics.data[77].width;
    texCoord.x *= em_width;
    texCoord.x /= textureSize(sheetmap_msdf_array, 0).x;

    float glyph_deadspace = em_width - metrics.width;
    glyph_deadspace *= 0.5;

    texCoord.x -= glyph_deadspace / em_width;

    return colour;
}
