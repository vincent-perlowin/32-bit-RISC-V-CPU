//passed

module TB_INCREMENTER();

logic reset, clk;

logic [3:0] icrmt;

INCREMENTER dut (.reset(reset), .clk(clk), .icrmt(icrmt));


initial begin
    clk = 0;
    while (1)
        #5 clk = ~clk;
end

initial begin
    reset = 1;
    #27 reset = 0;
    #100 reset = 1;
    #10 reset = 0;
    #200 $finish;
end





endmodule