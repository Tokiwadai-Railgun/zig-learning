const std = @import("std");

pub fn build(b: *std.Build) void {
    const version:std.SemanticVersion = .{ .major = 0, .minor = 0, .patch = 0, .pre = "pre 1" };

    const is_prod = b.option(bool, "production", "Should we build to produciton ? (uses a different optimisation method)") orelse false;

    var exe: *std.Build.Step.Compile = undefined;
    if (is_prod) {
        exe = b.addExecutable(.{
            .name = "stack_production",
            .root_module = b.createModule(.{
                .root_source_file = b.path("src/main.zig"),
                .target = b.graph.host,
                .optimize = .ReleaseSafe
            }),
            .version = version
        });
        b.installArtifact(exe);

    } else {
        exe = b.addExecutable(.{
            .name = "stack",
            .root_module = b.createModule(.{
                .root_source_file = b.path("src/main.zig"),
                .target = b.graph.host,
                .optimize = .Debug
            }),
            .version = version
        });

        b.installArtifact(exe);
    }


    const test_exe = b.addTest(.{
        .name = "unit_test",
        .root_module = b.createModule(.{
            .root_source_file = b.path("src/main.zig"),
            .target = b.graph.host
        }),
    });


    const run_arti = b.addRunArtifact(exe);
    const run_step = b.step("run", "Run the project");
    run_step.dependOn(&run_arti.step);

    const test_arti = b.addRunArtifact(test_exe);
    const test_step = b.step("test", "Run each test blocks");
    test_step.dependOn(&test_arti.step);
}
