`timescale 1 ns / 100 ps

module half_adder_tb;

localparam T = 20;
reg clk;
reg a, b;
wire sum, carry;

// golden
reg g_sum, g_carry;

integer err;
integer check;

// buf for golden
reg [3:0] read_data [0:3];
integer i;
integer foutput;

half_adder u_half_adder(.a(a), .b(b), .sum(sum), .carry(carry));

initial clk = 1;
always#T clk = ~clk;

initial
begin
    $dumpfile("half_adder.vcd");
    $dumpvars();
end

initial
begin
    err = 0;
    check = 0;

    $readmemb("data.txt", read_data);
    foutput = $fopen("output.txt");

    for (i=0; i<4; i=i+1) begin
        {a, b, g_carry, g_sum} = read_data[i];
        #T;
        if(sum !== g_sum || carry !== g_carry) begin
            $display("a=%d, b=%d", a, b);
            $display("expect carry/sum=%d/%d, but get %d/%d", g_carry, g_sum, carry, sum);
            err = err + 1;
        end
        check = check + 1;

        $fdisplay(foutput, "%b%b%b%b%b%b", a, b, carry, sum, g_carry, g_sum);
    end

    $display("Check %4d times", check);
    if(err !== 0) begin
        $display("Failed!! %4d errors", err);
    end else begin
        $display("Simulation PASS!! %4d errors", err);
    end

    $fclose(foutput);

    $finish;
end
endmodule

