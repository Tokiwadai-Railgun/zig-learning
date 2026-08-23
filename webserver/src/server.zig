const std = @import("std");
const Socket = std.Io.net.Socket;
const Protocol = std.Io.net.Protocol;

pub const Server = struct {
    io: std.Io,
    address: std.Io.net.IpAddress,
    port: u16,
    host: []const u8,

    pub fn init(io: std.Io, host: []const u8, port: u16) !Server {
        const address = try std.Io.net.IpAddress.parseIp4(host, port);
        return .{ .io=io, .host=host, .port=port, .address=address};
    }

    pub fn listen(self: Server) !std.Io.net.Server {
        std.debug.print("Server listening on address : {s}:{d}\n", .{self.host, self.port});
        return try self.address.listen(self.io, .{ .mode = Socket.Mode.stream, .protocol=Protocol.tcp});
    }
};
