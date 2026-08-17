//! The typeface data structure for sheetmapping

metrics: std.ArrayList(GlyphMetrics),
source: Source,

///Load a typeface from ttf
pub fn initFromTrueTypeMemory(
    ttf_memory: []const u8,
    allocator: std.mem.Allocator,
) !TypeFace {
    _ = allocator; // autofix
    const ttf = try TrueType.load(ttf_memory);
    _ = ttf; // autofix
}

pub fn deinit(
    typeface: *TypeFace,
    allocator: std.mem.Allocator,
) void {
    allocator.free(typeface.metrics);

    typeface.* = undefined;
}

///Requests the corresponding glyphs for the codepoints in utf8
pub fn requestGlyphsForCodepoints(utf8: []const u8) !void {
    _ = utf8; // autofix

}

pub const GlyphMetrics = extern struct {};

///Represents the source from which a typeface was constructed
pub const Source = union(enum) {
    ///The typeface does not have a source
    none,
    ///A sheetmap type face file
    sheetmap_tf,
    ///A true type file
    ttf: TrueType,
};

const TypeFace = @This();
const std = @import("std");
const TrueType = @import("TrueType");
