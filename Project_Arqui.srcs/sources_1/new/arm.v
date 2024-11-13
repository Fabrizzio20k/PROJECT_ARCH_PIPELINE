module arm(
    input clk, reset,
    output [31:0] PCF,
    input [31:0] InstrF,
    output MemWriteM,
    output [31:0] ALUOutM, WriteDataM,
    input [31:0] ReadDataM
);
    wire [1:0] RegSrcD, ImmSrcD, ALUControlE;
    wire ALUSrcE, BranchTakenE, MemtoRegW, PCSrcW, RegWriteW;
    wire [3:0] ALUFlagsE;
    wire [31:0] InstrD;
    wire RegWriteM, MemtoRegE, PCWrPendingF;
    wire [1:0] ForwardAE, ForwardBE;
    wire StallF, StallD, FlushD, FlushE;
    wire Match_1E_M, Match_1E_W, Match_2E_M, Match_2E_W, Match_12D_E;

    controller c(
        .clk(clk),
        .reset(reset),
        .InstrD(InstrD[31:12]),
        .ALUFlagsE(ALUFlagsE),
        .RegSrcD(RegSrcD),
        .ImmSrcD(ImmSrcD),
        .ALUSrcE(ALUSrcE),
        .BranchTakenE(BranchTakenE),
        .ALUControlE(ALUControlE),
        .MemWriteM(MemWriteM),
        .MemtoRegW(MemtoRegW),
        .PCSrcW(PCSrcW),
        .RegWriteW(RegWriteW),
        .RegWriteM(RegWriteM),
        .MemtoRegE(MemtoRegE),
        .PCWrPendingF(PCWrPendingF),
        .FlushE(FlushE)
    );

    datapath dp(
        .clk(clk),
        .reset(reset),
        .RegSrcD(RegSrcD),
        .ImmSrcD(ImmSrcD),
        .ALUSrcE(ALUSrcE),
        .BranchTakenE(BranchTakenE),
        .ALUControlE(ALUControlE),
        .MemtoRegW(MemtoRegW),
        .PCSrcW(PCSrcW),
        .RegWriteW(RegWriteW),
        .PCF(PCF),
        .InstrF(InstrF),
        .InstrD(InstrD),
        .ALUOutM(ALUOutM),
        .WriteDataM(WriteDataM),
        .ReadDataM(ReadDataM),
        .ALUFlagsE(ALUFlagsE),
        .Match_1E_M(Match_1E_M),
        .Match_1E_W(Match_1E_W),
        .Match_2E_M(Match_2E_M),
        .Match_2E_W(Match_2E_W),
        .Match_12D_E(Match_12D_E),
        .ForwardAE(ForwardAE),
        .ForwardBE(ForwardBE),
        .StallF(StallF),
        .StallD(StallD),
        .FlushD(FlushD)
    );

    hazard h(
        .clk(clk),
        .reset(reset),
        .Match_1E_M(Match_1E_M),
        .Match_1E_W(Match_1E_W),
        .Match_2E_M(Match_2E_M),
        .Match_2E_W(Match_2E_W),
        .Match_12D_E(Match_12D_E),
        .RegWriteM(RegWriteM),
        .RegWriteW(RegWriteW),
        .BranchTakenE(BranchTakenE),
        .MemtoRegE(MemtoRegE),
        .PCWrPendingF(PCWrPendingF),
        .PCSrcW(PCSrcW),
        .ForwardAE(ForwardAE),
        .ForwardBE(ForwardBE),
        .StallF(StallF),
        .StallD(StallD),
        .FlushD(FlushD),
        .FlushE(FlushE)
    );
endmodule