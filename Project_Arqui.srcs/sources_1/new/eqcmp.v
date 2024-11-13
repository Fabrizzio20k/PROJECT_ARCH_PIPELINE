module eqcmp #(parameter WIDTH = 8) (
    input [WIDTH-1:0] a, b,
    output y
);
    assign y = (a == b);
endmodule
