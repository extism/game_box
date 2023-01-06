const test_main = @import("main.zig");
const test_game = @import("game.zig");

test {
    @import("std").testing.refAllDecls(@This());
}
