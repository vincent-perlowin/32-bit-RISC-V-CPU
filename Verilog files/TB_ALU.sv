// tested --- sucseeded in all teset

module TB_ALU ();

logic [31:0] a, b, o;
logic [3:0] ctrl;


ALU dut (.a(a), .b(b), .o(o), .ctrl(ctrl));


initial begin
    for(ctrl=0;ctrl != 16;ctrl++) begin
        a=0; // zeros 1
        b=0;
        #10;
        a = 1234567890; //big 2
        b = 876543021;
        #10;
        a = 2345678901; //overflow 3
        b = 3456789012;
        #10;
        a=30; // p less 4
        b=40;
        #10;
        a=50; // p more 5
        b=40;
        #10;
        a=-10; // o less 6
        b=10;
        #10;
        a=20; //o more 7
        b=-20;
        #10;
        a=-60; //n less 8
        b=-50;
        #10;
        a=-60; //n more 9
        b=-70;
        #10;

    end
    $finish;
end


endmodule