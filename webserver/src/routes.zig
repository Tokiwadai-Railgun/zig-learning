const std = @import("std");
const Request = @import("request.zig");

pub const QueryParameter = struct {
    name: []const u8,
    value: []const u8
};

pub const Registery = std.StringHashMap(*Route);

pub fn retrieve_handler(registery: *Registery, path: []const u8, method: Request.Method) error{MethodNotAllowed, NotFound}!Handler {
    const route = registery.get(path);
    if (route) |r| {
        switch (method) {
            .GET => {
                if (r.get_handler) |handler| {
                    return handler;
                } else {
                    return error.MethodNotAllowed;
                }
            },
            .PUT => {
                if (r.put_handler) |handler| {
                    return handler;
                } else {
                    return error.MethodNotAllowed;
                }
            },
            .POST => {
                if (r.post_handler) |handler| {
                    return handler;
                } else {
                    return error.MethodNotAllowed;
                }
            },
            .DELETE => {
                if (r.delete_handler) |handler| {
                    return handler;
                } else {
                    return error.MethodNotAllowed;
                }
            }
        }

        return error.MethodNotAllowed;
    } 

    return error.NotFound;
}

// Need to get the current route
// Need to parse url parameters

// pub const Handler = *const fn (std.Io, *Request.Request, *std.Io.net.Stream) anyerror!void;
pub const Handler = *const fn() anyerror!void;

pub const Route = struct {
    path: []const u8,
    registery: *Registery,
    get_handler: ?Handler,
    post_handler: ?Handler,
    put_handler: ?Handler,
    delete_handler: ?Handler,
        // Multiple others methods can be added, only the basics are present here

    pub fn init(path: []const u8, registery: *Registery) !Route {
        var route: Route = .{
            .path = path,
            .registery = registery,
            .get_handler = null,
            .post_handler = null,
            .put_handler = null,
            .delete_handler = null
        };
        try registery.put(path, &route);
        return route;
    }
    pub fn register_get(self: *Route, handler: Handler) void {
        self.get_handler = handler;
    }
};
