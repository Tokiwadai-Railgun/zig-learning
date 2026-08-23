const std = @import("std");
const Io = std.Io;
const Server = @import("server.zig").Server;
const Request=  @import("request.zig");
const SRequest = @import("request.zig").Request;
const Response = @import("response.zig");

const webserver = @import("webserver");

pub fn main(init: std.process.Init) !void {
    const io = init.io;
    const server = try Server.init(io, "127.0.0.1", 8080);
    var listen = try server.listen();

    var buffer: [1000]u8 = undefined;
    // infinite loop to handle infinite request
    while (true) {
        const conn = try listen.accept(io);
        defer conn.close(init.io);

        // @memset(&buffer, 0);
        try Request.read_request(io, conn, &buffer);

        const req=  try SRequest.parse_request(&buffer);
        req.print();

        try Response.send_200(conn, io);
    }
}
