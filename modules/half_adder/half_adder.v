module half_adder
(
    input a,
    input b,
    output sum,
    output carry
);

assign {carry, sum} = a + b;

endmodule
