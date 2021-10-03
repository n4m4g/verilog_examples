module fifo
#(parameter DW=8, CNT=4) // depth = 2**4
(
    input               clk,
    input               rst_n,
    input               en_i,
    input               we_i,
    input               re_i,
    input      [DW-1:0] din_i,
    output reg [DW-1:0] dout_o,
    output reg          empty_o,
    output reg          full_o
);

parameter DEP = 1 << CNT;
reg [DW-1:0] ram [0:DEP-1];
reg [CNT:0]  w_cnt_r;
reg [CNT:0]  r_cnt_r;

reg          we_d1_r;
reg          re_d1_r;
reg [DW-1:0] din_d1_r;

// sample input
always@(posedge clk or negedge rst_n) begin
    if(~rst_n) begin
        we_d1_r  <= 1'd0;
        re_d1_r  <= 1'd0;
        din_d1_r <= {(DW){1'd0}};
    end else if(en_i) begin
        we_d1_r  <= we_i;
        re_d1_r  <= re_i;
        din_d1_r <= din_i;
    end
end

wire full_w   = (w_cnt_r[CNT] != r_cnt_r[CNT]) &&
                (w_cnt_r[CNT-1:0] ==r_cnt_r[CNT-1:0]);
wire writable = we_d1_r & ~full_w;

wire empty_w  = w_cnt_r == r_cnt_r;
wire readable = re_d1_r & ~empty_w;

// write ptr
always@(posedge clk or negedge rst_n) begin
    if(~rst_n) begin
        w_cnt_r <= 0;
    end else if(en_i) begin
        if (writable) begin
            w_cnt_r <= w_cnt_r + 1;
        end
    end
end


// reat ptr
always@(posedge clk or negedge rst_n) begin
    if(~rst_n) begin
        r_cnt_r <= 0;
    end else if(en_i) begin
        if (readable) begin
            r_cnt_r <= r_cnt_r + 1;
        end
    end
end


// empty logic
always@(posedge clk or negedge rst_n) begin
    if(~rst_n) begin
        empty_o <= 1'd0;
    end else if(en_i) begin
        empty_o <= empty_w;
    end
end

// full logic
always@(posedge clk or negedge rst_n) begin
    if(~rst_n) begin
        full_o <= 1'd0;
    end else if(en_i) begin
        full_o <= full_w;
    end
end


// write logic
genvar t;
generate
    for(t=0; t<DEP; t=t+1) begin
        always@(posedge clk or negedge rst_n) begin
            if(~rst_n) begin
                ram[t] <= {(DW){1'd0}};
            end else if(en_i) begin
                if(writable && (t==w_cnt_r)) begin
                    ram[t] <= din_d1_r;
                end
            end
        end
    end
endgenerate


// mask fifo for dout
wire [DW-1:0] ram_and_w [0:DEP-1];
generate
    for(t=0; t<DEP; t=t+1) begin
        assign ram_and_w[t] = (r_cnt_r==t) ? ram[t] : {DW{1'd0}};
    end
endgenerate


// outflow mask data
wire [DW-1:0] ram_or_w [1:DEP-1];
generate
    assign ram_or_w[1] = ram_and_w[1] | ram_and_w[0];
    for(t=2; t<DEP; t=t+1) begin
        assign ram_or_w[t] = ram_and_w[t] | ram_or_w[t-1];
    end
endgenerate


// output logic
wire [CNT-1:0] sel = r_cnt_r[CNT-1:0];
// read logic
always@(posedge clk or negedge rst_n) begin
    if(~rst_n) begin
        dout_o <= {DW{1'd0}};
    end else if(en_i && readable) begin
        dout_o <= ram_or_w[DEP-1];
    end
end


endmodule
