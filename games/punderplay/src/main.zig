const std = @import("std");
const extism_pdk = @import("extism-pdk");
const Plugin = extism_pdk.Plugin;
const json = std.json;
const game = @import("game.zig");

const VAR_STATE = "state";

pub fn main() void {}

pub fn initGame(config: game.Config, allocator: std.mem.Allocator) game.Game {
    return game.Game.init(allocator, config.player_ids);
}

const LiveEvent = struct {
    player_id: []const u8,
    event_name: []const u8,
    value: EventPayload,
};

const EventPayload = struct {
    prompt_id: usize,
    pun: []const u8,
};

pub fn handleEvent(event: LiveEvent, state: *game.Game) *game.Game {
    // switch (event.event_name) {}
    _ = event;

    return state;
}

const Assigns = struct {};

pub fn renderView(data: Assigns) i32 {
    _ = data;
    return 0;
}

export fn init_game() i32 {
    var plugin = Plugin.init(std.heap.wasm_allocator);
    const input = plugin.getInput() catch unreachable;
    defer plugin.allocator.free(input);

    var stream = json.TokenStream.init(input);
    const config = json.parse(game.Config, &stream, .{ .allocator = plugin.allocator }) catch unreachable;
    defer json.parseFree(game.Config, config, .{ .allocator = plugin.allocator });

    var gameState = initGame(config, plugin.allocator);
    defer gameState.deinit();

    plugin.setVar(VAR_STATE, gameState.to_json());

    return 0;
}

export fn handle_event() i32 {
    var plugin = Plugin.init(std.heap.wasm_allocator);
    const input = plugin.getInput() catch unreachable;
    defer plugin.allocator.free(input);

    var stream = json.TokenStream.init(input);
    const event = json.parse(LiveEvent, &stream, .{ .allocator = plugin.allocator }) catch unreachable;
    defer json.parseFree(LiveEvent, event, .{ .allocator = plugin.allocator });

    var gameState = game.Game.from_json(plugin.allocator, plugin.getVar(VAR_STATE) catch unreachable orelse "{}");
    defer gameState.deinit();

    var newGameState = handleEvent(event, &gameState);
    defer newGameState.deinit();

    plugin.setVar(VAR_STATE, newGameState.*.to_json());

    return 0;
}

// export fn render(input: []const u8) i32 {
//     const assigns = json.parse(Assigns, input, .{});
//     return renderView(assigns);
// }
