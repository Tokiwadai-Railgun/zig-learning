const std = @import("std");
const Server = @import("server.zig").Server;
const Route = @import("routes.zig").Route;
const Request = @import("request.zig").Request;

const webserver = @import("webserver");

pub fn main(init: std.process.Init) !void {
    const io = init.io;
    var server = try Server.init(io, "127.0.0.1", 8080);
    
    var gpa = std.heap.DebugAllocator(.{}){};
    const allocator = gpa.allocator();

    var registery = std.StringHashMap(*Route).init(allocator);

    var root_route = try Route.init("/", &registery);
    root_route.register_get(simplified_handler);

    try server.listen(&registery);
}

pub fn simplified_handler() !void {
    std.debug.print("This is a function", .{});
}

pub fn root_handler(io: std.Io, ctx: *Request, stream: *std.Io.net.Stream) !void {
    _ = io;
    _ = stream;
    std.debug.print("Request Received on {s}", .{ ctx.uri});
}
