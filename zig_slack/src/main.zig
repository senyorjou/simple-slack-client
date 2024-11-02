const std = @import("std");
const fmt = std.fmt;
const http = std.http;
const json = std.json;
const process = std.process;

const dt = @import("datetime.zig");

const Topic = struct { value: []const u9, creator: []const u8, last_set: u32 };
const Purpose = struct { value: []const u8, creator: []const u8, last_set: u32 };
const ResponseMetadata = struct { next_cursor: []const u8 };
const Channel = struct {
    id: []const u8,
    name: []const u8,
    is_channel: bool,
    is_group: bool,
    is_im: bool,
    created: u32,
    creator: []const u8,
    is_archived: bool,
    is_general: bool,
    unlinked: u8,
    name_normalized: []const u8,
    is_shared: bool,
    is_ext_shared: bool,
    is_org_shared: bool,
    pending_shared: [][]const u8,
    is_pending_ext_shared: bool,
    is_member: bool,
    is_private: bool,
    is_mpim: bool,
    updated: u64,
    topic: Topic,
    purpose: Purpose,
    previous_names: [][]const u8,
    num_members: u32,
};

const Channels = struct { ok: bool, channels: []Channel, response_metadata: ResponseMetadata };

pub fn main() !void {
    std.debug.print("Balena has memory\n", .{});

    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();

    try getSlackConversations(allocator);
}

pub fn getSlackConversations(allocator: std.mem.Allocator) !void {
    const url = comptime std.Uri.parse("https://slack.com/api/conversations.list") catch unreachable;
    const token = try process.getEnvVarOwned(allocator, "SLACK_TOKEN");
    defer allocator.free(token);

    // Create HTTP client
    var client = std.http.Client{ .allocator = allocator };
    defer client.deinit();

    var server_header_buffer: [8192]u8 = undefined; // 8kb
    var request = try client.open(.GET, url, .{
        .server_header_buffer = &server_header_buffer,
    });
    defer request.deinit();

    var authorization_header_buf: [64]u8 = undefined;
    const authorization_header = try fmt.bufPrint(&authorization_header_buf, "Bearer {s}", .{token});
    request.headers.authorization = .{ .override = authorization_header };

    try request.send();
    try request.finish();
    try request.wait();

    const body = try request.reader().readAllAlloc(allocator, 1024 * 1024);
    defer allocator.free(body);

    var arena_allocator = std.heap.ArenaAllocator.init(allocator);
    defer arena_allocator.deinit();
    const channels = try json.parseFromSliceLeaky(Channels, arena_allocator.allocator(), body, .{
        .allocate = .alloc_always,
        .ignore_unknown_fields = true,
    });

    std.debug.print("Number of channels: {d}\n", .{channels.channels.len});

    // List all channel names
    std.debug.print("Channel names:\n", .{});
    for (channels.channels) |channel| {
        std.debug.print("- {s} [{d}]\n", .{ channel.name, channel.num_members });
    }
    // std.debug.print("DT {s}", .{dt.timestampToDateTime(1727853324)});
}
