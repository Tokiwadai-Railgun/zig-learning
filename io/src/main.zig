const std = @import("std");
const Io = std.Io;

pub fn main(init: std.process.Init) !void {
    const io = init.io;
    var write_buffer: [1024]u8 = undefined;
    var stdout_writer = std.Io.File.stdout().writer(io, &write_buffer);
    const stdout = &stdout_writer.interface;

    try stdout.print("Hello everyone\n", .{});


    // ------ Creating a file ------
    const cwd = std.Io.Dir.cwd();
    const file = try cwd.createFile(io, "test.txt", .{ .read = true }); // read option is not necessary for the creation, only used for the read operation coming later on
    defer file.close(io);

    _ = try file.writePositionalAll(io, "Hello there, i'm in the file\n", 0);


    // ------ Reading the created file ------
    var file_buf: [1024]u8 = undefined;
    @memset(file_buf[0..], 0);
    var file_reader = file.reader(io, &file_buf);
    const fr = &file_reader.interface;

    var gpa = std.heap.DebugAllocator(.{}){};
    const allocator = gpa.allocator();

    const file_len = try file.length(io);

    const file_content = try fr.readAlloc(allocator, file_len);
    defer allocator.free(file_content);

    try stdout.print("Wrote : \n\t{s}", .{file_content});
    try stdout.flush();
}
