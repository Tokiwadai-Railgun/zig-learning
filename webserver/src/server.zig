const std = @import("std");
const Request = @import("request.zig");
const Response = @import("response.zig");
const Socket = std.Io.net.Socket;
const Protocol = std.Io.net.Protocol;
const Stream = std.Io.net.Stream;


const DelimiterError = std.Io.Reader.DelimiterError;

/// Number of tasks handling connections
const parallel_workers = 3;

const queu_size = 100;
const Queue = std.Io.Queue(*Stream);

pub const Server = struct {
    io: std.Io,
    address: std.Io.net.IpAddress,
    port: u16,
    host: []const u8,

    pub fn init(io: std.Io, host: []const u8, port: u16) !Server {
        const address = try std.Io.net.IpAddress.parseIp4(host, port);
        return .{ .io=io, .host=host, .port=port, .address=address };
    }

    pub fn listen(self: *Server) !void {
        // Configure queue
        var queu_buffer: [queu_size]*Stream = undefined;
        var queue = std.Io.Queue(*Stream).init(&queu_buffer);

        var group = std.Io.Group.init;
        defer group.cancel(self.io);

        var server = try self.address.listen(self.io, .{ .mode = Socket.Mode.stream, .protocol=Protocol.tcp});
        std.debug.print("Server listening on address : {s}:{d}\n", .{self.host, self.port});

        group.async(self.io, acceptConnections, .{self.io, &queue, &server});
        for (0..parallel_workers) |_| {
            group.async(self.io, handleConnctions, .{self.io, &queue});
        }


        try group.await(self.io);
    }

    pub fn handleConnctions(io: std.Io, queue: *Queue) error{Canceled}!void {
        var buffer: [1000]u8 = undefined;
        while (true) {
            const stream = queue.getOne(io) catch |err| switch (err) {
                error.Canceled => return error.Canceled,
                else => return
            };
            defer stream.close(io);

            Request.read_request(io, stream, buffer[0..]) catch {
                Response.send_500(stream, io) catch { return; };
            };

            const req = Request.Request.parse_request(&buffer) catch {
                Response.send_500(stream, io) catch { return; };
            };
            req.print();

            Response.send_200(stream, io) catch { return; };
        }
    }

    pub fn acceptConnections(io: std.Io, queue: *Queue, server: *std.Io.net.Server) !void {
        while (true) {
            var stream = server.accept(io) catch |err| switch (err) {
                error.Canceled => return error.Canceled,
                else => return
            };

            queue.putOne(io, &stream) catch |err| switch (err) {
                error.Canceled => return error.Canceled,
                error.Closed => return
            };
        }
    }
};
