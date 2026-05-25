package shift_reg_seq_item_pkg;
`include "uvm_macros.svh"
import uvm_pkg::*;
import shared_package_shift_reg::*;

class shift_reg_seq_item extends uvm_sequence_item;
  `uvm_object_utils(shift_reg_seq_item)

  rand bit reset;
  rand bit serial_in;
  rand direction_e direction;
  rand mode_e mode;
  rand bit [5:0] datain;
  logic [5:0] dataout;

  function new(string name = "shift_reg_seq_item");
    super.new(name);
  endfunction

  function string convert2string();
    return $sformatf("%s reset = 0b%b, serial_in = 0b%b, direction = %s, mode = %s, datain = 0b%h, dataout = 0b%h",
                  super.convert2string()  , reset, serial_in, direction, mode, datain, dataout);
  endfunction

  function string convert2string_stimulus();
    return $sformatf("reset = 0b%b, serial_in = 0b%b, direction = %s, mode = %s, datain = 0b%h",
                     reset, serial_in, direction, mode, datain);
  endfunction

  constraint rst_constrain {
    reset dist {1 := 10, 0 := 90};
  }

endclass
endpackage