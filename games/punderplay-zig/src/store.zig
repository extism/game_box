const std = @import("std");
const extism_pdk = @import("extism-pdk");
const Plugin = extism_pdk.Plugin;
const json = std.json;
const game = @import("game.zig");

pub const PluginStore = struct {
    inner: *Plugin,

    const Self = @This();

    pub fn init(plugin: *Plugin) Self {
        return Self{ .inner = plugin };
    }

    pub fn get(self: Self, key: []const u8) []const u8 {
        return self.inner.getVar(key) catch unreachable orelse "";
    }

    pub fn set(self: Self, key: []const u8, value: []const u8) void {
        self.inner.setVar(key, value);
    }
};

pub const MockStore = struct {
    inner: std.StringHashMap([]const u8),

    const Self = @This();

    pub fn init(allocator: std.mem.Allocator) Self {
        return Self{
            .inner = std.StringHashMap([]const u8).init(allocator),
        };
    }

    pub fn deinit(self: *Self) void {
        self.inner.deinit();
    }

    pub fn get(self: Self, key: []const u8) []const u8 {
        return self.inner.get(key) orelse "";
    }

    pub fn set(self: *Self, key: []const u8, value: []const u8) void {
        self.inner.put(key, value) catch unreachable;
    }
};

// Thank you to Yigong Liu, and their post[0], without which I'd not have figured this out...
// 0: https://zig.news/yglcode/code-study-interface-idiomspatterns-in-zig-standard-libraries-4lkj
pub const Store = struct {
    ptr: *anyopaque,
    vtab: *const VTab,
    const VTab = struct {
        get: *const fn (ptr: *anyopaque, key: []const u8) []const u8,
        set: *const fn (ptr: *anyopaque, key: []const u8, value: []const u8) void,
    };

    pub fn get(self: Store, key: []const u8) []const u8 {
        return self.vtab.get(self.ptr, key);
    }

    pub fn set(self: Store, key: []const u8, value: []const u8) void {
        self.vtab.set(self.ptr, key, value);
    }

    pub fn init(store: anytype) Store {
        const Ptr = @TypeOf(store);
        const PtrInfo = @typeInfo(Ptr);
        std.debug.assert(PtrInfo == .Pointer);
        std.debug.assert(PtrInfo.Pointer.size == .One);
        std.debug.assert(@typeInfo(PtrInfo.Pointer.child) == .Struct);

        const alignment = PtrInfo.Pointer.alignment;
        const impl = struct {
            fn get(ptr: *anyopaque, key: []const u8) []const u8 {
                const self = @ptrCast(Ptr, @alignCast(alignment, ptr));
                return self.get(key);
            }

            fn set(ptr: *anyopaque, key: []const u8, value: []const u8) void {
                const self = @ptrCast(Ptr, @alignCast(alignment, ptr));
                self.set(key, value);
            }
        };

        return .{ .ptr = store, .vtab = &.{
            .get = impl.get,
            .set = impl.set,
        } };
    }
};

test "mock store" {
    var mock = MockStore.init(std.testing.allocator);
    defer mock.deinit();

    mock.set("some_key", "some_value");
    try std.testing.expectEqualStrings("some_value", mock.get("some_key"));
}

test "Store with MockStore" {
    var m = MockStore.init(std.testing.allocator);
    defer m.deinit();

    var store = Store.init(&m);
    store.set("some_key", "some_value");
    try std.testing.expectEqualStrings("some_value", store.get("some_key"));
}
