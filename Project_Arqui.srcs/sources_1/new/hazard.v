module hazard(
    input clk, reset,
    input Match_1E_M, Match_1E_W, Match_2E_M, Match_2E_W, Match_12D_E,
    input RegWriteM, RegWriteW,
    input BranchTakenE, MemtoRegE,
    input PCWrPendingF, PCSrcW,
    output reg [1:0] ForwardAE, ForwardBE,
    output StallF, StallD,
    output FlushD, FlushE
);
    wire ldrStallD;

    // forwarding logic
    always @(*) begin
        if (Match_1E_M & RegWriteM) ForwardAE = 2'b10;
        else if (Match_1E_W & RegWriteW) ForwardAE = 2'b01;
        else ForwardAE = 2'b00;

        if (Match_2E_M & RegWriteM) ForwardBE = 2'b10;
        else if (Match_2E_W & RegWriteW) ForwardBE = 2'b01;
        else ForwardBE = 2'b00;
    end

    // stalls and flushes
    // Load RAW
    assign ldrStallD = Match_12D_E & MemtoRegE;
    assign StallD = ldrStallD;
    assign StallF = ldrStallD | PCWrPendingF;
    assign FlushE = ldrStallD | BranchTakenE;
    assign FlushD = PCWrPendingF | PCSrcW | BranchTakenE;
endmodule