/*
error 1 ->invalid instuction
error 2 ->invalid jump/branch loacation

aSel -> A port of alu
bSel -> B port of alu
BusSel -> selects component to output to main bus
IN__  -> enables the regester __
adress -> outputs ram at that adress (plus next three generally) // byt makes only 1 and half makes only 2 while unsigned makes bit extentions 0s

*/


module RISK_V_32I_CPU (input logic raw_reset, clk, output logic [31:0] Oo, output logic [3:0] Oerror);
logic [31:0] x0, x1, x2, x3, x4, x5, x6, x7, x8, x9, x10, x11, x12, x13, x14, x15, x16, x17, x18, x19, x20, x21, x22, x23, x24, x25, x26, x27, x28, x29, x30, x31, pc, ir, adress; //registers
logic [4:0] INreg; //general regester enables
logic INpc, INir, INareg, INram, INout, reset; //regester enables
logic [5:0] aSel, bSel; //select line for what gets but in the ALU and on the bus
logic [1:0] BusSel;

logic [4:0] rs1, rs2, rd; //things parsed from instuctions

logic [31:0] Bus, a, b, o, imm, out; //non regester 32-bit wires
logic byt, half, tunsigned; //key for how much data gets taken from RAM (whole inplied from both off)

logic [3:0] error, ierror, oerror; //error output (0->no error, 1->bad instuction, 2-> pc is not a multible of 4)
assign error = ierror | oerror;

logic[7:0] build01, build12, build23;
logic[1:0] INb, OUTb;

logic ROMbus;

logic [3:0] alu_ctrl;
logic [2:0] immOveride; // instuction immedeate overide 

logic [7:0]RAM[0:16_777_215]; //16 megs of ram can add up to 4 gigs

//---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
initial $readmemb("new_prog.mem", RAM); //THIS IS NOT REAL CODE, MUST BE REMOVED FOR REAL CODE USE!!!!
//---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

assign x0 = 32'h0;
assign ROMbus = |Bus;
assign Oo = out;
assign Oerror = error;

ALU alu (.a(a), .b(b), .ctrl(alu_ctrl), .o(o));

ROM rom(.clk(clk), .reset(reset), .togle(ir[30]), .Bus(ROMbus), .rs1(rs1), .rs2(rs2), .rd(rd), .opcode(ir[6:2]), .funct3(ir[14:12]), //opcode funct3 and togle are from instuction, togle=ir[30]
    .INreg(INreg), .INpc(INpc), .INir(INir), .INareg(INareg), .INram(INram), //enables
        .aSel(aSel), .BusSel(BusSel), .bSel(bSel), .alu_ctrl(alu_ctrl), //selects
        .byt(byt), .half(half), .tunsigned(tunsigned), //output togles
        .immOveride(immOveride), .INb(INb), .OUTb(OUTb), .INout(INout));

