module dmem(
    input clk, we,
    input [31:0] a, wd,
    output [31:0] rd
);
    reg [31:0] RAM [0:2097151];
    initial $readmemh("memfile.dat", RAM);
    assign rd = RAM[a[22:2]]; // word aligned
    always @(posedge clk)
        if (we) RAM[a[22:2]] <= wd;
endmodule

