const std = @import("std");

const Docker = struct {
    host: []const u8,
    root_password: []const u8
};

const Podman = struct {
    host: []const u8,
    username: []const u8,
    user_password: []const u8
};

const ContainerSoftware = union(enum) {
    docker: Docker,
    podman: Podman
};

pub fn main(init: std.process.Init) !void {
    _ = init;
    const owomnipotent_docker: Docker = .{
        .host = "127.0.0.1",
        .root_password = "Big root password"
    };

    const owomnipotent_podman: Podman =  .{
        .host = "127.0.0.1",
        .username = "Random user name",
        .user_password = "Big user password"
    };


    const container_podman: ContainerSoftware = .{ .podman = owomnipotent_podman };
    const container_docker: ContainerSoftware = .{ .docker = owomnipotent_docker };
    connect_to_container(container_podman);
    connect_to_container(container_docker);


    // Hashmap representing the id of the host with it's corresponding container service (the union type)
    var gpa = std.heap.DebugAllocator(.{}){};
    const allocator = gpa.allocator();
    var hashmap = std.StringHashMap(ContainerSoftware).init(allocator);
    try hashmap.put("owomnipotent", container_podman);
}

fn connect_to_container(container_service: ContainerSoftware) void {
    switch (container_service) {
        .podman => |p|{
            std.debug.print("Connecting to podman on {s}\n", .{p.host});
        },
        .docker => |d| {
            std.debug.print("Connecting to docker on {s}\n", .{d.host});
        }
    }
}