always_comb  begin //parsing instuction (type, registers, and imideate value)
    rs1 = ir[19:15]; //setting the registers used (if a register isn't used then it wont be assigned)
    rs2 = ir[24:20];
    rd = ir[11:7];
    
    if (ir[1:0]!=2'b11) begin//error
        imm[31:11] = {21{ir[31]}};
        imm[10:0] = ir[30:20];
        ierror = 4'h1;
    end
    else if (immOveride != 0) begin
        imm[31:3] = 0;
        imm[2:0] = immOveride;
        ierror = 4'h0;
    end
    else if (ir[4:2]==5'b101) begin //U-type
        imm[31:12]=ir[31:12];
        imm[11:0]=11'h0;
        ierror = 4'h0;
    end
    else if (ir[6]&ir[3]&ir[2]) begin//J-type
        imm[31:20]={12{ir[31]}};
        imm[19:12]=ir[19:12];
        imm[11]=ir[20];
        imm[10:1]=ir[30:21];
        imm[0]=1'b0;
        ierror = 4'h0;
    end
    else if (ir[6:4]==3'b010& ~ir[2])begin //S-type
        imm[31:11] = {21{ir[31]}};
        imm[10:5] = ir[30:25];
        imm[4:0] = ir[11:7];
        ierror = 4'h0;
    end
    else if (ir[6:4]==3'b110& ~ir[2]) begin //B-type
        imm[31:12] = {20{ir[31]}};
        imm[11] = ir[7];
        imm[10:5] = ir[30:25];
        imm[4:1] = ir[11:8];
        imm[0] = 1'b0;
        ierror = 4'h0;
    end
    else if (ir[6:4]==3'b011& ~ir[2]) begin//R-type
        imm[31:11] = {21{ir[31]}};
        imm[10:0] = ir[30:20];
        ierror = 4'h0;
    end
    else begin//I-type
        imm[31:11] = {21{ir[31]}};
        imm[10:0] = ir[30:20];
        ierror = 4'h0;
    end
end


always_comb begin //regester input output definitions
    case (aSel) 
        1: a=x1;
        2: a=x2;
        3: a=x3;
        4: a=x4;
        5: a=x5;
        6: a=x6;
        7: a=x7;
        8: a=x8;
        9: a=x9;
        10: a=x10;
        21: a=x21;
        22: a=x22;
        23: a=x23;
        24: a=x24;
        25: a=x25;
        26: a=x26;
        27: a=x27;
        28: a=x28;
        29: a=x29;
        30: a=x30;
        31: a=x31;
        32: a=pc;
        33: a=adress;
        default a=x0;
    endcase
    case (bSel) 
        0: b=x0;
        1: b=x1;
        2: b=x2;
        3: b=x3;
        4: b=x4;
        5: b=x5;
        6: b=x6;
        7: b=x7;
        8: b=x8;
        9: b=x9;
        10: b=x10;
        21: b=x21;
        22: b=x22;
        23: b=x23;
        24: b=x24;
        25: b=x25;
        26: b=x26;
        27: b=x27;
        28: b=x28;
        29: b=x29;
        30: b=x30;
        31: b=x31;
        default: b = imm;
    endcase
    case (BusSel) 
        1: Bus=pc; //program counter
        2: Bus=o; //alu output
        3: begin //ram to bus
            Bus[7:0] = build01;
            if(byt) Bus[31:8] = {24{Bus[7]&~tunsigned}};
            else begin
                Bus[15:8] = build12;
                if(half) Bus[31:16] = {16{Bus[15]&~tunsigned}};
                else begin
                    Bus[31:24] = RAM[adress];
                    Bus[23:16] = build23;
                end
            end
        end
        default: Bus=x0;
    endcase

end

always_ff @ (posedge clk) begin
    if(INreg==1) x1 <= Bus;
end

always_ff @ (posedge clk) begin
    if(INreg==2) x2 <= Bus;
end

always_ff @ (posedge clk) begin
    if(INreg==3) x3 <= Bus;
end

always_ff @ (posedge clk) begin
    if(INreg==4) x4 <= Bus;
end

always_ff @ (posedge clk) begin
    if(INreg==5) x5 <= Bus;
end

always_ff @ (posedge clk) begin
    if(INreg==6) x6 <= Bus;
end

always_ff @ (posedge clk) begin
    if(INreg==7) x7 <= Bus;
end

always_ff @ (posedge clk) begin
    if(INreg==8) x8 <= Bus;
end

always_ff @ (posedge clk) begin
    if(INreg==9) x9 <= Bus;
end

always_ff @ (posedge clk) begin
    if(INreg==10) x10 <= Bus;
end

always_ff @ (posedge clk) begin
    if(INreg==11) x11 <= Bus;
end

always_ff @ (posedge clk) begin
    if(INreg==12) x12 <= Bus;
end

always_ff @ (posedge clk) begin
    if(INreg==13) x13 <= Bus;
end

always_ff @ (posedge clk) begin
    if(INreg==14) x14 <= Bus;
end

always_ff @ (posedge clk) begin
    if(INreg==15) x15 <= Bus;
end

always_ff @ (posedge clk) begin
    if(INreg==16) x16 <= Bus;
end

always_ff @ (posedge clk) begin
    if(INreg==17) x17 <= Bus;
end

always_ff @ (posedge clk) begin
    if(INreg==18) x18 <= Bus;
end

always_ff @ (posedge clk) begin
    if(INreg==19) x19 <= Bus;
end

always_ff @ (posedge clk) begin
    if(INreg==20) x20 <= Bus;
end

always_ff @ (posedge clk) begin
    if(INreg==21) x21 <= Bus;
end

always_ff @ (posedge clk) begin
    if(INreg==22) x22 <= Bus;
end

always_ff @ (posedge clk) begin
    if(INreg==23) x23 <= Bus;
end

always_ff @ (posedge clk) begin
    if(INreg==24) x24 <= Bus;
end

always_ff @ (posedge clk) begin
    if(INreg==25) x25 <= Bus;
end

always_ff @ (posedge clk) begin
    if(INreg==26) x26 <= Bus;
end

always_ff @ (posedge clk) begin
    if(INreg==27) x27 <= Bus;
end

always_ff @ (posedge clk) begin
    if(INreg==28) x28 <= Bus;
end

always_ff @ (posedge clk) begin
    if(INreg==29) x29 <= Bus;
end

always_ff @ (posedge clk) begin
    if(INreg==30) x30 <= Bus;
end

always_ff @ (posedge clk) begin
    if(INreg==31) x31 <= Bus;
end

always_ff @ (posedge clk) begin
    if(INout) out <= Bus;
end

always_ff @ (negedge clk) begin
    reset <= raw_reset;
end

always_ff @ (posedge clk) begin //program counter (istruction pointer)
    if(reset) pc<=x0;
    else if(INpc) begin 
        pc[31:1] <= Bus[31:1];
        pc[0] = 0;
    end
end

always_ff @ (posedge clk) begin //instuction register 
    if(reset) ir <= 32'h0000_0003;
    else if(INir) ir <= Bus;
end

always_ff @ (posedge clk) begin //adress (ram) register
    if(reset) adress<=x0;
    else if(INareg) adress <= Bus;
end

always_ff @(posedge clk) begin //ram temperary regesters
    if(INb == 0) build01 <= RAM[adress];
    else if(INb == 1) build12 <= RAM[adress];
    else if(INb == 2) build23 <= RAM[adress];
    else if(INram) begin
        RAM[adress] <= Bus[7:0];
        build01 <= Bus[15:8];
        build12 <= Bus[23:16];
        build23 <= Bus[31:24];
    end
    else if(OUTb == 1) RAM[adress] <= build01;
    else if(OUTb == 2) RAM[adress] <= build12;
    else if(OUTb == 3) RAM[adress] <= build23;
end

always_comb begin //offset error
    if(INpc&(Bus[1]|Bus[0])) oerror = 4'h2;
    else oerror = 4'h0;
end





endmodule