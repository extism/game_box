const std = @import("std");
const extism_pdk = @import("extism-pdk");
const Plugin = extism_pdk.Plugin;
const json = std.json;
const game = @import("game.zig");

pub fn main() void {}

pub fn initGame(config: game.Config, plugin: *Plugin) i32 {
    const game_state = game.Game.init(plugin.allocator, config.player_ids);
    const data = game_state.to_json();
    plugin.output(data);
    return 0;
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

pub fn handleEvent(event: LiveEvent) i32 {
    _ = event;
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

    return initGame(config, &plugin);
}

// export fn handle_event(input: []const u8) i32 {
//     const event = json.parse(LiveEventEvent, input, .{}) catch unreachable;
//     return handleEvent(event);
// }

// export fn render(input: []const u8) i32 {
//     const assigns = json.parse(Assigns, input, .{});
//     return render(assigns);
// }
