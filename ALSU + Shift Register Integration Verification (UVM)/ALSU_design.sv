module ALSU(ALSU_if.DUT alsu , input logic signed [5:0] out_shift_reg);

parameter INPUT_PRIORITY = "A";
parameter FULL_ADDER = "ON";

reg red_op_A_reg, red_op_B_reg, bypass_A_reg, bypass_B_reg;
reg direction_reg, serial_in_reg;
reg cin_reg;
reg [2:0] opcode_reg;
reg signed [2:0] A_reg, B_reg;

wire invalid_red_op, invalid_opcode, invalid;


assign invalid_red_op = (alsu.red_op_A | alsu.red_op_B) & (alsu.opcode[1] | alsu.opcode[2]);
assign invalid_opcode = alsu.opcode[1] & alsu.opcode[2];
assign invalid = invalid_red_op | invalid_opcode;


always @(posedge alsu.clk or posedge alsu.rst) begin
  if(alsu.rst) begin
     cin_reg <= 0;
     red_op_B_reg <= 0;
     red_op_A_reg <= 0;
     bypass_B_reg <= 0;
     bypass_A_reg <= 0;
     direction_reg <= 0;
     serial_in_reg <= 0;
     opcode_reg <= 0;
     A_reg <= 0;
     B_reg <= 0;
  end else begin
     cin_reg <= alsu.cin;
     red_op_B_reg <= alsu.red_op_B;
     red_op_A_reg <= alsu.red_op_A;
     bypass_B_reg <= alsu.bypass_B;
     bypass_A_reg <= alsu.bypass_A;
     direction_reg <= alsu.direction;
     serial_in_reg <= alsu.serial_in;
     opcode_reg <= alsu.opcode;
     A_reg <= alsu.A;
     B_reg <= alsu.B;
  end
end

always @(posedge alsu.clk or posedge alsu.rst) begin
  if(alsu.rst) begin
     alsu.leds <= 0;
  end else begin
      if (invalid)
        alsu.leds <= ~alsu.leds;
      else
        alsu.leds <= 0;
  end
end

always @(posedge alsu.clk or posedge alsu.rst) begin
  if(alsu.rst) begin
    alsu.out <= 0;
  end
  else begin

    if (bypass_A_reg && bypass_B_reg)
      alsu.out <= (INPUT_PRIORITY == "A")? A_reg: B_reg;

    else if (bypass_A_reg)
      alsu.out <= A_reg;

    else if (bypass_B_reg)
      alsu.out <= B_reg;

    else if (invalid)
      alsu.out <= 0;

    else begin
      case (opcode_reg)


        3'h0: begin 
          if (red_op_A_reg && red_op_B_reg)
            alsu.out <= (INPUT_PRIORITY == "A")? |A_reg: |B_reg;
          else if (red_op_A_reg) 
            alsu.out <= |A_reg;
          else if (red_op_B_reg)
            alsu.out <= |B_reg;
          else 
            alsu.out <= A_reg | B_reg;
        end

 
        3'h1: begin
          if (red_op_A_reg && red_op_B_reg)
            alsu.out <= (INPUT_PRIORITY == "A")? ^A_reg: ^B_reg;
          else if (red_op_A_reg) 
            alsu.out <= ^A_reg;
          else if (red_op_B_reg)
            alsu.out <= ^B_reg;
          else 
            alsu.out <= A_reg ^ B_reg;
        end


        3'h2: begin
          if (FULL_ADDER == "ON")
            alsu.out <= A_reg + B_reg + cin_reg;
          else
            alsu.out <= A_reg + B_reg;
        end


        3'h3: alsu.out <= A_reg * B_reg;

   
        3'h4: alsu.out <= out_shift_reg;

     
        3'h5: alsu.out <= out_shift_reg;

      endcase
    end 
  end
end

endmodule