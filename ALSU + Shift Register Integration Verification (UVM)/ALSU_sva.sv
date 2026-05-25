module ALSU_sva (ALSU_if alsu);

  
  property p_reset;
    @(posedge alsu.clk)
    alsu.rst |=> (alsu.out == 0 && alsu.leds == 0);
  endproperty

  a_reset: assert property (p_reset);


  
  property p_add;
    @(posedge alsu.clk)
    (alsu.opcode == 3'h2 && !alsu.rst)
    |=> alsu.out == (alsu.A + alsu.B + alsu.cin);
  endproperty

  a_add: assert property (p_add);


 
  property p_mult;
    @(posedge alsu.clk)
    (alsu.opcode == 3'h3 && !alsu.rst)
    |=> alsu.out == (alsu.A * alsu.B);
  endproperty

  a_mult: assert property (p_mult);


 
  property p_or;
    @(posedge alsu.clk)
    (alsu.opcode == 3'h0 && !alsu.red_op_A && !alsu.red_op_B)
    |=> alsu.out == (alsu.A | alsu.B);
  endproperty

  a_or: assert property (p_or);


  property p_xor;
    @(posedge alsu.clk)
    (alsu.opcode == 3'h1 && !alsu.red_op_A && !alsu.red_op_B)
    |=> alsu.out == (alsu.A ^ alsu.B);
  endproperty

  a_xor: assert property (p_xor);


 
  property p_bypass_A;
    @(posedge alsu.clk)
    (alsu.bypass_A && !alsu.rst)
    |=> alsu.out == alsu.A;
  endproperty

  a_bypass_A: assert property (p_bypass_A);


 
  property p_bypass_B;
    @(posedge alsu.clk)
    (alsu.bypass_B && !alsu.rst && !alsu.bypass_A)
    |=> alsu.out == alsu.B;
  endproperty

  a_bypass_B: assert property (p_bypass_B);


  property p_invalid_out;
    @(posedge alsu.clk)
    ((alsu.opcode[1] & alsu.opcode[2]) ||
     ((alsu.red_op_A | alsu.red_op_B) && (alsu.opcode[1] | alsu.opcode[2])))
    |=> alsu.out == 0;
  endproperty

  a_invalid_out: assert property (p_invalid_out);


  property p_invalid_leds;
    @(posedge alsu.clk)
    ((alsu.opcode[1] & alsu.opcode[2]) ||
     ((alsu.red_op_A | alsu.red_op_B) && (alsu.opcode[1] | alsu.opcode[2])))
    |=> alsu.leds == ~$past(alsu.leds);
  endproperty

  a_invalid_leds: assert property (p_invalid_leds);


 
  c_add:     cover property (@(posedge alsu.clk) alsu.opcode == 3'h2);
  c_mult:    cover property (@(posedge alsu.clk) alsu.opcode == 3'h3);
  c_shift:   cover property (@(posedge alsu.clk) alsu.opcode == 3'h4);
  c_rotate:  cover property (@(posedge alsu.clk) alsu.opcode == 3'h5);
  c_invalid: cover property (@(posedge alsu.clk) (alsu.opcode[1] & alsu.opcode[2]));

endmodule