module TB_TOP();

logic reset, clk;
logic [31:0] Oo;
logic [3:0] Oerror;

RISK_V_32I_CPU dut (.clk(clk), .raw_reset(reset), .Oo(Oo), .Oerror(Oerror));

initial begin
    clk = 0;
    while (1)
        #5 clk = ~clk;
end

initial begin
    reset = 1;
    #23 reset = 0;
end



endmodule