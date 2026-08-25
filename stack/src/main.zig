const std = @import("std");
const Stack = @import("stack.zig");

const U32Stack = struct {
    capacity: usize,
    size: usize,
    array: []u32,
    allocator: std.mem.Allocator,

    fn initCapacity(allocator: std.mem.Allocator, capacity: usize) error{OutOfMemory}!U32Stack {
        var buf = try allocator.alloc(u32, capacity);
        return .{
            .capacity = capacity,
            .size = 0,
            .array = buf[0..],
            .allocator = allocator
        };
    }

    fn push(self: *U32Stack, elem: u32) !void {
        // WARNING: Function arguments are constants, therefore passing an argument here is the necessary tool
        if (self.capacity == self.size) {
            var new_array = try self.allocator.alloc(u32, self.capacity * 2);
            @memcpy(new_array[0..self.capacity], self.array);
            self.capacity *= 2;

            self.allocator.free(self.array);
            self.array = new_array[0..];
        }

        self.array[self.size] = elem;
        self.size += 1;
    }

    fn pop(self: *U32Stack) u32 {
        self.size -= 1;
        return self.array[self.size];
    }

    fn print_dbg(self: *U32Stack) void {
        for (0..self.size) |i| {
            std.debug.print("[{d}] - {d}\n", .{i, self.array[i]});
        }
    }

    pub fn deinit(self: *U32Stack) void {
        // useful function, especially whne you do not know what the object is made of. 
        // Will always exists in custom structs requiring an allocator to be init
        self.allocator.free(self.array);
    }
};

// TODO: write the stack implementation
pub fn main(_: std.process.Init) !void {
    var gpa = std.heap.DebugAllocator(.{}){};
    const allocator = gpa.allocator();
    var stack = try U32Stack.initCapacity(allocator, 4);
    defer stack.deinit(allocator);

    try stack.push(allocator, 2);
    try stack.push(allocator, 2);
    try stack.push(allocator, 3);
    try stack.push(allocator, 4);
    try stack.push(allocator, 5);

    stack.print_dbg();

    _ = stack.pop();
    stack.print_dbg();
}
