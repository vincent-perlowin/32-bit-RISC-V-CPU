module ADDER32 (
    input logic [31:0] a, b,
    input logic cI,
    output logic [31:0] o,
    output logic cO
);

logic [31:0] arrcI, arrcO; //carry arrays

FULLADD fa[31:0] (.a(a), .b(b), .cI(arrcI), .s(o), .cO(arrcO)); //array of full adders

assign arrcI[31:1] = arrcO[30:0]; //setting the carries to go up the line

assign arrcI[0] = cI;
assign cO = arrcO[31]; //setting the ends to the unputs and outputs 


endmodule