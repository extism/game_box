const std = @import("std");
const extism_pdk = @import("extism-pdk");
const Plugin = extism_pdk.Plugin;
const json = std.json;
const game = @import("game.zig");
const store = @import("store.zig");

const VAR_STATE = "state";

pub fn main() void {}

pub fn initGame(allocator: std.mem.Allocator, config: game.Config, state: store.Store) !i32 {
    var gameState: game.Game = undefined;
    try gameState.init(allocator, config.player_ids);
    state.set(VAR_STATE, try gameState.toJson(allocator));
    return 0;
}

const LiveEvent = struct {
    player_id: []const u8,
    value: EventPayload,
};

const EventPayload = struct {
    prompt_id: usize,
    pun: []const u8,
};

pub fn handleEvent(allocator: std.mem.Allocator, event: LiveEvent, state: store.Store) i32 {
    // var gameState = game.Game.fromJson(allocator, state.get(VAR_STATE));
    // _ = gameState;

    // switch (event.event_name) {}

    _ = allocator;
    _ = event;
    _ = state;

    return 0;
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

    var pluginStore = store.PluginStore.init(&plugin);
    var state = store.Store.init(&pluginStore);

    return initGame(plugin.allocator, config, state) catch -1;
}

export fn handle_event() i32 {
    var plugin = Plugin.init(std.heap.wasm_allocator);
    const input = plugin.getInput() catch unreachable;
    defer plugin.allocator.free(input);

    var stream = json.TokenStream.init(input);
    const event = json.parse(LiveEvent, &stream, .{ .allocator = plugin.allocator }) catch unreachable;
    defer json.parseFree(LiveEvent, event, .{ .allocator = plugin.allocator });

    var pluginStore = store.PluginStore.init(&plugin);
    var state = store.Store.init(&pluginStore);

    return handleEvent(plugin.allocator, event, state);
}

// export fn render(input: []const u8) i32 {
//     const assigns = json.parse(Assigns, input, .{});
//     return renderView(assigns);
// }
