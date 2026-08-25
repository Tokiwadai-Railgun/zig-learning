const std = @import("std");

pub fn Stack(comptime T: type) type {
    return struct {
        capacity: usize,
        size: usize,
        array: []T,
        allocator: std.mem.Allocator,
        const Self = @This();

        pub fn init(allocator: std.mem.Allocator, 
            capacity: usize) error{OutOfMemory}!Self {
            var array = try allocator.alloc(T, capacity);
            return .{
                .capacity = capacity,
                .size = 0,
                .array = array[0..],
                .allocator = allocator
            };
        }

        fn push(self: *Self, elem: T) !void {
            // WARNING: Function arguments are constants, therefore passing an argument here is the necessary tool
            if (self.capacity == self.size) {
                var new_array = try self.allocator.alloc(T, self.capacity * 2);
                @memcpy(new_array[0..self.capacity], self.array);
                self.capacity *= 2;

                self.allocator.free(self.array);
                self.array = new_array[0..];
            }

            self.array[self.size] = elem;
            self.size += 1;
        }

        fn pop(self: *Self) u32 {
            self.size -= 1;
            return self.array[self.size];
        }

        fn print_dbg(self: *Self) void {
            for (0..self.size) |i| {
                std.debug.print("[{d}] - {d}\n", .{i, self.array[i]});
            }
        }

        pub fn deinit(self: *Self) void {
            self.allocator.free(self.array);
        }
    };
}

test "Testing Generic implementation on U8" {
    const allocator = std.testing.allocator;
    const u8Stack = Stack(u8);
    var stack = try u8Stack.init(allocator, 3);
    defer stack.deinit();

    try stack.push(1);
    try stack.push(2);
    try stack.push(3);
    try stack.push(4);

    try std.testing.expectEqual(4, stack.pop());
}
