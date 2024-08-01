/*
ON NEG EDGE (oposite of others)

counts up from 0-15 on negedge of clock
reset sets it to 0 while reset is active (next clock neg edge will imideatly set it to 1)

*/

module INCREMENTER ( 
    input logic reset, clk, 
    output logic [3:0] icrmt 
);

logic [3:0]  b, cI, cO, store;

FULLADD adder[3:0] (.a(icrmt), .b(b), .cI(cI), .s(store), .cO(cO));

assign cI[0] = 1'b1;
assign cI[3:1] = cO[2:0];
assign b = 4'h0;

always_ff @( negedge clk ) begin 
    if(reset) icrmt <= 4'h0;
    else icrmt <= store;
end


endmodule