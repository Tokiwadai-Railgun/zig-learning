const std = @import("std");
const Io = std.Io;

const b64encoder = @import("b64encoder");

pub fn main(init: std.process.Init) !void {
    const io = init.io;
    var stdout_buffer: [1024]u8 = undefined;
    var stdout_file_writer: Io.File.Writer = .init(.stdout(), io, &stdout_buffer);
    const stdout_writer = &stdout_file_writer.interface;

    const input = "aHi";
    var b64 = b64encoder.Base64.init();


    var gpa = std.heap.DebugAllocator(.{}){};
    const allocator = gpa.allocator();
    const output = try b64.encode(allocator, input);
    try stdout_writer.print("{s}\n", .{output});

    try stdout_writer.flush(); // Don't forget to flush!
}
