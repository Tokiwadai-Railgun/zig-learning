const std = @import("std");
const Stream = std.Io.net.Stream;
const Map = std.static_string_map.StaticStringMap;

pub const Method = enum { 
    GET,

    pub fn init(text: []const u8) !Method {
        return MethodMap.get(text).?;
    }

    pub fn is_supported(text: []const u8) bool {
        const method = MethodMap.get(text);

        if (method) |_| {
            return true;
        }

        return false;
    }

    pub fn print(self: Method) void {
        switch (self) {
            .GET => {
                std.debug.print("GET\n", .{});
            }
        }
    }
};
const MethodMap = Map(Method).initComptime(.{ .{ "GET", Method.GET } });

pub const Request = struct {
    method: Method,
    version: []const u8,
    uri: []const u8,

    pub fn init(method: Method,
                version: []const u8,
                uri: []const u8,) Request {
        return .{
            .method = method,
            .version = version,
            .uri = uri
        };
    }

    pub fn parse_request(req: []const u8) !Request {
        const line_end = std.mem.indexOfScalar(u8, req, '\n') orelse req.len;
        const line = req[0..line_end];
        var iterator = std.mem.splitScalar(u8, line, ' ');

        //  First line is : "GET / HTTP/1.1"
        //  Split :          ^__ ^ ^ 
        //                   1   2 3
        const method = try Method.init(iterator.next().?);
        const uri = iterator.next().?;
        const version = iterator.next().?;

        return Request.init(method, version, uri);
    }

    pub fn print(self: Request) void {
        std.debug.print("Method : ", .{});
        self.method.print();
        std.debug.print("Uri {s}\n", .{self.uri});
        std.debug.print("Version {s}\n", .{self.version});
    }
};

pub fn read_request(io: std.Io, stream: Stream, buffer: []u8) !void {
    var temp_buffer: [1024]u8 = undefined;
    var reader = stream.reader(io, &temp_buffer);
    const interface = &reader.interface;
    var start_index: usize = 0;

    for (0..5) |_| {
        const len = try read_next_line(interface, buffer, start_index);
        start_index = start_index + len;
    }
}

fn read_next_line(reader: *std.Io.Reader, buffer: []u8, start_index: usize) !usize {
    const next_line = try reader.takeDelimiterInclusive('\n');
    @memcpy(buffer[start_index..(start_index + next_line.len)], next_line);

    return next_line.len;
}
