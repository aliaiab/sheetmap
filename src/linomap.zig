pub const Context = struct {};

///Compute the sheetmap bounds (width and height in ems) for a given string
pub fn computeBoundsForText(
    text_buffer: TextBuffer,
) [2]f32 {
    _ = text_buffer; // autofix
    return @splat(0);
}

pub const ConstructFromTextOptions = packed struct(u32) {
    enable_terminal_colours: bool = true,
    _: u31 = 0,
};

///Allocate and construct a sheetmap from a utf8 string
pub fn constructFromText(
    context: *Context,
    text_buffer: TextBuffer,
    options: ConstructFromTextOptions,
) void {
    _ = options; // autofix
    _ = text_buffer; // autofix
    _ = context; // autofix
}

///Update a sheetmap line range with a utf8 string
pub fn updateFromText(
    context: *Context,
    text_buffer: TextBuffer,
    options: ConstructFromTextOptions,
) void {
    _ = options; // autofix
    _ = text_buffer; // autofix
    _ = context; // autofix
}

pub const CommandBuffer = struct {};

pub fn encodeConstructFromTextCommand(
    command_buffer: *CommandBuffer,
    text_buffer: TextBuffer,
) void {
    _ = text_buffer; // autofix
    _ = command_buffer; // autofix
}

pub fn encodeUpdateFromTextCommand(
    command_buffer: *CommandBuffer,
    text_buffer: TextBuffer,
) void {
    _ = text_buffer; // autofix

    _ = command_buffer; // autofix
}

pub const Linomap = extern struct {
    quadrat_buffer_begin: u32 = 0,
    kern_buffer_begin: u32 = 0,
    foreground_buffer_begin: u32 = 0,
    bakcground_buffer_begin: u32 = 0,
    width: u32,
    height: u32,
};

pub const LinomapSampler = extern struct {
    spacing_x: f32,
    spacing_y: f32,
    uv_rotation_quadrat: [2]f32,
    uv_rotation_glyph: [2]f32,
    foreground_colour: u32,
    background_colour: u32,
    typeface_texel_sampler: u32,
    typeface: u32,
};

pub const CombinedSheetmapSampler = extern struct {
    map: Linomap,
    sampler: LinomapSampler,
};

pub const TextBuffer = extern struct {
    codepoints: []const u8,
    lines: []u32 = &.{},
    line_lengths: []u16 = &.{},
    cluster_begins: []u32 = &.{},
    cluster_lengths: []u32 = &.{},
    line_strips: []LineStrip = &.{},
    format: Format = .codepoint_buffer,
    codepoint_format: CodepointFormat = .utf8,

    pub const LineStrip = struct {
        element_types: std.bit_set.IntegerBitSet(8),
        elements: [15]u8,

        pub const ElementType = enum(u8) {
            codepoint = 0,
            codepoint_cluster = 1,
        };
    };

    pub const CodepointFormat = enum {
        ascii,
        utf8,
        utf16,
    };

    pub const Format = enum {
        codepoint_buffer,
        codepoint_cluster_buffer,
    };

    pub const ClusterIndex = enum(u16) {
        whitespace,
        _,
    };
};

pub const Typeface = @import("Typeface.zig");

const std = @import("std");
