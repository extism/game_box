const std = @import("std");
const deps = @import("deps.zig");

pub fn build(b: *std.build.Builder) void {
    const mode = b.standardReleaseOptions();
    // const target = b.standardTargetOptions(.{ .default_target = .{ .cpu_arch = .wasm32, .os_tag = .freestanding } });
    const target = b.standardTargetOptions(.{
        .default_target = .{ .abi = .musl, .os_tag = .freestanding, .cpu_arch = .wasm32 },
    });
    const exe = b.addExecutable("punderplay", "src/main.zig");
    exe.setTarget(target);
    exe.setBuildMode(mode);
    deps.addAllTo(exe);
    exe.install();

    const game_tests = b.addTest("src/game.zig");
    deps.addAllTo(game_tests);

    const store_tests = b.addTest("src/store.zig");
    deps.addAllTo(store_tests);

    const game_test_step = b.step("test-game", "run `game` tests");
    game_test_step.dependOn(&game_tests.step);

    const store_test_step = b.step("test-store", "run `store` tests");
    store_test_step.dependOn(&store_tests.step);
}
