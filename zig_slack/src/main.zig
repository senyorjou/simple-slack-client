const std = @import("std");
const fmt = std.fmt;
const http = std.http;
const json = std.json;
const process = std.process;

const time = std.time;
const epoch = std.time.epoch;

const slack_client = @import("client.zig");
const dt = @import("datetime.zig");

const schemas = @import("schemas.zig");

pub fn main() !void {
    std.debug.print("Balena has memory\n", .{});

    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();
    const client = try slack_client.Client.init(allocator);
    defer client.deinit();

    var channels: schemas.Channels = undefined;
    var arena: std.heap.ArenaAllocator = undefined;
    try client.getChannels(&channels, &arena);
    defer arena.deinit();

    std.debug.print("Number of channels: {d}\n", .{channels.channels.len});
    std.debug.print("Created\t\tUpdated\t\tMembers\tName\n", .{});
    for (channels.channels) |channel| {
        const created = dt.epochToDateStr(channel.created);
        const updated = dt.epochToDateStr(channel.updated / 1000);
        std.debug.print("{s}\t{s}\t[{d}]\t{s}\n", .{ created, updated, channel.num_members, channel.name });
    }
}
