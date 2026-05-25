import uvm_pkg::*;
`include "uvm_macros.svh"
import ALSU_test_pkg::*;


module top();

  bit clk;
  initial begin
    forever #1 clk = ~clk;
  end

  ALSU_if alsu(clk);
  shift_reg_if shift_regif(clk);
  wire [5:0] out_shift_reg;
  ALSU t1 (alsu, out_shift_reg);

  shift_reg SR (
    clk,
    shift_regif.reset,
    shift_regif.serial_in,
    shift_regif.direction,
    shift_regif.mode,
    shift_regif.datain,
    shift_regif.dataout
  );

  
  
  assign shift_regif.serial_in = alsu.serial_in;
  assign shift_regif.direction = alsu.direction;
  assign shift_regif.datain    = alsu.A;


  assign shift_regif.mode = (alsu.opcode == 3'h5);


  assign shift_regif.reset = alsu.rst;

  
  assign out_shift_reg = shift_regif.dataout;

  bind ALSU ALSU_sva sva_inst (alsu);

  
  initial begin

    // ALSU interface
    uvm_config_db#(virtual ALSU_if)::set(
      null, "uvm_test_top", "ALSU_if", alsu
    );

    // shift_reg interface
    uvm_config_db#(virtual shift_reg_if)::set(
      null, "uvm_test_top", "shift_reg_if", shift_regif
    );

    run_test("ALSU_test");
  end

endmodule