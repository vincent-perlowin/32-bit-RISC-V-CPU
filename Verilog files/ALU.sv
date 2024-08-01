/*
32 bit CPU ALU

inputs a, b
outputs o

control ctrl (4-bits)

ctrl[3:1] -> output type
ctrl[0] -> togle bit

ctrl:
0010 -> ADD
0011 -> SUB
0100 -> SLT
0101 -> SLTU
011x -> XOR 
100x -> SLL 
1010 -> SRL 
1011 -> SRA 
110x -> OR
111x -> AND

*/


module ALU (
    input logic signed [31:0] a, b,
    input logic [3:0] ctrl,
    output logic [31:0] o
);

logic cI, cO, ra;

logic [31:0] ab, ao, slto, lo, ro;
ADDER32 adder (.a(a), .b(ab), .cI(cI), .o(ao), .cO(cO));

always_comb begin //subtraction mode when togle is on or we are in SLT mode
    if(ctrl[0]|ctrl[2]) begin
        ab = ~b;
        cI = 1'b1;
    end 
    else begin
        ab = b;
        cI = 1'b0;
    end
end

assign slto [31:1] = 31'h0;

always_comb begin // set if less than logic
    if(~ctrl[0]) begin // for signed ints first
        if(a[31] ^ b[31]) begin //if they have oposite signs then if a is negitive it is smaller and if it is negtive then a[31]=1 by definition
            slto [0] = a[31];
        end
        else begin // if they have the same signs then if the result of subtraction is negtive then A must be larger (we have to do the other step to avoid over/under flow errors)
            slto [0] = ao[31];
        end
    end
    else begin
        slto [0] = ~cO; //for unsigned ints we will always have an overflow if A is larger so A is smaller when cO = 0
    end
end

always_comb begin //defining shifts
    lo = a << b[4:0];
    if(~ctrl[0]) begin
        ro = a >> b[4:0];
    end
    else begin
        ro = a >>> b[4:0];
    end
end


always_comb begin //setting the output line depending on the context
    case (ctrl[3:1])
        1 : o=ao;
        2 : o=slto;
        3 : o=a^b;
        4 : o=lo;
        5 : o=ro;
        6 : o=a|b;
        7 : o=a&b;
        default: o=32'h0;
    endcase


end

endmodule 