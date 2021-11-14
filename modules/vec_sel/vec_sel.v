`define WIDTH 64
`define BIT   4
`define SEL   4    // log2(WIDTH/BIT)
`define NUM   `WIDTH/`BIT
`define NUM_M1   `NUM-1

module vec_sel
(
    input clk,
    input rst_n,
    input en,
    input [`WIDTH-1:0] in,
    output [`BIT-1:0] out
);

reg [`SEL-1:0] sel;

always@(posedge clk or negedge rst_n) begin
    if(~rst_n) begin
        sel <= {`SEL{1'b0}};
    end else if(en) begin
        if(sel==`SEL'd`NUM_M1) begin
            sel <= {`SEL{1'b0}}; 
        end else begin
            sel <= sel + `SEL'b1;
        end
    end
end

assign out = in[sel*`BIT +: `BIT];


endmodule
