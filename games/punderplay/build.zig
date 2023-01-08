const std = @import("std");
const deps = @import("deps.zig");

pub fn build(b: *std.build.Builder) void {
    const mode = b.standardReleaseOptions();
    const target = b.standardTargetOptions(.{ .default_target = .{ .cpu_arch = .wasm32, .os_tag = .freestanding } });
    const exe = b.addExecutable("punderplay", "src/main.zig");
    exe.setTarget(target);
    exe.setBuildMode(mode);
    deps.addAllTo(exe);
    exe.install();

    const game_tests = b.addTest("src/game.zig");
    deps.addAllTo(game_tests);
    game_tests.setBuildMode(mode);

    const test_step = b.step("test-game", "run `game` tests");
    test_step.dependOn(&game_tests.step);
}
