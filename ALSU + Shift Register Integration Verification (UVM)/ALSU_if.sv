interface ALSU_if (clk);
  input clk ;
  logic cin;
  logic rst;
  logic red_op_A;
  logic red_op_B;
  logic bypass_A;
  logic bypass_B;
  logic direction;
  logic serial_in;

  logic [2:0] opcode;
  logic signed [2:0] A;
  logic signed [2:0] B;

  logic [15:0] leds;
  logic signed [5:0] out;

  // Modport for DUT
  modport DUT (
    input  clk, cin, rst, red_op_A, red_op_B, bypass_A, bypass_B, direction, serial_in, opcode, A, B,
    output leds, out
  );

endinterface