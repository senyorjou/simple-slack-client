const std = @import("std");
const epoch = std.time.epoch;

pub fn epochToDateStr(timestamp: u64) []const u8 {
    const secs = epoch.EpochSeconds{ .secs = timestamp };
    const day = secs.getEpochDay();
    const year_day = day.calculateYearDay();
    const month_day = year_day.calculateMonthDay();
    const month = month_day.month.numeric();

    const allocator = std.heap.page_allocator;
    const date_string = std.fmt.allocPrint(allocator, "{d}/{d:0>2}/{d:0>2}", .{ year_day.year, month, month_day.day_index }) catch unreachable;
    // defer allocator.free(date_string);
    return date_string;
}
