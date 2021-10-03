`timescale 1 ns / 100 ps
`define DW  16
`define CNT 2

module fifo_tb;

reg           clk;
reg           rst_n;
reg           en_i;
reg           we_i;
reg           re_i;
reg  [`DW-1:0] din_i;
wire [`DW-1:0] dout_o;
wire          empty_o;
wire          full_o;

fifo
#
(
.DW(`DW),
.CNT(`CNT)
)
u_fifo
(
.clk    (clk),
.rst_n  (rst_n),
.en_i   (en_i),
.we_i   (we_i),
.re_i   (re_i),
.din_i  (din_i),
.dout_o (dout_o),
.empty_o(empty_o),
.full_o (full_o)
);


initial clk = 1'b0;
always #10 clk = ~clk;

initial
begin
    $dumpfile("fifo.vcd");
    $dumpvars();
end

initial
begin
    #1;
    rst_n = 1'b1;
    din_i = `DW'b0;
    re_i  = 1'b0;
    we_i  = 1'b0;
    en_i  = 1'b0;
    #5 en_i = 1'b1;
    #10 rst_n = 1'b0;
    #10 rst_n = 1'b1;

    #5 we_i = 1'b1;
    repeat(8) #20 din_i = din_i + `DW'b1;

    we_i = 1'b0;
    #20;

    re_i = 1'b1;
    repeat(4) #20;
    // re_i = 1'b0;
    #100;

    $finish;
end

endmodule
