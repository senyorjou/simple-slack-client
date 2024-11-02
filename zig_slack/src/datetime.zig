const std = @import("std");

const DateTime = struct {
    year: u16,
    month: u8,
    day: u8,
    hour: u8,
    minute: u8,
    second: u8,
};

pub fn timestampToDateTime(timestamp: u64) DateTime {
    const epoch_seconds = timestamp;
    const epoch = std.time.epoch.EpochSeconds{ .secs = epoch_seconds };
    const epoch_day = epoch.getEpochDay();
    const day_seconds = epoch.getDaySeconds();

    const year_day = std.time.epoch.YearAndDay.fromEpochDay(epoch_day);
    const month_day = std.time.epoch.MonthAndDay.fromYearDay(year_day.year, year_day.day);
    const time = std.time.epoch.SecondsInDay.fromSeconds(day_seconds);

    return DateTime{
        .year = year_day.year,
        .month = month_day.month,
        .day = month_day.day,
        .hour = time.getHoursIntoDay(),
        .minute = time.getMinutesIntoHour(),
        .second = time.getSecondsIntoMinute(),
    };
}
