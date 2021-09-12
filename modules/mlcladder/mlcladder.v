`timescale 1 ns / 100 ps

module FA(
  input  A,
  input  B,
  input  cin,
  output sum,
  output cout
);

assign {cout, sum} = A + B + cin;

endmodule


module clu(
  input  [3:0] A,
  input  [3:0] B,
  input        cin,
  input        bypass,
  output       P,
  output       G,
  output [3:0] cout
);

reg [3:0] g;
reg [3:0] p;
reg [4:0] c;

integer i;
always@(*) begin
  c[0] = cin;
  for (i=0; i<4; i=i+1) begin
    g[i]   = bypass ? A[i] : A[i] & B[i];
    p[i]   = bypass ? B[i] : A[i] ^ B[i];
    c[i+1] = g[i] | (p[i] & c[i]);
  end
end

assign G = (                     g[3])|
           (              p[3] & g[2])| 
           (       p[3] & p[2] & g[1])|
           (p[3] & p[2] & p[1] & g[0]);
assign P = &p;
assign cout = c[4:1];

endmodule

module FA4(
  input  [3:0] A,
  input  [3:0] B,
  input  [3:0] cin,
  output [3:0] sum
);

wire [3:0] cout;

genvar i;
generate
  for(i=0; i<4; i=i+1) begin
    FA fa (.A(A[i]),
           .B(B[i]),
           .cin(cin[i]),
           .sum(sum[i]),
           .cout(cout[i]));
  end
endgenerate

endmodule

module mlcladder(
  input  [15:0] A,
  input  [15:0] B,
  input         cin,
  output [15:0] sum,
  output        cout
);

wire [4:0] C;
wire [16:0] c;
wire [3:0] P;
wire [3:0] G;
wire P_redundant, G_redundant;

assign C[0] = cin;
assign c[0] = cin;
assign cout = c[16];

clu clu_u0(.A(G),
           .B(P),
           .cin(cin),
           .bypass(1'b1),
           .P(P_redundant),
           .G(G_redundant),
           .cout(C[4:1]));

genvar i;
generate
  for(i=0; i<4; i=i+1) begin
    clu clu_u(.A(A[i*4+3:i*4]),
              .B(B[i*4+3:i*4]),
              .cin(C[i]),
              .bypass(1'b0),
              .P(P[i]),
              .G(G[i]),
              .cout(c[i*4+4:i*4+1]));

    FA4 fa4(.A(A[i*4+3:i*4]),
            .B(B[i*4+3:i*4]),
            .cin(c[i*4+3:i*4]),
            .sum(sum[i*4+3:i*4]));
  end
endgenerate

endmodule
