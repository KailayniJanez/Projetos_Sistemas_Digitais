module Verilog_Lab1(
    input [3:0] SW,
    output [6:0] HEX0
);

    DEC_7SEG U1 (
        .Hex_digit(SW),
        .segment_a(HEX0[0]),
        .segment_b(HEX0[1]),
        .segment_c(HEX0[2]),
        .segment_d(HEX0[3]),
        .segment_e(HEX0[4]),
        .segment_f(HEX0[5]),
        .segment_g(HEX0[6])
    );

endmodule