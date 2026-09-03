const std = @import("std");
const Stream = std.Io.net.Stream;

pub fn send_200(conn: *Stream, io: std.Io) !void {
    const message = (
        "HTTP/1.1 200 OK\nContent-Length: 49"
        ++ "\nContent-Type: text/html\n"
        ++ "Connection: Closed\n\n<html><body>"
        ++ "<h1>Hello, World!</h1></body></html>\n"
    );

    var stream_writer = conn.writer(io, &.{});
    _ = try stream_writer.interface.write(message);
}

pub fn send_500(conn: *Stream, io: std.Io) !void {
    const message = (
        "HTTP/1.1 500 Internal Server Error\nContent-Length: 57"
        ++ "\nContent-Type: text/html\n"
        ++ "Connection: Closed\n\n<html><body>"
        ++ "<h1>Internal Server Error</h1></body></html>\n"
    );

    var stream_writer = conn.writer(io, &.{});
    _ = try stream_writer.interface.write(message);
}
