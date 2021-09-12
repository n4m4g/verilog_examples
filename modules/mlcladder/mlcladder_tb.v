`timescale 1 ns / 100 ps
`define N 1000

module mlcladder_tb;

  reg         clk;
  reg  [15:0] A;
  reg  [15:0] B;
  reg         cin;
  wire [15:0] sum;
  wire        cout;

  reg         result_co;
  reg  [15:0] result_sum;
  integer err;
  integer finished;
  integer check;

  mlcladder u0(
    .A(A),
    .B(B),
    .cin(cin),
    .sum(sum),
    .cout(cout)
  );

  initial clk = 1;
  always#25 clk = ~clk;

  integer i;
  initial
  begin: input_set_blk
    $dumpfile("mlcladder.vcd");
    $dumpvars();
    err = 0;
    finished = 0;
    check = 0;
    #1;
    for(i=0; i<`N; i++) begin
      {A, B} = {$random};
      cin = {$random}%2;
      {result_co, result_sum} = A + B + cin;
      #50;
      if({cout, sum} !== {result_co, result_sum}) begin
        err = err + 1;
        $display($time, ", A = %b, B = %b CIN = %b | COUT = %b SUM = %b | G_COUT = %b G_SUM = %b \n", A, B,cin,cout,sum, result_co, result_sum);
        $display($time, ", COUT^G_COUT = %b SUM^G_SUM = %b \n", cout^result_co,sum^result_sum);
        $display("Simulation terminated...");
        $finish;
      end
      check = check + 1;
    end // for
    finished = 1;

    #50;
    if(finished !== 1) begin
      $display("=== Code cannot be finished ===");
    end else if (err !== 0) begin
      $display("There are %3d errors...", err);
    end else if (check !== `N) begin
      $display("Should check %d times, but get %d times...", `N, check);
    end else begin
      $display("Simulation PASS");
      $display("Total %d patterns, check %d times...", `N, check);
    end
    $finish;
  end

endmodule
