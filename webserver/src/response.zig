const std = @import("std");
const Stream = std.Io.net.Stream;

pub fn send_200(conn: *Stream, io: std.Io) !void {
    const message = (
        "HTTP/1.1 200 OK\r\nContent-Length: 49"
        ++ "\r\nContent-Type: text/html\n"
        ++ "Connection: Closed\r\n\n<html><body>"
        ++ "<h1>Hello, World!</h1></body></html>\r\n"
    );

    var stream_writer = conn.writer(io, &.{});
    _ = try stream_writer.interface.write(message);
}

pub fn send_500(conn: *Stream, io: std.Io) !void {
    const message = (
        "HTTP/1.1 500 Internal Server Error\r\nContent-Length: 57"
        ++ "\r\nContent-Type: text/html\n"
        ++ "Connection: Closed\r\n\n<html><body>"
        ++ "<h1>Internal Server Error</h1></body></html>\r\n"
    );

    var stream_writer = conn.writer(io, &.{});
    _ = try stream_writer.interface.write(message);
}

pub fn send_404(conn: *Stream, io: std.Io) !void {
    const message = (
        "HTTP/1.1 404 Not Found Error\r\nContent-Length: 46"
        ++ "\r\nContent-Type: text/html\n"
        ++ "Connection: Closed\r\n\n<html><body>"
        ++ "<h1>Not Found</h1></body></html>\r\n"
    );

    var stream_writer = conn.writer(io, &.{});
    _ = try stream_writer.interface.write(message);
}

pub fn send_405(conn: *Stream, io: std.Io) !void {
    const message = (
        "HTTP/1.1 405 Method Not Allowed\r\nContent-Length: 54"
        ++ "\r\nContent-Type: text/html\n"
        ++ "Connection: Closed\r\n\n<html><body>"
        ++ "<h1>Method Not allowed</h1></body></html>\r\n"
    );

    var stream_writer = conn.writer(io, &.{});
    _ = try stream_writer.interface.write(message);
}

