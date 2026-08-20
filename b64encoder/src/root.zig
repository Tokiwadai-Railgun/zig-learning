//! By convention, root.zig is the root source file when making a package.
const std = @import("std");

pub const Base64 = struct {
    _table: *const [64]u8,

    pub fn init() Base64 {
        const upper = "ABCDEFGHIJKLMNOPQRSTUVWXYZ";
        const lower = "abcdefghijklmnopqrstuvwxyz";
        const numbers = "0123456789+/";
        return Base64{ ._table = upper ++ lower ++ numbers };
    }

    pub fn _char_at(self: Base64, index: usize) u8 {
        return self._table[index];
    }

    fn _calc_encode_length(input: []const u8) !usize {
        if (input.len < 3) {
            return 4;
        }

        const n_groups: usize = try std.math.divCeil(usize, input.len, 3);
        return n_groups * 4;
    }

    fn _calc_decode_length(input: []const u8) !usize {
        if (input.len < 4) {
            return 3;
        }

        const n_groups: usize = try std.math.divFloor(usize, input.len, 4);

        var multiple_groups: usize = n_groups * 3;
        var i: usize = input.len - 1;

        while (i > 0) : (i -= 1) {
            if (input[i] == '=') {
                multiple_groups -= 1;
            } else {
                break;
            }
        }

        return multiple_groups;
    }

    pub fn encode(self: Base64, allocator: std.mem.Allocator, input: []const u8) ![]u8 {
        if (input.len == 0) return "";

        const n_out = try _calc_encode_length(input);
        var out = try allocator.alloc(u8, n_out);
        var buf = [3]u8{ 0, 0, 0 };
        var count: u8 = 0;
        var iout: u64 = 0;

        for (input, 0..) |_, i| {
            buf[count] = input[i];
            count += 1;
            // Perfect 3 bytes window
            //  a           H           i
            //  95          772         105
            //  01100001    01001000    01101001
            //  011000 010100 100001 101001
            //  24     20     33     41
            //  Y      U      h      p
            //
            // transformed from __aHi__ to __YUhp__
            if (count == 3) {
                out[iout] = self._char_at(input[0] >> 2);
                out[iout + 1] = self._char_at(((0b00000011 & input[0]) << 4) + ((0b11110000 & input[1]) >> 4));
                out[iout + 2] = self._char_at(((0b00001111 & input[1]) << 2) + ((0b11000000 & input[2]) >> 6));
                out[iout + 3] = self._char_at((0b00111111 & input[2]));

                iout += 4;
                count = 0;
            }
        }

        if (count == 2) {
            // 2 bytes window
            //  a           H
            //  95          772
            //  01100001    01001000
            //  011000 010100 100000    =
            //  24     20     32        =
            //  Y      U      g         =
            //
            // transformed from __aH__ to __YUg=__

            out[iout] = self._char_at(input[0] >> 2);
            out[iout + 1] = self._char_at(((0b00000011 & input[0]) << 4) + ((0b11110000 & input[1]) >> 4));
            out[iout + 2] = self._char_at((0b00001111 & input[1]) << 2);
            out[iout + 3] = '=';
            iout += 4;
        }

        if (count == 1) {
            // 1 byte window
            //  a
            //  95
            //  01100001
            //  011000 010000   =   =
            //  24     16       =   =
            //  Y      P        =   =
            //
            // transformed from __a__ to __YP==__
            out[iout] = self._char_at(input[0] >> 2);
            out[iout + 1] = self._char_at((0b00000011 & input[0]) << 4);
            out[iout + 2] = '=';
            out[iout + 3] = '=';
        }

        return out;
    }
};
