module top(
    input clk, reset,
    output [31:0] WriteDataM, DataAdrM,
    output MemWriteM
);
    wire [31:0] PCF, InstrF, ReadDataM;

    // instantiate processor and memories
    arm arm_inst(
        .clk(clk),
        .reset(reset),
        .PCF(PCF),
        .InstrF(InstrF),
        .MemWriteM(MemWriteM),
        .ALUOutM(DataAdrM),
        .WriteDataM(WriteDataM),
        .ReadDataM(ReadDataM)
    );

    imem imem_inst(
        .a(PCF),
        .rd(InstrF)
    );

    dmem dmem_inst(
        .clk(clk),
        .we(MemWriteM),
        .a(DataAdrM),
        .wd(WriteDataM),
        .rd(ReadDataM)
    );
endmodule