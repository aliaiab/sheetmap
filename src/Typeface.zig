//! The typeface data structure for sheetmapping

//TODO: use a segmented list
metrics: std.ArrayList(GlyphMetrics),
codepoints_to_glyph_indices: std.AutoArrayHashMapUnmanaged(u21, GlyphIndex),
source: Source,

///Load a typeface from ttf
pub fn initFromTrueTypeMemory(
    ttf_memory: []const u8,
    allocator: std.mem.Allocator,
) !TypeFace {
    _ = allocator; // autofix
    const ttf = try TrueType.load(ttf_memory);

    return .{
        .metrics = .empty,
        .codepoints_to_glyph_indices = .empty,
        .source = .{
            .ttf = .{
                .truetype = ttf,
            },
        },
    };
}

pub fn deinit(
    typeface: *TypeFace,
    allocator: std.mem.Allocator,
) void {
    typeface.source.deinit(allocator);
    typeface.codepoints_to_glyph_indices.deinit(allocator);
    typeface.metrics.deinit(allocator);

    typeface.* = undefined;
}

///Maps the corresponding glyphs for the codepoints in utf8 and optionally applies kerning
pub fn mapGlyphsForCodepoints(
    typeface: *TypeFace,
    allocator: std.mem.Allocator,
    wtf8: []const u8,
    ///The glyph buffer to write the glyph indices to
    glyph_buffer: []GlyphIndex,
    ///An optional kern buffer, set to &.{} to specify no kerning
    kern_buffer: []f16,
) !void {
    var wtf8_iterator: std.unicode.Wtf8Iterator = .{
        .bytes = wtf8,
        .i = 0,
    };

    var glyph_index: usize = 0;

    //TODO: simd
    while (wtf8_iterator.nextCodepoint()) |codepoint| {
        if (typeface.codepoints_to_glyph_indices.get(codepoint)) |mapped_glyph| {
            glyph_buffer[glyph_index] = mapped_glyph;
        } else {
            //Load the glyph and map it
            glyph_buffer[glyph_index] = try typeface.source.mapCodepointToGlyph(
                allocator,
                &typeface.metrics,
                codepoint,
            );
        }

        glyph_index += 1;
    }

    if (kern_buffer.len != 0) {
        for (
            glyph_buffer[0 .. glyph_buffer.len - 1],
            glyph_buffer[1..],
            0..,
        ) |
            glyph_a,
            glyph_b,
            pair_index,
        | {
            kern_buffer[pair_index] = typeface.source.applyKerning(glyph_a, glyph_b);
        }
    }
}

pub const GlyphMetrics = extern struct {
    //The advance in em-space
    advance: f32,
};

///Represents the source from which a typeface was constructed
pub const Source = union(enum) {
    ///The typeface does not have a source
    none,
    ///A sheetmap type face file
    sheetmap_tf,
    ///A true type file
    ttf: struct {
        truetype: TrueType,
        glyph_map: std.AutoHashMapUnmanaged(TrueType.GlyphIndex, GlyphIndex) = .empty,
    },

    pub fn deinit(source: Source, allocator: std.mem.Allocator) void {
        _ = allocator; // autofix
        switch (source) {
            .none, .sheetmap_tf => {},
            .ttf => |ttf| {
                _ = ttf; // autofix

            },
        }
    }

    pub fn mapCodepointToGlyph(
        source: Source,
        allocator: std.mem.Allocator,
        glyph_metrics: *std.ArrayList(GlyphMetrics),
        codepoint: u21,
    ) !GlyphIndex {
        switch (source) {
            //TODO: handle these cases
            .none => unreachable,
            .sheetmap_tf => unreachable,
            .ttf => |ttf| {
                const ttf_glyph_index = ttf.truetype.codepointGlyphIndex(codepoint);

                const query = try ttf.glyph_map.getOrPut(allocator, ttf_glyph_index);
                if (!query.found_existing) {
                    query.value_ptr.* = @enumFromInt(@as(u16, @intCast(glyph_metrics.items.len)));

                    const horizontal_metrics = ttf.truetype.glyphHMetrics(ttf_glyph_index);

                    glyph_metrics.append(allocator, .{
                        .advance = horizontal_metrics.advance_width,
                    });
                }

                return query.value_ptr.*;
            },
        }
    }

    pub fn applyKerning(typeface: Source, lhs: GlyphIndex, rhs: GlyphIndex) f16 {
        switch (typeface) {
            //TODO: handle these cases
            .none, .sheetmap_tf => unreachable,
            .ttf => |ttf| {
                const lhs_ttf = ttf.glyph_map.get(lhs).?;
                const rhs_ttf = ttf.glyph_map.get(rhs).?;

                const advance = ttf.truetype.glyphKernAdvance(lhs_ttf, rhs_ttf);

                return @as(f32, @floatFromInt(advance)) / @as(f32, std.math.maxInt(i16));
            },
        }
    }
};

pub const GlyphIndex = enum(u16) {
    //Represents an empty glyph
    null = std.math.maxInt(u16),
    _,
};

const TypeFace = @This();
const std = @import("std");
const TrueType = @import("TrueType");
