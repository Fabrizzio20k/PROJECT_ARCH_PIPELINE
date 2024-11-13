module controller(
    input clk, reset,
    input [31:12] InstrD,
    input [3:0] ALUFlagsE,
    output reg [1:0] RegSrcD, ImmSrcD,
    output reg ALUSrcE, BranchTakenE,
    output reg [1:0] ALUControlE,
    output reg MemWriteM,
    output reg MemtoRegW, PCSrcW, RegWriteW,
    // hazard interface
    output reg RegWriteM, MemtoRegE,
    output reg PCWrPendingF,
    input FlushE
);
    reg [9:0] controlsD;
    reg ALUOpD;
    reg [1:0] ALUControlD;
    reg ALUSrcD;
    reg MemtoRegD, MemtoRegM;
    reg RegWriteD, RegWriteE, RegWriteGatedE;
    reg MemWriteD, MemWriteE, MemWriteGatedE;
    reg BranchD, BranchE;
    reg [1:0] FlagWriteD, FlagWriteE;
    reg PCSrcD, PCSrcE, PCSrcM;
    reg [3:0] FlagsE, FlagsNextE, CondE;
    wire CondExE;
    reg PCSrcGatedE;

    // Decode stage
    always @(*) begin
        casex (InstrD[27:26])
            2'b00: if (InstrD[25]) controlsD = 10'b0000101001; // DP imm
                  else controlsD = 10'b0000001001; // DP reg
            2'b01: if (InstrD[20]) controlsD = 10'b0001111000; // LDR
                  else controlsD = 10'b1001110100; // STR
            2'b10: controlsD = 10'b0110100010; // B
            default: controlsD = 10'b0000000000; // unimplemented
        endcase

        // Unpack controlsD
        {RegSrcD, ImmSrcD, ALUSrcD, MemtoRegD,
         RegWriteD, MemWriteD, BranchD, ALUOpD} = controlsD;

        // ALU Control logic
        if (ALUOpD) begin // which Data-processing Instr?
            case (InstrD[24:21])
                4'b0100: ALUControlD = 2'b00; // ADD
                4'b0010: ALUControlD = 2'b01; // SUB
                4'b0000: ALUControlD = 2'b10; // AND
                4'b1100: ALUControlD = 2'b11; // ORR
                default: ALUControlD = 2'b00; // unimplemented, default to ADD
            endcase
            FlagWriteD[1] = InstrD[20]; // update N and Z Flags if S bit is set
            FlagWriteD[0] = InstrD[20] & (ALUControlD == 2'b00 | ALUControlD == 2'b01);
        end else begin
            ALUControlD = 2'b00; // perform addition for non-data processing instr
            FlagWriteD = 2'b00; // don't update Flags
        end

        // Compute PCSrcD
        PCSrcD = (((InstrD[15:12] == 4'b1111) & RegWriteD) | BranchD);
    end

    // Execute stage registers
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            {FlagWriteE, BranchE, MemWriteE, RegWriteE, PCSrcE, MemtoRegE} <= 0;
            {ALUSrcE, ALUControlE} <= 0;
            CondE <= 0;
        end else if (FlushE) begin
            {FlagWriteE, BranchE, MemWriteE, RegWriteE, PCSrcE, MemtoRegE} <= 0;
            {ALUSrcE, ALUControlE} <= 0;
            CondE <= 0;
        end else begin
            {FlagWriteE, BranchE, MemWriteE, RegWriteE, PCSrcE, MemtoRegE} <=
                {FlagWriteD, BranchD, MemWriteD, RegWriteD, PCSrcD, MemtoRegD};
            {ALUSrcE, ALUControlE} <= {ALUSrcD, ALUControlD};
            CondE <= InstrD[31:28];
        end
    end

    // Flags register
    always @(posedge clk or posedge reset) begin
        if (reset)
            FlagsE <= 0;
        else
            FlagsE <= FlagsNextE;
    end

    // Conditional execution
    wire [3:0] FlagsNextE_wire;
    conditional Cond(
        .Cond(CondE),
        .Flags(FlagsE),
        .ALUFlags(ALUFlagsE),
        .FlagsWrite(FlagWriteE),
        .CondEx(CondExE),
        .FlagsNext(FlagsNextE_wire)
    );

    // Assignments to reg outputs
    always @(*) begin
        FlagsNextE = FlagsNextE_wire;
        BranchTakenE = BranchE & CondExE;
        RegWriteGatedE = RegWriteE & CondExE;
        MemWriteGatedE = MemWriteE & CondExE;
        PCSrcGatedE = PCSrcE & CondExE;
    end

    // Memory stage registers
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            {MemWriteM, MemtoRegM, RegWriteM, PCSrcM} <= 0;
        end else begin
            {MemWriteM, MemtoRegM, RegWriteM, PCSrcM} <=
                {MemWriteGatedE, MemtoRegE, RegWriteGatedE, PCSrcGatedE};
        end
    end

    // Writeback stage registers
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            {MemtoRegW, RegWriteW, PCSrcW} <= 0;
        end else begin
            {MemtoRegW, RegWriteW, PCSrcW} <=
                {MemtoRegM, RegWriteM, PCSrcM};
        end
    end

    // Hazard Prediction
    always @(*) begin
        PCWrPendingF = PCSrcD | PCSrcE | PCSrcM;
    end
endmodule
