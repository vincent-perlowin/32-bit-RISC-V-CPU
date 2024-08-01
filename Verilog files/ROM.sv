module ROM (
    input logic clk, reset, togle, Bus, input logic [4:0] rs1, rs2, rd,
        input logic [4:0] opcode, input logic [2:0] funct3, //opcode funct3 and togle are from instuction, togle=ir[30]
    output logic [4:0] INreg, output logic INpc, INir, INareg, INram, //enables
        output logic [5:0] aSel, bSel, output logic [3:0] alu_ctrl, //selects
        output logic byt, half, tunsigned, //output togles
        output logic [2:0] immOveride,  output logic [1:0] BusSel,
        output logic[1:0] INb, OUTb, INout
    );

//11
logic [3:0] icrmt;
logic inReset, branchReg, INbr, stop_inc, iclk;
assign ireset = inReset | reset;
INCREMENTER incrementer(.reset(ireset), .clk(iclk), .icrmt(icrmt));

always_ff @ (posedge clk) if(INbr) branchReg<= Bus;

assign iclk = clk&~stop_inc;

always_comb begin
    if(icrmt == 15 & ~ireset) stop_inc = 1;
    else stop_inc = 0;
end

always_comb begin
    if(icrmt == 3) byt =0;
    else byt = ~(funct3[1] | funct3[0] | opcode[2]);
end

