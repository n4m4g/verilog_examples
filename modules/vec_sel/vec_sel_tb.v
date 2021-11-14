`timescale 1 ns / 100 ps

module vec_sel_tb;

localparam T = 10;

reg clk;
reg rst_n;
reg en;
reg [`WIDTH-1:0] in;
wire [`BIT-1:0] out;

// golden
reg [`BIT-1:0] g_out;

integer i;
integer err;
integer check;

vec_sel u_vec_sel
(
.clk(clk),
.rst_n(rst_n),
.en(en),
.in(in),
.out(out)
);

initial clk = 1;
always#(T/2) clk = ~clk;

initial
begin
    $dumpfile("vec_sel.vcd");
    $dumpvars();
end

integer init_i;

initial
begin
    i = 0;
    err = 0;
    rst_n = 1;
    en = 0;
    init_i = 0;
    
    for(init_i=0; init_i<32; init_i=init_i+1) begin
        in[init_i*32 +: 32] = {$random};
    end

    #1;

    #T rst_n = ~rst_n;
    #T rst_n = ~rst_n;

    #T;

    en = 1;

    forever begin
        g_out = in[i*`BIT +: `BIT];

        @(negedge clk);
        if(out !== g_out) begin
            $display($time, ", out: %d, g_out: %d", out, g_out);
            err = err + 1;
        end
        @(posedge clk);
        i = i == `NUM_M1 ? 0 : i + 1;
    end

end

initial begin
    #(T*1000);

    if(err !== 0) begin
        $display("Simulation FAILED");
    end else begin
        $display("Simulation PASS");
    end
    $finish;
end



// initial
// begin
//     err = 0;
//     check = 0;
// 
//     $readmemb("data.txt", read_data);
//     foutput = $fopen("output.txt");
// 
//     for (i=0; i<4; i=i+1) begin
//         {a, b, g_carry, g_sum} = read_data[i];
//         #T;
//         if(sum !== g_sum || carry !== g_carry) begin
//             $display("a=%d, b=%d", a, b);
//             $display("expect carry/sum=%d/%d, but get %d/%d", g_carry, g_sum, carry, sum);
//             err = err + 1;
//         end
//         check = check + 1;
// 
//         $fdisplay(foutput, "%b%b%b%b%b%b", a, b, carry, sum, g_carry, g_sum);
//     end
// 
//     $display("Check %4d times", check);
//     if(err !== 0) begin
//         $display("Failed!! %4d errors", err);
//     end else begin
//         $display("Simulation PASS!! %4d errors", err);
//     end
// 
//     $fclose(foutput);
// 
//     $finish;
// end
endmodule

