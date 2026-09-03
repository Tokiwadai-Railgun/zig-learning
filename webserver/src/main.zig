const std = @import("std");
const Io = std.Io;
const Server = @import("server.zig").Server;
const Request=  @import("request.zig");
const SRequest = @import("request.zig").Request;
const Response = @import("response.zig");

const webserver = @import("webserver");

pub fn main(init: std.process.Init) !void {
    const io = init.io;
    var server = try Server.init(io, "127.0.0.1", 8080);
    try server.listen();
}
