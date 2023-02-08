const std = @import("std");
const extism_pdk = @import("extism-pdk");
const Plugin = extism_pdk.Plugin;
const json = std.json;
const game = @import("game.zig");

const VAR_STATE = "state";

pub fn main() void {}

pub fn initGame(allocator: std.mem.Allocator, config: game.Config) !game.Game {
    var state: game.Game = undefined;
    try state.init(allocator, config.player_ids);
    return state;
}

const LiveEvent = struct {
    player_id: game.Player,
    event_name: []const u8,
    value: EventPayload,
};

const EventPayload = struct {
    prompt: [2][]const u8,
    pun: []const u8,
};

const EventUpdate = struct {
    state: game.Game,
    assigns: Assigns,
};

pub fn handleEvent(allocator: std.mem.Allocator, event: LiveEvent, state: *game.Game, update: *EventUpdate) !void {
    _ = allocator;
    _ = update;
    _ = state;

    if (std.mem.eql(u8, event.event_name, "submit-prompt")) {}

    return;
}

const Assigns = struct {
    is_judge: bool,
    is_winner: ?bool,
    submitted_pun: bool,
    current_round: u8,
};

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
    // defer json.parseFree(game.Config, config, .{ .allocator = plugin.allocator }); // TODO: this causes an out of bounds memory access

    var state = initGame(plugin.allocator, config) catch unreachable;

    plugin.setVar(VAR_STATE, state.toJson(plugin.allocator) catch unreachable);

    debugOutput(plugin, state);
    return 0;
}

fn debugOutput(plugin: Plugin, state: game.Game) void {
    plugin.output(state.toJson(plugin.allocator) catch unreachable);
}

export fn handle_event() i32 {
    var plugin = Plugin.init(std.heap.wasm_allocator);
    const input = plugin.getInput() catch unreachable;
    defer plugin.allocator.free(input);

    var stream = json.TokenStream.init(input);
    const event = json.parse(LiveEvent, &stream, .{ .allocator = plugin.allocator }) catch unreachable;
    defer json.parseFree(LiveEvent, event, .{ .allocator = plugin.allocator });

    const data = plugin.getVar(VAR_STATE) catch unreachable orelse return -1;
    var state: game.Game = undefined;
    state.fromJson(plugin.allocator, data) catch unreachable;

    var eventUpdate: EventUpdate = undefined;
    handleEvent(plugin.allocator, event, &state, &eventUpdate) catch unreachable;

    plugin.setVar(VAR_STATE, state.toJson(plugin.allocator) catch unreachable);

    return 0;
}

// export fn render(input: []const u8) i32 {
//     const assigns = json.parse(Assigns, input, .{});
//     return renderView(assigns);
// }