always_comb begin
    tunsigned = funct3[2];
    half = funct3[0] & ~opcode[2];
    if(icrmt ==0) begin
        INb = 0;

        BusSel = 2;
        aSel=32;
        bSel=32;
        immOveride=1;
        alu_ctrl=4'b0010;
        INareg=1;

        INir = 0;
        INreg = 0;
        INpc=0;
        INram = 0;
        inReset=0;
        INbr=0;
        OUTb = 0;
        INout =0;
    end
    else if(icrmt ==1) begin
        INb = 1;

        BusSel = 2;
        aSel=32;
        bSel=32;
        immOveride=2;
        alu_ctrl=4'b0010;
        INareg=1;

        INir = 0;
        INreg = 0;
        INpc=0;
        INram = 0;
        inReset=0;
        INbr=0;
        OUTb = 0;
        INout =0;
    end
    else if(icrmt ==2) begin
        INb = 2;

        BusSel = 2;
        aSel=32;
        bSel=32;
        immOveride=3;
        alu_ctrl=4'b0010;
        INareg=1;

        INir = 0;
        INreg = 0;
        INpc=0;
        INram = 0;
        inReset=0;
        INbr=0;
        OUTb = 0;
        INout =0;
    end
    else if(icrmt ==3) begin
        BusSel = 3;
        INir = 1;

        INreg = 0;
        INpc=0;
        INareg=0;
        INram = 0;
        aSel=0;
        bSel=0;
        alu_ctrl=0;
        immOveride=0;
        inReset=0;
        INbr=0;
        INb = 3;
        OUTb = 0;
        INout =0;
    end
    else if(~opcode[4]&opcode[2:0]==3'b100) begin  //ALU instuctions
        INram = 0;
        INir = 0;
        INbr=0;
        INb = 3;
        OUTb = 0;
        if(icrmt == 4) begin
            aSel = rs1;
            INreg = rd;
            BusSel = 2;
            if(opcode[3]) bSel = rs2;
            else bSel = 32;

            INpc=0;
            INareg=0;
            immOveride=0;
            inReset =0;
            INout =1;
            
            if(funct3==3'b000) begin //add / sub
                alu_ctrl[3:1]=3'b001;
                alu_ctrl[0]=opcode[3]&togle;
            end
            else if(funct3[2:1]==2'b01) begin  // SLT / SLTU
                alu_ctrl[3:1] = 3'b010;
                alu_ctrl[0] = funct3[0];
            end
            else if(funct3[1:0] == 2'b01) begin // SLL / SRL / SRA
                alu_ctrl[3:2] = 2'b10;
                alu_ctrl[1] = funct3[2];
                alu_ctrl[0] = togle;
            end
            if(funct3==3'b100) alu_ctrl = 4'b0110; //XOR
            if(funct3[3]&funct3[2]) begin // OR / AND
                alu_ctrl[3:1] = funct3;
                alu_ctrl[0] = 0;
            end
        end
        else begin //get next instuction ready and reset
            aSel = 32;
            bSel = 32;
            immOveride = 4;
            INpc = 1;
            INareg = 1;
            inReset = 1;
            BusSel = 2;
            alu_ctrl = 4'b0010;

            INreg = 0;
            INout =0;
        end
    end
    else if(opcode[2:0]==3'b101) begin // LUI / AUIPC
        INram = 0;
        INir = 0;
        INbr = 0;
        INb = 3;
        OUTb = 0;
        INout =0;
        if(icrmt == 4) begin
            bSel = 32;
            alu_ctrl = 4'b0010;
            BusSel = 2;
            INreg = rd;

            if(opcode[3]) aSel = 0; //whether or not to add to pc
            else aSel = 32;

            INpc = 0;
            INareg=0;
            immOveride=0;
            inReset =0;
        end
        else  begin //get next instuction ready and reset
            aSel = 32;
            bSel = 32;
            immOveride = 4;
            INpc = 1;
            INareg = 1;
            inReset = 1;
            BusSel = 2;
            alu_ctrl = 4'b0010;

            INreg = 0;
        end
    end
    else if(opcode[4]&opcode[3]&opcode[0]) begin // jump instuctions
        INram = 0;
        INir = 0;
        INbr = 0;
        INb = 3;
        OUTb = 0;
        INout =0;
        if(icrmt == 4) begin //record return adress
            aSel = 32;
            bSel = 32;
            immOveride = 4;
            INreg = rd;
            BusSel = 2;
            alu_ctrl = 4'b0010;

            INareg = 0;
            INpc = 0;
            inReset = 0;
        end
        else begin //jump 
            bSel = 32;
            if(opcode[1]) aSel = 32; //offset to pc or reg
            else aSel = rs1;
            INpc = 1;
            INareg = 1;
            inReset = 1;
            BusSel = 2;
            alu_ctrl = 4'b0010;

            immOveride = 0;
            INreg = 0;
        end
    end
    else if(opcode[4:2]==3'b110 & ~opcode[0]) begin //branch (jump) if x
        INram = 0;
        INir = 0;
        INreg = 0;
        BusSel = 2;
        INb = 3;
        OUTb = 0;
        INout =0;
        if(icrmt == 4) begin //do the operation and store the result in branch reg 
            INbr = 1;
            aSel = rs1;
            bSel = rs2;
            if(funct3[2]) begin // either subtracts, SLT, or SLTU given
                alu_ctrl[3:1] = 3'b010;
                alu_ctrl[0] = funct3[1];
            end
            else alu_ctrl = 4'b0011;

            INpc = 0;
            INareg = 0;
            inReset = 0;
            immOveride = 0;
        end
        else begin
            bSel = 32;
            aSel = 32; 
            INpc = 1;
            INareg = 1;
            inReset = 1;   
            alu_ctrl = 4'b0010;
            if((funct3[2]^funct3[0])== branchReg) immOveride = 0;//if true branch
            else immOveride = 4; //basicly go 4 forward do to imm ofset

            INbr = 0;
        end
    end
    else if(~(opcode[4]|opcode[2]|opcode[1]|opcode[0])) begin  //store / load instuctions
        INbr = 0;
        INir = 0;
        alu_ctrl = 4'b0010;
        INout =0;

        if(icrmt==4) begin //going to store adress
            aSel = rs1;
            bSel = 32;
            BusSel = 2;
            INareg = 1;

            INram = 0;
            INreg = 0;
            INpc = 0;
            inReset = 0;
            immOveride = 0;
            INb = 3;
            OUTb = 0;
        end
        else if(icrmt == 5) begin //store or load
            INpc = 0;
            inReset = 0;
            immOveride = 0;
            aSel = 0;
            bSel = rs2;
            BusSel = 2;
            INareg = 0;
            INreg = 0;

            if(opcode[3]) begin //store
                INram = 1;

                INb = 3;
                OUTb = 0;
            end
            else begin //load
                INram = 0;
                INb = 0;
                OUTb = 0;
            end
        end
        else if (icrmt == 6) begin
            aSel = 33;
            bSel = 32;
            immOveride = 1;
            BusSel = 2;
            INareg = 1;

            INb = 3;
            OUTb = 0;
            INpc = 0;
            inReset = 0;
            INreg = 0;
            INram = 0;
        end
        else if (icrmt == 7) begin
            aSel = 33;
            bSel = 32;
            immOveride = 1;
            BusSel = 2;
            INareg = 1;

            INram = 0;
            INpc = 0;
            inReset = 0;
            INreg = 0;
            INram = 0;

            if(opcode[3]) begin //store
                INb = 3;
                OUTb = 1;
            end
            else begin //load
                INb = 1;
                OUTb = 0;
            end
        end
        else if (icrmt == 8) begin
            aSel = 33;
            bSel = 32;
            immOveride = 1;
            BusSel = 2;
            INareg = 1;

            INram = 0;
            INpc = 0;
            inReset = 0;
            INreg = 0;
            INram = 0;
            
            if(opcode[3]) begin //store
                INb = 3;
                OUTb = 2;
            end
            else begin //load
                INb = 2;
                OUTb = 0;
            end
        end
        else if (icrmt == 9) begin
            aSel = 33;
            bSel = 32;
            immOveride = 0;
            INareg = 0;

            INram = 0;
            INpc = 0;
            inReset = 0;
            
            if(opcode[3]) begin //store
                INb = 3;
                OUTb = 3;
                INram = 0;
                BusSel = 2;
                INreg = 0;

            end
            else begin //load
                INb = 3;
                OUTb = 0;
                INram = 0;
                BusSel = 3;
                INreg = rd;
            end
        end
        else begin
            aSel = 32;
            bSel = 32;
            immOveride = 4;
            INpc = 1;
            INareg = 1;
            inReset = 1;
            BusSel = 2;

            INreg = 0;
            INram = 0;
        end
    end
    else if(~opcode[4]&opcode[1]&opcode[0]) begin
        aSel = 32;
        bSel = 32;
        immOveride = 4;
        INpc = 1;
        INareg = 1;
        inReset = 1;
        BusSel = 2;
        alu_ctrl = 4'b0010;

        INreg = 0;
        INram = 0;
        INbr = 0;
        INir = 0;
        INb = 3;
        OUTb = 0;
        INout =0;
    end
    else begin
        aSel = 32;
        bSel = 32;
        immOveride = 0;
        INpc = 0;
        INareg = 0;
        inReset = 0;
        BusSel = 0;
        alu_ctrl = 4'b0010;
        INreg = 0;
        INram = 0;
        INbr = 0;
        INir = 0;
        INb = 3;
        OUTb = 0;
        INout =0;
    end
end



endmodule