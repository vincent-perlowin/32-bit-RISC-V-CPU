module FULLADD (
    input logic a, b, cI,
    output logic s, cO
);

logic g, p, i3; //signles for intermedeats

always_comb begin 
    g = a ^ b; //generate is 1 if only one is on
    p = a & b;  //propodate is one if both are on (then carry will definatly be on)
    
    i3 = g & cI; //if generate is 1 then a or b is 1 so if then cI is also 1 cO should be 1
    cO = i3 | p;  //the two cases where carry is set

    s = g ^ cI; //sum is only on if an odd num of inputs is on so (a ^ b) ^ cI

end

endmodule