pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    const truetype = b.dependency("TrueType", .{
        .target = target,
        .optimize = optimize,
    });

    const mod = b.addModule("sheetmap", .{
        .root_source_file = b.path("src/sheetmap.zig"),
        .target = target,
    });

    mod.addImport("TrueType", truetype.module("TrueType"));

    const build_examples = b.option(bool, "examples", "Build the examples") orelse false;

    if (build_examples) {
        if (b.lazyDependency("sokol", .{
            .target = target,
            .optimize = optimize,
        })) |sokol| {
            const exe = b.addExecutable(.{
                .name = "sheetmap-zoo",
                .root_module = b.createModule(.{
                    .root_source_file = b.path("examples/zoo/main.zig"),
                    .target = target,
                    .optimize = optimize,
                    .imports = &.{
                        .{ .name = "sheetmap", .module = mod },
                        .{ .name = "sokol", .module = sokol.module("sokol") },
                    },
                }),
            });

            b.installArtifact(exe);
        }
    }

    const mod_tests = b.addTest(.{
        .root_module = mod,
    });

    const run_mod_tests = b.addRunArtifact(mod_tests);

    const test_step = b.step("test", "Run tests");
    test_step.dependOn(&run_mod_tests.step);
}

const std = @import("std");
